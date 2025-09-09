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
<img width="1338" height="690" alt="Screenshot 2025-09-09 at 3 26 14 PM" src="https://github.com/user-attachments/assets/dbacfe8c-45e4-4a78-a1cc-bab57fdb5a67" />

Response for top incident categories API were huge, hence it is capture in below files 
- [top-incident-categories-day-act.txt](https://github.com/user-attachments/files/22233954/top-incident-categories-day-act.txt) 
- [top-incident-categories-day-agg.txt](https://github.com/user-attachments/files/22233956/top-incident-categories-day-agg.txt)
- [top-incident-categories-hour-agg.txt](https://github.com/user-attachments/files/22233961/top-incident-categories-hour-agg.txt) 
- [top-incident-categories-hour-act.txt](https://github.com/user-attachments/files/22233960/top-incident-categories-hour-act.txt)

---

### Test for 7days

<img width="1338" height="932" alt="Screenshot 2025-09-09 at 6 18 29 PM" src="https://github.com/user-attachments/assets/6a8c37cd-b895-4edd-b051-2fabfff6847a" />
<img width="1338" height="853" alt="Screenshot 2025-09-09 at 6 12 47 PM" src="https://github.com/user-attachments/assets/4307ea10-3a85-4d9f-9f7d-66eb0ced81da" />
<img width="1338" height="809" alt="Screenshot 2025-09-09 at 6 09 34 PM" src="https://github.com/user-attachments/assets/aded34d9-b8ae-4e19-9dc8-74f8d57d1ff0" />
<img width="1338" height="683" alt="Screenshot 2025-09-09 at 6 06 48 PM" src="https://github.com/user-attachments/assets/5fda8c9b-1715-4132-82a5-a09f8de90d10" />

Response for top incident categories API were huge, hence it is capture in below files 
- [top-incident-categories-7d-day-act.txt](https://github.com/user-attachments/files/22234649/top-incident-categories-7d-day-act.txt)
- [top-incident-categories-7d-day-agg.txt](https://github.com/user-attachments/files/22234650/top-incident-categories-7d-day-agg.txt)
- [top-incident-categories-7d-hour-agg.txt](https://github.com/user-attachments/files/22234652/top-incident-categories-7d-hour-agg.txt)
- [top-incident-categories-7d-hour-act.txt](https://github.com/user-attachments/files/22234651/top-incident-categories-7d-hour-act.txt)

I found that the shared org has very limited amount of data preent in them hen I have ran the test for Org 0 as well to showcase the performance

``` 
MSP Org  | Query Name                       | Actual Time   | Agg. Time 
-------------------------------------------------------------------------
0        | Top Orgs for Categories......... | 63.098676   s | 66.447045 s
0        | Top Incident Categories (Hourly) | 32.094867   s | 6.805529  s
0        | Top Incident Categories (Daily). | 52.181173   s | 7.028487  s
0        | Top Policy Hitcounts............ | 6.791471    s | 3.916105  s
0        | Top User Blocks................. | 45.678870   s | 59.131933 s
8116145  | Top Orgs for Categories......... | 0.462557    s | 1.982688  s
8116145  | Top Incident Categories (Hourly) | 0.257771    s | 0.284718  s
8116145  | Top Incident Categories (Daily). | 0.259104    s | 0.340418  s
8116145  | Top Policy Hitcounts............ | 0.196869    s | 0.145920  s
8116145  | Top User Blocks................. | 0.229350    s | 0.234277  s
7097480  | Top Orgs for Categories......... | 0.141093    s | 0.133332  s
7097480  | Top Incident Categories (Hourly) | 0.124099    s | 0.134777  s
7097480  | Top Incident Categories (Daily). | 0.136234    s | 0.152360  s
7097480  | Top Policy Hitcounts............ | 0.127378    s | 0.112103  s
7097480  | Top User Blocks................. | 0.176916    s | 0.175501  s
5401137  | Top Orgs for Categories......... | 0.119129    s | 0.131421  s
5401137  | Top Incident Categories (Hourly) | 0.135156    s | 0.143080  s
5401137  | Top Incident Categories (Daily). | 0.128417    s | 0.127474  s
5401137  | Top Policy Hitcounts............ | 0.124363    s | 0.111620  s
5401137  | Top User Blocks................. | 0.125064    s | 0.126859  s
2467118  | Top Orgs for Categories......... | 0.273291    s | 0.257968  s
2467118  | Top Incident Categories (Hourly) | 0.278120    s | 0.242996  s
2467118  | Top Incident Categories (Daily). | 0.220157    s | 0.228284  s
2467118  | Top Policy Hitcounts............ | 0.125449    s | 0.163165  s
2467118  | Top User Blocks................. | 0.290395    s | 0.969985  s
2505472  | Top Orgs for Categories......... | 0.166294    s | 0.187119  s
2505472  | Top Incident Categories (Hourly) | 0.144970    s | 0.154230  s
2505472  | Top Incident Categories (Daily). | 0.157897    s | 0.156590  s
2505472  | Top Policy Hitcounts............ | 0.122612    s | 0.126782  s
2505472  | Top User Blocks................. | 0.157736    s | 0.142715  s
2533528  | Top Orgs for Categories......... | 0.217303    s | 0.239511  s
2533528  | Top Incident Categories (Hourly) | 0.216720    s | 0.196786  s
2533528  | Top Incident Categories (Daily). | 0.172735    s | 0.185092  s
2533528  | Top Policy Hitcounts............ | 0.139310    s | 0.125563  s
2533528  | Top User Blocks................. | 0.161502    s | 0.152968  s
2197293  | Top Orgs for Categories......... | 0.196613    s | 0.285245  s
2197293  | Top Incident Categories (Hourly) | 0.320144    s | 0.333554  s
2197293  | Top Incident Categories (Daily). | 0.322115    s | 0.314473  s
2197293  | Top Policy Hitcounts............ | 0.187568    s | 0.112093  s
2197293  | Top User Blocks................. | 0.126101    s | 0.113034  s
2639420  | Top Orgs for Categories......... | 0.134437    s | 0.139296  s
2639420  | Top Incident Categories (Hourly) | 0.186828    s | 0.168381  s
2639420  | Top Incident Categories (Daily). | 0.131773    s | 0.142795  s
2639420  | Top Policy Hitcounts............ | 0.114476    s | 0.118774  s
2639420  | Top User Blocks................. | 0.149495    s | 0.159954  s
```
