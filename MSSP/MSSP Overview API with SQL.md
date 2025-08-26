# MSSP Overview API with SQL queries:

## API -> /top-orgs-for-categories

`curl "localhost:3000/providers/1816781/top-orgs-for-categories?from=1748582481000&to=1748587001000&categories=65,67,68,150" -H "Authorization: internalv1 testtoken" | jq .`

SQL Query:

``` sql
-- DNS
SELECT
	organizationIds[1] AS orgId,
	count(*) AS count
FROM
	dns_dist PREWHERE hasAny(allCategories, '(64 65 66 67 68 150)')
WHERE
	((mspOrganizationId = '1816781'
		AND (handling in '("blocked" "botnet" "domaintagging" "malware" "phish" "suspicious" "security" "refused" "sinkhole" "application")'))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	orgId
ORDER BY
	count DESC
LIMIT '5'

-- PROXY
SELECT
	transaction_organizationId AS orgId,
	count(*) AS count
FROM
	sig_proxy_dist
WHERE
	(((transaction_mspOrganizationId = '1816781'
		AND verdict_status = 'BLOCKED')
	AND hasAny(verdict_categories, '(64 65 66 67 68 150)'))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	orgId
ORDER BY
	count DESC
LIMIT '5'
```
---

## API -> /top-incident-categories

`curl "localhost:3000/providers/1816781/top-incident-categories?from=1748582481000&to=1748587001000" -H "Authorization: internalv1 testtoken" | jq .`

SQL Query:

Hourwise-
``` sql
-- DNS
SELECT
	distinct toInt64(hourhumanreadable) AS hourtimestamp,
	(toStartOfHour(toDateTime(timestamp))) AS hourhumanreadable,
	arrayJoin(allCategories) AS category,
	count(*) AS requestCount
FROM
	dns_dist
WHERE
	((mspOrganizationId = '1816781'
		AND ((handling in ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application'))
			AND hasAny(allCategories, [65, 67, 68, 150])))
		AND (timestamp >= toInt64(toStartOfHour(toDateTime(1748582481)))
			AND timestamp <= toInt64(toStartOfHour(addHours(toDateTime(1748587001), 1)))
				AND eventDate >= '2025-05-30'
				AND eventDate <= '2025-05-30'))
GROUP BY
	hourhumanreadable,
	category
ORDER BY
	hourhumanreadable ASC

-- PROXY
SELECT
	distinct toInt64(hourhumanreadable) AS hourtimestamp,
	(toStartOfHour(toDateTime(timestamp))) AS hourhumanreadable,
	arrayJoin(verdict_categories) AS category,
	count(*) AS requestCount
FROM
	sig_proxy_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND (verdict_status = 'BLOCKED'
			AND hasAny(verdict_categories, [65, 67, 68, 150])))
		AND (timestamp >= toInt64(toStartOfHour(toDateTime(1748582481)))
			AND timestamp <= toInt64(toStartOfHour(addHours(toDateTime(1748587001), 1)))
				AND eventDate >= '2025-05-30'
				AND eventDate <= '2025-05-30'))
GROUP BY
	hourhumanreadable,
	category
ORDER BY
	hourhumanreadable ASC
```

Daywise-
``` sql
-- DNS
SELECT
	distinct toInt64(hourhumanreadable) AS hourtimestamp,
	(toStartOfDay(toDateTime(timestamp))) AS hourhumanreadable,
	arrayJoin(allCategories) AS category,
	count(*) AS requestCount
FROM
	dns_dist
WHERE
	((mspOrganizationId = '1816781'
		AND ((handling in ('blocked', 'botnet', 'domaintagging', 'malware', 'phish', 'suspicious', 'security', 'refused', 'sinkhole', 'application'))
			AND hasAny(allCategories, [65, 67, 68, 150])))
		AND (timestamp >= toInt64(toStartOfDay(toDateTime(1748582481)))
			AND timestamp <= toInt64(toStartOfDay(addDays(toDateTime(1748587001), 1)))
				AND eventDate >= '2025-05-30'
				AND eventDate <= '2025-05-30'))
GROUP BY
	hourhumanreadable,
	category
ORDER BY
	hourhumanreadable ASC

-- PROXY
SELECT
	distinct toInt64(hourhumanreadable) AS hourtimestamp,
	(toStartOfDay(toDateTime(timestamp))) AS hourhumanreadable,
	arrayJoin(verdict_categories) AS category,
	count(*) AS requestCount
FROM
	sig_proxy_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND (verdict_status = 'BLOCKED'
			AND hasAny(verdict_categories, [65, 67, 68, 150])))
		AND (timestamp >= toInt64(toStartOfDay(toDateTime(1748582481)))
			AND timestamp <= toInt64(toStartOfDay(addDays(toDateTime(1748587001), 1)))
				AND eventDate >= '2025-05-30'
				AND eventDate <= '2025-05-30'))
GROUP BY
	hourhumanreadable,
	category
ORDER BY
	hourhumanreadable ASC
```
---

## API -> /top-policy-hitcounts

`curl "localhost:3000/providers/1816781/top-policy-hitcounts?from=1748582481000&to=1748587001000&limit=10" -H "Authorization: internalv1 testtoken" | jq .`

SQL Queries:
``` sql
-- IPS
SELECT firewallRuleId AS ruleid,
count(*) AS count,
any(organizationId) AS orgid
FROM
ips_dist
WHERE
((mspOrganizationId = '1816781'
	AND isNotNull(firewallRuleId))
	AND (timestamp >= '1748582481'
		AND timestamp <= '1748587001'
		AND eventDate >= '2025-05-30'
		AND eventDate <= '2025-05-30'))
GROUP BY
ruleid
ORDER BY
count DESC
LIMIT 0,
10

-- SWA
SELECT
	transaction_policy_ruleId AS ruleid,
	count(*) AS count,
	any(transaction_organizationId) AS orgid
FROM
	swa_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND isNotNull(transaction_policy_ruleId))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	count DESC
LIMIT 0,
10

-- DNS
SELECT
	ruleId AS ruleid,
	count(*) AS count,
	any(organizationIds[1]) AS orgid
FROM
	dns_dist
WHERE
	((mspOrganizationId = '1816781'
		AND isNotNull(ruleId))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	count DESC
LIMIT 0,
10

-- PROXY
SELECT
	transaction_policy_ruleId AS ruleid,
	count(*) AS count,
	any(transaction_organizationId) AS orgid
FROM
	sig_proxy_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND isNotNull(transaction_policy_ruleId))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	count DESC
LIMIT 0,
10

-- CDFW
SELECT
	rule_id AS ruleid,
	count(*) AS count,
	any(organization_id) AS orgid
FROM
	cdfw_dist
WHERE
	((mspOrganizationId = '1816781'
		AND isNotNull(rule_id))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	count DESC
LIMIT 0,
10

-- ZPROXY
SELECT
	ruleId AS ruleid,
	count(*) AS count,
	any(organizationIds[1]) AS orgid
FROM
	zproxy_dist
WHERE
	((mspOrganizationIds[1] = '1816781'
		AND isNotNull(ruleId))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	count DESC
LIMIT 0,
10
```
---

## API -> /top-user-blocks

`curl --location 'localhost:3000/providers/1816781/top-user-blocks?from=1748582481000&to=1748587001000' -H 'Authorization: internalv1 testtoken' | jq .`

SQL Queries:
``` sql
-- CDFW
SELECT
	origin_id AS originId,
	organization_id AS orgId,
	origin_type AS origintype,
	count(*) AS count
FROM
	cdfw_dist
WHERE
	((mspOrganizationId = '1816781'
		AND verdict = 'BLOCK'
		AND (origin_type in ('7', '43', '48')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'

-- ZPROXY
SELECT
	originIds[1] AS originId,
	organizationIds[1] AS orgId,
	originTypes[1] AS origintype,
	count(*) AS count
FROM
	zproxy_dist
WHERE
	((mspOrganizationIds[1] = '1816781'
		AND verdict = 'BLOCK'
		AND (originTypes[1] in ('7', '43', '48')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'

-- IPS
SELECT
	originId AS originId,
	organizationId AS orgId,
	originType AS origintype,
	count(*) AS count
FROM
	ips_dist
WHERE
	((mspOrganizationId = '1816781'
		AND action = 'BLOCK'
		AND (originType in ('7', '43', '48')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'

-- PROXY
SELECT
	transaction_originId AS originId,
	transaction_organizationId AS orgId,
	transaction_originType AS origintype,
	count(*) AS count
FROM
	sig_proxy_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND verdict_status = 'BLOCKED'
		AND (transaction_originType in ('7', '43', '48')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'

-- SWA
SELECT
	transaction_originId AS originId,
	transaction_organizationId AS orgId,
	transaction_originType AS origintype,
	count(*) AS count
FROM
	swa_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND verdict_status = 'BLOCKED'
		AND (transaction_originType in ('7', '43', '48')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'

-- DNS
SELECT
	originIds[1] AS originId,
	organizationIds[1] AS orgId,
	originTypes[1] AS origintype,
	count(*) AS count
FROM
	dns_dist
WHERE
	((mspOrganizationId = '1816781'
		AND (handling in '("blocked" "botnet" "domaintagging" "malware" "phish" "suspicious" "security" "refused" "sinkhole" "application")')
			AND (originTypes[1] in '(7 43 48)'))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	originId,
	orgId,
	origintype
ORDER BY
	count DESC
LIMIT '10'
```
---

## API -> /summaries-by-rule-msp

`curl --location 'localhost:3000/providers/1816781/summaries-by-rule-msp?from=1748582481000&to=1748587001000&ruleids=391327,43' -H 'Authorization: internalv1 testtoken' | jq .`

SQL Queries:
``` sql
-- SWA
SELECT
	transaction_policy_ruleId AS ruleid,
	count(*) AS hitcount,
	max(timestamp) AS lasteventat
FROM
	swa_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND (transaction_policy_ruleId in ('391327', '43')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	hitcount DESC

-- PROXY
SELECT
	transaction_policy_ruleId AS ruleid,
	count(*) AS hitcount,
	max(timestamp) AS lasteventat
FROM
	sig_proxy_dist
WHERE
	((transaction_mspOrganizationId = '1816781'
		AND (transaction_policy_ruleId in ('391327', '43')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	hitcount DESC

-- DNS
SELECT
	ruleId AS ruleid,
	count(*) AS hitcount,
	max(timestamp) AS lasteventat
FROM
	dns_dist
WHERE
	((mspOrganizationId = '1816781'
		AND (ruleId in ('391327', '43')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	hitcount DESC

-- ZPROXY
SELECT
	ruleId AS ruleid,
	count(*) AS hitcount,
	max(timestamp) AS lasteventat
FROM
	zproxy_dist
WHERE
	((mspOrganizationIds[1] = '1816781'
		AND (ruleId in ('391327', '43')))
		AND (timestamp >= '1748582481'
			AND timestamp <= '1748587001'
			AND eventDate >= '2025-05-30'
			AND eventDate <= '2025-05-30'))
GROUP BY
	ruleid
ORDER BY
	hitcount DESC
```
