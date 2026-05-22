/* ============================================================
   02_readmissions_30day.sql
   Report 02 — 30-Day Inpatient Readmission Rate
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Marcus Reilly RN, Care Transitions Coordinator
   ------------------------------------------------------------
   PURPOSE
   For inpatient discharges 2017-2021, the 30-day readmission
   rate, grouped by the QUARTER of the index discharge.

   KEY DECISIONS (full rationale in report-notes.md):
   - Index event = an inpatient discharge (ADT_PAT_CLASS_C = 1).
   - Readmission = a LATER inpatient admission by the SAME
     patient, within 30 days of the index discharge.
   - Each index discharge counts ONCE if it had >= 1 qualifying
     readmission. Ticket asked to count every bounce-back — that
     is wrong for a RATE (numerator could exceed denominator).
   - Grain = QUARTER, not the requested month. Monthly buckets
     held only 1-5 discharges, producing wild swings (0% to 80%
     month to month) that are noise, not signal. Quarterly pools
     enough discharges for a stable, readable trend.
   - Reliability flag: quarters under 30 discharges are marked
     low-volume (early quarters are thinner than later ones).
   - Window 2017-2021, consistent with Report 01.
   - Planned readmissions not excluded (no flag in source data).
   - Edge effect: discharges late in 2021 have little follow-up
     time in the data; their readmissions may be undercounted.
   ============================================================ */

USE EpicClaritySim;

DECLARE @window_start datetime2 = '2017-01-01';
DECLARE @window_end   datetime2 = '2022-01-01';   -- exclusive
DECLARE @min_volume   int       = 30;             -- reliability threshold

;WITH index_stays AS (
    /* Every inpatient discharge in the window — the DENOMINATOR. */
    SELECT PAT_ID, PAT_ENC_CSN_ID, HOSP_DISCH_TIME
    FROM PAT_ENC_HSP
    WHERE ADT_PAT_CLASS_C = 1
      AND HOSP_ADMSN_TIME IS NOT NULL
      AND HOSP_DISCH_TIME IS NOT NULL
      AND HOSP_DISCH_TIME >= @window_start
      AND HOSP_DISCH_TIME <  @window_end
),
all_inpatient AS (
    /* Pool of potential readmissions — all inpatient admissions,
       NOT window-limited (a Dec-2021 discharge can be readmitted
       in Jan 2022). */
    SELECT PAT_ID, PAT_ENC_CSN_ID, HOSP_ADMSN_TIME
    FROM PAT_ENC_HSP
    WHERE ADT_PAT_CLASS_C = 1
      AND HOSP_ADMSN_TIME IS NOT NULL
),
flagged AS (
    /* YES/NO per index discharge: did >= 1 qualifying
       readmission exist? EXISTS = one row regardless of how
       many readmissions — keeps each discharge counted once. */
    SELECT
        idx.PAT_ENC_CSN_ID,
        idx.HOSP_DISCH_TIME,
        CASE WHEN EXISTS (
            SELECT 1
            FROM all_inpatient AS rdm
            WHERE rdm.PAT_ID = idx.PAT_ID
              AND rdm.PAT_ENC_CSN_ID <> idx.PAT_ENC_CSN_ID
              AND rdm.HOSP_ADMSN_TIME >  idx.HOSP_DISCH_TIME
              AND rdm.HOSP_ADMSN_TIME <= DATEADD(DAY, 30, idx.HOSP_DISCH_TIME)
        ) THEN 1 ELSE 0 END AS was_readmitted
    FROM index_stays AS idx
),
quarterly AS (
    /* Roll discharges up to calendar quarter.
       Label format: 2019-Q2  */
    SELECT
        CAST(YEAR(HOSP_DISCH_TIME) AS varchar(4))
            + '-Q'
            + CAST(DATEPART(QUARTER, HOSP_DISCH_TIME) AS varchar(1)) AS disch_quarter,
        was_readmitted
    FROM flagged
)
SELECT
    disch_quarter                                    AS [Discharge Quarter],
    COUNT(*)                                         AS [Inpatient Discharges],
    SUM(was_readmitted)                              AS [Readmitted within 30 Days],
    CAST( 100.0 * SUM(was_readmitted) / COUNT(*)
          AS decimal(5,2) )                          AS [Readmission Rate %],
    CASE WHEN COUNT(*) < @min_volume
         THEN 'Low volume - interpret with caution'
         ELSE 'OK'
    END                                              AS [Reliability]
FROM quarterly
GROUP BY disch_quarter
ORDER BY disch_quarter;