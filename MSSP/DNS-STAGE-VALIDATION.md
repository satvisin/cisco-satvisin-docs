# DNS STAGE VALIDATION AND PERFORMANCE

### DNS TABLE STRUCTURES:
For all the queries used for MSSP Overview APIs we are using `dns_agg_table_1_dist` table as it houses the required information.
![Xnip2025-09-09_14-22-47](https://github.com/user-attachments/assets/eca4e094-3228-4af4-a7d7-b44c5426cc85)

---

## Queries

Actual Queries:
``` sql
-- 1. Top Orgs for Categories:
SELECT 
    organizationIds[1] AS orgId, 
    count(*) AS count 
FROM dns_dist 
PREWHERE hasAny(allCategories, [64, 65, 66, 67, 68, 150]) 
WHERE 
    mspOrganizationId = 0 
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application') 
    AND timestamp >= 1757289600 
    AND timestamp <= 1757375999 
    AND eventDate >= '2025-09-08' 
    AND eventDate <= '2025-09-08' 
GROUP BY orgId 
ORDER BY count DESC 
LIMIT 5

-- 2. Top Incident Categories (Hourly)
SELECT 
    toInt64(toStartOfHour(toDateTime(timestamp))) AS hourtimestamp, 
    toStartOfHour(toDateTime(timestamp)) AS hourhumanreadable, 
    arrayJoin(allCategories) AS category, 
    count(*) AS requestCount 
FROM dns_dist 
WHERE 
    mspOrganizationId = 0 
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application') 
    AND hasAny(allCategories, [65, 67, 68, 150]) 
    AND timestamp >= toInt64(toStartOfHour(toDateTime(1757289600))) 
    AND timestamp <= toInt64(toStartOfHour(addHours(toDateTime(1757375999), 1))) 
    AND eventDate >= '2025-09-08' 
    AND eventDate <= '2025-09-08' 
GROUP BY hourhumanreadable, category 
ORDER BY hourhumanreadable ASC

-- 3. Top Incident Categories (Daily)
SELECT 
    toInt64(toStartOfDay(toDateTime(timestamp))) AS hourtimestamp, 
    toStartOfDay(toDateTime(timestamp)) AS hourhumanreadable, 
    arrayJoin(allCategories) AS category, 
    count(*) AS requestCount 
FROM dns_dist 
WHERE 
    mspOrganizationId = 0 
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application') 
    AND hasAny(allCategories, [65, 67, 68, 150]) 
    AND timestamp >= toInt64(toStartOfDay(toDateTime(1757289600))) 
    AND timestamp <= toInt64(toStartOfDay(addDays(toDateTime(1757375999), 1))) 
    AND eventDate >= '2025-09-08' 
    AND eventDate <= '2025-09-08' 
GROUP BY hourhumanreadable, category 
ORDER BY hourhumanreadable ASC

-- 4. Top Policy Hitcounts
SELECT 
    ruleId AS ruleid, 
    count(*) AS count, 
    any(organizationIds[1]) AS orgid 
FROM dns_dist 
WHERE 
    mspOrganizationId = 0 
    AND isNotNull(ruleId) 
    AND timestamp >= 1757289600 
    AND timestamp <= 1757375999 
    AND eventDate >= '2025-09-08' 
    AND eventDate <= '2025-09-08' 
GROUP BY ruleid 
ORDER BY count DESC 
LIMIT 10

-- 5. Top User Blocks
SELECT 
    originIds[1] AS originId, 
    organizationIds[1] AS orgId, 
    originTypes[1] AS origintype, 
    count(*) AS count 
FROM dns_dist 
WHERE 
    mspOrganizationId = 0 
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application') 
    AND originTypes[1] IN (7, 43, 48) 
    AND timestamp >= 1757289600 
    AND timestamp <= 1757375999 
    AND eventDate >= '2025-09-08' 
    AND eventDate <= '2025-09-08' 
GROUP BY originId, orgId, origintype 
ORDER BY count DESC 
LIMIT 10
```

Aggregate Queries:
``` sql
-- 1. Top Orgs for Categories (using dns_agg_table_1_dist)
SELECT 
    orgId, 
    countMerge(requestCount) AS count
FROM dns_agg_table_1_dist
WHERE 
    mspOrganizationId = 0
    AND hasAny(allCategories, [64, 65, 66, 67, 68, 150])
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application')
    AND timestamp >= 1757289600
    AND timestamp <= 1757375999
    AND eventDate >= '2025-09-08'
    AND eventDate <= '2025-09-08'
GROUP BY orgId
ORDER BY count DESC
LIMIT 5

-- 2. Top Incident Categories (Hourly) (using dns_agg_table_1_dist)
SELECT 
    toInt64(toStartOfHour(toDateTime(timestamp))) AS hourtimestamp,
    toStartOfHour(toDateTime(timestamp)) AS hourhumanreadable,
    arrayJoin(allCategories) AS category,
    countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist
WHERE 
    mspOrganizationId = 0
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application')
    AND hasAny(allCategories, [65, 67, 68, 150])
    AND timestamp >= toInt64(toStartOfHour(toDateTime(1757289600)))
    AND timestamp <= toInt64(toStartOfHour(addHours(toDateTime(1757375999), 1)))
    AND eventDate >= '2025-09-08'
    AND eventDate <= '2025-09-08'
GROUP BY hourhumanreadable, category
ORDER BY hourhumanreadable ASC

-- 3. Top Incident Categories (Daily) (using dns_agg_table_1_dist)
SELECT 
    toInt64(toStartOfDay(toDateTime(timestamp))) AS hourtimestamp,
    toStartOfDay(toDateTime(timestamp)) AS hourhumanreadable,
    arrayJoin(allCategories) AS category,
    countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist
WHERE 
    mspOrganizationId = 0
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application')
    AND hasAny(allCategories, [65, 67, 68, 150])
    AND timestamp >= toInt64(toStartOfDay(toDateTime(1757289600)))
    AND timestamp <= toInt64(toStartOfDay(addDays(toDateTime(1757375999), 1)))
    AND eventDate >= '2025-09-08'
    AND eventDate <= '2025-09-08'
GROUP BY hourhumanreadable, category
ORDER BY hourhumanreadable ASC

-- 4. Top Policy Hitcounts (using dns_agg_table_1_dist)
SELECT 
    ruleIdCoalesce AS ruleid,
    countMerge(requestCount) AS count,
    any(orgId) AS orgid
FROM dns_agg_table_1_dist
WHERE 
    mspOrganizationId = 0
    AND isRuleIdNull = 0
    AND timestamp >= 1757289600
    AND timestamp <= 1757375999
    AND eventDate >= '2025-09-08'
    AND eventDate <= '2025-09-08'
GROUP BY ruleid
ORDER BY count DESC
LIMIT 10

-- 5. Top User Blocks (using dns_agg_table_1_dist)
SELECT 
    originId,
    orgId,
    originTypes[1] AS origintype,
    countMerge(blockedRequestCount) AS count
FROM dns_agg_table_1_dist
WHERE 
    mspOrganizationId = 0
    AND handling IN ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application')
    AND originTypes[1] IN (7, 43, 48)
    AND timestamp >= 1757289600
    AND timestamp <= 1757375999
    AND eventDate >= '2025-09-08'
    AND eventDate <= '2025-09-08'
GROUP BY originId, orgId, origintype
ORDER BY count DESC
LIMIT 10
```

---

### Screenshots of multiple test for 24hr
<img width="1338" height="831" alt="Screenshot 2025-09-09 at 5 28 22 PM" src="https://github.com/user-attachments/assets/82a71421-4854-4912-9743-3b8325488f5d" />
<img width="1338" height="831" alt="Screenshot 2025-09-09 at 5 26 48 PM" src="https://github.com/user-attachments/assets/69ee2649-0b20-48d6-80c7-8e39875e7a50" />
<img width="1338" height="831" alt="Screenshot 2025-09-09 at 3 48 56 PM" src="https://github.com/user-attachments/assets/3d69f1e9-f1b7-463c-bf70-2491dd89c67d" />
<img width="1338" height="831" alt="Screenshot 2025-09-09 at 3 46 57 PM" src="https://github.com/user-attachments/assets/8f20a3d1-5d47-4f68-bb46-cc8dc5397efa" />
<img width="1338" height="690" alt="Screenshot 2025-09-09 at 3 26 14 PM" src="https://github.com/user-attachments/assets/dbacfe8c-45e4-4a78-a1cc-bab57fdb5a67" />

Response for top incident categories API were huge, hence it is capture in below files 
- [top-incident-categories-day-act.txt](https://github.com/user-attachments/files/22233954/top-incident-categories-day-act.txt) 
- [top-incident-categories-day-agg.txt](https://github.com/user-attachments/files/22233956/top-incident-categories-day-agg.txt)
- [top-incident-categories-hour-agg.txt](https://github.com/user-attachments/files/22233961/top-incident-categories-hour-agg.txt) 
- [top-incident-categories-hour-act.txt](https://github.com/user-attachments/files/22233960/top-incident-categories-hour-act.txt)


