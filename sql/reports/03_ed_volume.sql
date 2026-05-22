/* ============================================================
   03_ed_volume.sql
   Report 03 — ED Encounter Volume by Age Band and Year
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Dr. Priya Anand, ED Operations Director
   ------------------------------------------------------------
   PURPOSE
   ED encounter volume for 2017-2021, broken out by patient age
   band and by year — a capacity-planning view of who uses the
   ED and how that volume moves over time.

   SCOPE NOTE — why this report exists in this form:
   Report 03 went through three scope decisions, all driven by
   confirmed data limitations in the source:
   1. ED Throughput (original) — not buildable: every ED timing
      column (ED_ARRIVAL/DEPARTURE_TIME, CHECKIN/ROOM/CHECKOUT
      _DTTM) is unpopulated.
   2. ED Disposition — not reliable: DISCH_DISP_C is fully NULL,
      and the same-day-admission inference produced only ~13
      admissions across 2017-2021, with an age pattern that ran
      clinically backwards (0% admit rate for 65-79 and 80+).
      A report whose own sanity check fails was not shipped.
   3. ED Volume (this report) — fully supported: needs only
      encounter counts and dates, both confirmed populated.
   This report counts what is actually in the data; it infers
   nothing.

   KEY DECISIONS (full rationale in report-notes.md):
   - ED encounter = ADT_PAT_CLASS_C = 4, CONTACT_DATE 2017-2021.
   - Age band measured at the ED encounter date.
   - Window 2017-2021, consistent with Reports 01 and 02.
   - Low-volume reliability flag at 30 encounters per cell.
   ============================================================ */

USE EpicClaritySim;

DECLARE @window_start datetime2 = '2017-01-01';
DECLARE @window_end   datetime2 = '2022-01-01';   -- exclusive
DECLARE @min_volume   int       = 30;             -- reliability threshold

;WITH ed AS (
    /* Every ED encounter in the window, tagged with the year
       and the patient's age band at the time of the visit. */
    SELECT
        hsp.PAT_ENC_CSN_ID,
        YEAR(enc.CONTACT_DATE) AS ed_year,
        CASE
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, enc.CONTACT_DATE) < 18  THEN '00-17'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, enc.CONTACT_DATE) < 45  THEN '18-44'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, enc.CONTACT_DATE) < 65  THEN '45-64'
            WHEN DATEDIFF(YEAR, pat.BIRTH_DATE, enc.CONTACT_DATE) < 80  THEN '65-79'
            ELSE '80+'
        END AS age_band
    FROM PAT_ENC_HSP AS hsp
    INNER JOIN PAT_ENC AS enc
            ON hsp.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
    INNER JOIN PATIENT AS pat
            ON hsp.PAT_ID = pat.PAT_ID
    WHERE hsp.ADT_PAT_CLASS_C = 4
      AND enc.CONTACT_DATE >= @window_start
      AND enc.CONTACT_DATE <  @window_end
)
SELECT
    age_band                                         AS [Age Band],
    COUNT(*)                                         AS [Total ED Encounters],
    /* one column per year — a quick volume trend across 2017-2021 */
    SUM(CASE WHEN ed_year = 2017 THEN 1 ELSE 0 END)  AS [2017],
    SUM(CASE WHEN ed_year = 2018 THEN 1 ELSE 0 END)  AS [2018],
    SUM(CASE WHEN ed_year = 2019 THEN 1 ELSE 0 END)  AS [2019],
    SUM(CASE WHEN ed_year = 2020 THEN 1 ELSE 0 END)  AS [2020],
    SUM(CASE WHEN ed_year = 2021 THEN 1 ELSE 0 END)  AS [2021],
    CASE WHEN COUNT(*) < @min_volume
         THEN 'Low volume - interpret with caution'
         ELSE 'OK' END                               AS [Reliability]
FROM ed
GROUP BY age_band
ORDER BY age_band;