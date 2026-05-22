/* ============================================================
   01_los_observed_expected.sql
   Report 01 — Inpatient Length of Stay: Observed vs Expected
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Dr. Eleanor Voss, Medical Director Clinical Quality
   ------------------------------------------------------------
   PURPOSE
   For inpatient encounters, compare observed length of stay to
   expected, broken out by patient age band.

   KEY DECISIONS (full rationale in report doc):
   - Inpatient only (ADT_PAT_CLASS_C = 1). Emergency encounters
     have no usable LOS in the source data.
   - Date window: discharges 2017-2021. The ticket asked for
     "last 12 months", but Synthea generates lifetime medical
     histories (discharges span 1928-2021), so no recent rolling
     window is meaningful. A dense recent 5-year band was chosen
     as a realistic reporting-window proxy.
   - 30-day cap: stays over 720 hrs excluded as data artifacts.
     Applied to BOTH this report and the EXPECTED_LOS backfill
     so observed and expected reconcile.
   - O/E ratio = SUM(observed) / SUM(expected), NOT avg-of-avgs.
   - EXPECTED_LOS is an age-band-average PROXY, not a risk model.
   - Deaths during stay are KEPT but shown as a count column.
   - Reliability flag: bands under 30 discharges are marked
     "Low volume" — a ratio built on a tiny sample is unstable
     and could mislead the committee (e.g. one long pediatric
     stay swinging the whole band). Rows are flagged, not
     suppressed, so the population stays visible.
   ============================================================ */

USE EpicClaritySim;

DECLARE @window_start    datetime2 = '2017-01-01';
DECLARE @window_end      datetime2 = '2022-01-01';
DECLARE @min_volume      int       = 30;

;WITH inpatient_los AS (
    SELECT
        hsp.PAT_ENC_CSN_ID,
        hsp.LOS_HRS,
        hsp.EXPECTED_LOS,
        hsp.DEATH_DURING_STAY_YN,
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
    WHERE hsp.ADT_PAT_CLASS_C = 1
      AND hsp.LOS_HRS      IS NOT NULL
      AND hsp.EXPECTED_LOS IS NOT NULL
      AND hsp.LOS_HRS      <= 720
      AND hsp.HOSP_DISCH_TIME >= @window_start
      AND hsp.HOSP_DISCH_TIME <  @window_end
),
band_summary AS (
    SELECT
        age_band,
        COUNT(*)                                                    AS discharges,
        SUM(CASE WHEN DEATH_DURING_STAY_YN = 'Y' THEN 1 ELSE 0 END) AS deaths,
        AVG(LOS_HRS)                                                AS avg_obs_hrs,
        AVG(EXPECTED_LOS)                                           AS avg_exp_hrs,
        SUM(LOS_HRS)                                                AS sum_obs_hrs,
        SUM(EXPECTED_LOS)                                           AS sum_exp_hrs
    FROM inpatient_los
    GROUP BY age_band
)
SELECT
    age_band                                            AS [Age Band],
    discharges                                          AS [Inpatient Discharges],
    deaths                                              AS [Deaths During Stay],
    CAST(avg_obs_hrs / 24.0 AS decimal(8,2))            AS [Avg Observed LOS (days)],
    CAST(avg_exp_hrs / 24.0 AS decimal(8,2))            AS [Avg Expected LOS (days)],
    CAST(sum_obs_hrs / NULLIF(sum_exp_hrs, 0)
         AS decimal(8,3))                               AS [O/E Ratio],
    CASE WHEN discharges < @min_volume
         THEN 'Low volume - interpret with caution'
         ELSE 'OK'
    END                                                 AS [Reliability]
FROM band_summary
ORDER BY [O/E Ratio] DESC;