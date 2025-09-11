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

I found that the shared org has very limited amount of data preent in them hen I have ran the test for Org 0 as well to showcase the performance



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

---
---
## DNS Validation [11-Sept-2025]

Running test for 7 days produces the below result:
```
MSP Org  | Query Name   | Actual Time  | Agg. Time 
-------------------------------------------------------------
0        | Top Orgs for Categories......... | 15.538970   s | 23.877710 s
0        | Top Incident Categories (Hourly) | 7.053405    s | 37.517181 s
0        | Top Incident Categories (Daily). | 6.851748    s | 26.049522 s
0        | Top Policy Hitcounts............ | 3.808293    s | 0.802331  s
0        | Top User Blocks................. | 45.920797   s | 9.153821  s
8116145  | Top Orgs for Categories......... | 1.581374    s | 0.318277  s
8116145  | Top Incident Categories (Hourly) | 0.302408    s | 0.241228  s
8116145  | Top Incident Categories (Daily). | 0.296912    s | 0.270959  s
8116145  | Top Policy Hitcounts............ | 0.153992    s | 0.110551  s
8116145  | Top User Blocks................. | 0.235317    s | 0.152367  s
7097480  | Top Orgs for Categories......... | 0.120131    s | 0.130278  s
7097480  | Top Incident Categories (Hourly) | 0.136283    s | 0.126590  s
7097480  | Top Incident Categories (Daily). | 0.115440    s | 0.127113  s
7097480  | Top Policy Hitcounts............ | 0.109918    s | 0.100483  s
7097480  | Top User Blocks................. | 0.148063    s | 0.138571  s
5401137  | Top Orgs for Categories......... | 0.125645    s | 0.111593  s
5401137  | Top Incident Categories (Hourly) | 0.115504    s | 0.119983  s
5401137  | Top Incident Categories (Daily). | 0.121540    s | 0.110992  s
5401137  | Top Policy Hitcounts............ | 0.112123    s | 0.098700  s
5401137  | Top User Blocks................. | 0.136023    s | 0.107160  s
2467118  | Top Orgs for Categories......... | 0.340510    s | 0.255791  s
2467118  | Top Incident Categories (Hourly) | 0.234318    s | 0.239509  s
2467118  | Top Incident Categories (Daily). | 0.235757    s | 0.287706  s
2467118  | Top Policy Hitcounts............ | 0.118551    s | 0.103525  s
2467118  | Top User Blocks................. | 0.319617    s | 0.215601  s
2505472  | Top Orgs for Categories......... | 0.166813    s | 0.163499  s
2505472  | Top Incident Categories (Hourly) | 0.136123    s | 0.169645  s
2505472  | Top Incident Categories (Daily). | 0.136500    s | 0.406581  s
2505472  | Top Policy Hitcounts............ | 0.126206    s | 0.099095  s
2505472  | Top User Blocks................. | 0.139951    s | 0.147486  s
2533528  | Top Orgs for Categories......... | 0.236661    s | 0.213334  s
2533528  | Top Incident Categories (Hourly) | 0.195775    s | 0.236290  s
2533528  | Top Incident Categories (Daily). | 0.173057    s | 0.164209  s
2533528  | Top Policy Hitcounts............ | 0.119897    s | 0.101866  s
2533528  | Top User Blocks................. | 0.166626    s | 0.252174  s
2197293  | Top Orgs for Categories......... | 0.118363    s | 0.104300  s
2197293  | Top Incident Categories (Hourly) | 0.121290    s | 0.127475  s
2197293  | Top Incident Categories (Daily). | 0.110802    s | 0.103680  s
2197293  | Top Policy Hitcounts............ | 0.108316    s | 0.099150  s
2197293  | Top User Blocks................. | 0.119645    s | 0.103286  s
2639420  | Top Orgs for Categories......... | 0.138968    s | 0.128328  s
2639420  | Top Incident Categories (Hourly) | 0.430311    s | 0.306125  s
2639420  | Top Incident Categories (Daily). | 0.142759    s | 0.118649  s
2639420  | Top Policy Hitcounts............ | 0.111221    s | 0.101444  s
2639420  | Top User Blocks................. | 0.151698    s | 0.125871  s
```

