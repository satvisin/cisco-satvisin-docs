# REPORT-15779-Validation

Changes done for REPORT-15779 solves two issues 
- Mutliregion data integration for all four MSSP Overview APIs i.e. top-incident-categories, top-orgs-for-categories, top-policy-hitcounts and top-user-blocks.
- Top user blocks count logic update to include the other origin data feild from sig_proxy_dist, cdfw_dist and swa_dist tables.

## Multiregion data integration verification 

**Before:**

Call made for US region
<img width="2159" height="1631" alt="image-20250825-161226" src="https://github.com/user-attachments/assets/ad5f155d-5f35-4159-a72f-c1c3da16578a" />

Call made for EU region
<img width="2835" height="1723" alt="image-20250826-075528" src="https://github.com/user-attachments/assets/a235a407-293c-4132-8c24-202599adb090" />

**After:** 

![Xnip2025-09-04_18-02-28](https://github.com/user-attachments/assets/e2a2d148-1799-4b0f-a7d9-5472549ff072)
<img width="763" height="398" alt="Screenshot 2025-09-04 at 6 01 00 PM" src="https://github.com/user-attachments/assets/3db02cb6-495f-4732-a451-19c99d1105ea" />

## Top user blocks count logic update
Count seems to be matching
![Xnip2025-09-04_18-23-19](https://github.com/user-attachments/assets/230a4050-2e17-43f5-8ae3-69982bc64f2f)
![Xnip2025-09-04_18-22-44](https://github.com/user-attachments/assets/b249d979-d0c9-4562-8be6-c779b380d08c)

Updated queries:

``` sql
-- SIG_PROXY_DIST
SELECT
    transaction_originIds,
    transaction_organizationIds,
    transaction_mspOrganizationId,
    transaction_originTypes,
    count(*) AS count
FROM sig_proxy_dist
ARRAY JOIN
    arrayConcat([transaction_originId], transaction_otherOriginIds) AS transaction_originIds,
    arrayConcat([transaction_organizationId], transaction_otherOrganizationIds) AS transaction_organizationIds,
    arrayConcat([transaction_originType], transaction_otherOriginTypes) AS transaction_originTypes
WHERE (verdict_status = 2) AND (transaction_mspOrganizationId = 8345462) AND (transaction_originTypes IN (7, 43, 48)) AND (timestamp >= 1755758672) AND (timestamp <= 1756406672) AND (eventDate >= '2025-08-21') AND (eventDate <= '2025-08-28')
GROUP BY
    transaction_originIds,
    transaction_organizationIds,
    transaction_mspOrganizationId,
    transaction_originTypes
ORDER BY count DESC
LIMIT 10  
-- CDFW_DIST
SELECT
    originIds,
    organizationIds,
    mspOrganizationId,
    originTypes,
    count(*) AS count
FROM cdfw_dist
ARRAY JOIN
    arrayConcat([origin_id], other_origin_ids) AS originIds,
    arrayConcat([organization_id], other_organization_ids) AS organizationIds,
    arrayConcat([origin_type], other_origin_types) AS originTypes
WHERE (verdict = 2) AND (mspOrganizationId = 8345462) AND (originTypes IN (7, 43, 48)) AND (timestamp >= 1755758672) AND (timestamp <= 1756406672) AND (eventDate >= '2025-08-21') AND (eventDate <= '2025-08-28')
GROUP BY
    originIds,
    organizationIds,
    mspOrganizationId,
    originTypes
ORDER BY count DESC
LIMIT 10

-- SWA_DIST
SELECT
    transaction_originIds,
    transaction_organizationIds,
    transaction_mspOrganizationId,
    transaction_originTypes,
    count(*) AS count
FROM swa_dist
ARRAY JOIN
    arrayConcat([transaction_originId], transaction_otherOriginIds) AS transaction_originIds,
    arrayConcat([transaction_organizationId], transaction_otherOrganizationIds) AS transaction_organizationIds,
    arrayConcat([transaction_originType], transaction_otherOriginTypes) AS transaction_originTypes
WHERE (verdict_status = 2) AND (transaction_mspOrganizationId = 0) AND (transaction_originTypes IN (7, 43, 48)) AND (timestamp >= 1755758672) AND (timestamp <= 1756406672) AND (eventDate >= '2025-08-21') AND (eventDate <= '2025-08-28')
GROUP BY
    transaction_originIds,
    transaction_organizationIds,
    transaction_mspOrganizationId,
    transaction_originTypes
ORDER BY count DESC
LIMIT 10 
```
