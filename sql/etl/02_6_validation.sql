-- ================================================================
-- 02_6_validation.sql
-- ================================================================
-- Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
-- Phase:   2 - ETL  |  Stage: 2.6 - Validation
-- Purpose: Verify the ETL-loaded database is sound before Phase 3.
--          No data changes - read-only checks.
--
-- Three parts:
--   PART 1 - Row-count inventory (official record of the load)
--   PART 2 - Referential integrity (orphan hunt - no enforced FKs)
--   PART 3 - Data sanity spot-checks
-- ================================================================

USE EpicClaritySim;
GO

-- ================================================================
-- PART 1 - ROW-COUNT INVENTORY
-- ================================================================
PRINT '--- PART 1: Row-count inventory ---';

SELECT 'CLARITY_DEP'        AS TBL, COUNT(*) AS ROWS_LOADED FROM CLARITY_DEP
UNION ALL SELECT 'CLARITY_LOC',        COUNT(*) FROM CLARITY_LOC
UNION ALL SELECT 'CLARITY_SER',        COUNT(*) FROM CLARITY_SER
UNION ALL SELECT 'CLARITY_PAYOR',      COUNT(*) FROM CLARITY_PAYOR
UNION ALL SELECT 'PATIENT',            COUNT(*) FROM PATIENT
UNION ALL SELECT 'PAT_ENC',            COUNT(*) FROM PAT_ENC
UNION ALL SELECT 'PAT_ENC_HSP',        COUNT(*) FROM PAT_ENC_HSP
UNION ALL SELECT 'PROBLEM_LIST',       COUNT(*) FROM PROBLEM_LIST
UNION ALL SELECT 'ORDER_MED',          COUNT(*) FROM ORDER_MED
UNION ALL SELECT 'ORDER_PROC',         COUNT(*) FROM ORDER_PROC
UNION ALL SELECT 'LAB_RESULTS',        COUNT(*) FROM LAB_RESULTS
UNION ALL SELECT 'HSP_ACCOUNT',        COUNT(*) FROM HSP_ACCOUNT
UNION ALL SELECT 'CLAIM_INFO',         COUNT(*) FROM CLAIM_INFO
UNION ALL SELECT 'CHARGE_DETAIL',      COUNT(*) FROM CHARGE_DETAIL
UNION ALL SELECT 'PAYMENT_DETAIL',     COUNT(*) FROM PAYMENT_DETAIL
UNION ALL SELECT 'ARPB_TRANSACTIONS',  COUNT(*) FROM ARPB_TRANSACTIONS
ORDER BY TBL;
GO

-- ================================================================
-- PART 2 - REFERENTIAL INTEGRITY (orphan hunt)
-- Every count below should be 0. A non-zero count = orphan rows
-- pointing at a parent that doesn't exist.
-- ================================================================
PRINT '--- PART 2: Referential integrity (all should be 0) ---';

SELECT 'PAT_ENC -> PATIENT (bad PAT_ID)' AS CHECK_NAME,
       COUNT(*) AS ORPHANS
FROM PAT_ENC e
LEFT JOIN PATIENT p ON e.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'PAT_ENC_HSP -> PAT_ENC (bad CSN)',
       COUNT(*)
FROM PAT_ENC_HSP h
LEFT JOIN PAT_ENC e ON h.PAT_ENC_CSN_ID = e.PAT_ENC_CSN_ID
WHERE e.PAT_ENC_CSN_ID IS NULL

UNION ALL
SELECT 'PROBLEM_LIST -> PATIENT (bad PAT_ID)',
       COUNT(*)
FROM PROBLEM_LIST x
LEFT JOIN PATIENT p ON x.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'ORDER_MED -> PATIENT (bad PAT_ID)',
       COUNT(*)
FROM ORDER_MED x
LEFT JOIN PATIENT p ON x.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'ORDER_PROC -> PATIENT (bad PAT_ID)',
       COUNT(*)
FROM ORDER_PROC x
LEFT JOIN PATIENT p ON x.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'LAB_RESULTS -> PATIENT (bad PAT_ID)',
       COUNT(*)
FROM LAB_RESULTS x
LEFT JOIN PATIENT p ON x.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'HSP_ACCOUNT -> PATIENT (bad PAT_ID)',
       COUNT(*)
FROM HSP_ACCOUNT x
LEFT JOIN PATIENT p ON x.PAT_ID = p.PAT_ID
WHERE p.PAT_ID IS NULL

UNION ALL
SELECT 'CLAIM_INFO -> HSP_ACCOUNT (bad ACCT)',
       COUNT(*)
FROM CLAIM_INFO x
LEFT JOIN HSP_ACCOUNT a ON x.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
WHERE a.HSP_ACCOUNT_ID IS NULL

UNION ALL
SELECT 'CHARGE_DETAIL -> HSP_ACCOUNT (bad ACCT)',
       COUNT(*)
FROM CHARGE_DETAIL x
LEFT JOIN HSP_ACCOUNT a ON x.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
WHERE a.HSP_ACCOUNT_ID IS NULL

UNION ALL
SELECT 'PAYMENT_DETAIL -> HSP_ACCOUNT (bad ACCT)',
       COUNT(*)
FROM PAYMENT_DETAIL x
LEFT JOIN HSP_ACCOUNT a ON x.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
WHERE a.HSP_ACCOUNT_ID IS NULL

UNION ALL
SELECT 'ARPB_TRANSACTIONS -> HSP_ACCOUNT (bad ACCT)',
       COUNT(*)
FROM ARPB_TRANSACTIONS x
LEFT JOIN HSP_ACCOUNT a ON x.HSP_ACCOUNT_ID = a.HSP_ACCOUNT_ID
WHERE a.HSP_ACCOUNT_ID IS NULL;
GO

-- ================================================================
-- PART 3 - DATA SANITY SPOT-CHECKS
-- ================================================================
PRINT '--- PART 3: Data sanity checks ---';

-- 3a. Encounters dated before the patient's birth (should be 0)
SELECT 'Encounters before patient birth' AS CHECK_NAME,
       COUNT(*) AS BAD_ROWS
FROM PAT_ENC e
JOIN PATIENT p ON e.PAT_ID = p.PAT_ID
WHERE e.CONTACT_DATE < p.BIRTH_DATE;

-- 3b. Negative charge amounts (should be 0)
SELECT 'Negative charge amounts' AS CHECK_NAME,
       COUNT(*) AS BAD_ROWS
FROM CHARGE_DETAIL
WHERE CHARGE_AMOUNT < 0;

-- 3c. ZC_ code coverage - PATIENT.SEX_C values all exist in ZC_SEX
SELECT 'PATIENT.SEX_C not in ZC_SEX' AS CHECK_NAME,
       COUNT(*) AS BAD_ROWS
FROM PATIENT p
LEFT JOIN ZC_SEX z ON p.SEX_C = z.SEX_C
WHERE p.SEX_C IS NOT NULL AND z.SEX_C IS NULL;

-- 3d. PAT_ENC.ENC_TYPE_C values all exist in ZC_ENC_TYPE
SELECT 'PAT_ENC.ENC_TYPE_C not in ZC_ENC_TYPE' AS CHECK_NAME,
       COUNT(*) AS BAD_ROWS
FROM PAT_ENC e
LEFT JOIN ZC_ENC_TYPE z ON e.ENC_TYPE_C = z.ENC_TYPE_C
WHERE e.ENC_TYPE_C IS NOT NULL AND z.ENC_TYPE_C IS NULL;

-- 3e. Encounter linkage rate (informational - not a pass/fail)
SELECT 'ORDER_MED encounter link rate' AS CHECK_NAME,
       CAST(100.0 * SUM(CASE WHEN PAT_ENC_CSN_ID IS NOT NULL
                             THEN 1 ELSE 0 END) / COUNT(*)
            AS DECIMAL(5,1)) AS PCT_LINKED
FROM ORDER_MED;
GO

PRINT '--- Validation complete ---';