/*
--------------------- QUERY 1 ---------------------
*/

-- SOURCE TABLE
SELECT
    toInt64(hourhumanreadable) AS hourtimestamp,
    toStartOfDay(toDateTime(timestamp)) AS hourhumanreadable,
    arrayJoin(allCategories) AS category,
    count(*) AS requestCount
FROM
    dns_dist
WHERE
    mspOrganizationId IN [8116145]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
    AND hasAny(allCategories, [65,110,86,88,108,109,150,61,64,66,68,67])
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    hourhumanreadable,
    category
ORDER BY
    hourhumanreadable ASC

-- AGG TABLE
SELECT
	toInt64(hourhumanreadable) AS hourtimestamp,
    toStartOfDay(toDateTime(tsHour)) AS hourhumanreadable,
    arrayJoin(allCategories) AS category,
    countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist
WHERE
    mspOrganizationId IN [8116145]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
    AND hasAny(allCategories, [65,110,86,88,108,109,150,61,64,66,68,67])
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
	hourtimestamp,
    hourhumanreadable,
    category
ORDER BY
    hourhumanreadable ASC

/*
--------------------- QUERY 2 ---------------------
*/

-- SOURCE TABLE
SELECT
    ruleId AS ruleid,
    count(*) AS count
FROM
    dns_dist
WHERE
    isNotNull(ruleId)
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    ruleid
ORDER BY
    count DESC

-- AGG TABLE
SELECT
	ruleIdCoalesce AS ruleid,
    countMerge(requestCount) AS count
FROM dns_agg_table_1_dist
WHERE
    isRuleIdNull = 0
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
	ruleid
ORDER BY
    count DESC

/*
--------------------- QUERY 3 ---------------------
*/

-- SOURCE TABLE
SELECT
    organizationIds[1] as orgId,
    count(*) as count
FROM
    dns_dist
WHERE
    mspOrganizationId IN [8116145]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
    AND hasAny(allCategories, [65,110,86,88,108,109,150,61,64,66,68,67])
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    orgId
ORDER BY
    count desc

-- AGG TABLE
SELECT
	orgId,
	countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist
WHERE
    mspOrganizationId IN [8116145]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
    AND hasAny(allCategories, [65,110,86,88,108,109,150,61,64,66,68,67])
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    orgId
ORDER BY
    requestCount desc

/*
--------------------- QUERY 4 ---------------------
*/

-- SOURCE TABLE
SELECT
	originIds[1] as originId,
	organizationIds[1] as orgId,
	count(*) as count
FROM dns_dist
WHERE
	mspOrganizationId IN [0]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
	AND originTypes[1] in [7,43,48]
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
	originId,
	orgId
ORDER BY count DESC

-- AGG TABLE
SELECT
	originId,
	orgId,
	countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist
WHERE
    mspOrganizationId IN [0]
    AND handling IN (
        'blocked', 'botnet', 'domaintagging', 'malware',
        'phish', 'suspicious', 'security', 'refused',
        'sinkhole', 'application'
    )
    AND originTypes[1] in [7,43,48]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
	originId,
    orgId
ORDER BY
    requestCount DESC

/*
--------------------- QUERY 5 --------------------- [Updated]
*/

-- SOURCE TABLE
SELECT
	ruleId AS ruleid,
	COUNT(*) AS hitcount,
	toStartOfHour(toDateTime(MAX(timestamp))) AS lasteventat_tsHour
FROM dns_dist
WHERE
	mspOrganizationId = 0
	AND ruleId IN [500478, 831016, 831012, 1384651]
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY ruleid
ORDER BY hitcount DESC

-- AGG TABLE
SELECT
	ruleIdCoalesce AS ruleId,
	countMerge(requestCount) AS requestCount,
	MAX(tsHour) AS lasteventat_tsHour
FROM dns_agg_table_1_dist
WHERE
	mspOrganizationId = 0
	AND ruleId IN [500478, 831016, 831012, 1384651]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY ruleId
ORDER BY requestCount DESC