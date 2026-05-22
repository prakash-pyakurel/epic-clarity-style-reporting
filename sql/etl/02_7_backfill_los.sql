/* ============================================================
   02_7_backfill_los.sql
   Purpose : Populate PAT_ENC_HSP.LOS_HRS and .EXPECTED_LOS,
             both left NULL after Phase 2 ETL (Synthea provides
             neither value).
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 2.7 (data fix — run once, before Phase 3 reports)
   Author  : Prakash

   SCOPE NOTE — discovered during this backfill:
   - Emergency encounters (ADT_PAT_CLASS_C = 4) have no usable
     duration: HOSP_ADMSN_TIME = HOSP_DISCH_TIME on 2,060 of
     2,168 rows, and ED_ARRIVAL/DEPARTURE_TIME are NULL.
   - Therefore LOS is an INPATIENT-ONLY metric here. The 1,728
     inpatient rows have genuine timestamps; Emergency rows are
     intentionally left with EXPECTED_LOS = NULL and excluded
     from Report 01.
   ============================================================ */

USE EpicClaritySim;
GO

/* ---- SAFETY CHECK (read-only) — starting state -------------- */
SELECT
    COUNT(*)                                                   AS total_hsp_rows,
    SUM(CASE WHEN LOS_HRS      IS NULL THEN 1 ELSE 0 END)       AS los_hrs_null,
    SUM(CASE WHEN EXPECTED_LOS IS NULL THEN 1 ELSE 0 END)       AS expected_los_null,
    SUM(CASE WHEN HOSP_ADMSN_TIME IS NOT NULL
              AND HOSP_DISCH_TIME IS NOT NULL THEN 1 ELSE 0 END) AS has_both_timestamps
FROM PAT_ENC_HSP;
GO


/* ============================================================
   PASS 1 — OBSERVED LOS_HRS
   Elapsed hours = minutes / 60.0 (true elapsed time, not
   DATEDIFF(HOUR,...) which counts boundary crossings).
   Applies to all rows with valid timestamps; Emergency rows
   will mostly compute to 0 (admit = discharge) — expected.
   ============================================================ */
UPDATE PAT_ENC_HSP
SET LOS_HRS = CAST(
        DATEDIFF(MINUTE, HOSP_ADMSN_TIME, HOSP_DISCH_TIME) / 60.0
        AS decimal(8,2))
WHERE HOSP_ADMSN_TIME IS NOT NULL
  AND HOSP_DISCH_TIME IS NOT NULL
  AND HOSP_DISCH_TIME >= HOSP_ADMSN_TIME;   -- guard: no negative stays
GO


/* ============================================================
   PASS 2 — EXPECTED_LOS  (age-band proxy, INPATIENT ONLY)
   DRG_ID and HOSP_SERV_C are both NULL across all inpatient
   rows, so neither can anchor "expected LOS". Age band is used
   instead — a documented PROXY, not a risk-adjusted model.
   EXPECTED_LOS = avg observed LOS_HRS within the same age band.
   Age is measured at admission time (data is 2021-era).
   ============================================================ */
;WITH inpatient_age AS (
    SELECT
        hsp.PAT_ENC_CSN_ID,
        hsp.LOS_HRS,
        CASE
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, hsp.HOSP_ADMSN_TIME) < 18  THEN '00-17'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, hsp.HOSP_ADMSN_TIME) < 45  THEN '18-44'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, hsp.HOSP_ADMSN_TIME) < 65  THEN '45-64'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, hsp.HOSP_ADMSN_TIME) < 80  THEN '65-79'
            ELSE '80+'
        END AS age_band
    FROM PAT_ENC_HSP AS hsp
    INNER JOIN PATIENT AS pat
            ON hsp.PAT_ID = pat.PAT_ID
    WHERE hsp.ADT_PAT_CLASS_C = 1          -- inpatient only
      AND hsp.LOS_HRS IS NOT NULL
),
band_avg AS (
    SELECT age_band, AVG(LOS_HRS) AS avg_los_for_band
    FROM inpatient_age
    GROUP BY age_band
)
UPDATE hsp
SET hsp.EXPECTED_LOS = CAST(b.avg_los_for_band AS decimal(8,2))
FROM PAT_ENC_HSP AS hsp
INNER JOIN inpatient_age AS ia ON hsp.PAT_ENC_CSN_ID = ia.PAT_ENC_CSN_ID
INNER JOIN band_avg      AS b  ON ia.age_band        = b.age_band;
GO


/* ---- VERIFY (read-only) — inpatient filled, emergency NULL -- */
SELECT
    CASE WHEN ADT_PAT_CLASS_C = 1 THEN 'Inpatient' ELSE 'Emergency' END AS pat_class,
    COUNT(*)                                                      AS rows_total,
    SUM(CASE WHEN EXPECTED_LOS IS NULL THEN 1 ELSE 0 END)         AS expected_los_null,
    CAST(MIN(EXPECTED_LOS) AS decimal(8,2))                       AS min_expected,
    CAST(MAX(EXPECTED_LOS) AS decimal(8,2))                       AS max_expected
FROM PAT_ENC_HSP
GROUP BY CASE WHEN ADT_PAT_CLASS_C = 1 THEN 'Inpatient' ELSE 'Emergency' END;
GO