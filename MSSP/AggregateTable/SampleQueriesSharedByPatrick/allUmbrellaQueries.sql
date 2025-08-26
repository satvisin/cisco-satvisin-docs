/*
--------------------- QUERY 1 ---------------------
*/

-- SOURCE TABLE
SELECT
    organizationIds[1] AS orgId,
    count(*) AS requestCount,
    SUM (assumeNotNull(CASE
        WHEN has (['blocked',
        'botnet',
        'domaintagging',
        'malware',
        'phish',
        'suspicious',
        'security',
        'refused',
        'sinkhole',
        'application'],
        handling) THEN 1
        ELSE 0
    END)) AS blockedrequestscount
FROM dns_dist
WHERE
    mspOrganizationId IN [2533528]
    AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
    AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY orgId ORDER BY requestCount DESC

-- AGG TABLE
SELECT
    orgId,
    countMerge(requestCount) AS requestCount,
    countIfMerge(blockedRequestCount) AS blockedrequestscount
FROM dns_agg_table_1_dist
WHERE
    mspOrganizationId IN [2533528]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY orgId ORDER BY requestCount DESC


/*
--------------------- QUERY 2 ---------------------
*/

-- SOURCE TABLE
SELECT
    organizationIds [1] AS orgId,
    count(*) AS requestCount,
    arrayJoin(allCategories) AS category,
    SUM (assumeNotNull(CASE
        WHEN has (['blocked',
        'botnet',
        'domaintagging',
        'malware',
        'phish',
        'suspicious',
        'security',
        'refused',
        'sinkhole',
        'application'],
        handling) THEN 1
        ELSE 0
    END)) AS blockedrequestscount
FROM
    dns_dist
WHERE
	mspOrganizationId IN [2533528]
    AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
    AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    orgId,
    category
ORDER BY
    requestCount

-- AGG TABLE
SELECT
    orgId,
    countMerge(requestCount) AS requestCount,
    arrayJoin(allCategories) AS category,
    countIfMerge(blockedRequestCount) AS blockedrequestscount
FROM dns_agg_table_1_dist
WHERE
	mspOrganizationId IN [2533528]
	AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
	orgId,
	category
ORDER BY
	requestCount

/*
--------------------- QUERY 3 --------------------- (Note different Agg table being queried)
*/

-- SOURCE TABLE
SELECT
    distinct (organizationIds [1]) AS orgId,
    originType AS origintype,
    uniq(originId) AS originidcount
FROM
    dns_dist ARRAY
JOIN originIds AS originId,
    originTypes AS originType,
    organizationIds AS organizationId PREWHERE mspOrganizationId IN [2533528, 2568710, 8263214, 8267685, 8217978]
WHERE
    organizationId = organizationIds[1]
    AND originType <> 0
    AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
    AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    orgId,
    origintype

-- AGG TABLE
SELECT
    orgId,
    originType,
    uniqMerge(originIdCount) AS originIdCount
FROM dns_agg_table_2_dist
PREWHERE mspOrganizationId IN [2533528, 2568710, 8263214, 8267685, 8217978]
WHERE
    tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    orgId,
    originType

/*
--------------------- QUERY 4-8 ---------------------
*/

-- SOURCE TABLE
SELECT
    (toStartOfHour(toDateTime(timestamp),'UTC')) AS hourhumanreadable,
    toInt64(hourhumanreadable) AS hourtimestamp,
    count(*) AS count
FROM
    dns_dist PREWHERE hasAny(allCategories,[65,110,86,88,108,109,150,61,64,66,68,67])
WHERE
	mspOrganizationId IN [2533528]
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
	AND eventDate = '2025-07-16'
GROUP BY
    hourhumanreadable
ORDER BY
    hourhumanreadable ASC

-- AGG TABLE
SELECT
    tsHour as hourhumanreadable,
    toInt64(hourhumanreadable) AS hourtimestamp,
    countMerge(requestCount) AS requestCount
FROM dns_agg_table_1_dist PREWHERE hasAny(allCategories,[65,110,86,88,108,109,150,61,64,66,68,67])
WHERE
	mspOrganizationId IN [2533528]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    hourhumanreadable
ORDER BY
	hourhumanreadable ASC

/*
--------------------- QUERY 9 ---------------------
*/

-- SOURCE TABLE
SELECT
    (toStartOfHour(toDateTime(timestamp),'UTC')) AS hourhumanreadable,
    toInt64(hourhumanreadable) AS hourtimestamp,
    count(*) AS count
FROM
    dns_dist
WHERE
	mspOrganizationId IN [2533528]
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
	AND eventDate = '2025-07-16'
GROUP BY
    hourhumanreadable
ORDER BY
    hourhumanreadable ASC

-- AGG TABLE
SELECT
    tsHour as hourhumanreadable,
    toInt64(hourhumanreadable) AS hourtimestamp,
    countMerge(requestCount) AS requestCount
FROM
	dns_agg_table_1_dist
WHERE
	mspOrganizationId IN [2533528]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    hourhumanreadable
ORDER BY hourhumanreadable ASC

/*
--------------------- QUERY 10 --------------------
*/

-- SOURCE TABLE
SELECT
    arrayJoin(allCategories) AS category,
    count(*) AS requestCount,
    SUM (assumeNotNull(CASE
        WHEN has (['blocked',
        'botnet',
        'domaintagging',
        'malware',
        'phish',
        'suspicious',
        'security',
        'refused',
        'sinkhole',
        'application'],
        handling) THEN 1
        ELSE 0
    END)) AS blockedrequestscount,
    COUNT (distinct (organizationIds[1])) AS orgCount
FROM
    dns_dist
WHERE
	mspOrganizationId IN [2533528]
	AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
	AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
	AND eventDate = '2025-07-16'
GROUP BY
    category
ORDER BY
    requestCount DESC

-- AGG TABLE
SELECT
    arrayJoin(allCategories) AS category,
    countMerge(requestCount) AS requestCount,
    countIfMerge(blockedRequestCount) AS blockedrequestscount,
    COUNT (distinct(orgId)) AS orgCount
FROM
	dns_agg_table_1_dist
WHERE
	mspOrganizationId IN [2533528]
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    category
ORDER BY
	requestCount DESC

/*
--------------------- QUERY 11 -------------------- (Note different Agg table being queried)
*/

-- SOURCE TABLE
SELECT
    qname AS domain,
    count(*) AS requestCount,
    SUM (assumeNotNull(CASE
        WHEN has (['blocked',
        'botnet',
        'domaintagging',
        'malware',
        'phish',
        'suspicious',
        'security',
        'refused',
        'sinkhole',
        'application'],
        handling) THEN 1
        ELSE 0
    END)) AS blockedrequestscount,
    groupUniqArrayArray(allCategories) AS categories,
    COUNT (distinct (organizationIds [1])) AS orgCount
FROM
    dns_dist PREWHERE hasAny(allCategories,[65,110,86,88,108,109,150,61,64,66,68,67])
WHERE
    mspOrganizationId IN (2533528, 2568710, 8263214, 8267685, 8217978)
    AND toStartOfHour(toDateTime(timestamp)) >= toDateTime('2025-07-16 00:00:00')
    AND toStartOfHour(toDateTime(timestamp)) <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    domain
ORDER BY
    requestCount DESC

-- AGG TABLE
SELECT
    qname AS domain,
    countMerge(requestCount) AS requestCount,
    countIfMerge(blockedRequestCount) AS blockedrequestscount,
    groupUniqArrayArray(allCategories) AS categories,
    COUNT (distinct (orgId)) AS orgCount
FROM dns_agg_table_3_dist PREWHERE hasAny(allCategories,[65,110,86,88,108,109,150,61,64,66,68,67])
WHERE
    mspOrganizationId IN (2533528, 2568710, 8263214, 8267685, 8217978)
    AND tsHour >= toDateTime('2025-07-16 00:00:00')
    AND tsHour <= toDateTime('2025-07-16 06:00:00')
    AND eventDate = '2025-07-16'
GROUP BY
    domain
ORDER BY
    requestCount DESC
