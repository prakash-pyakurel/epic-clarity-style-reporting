/* ============================================================
   05_lab_volume.sql
   Report 05 — Lab Test Volume & Test Mix
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Janet Liu, Laboratory Operations Manager
   ------------------------------------------------------------
   PURPOSE
   Top genuine lab tests by result volume, 2017-2021, with a
   per-year trend — a staffing and capacity-planning view of
   what drives lab workload.

   KEY DECISIONS (full rationale in report-notes.md):
   - DATA-MEANING FINDING: the table named LAB_RESULTS actually
     holds ALL clinical observations — vital signs, SDOH survey
     items, AND genuine lab tests. An unfiltered "top tests by
     volume" surfaced blood pressure and survey questions, not
     labs. The report filters to genuine lab tests.
   - Lab tests are isolated by REFERENCE_UNIT: true lab results
     report in clinical lab units (mg/dL, mmol/L, g/dL, U/L,
     etc.). Vitals (mm[Hg], kg, /min) and surveys (NULL, {score})
     are excluded. A defined unit list is used — documented, and
     deliberately limited to unambiguous lab units.
   - Window 2017-2021, not the requested "whole history"
     (RESULT_DATE runs to 1932 — Synthea lifetime data).
     Consistent with the dashboard's other reports.
   - Top 15 lab tests by total volume — keeps it actionable.
   - One row = one result component = the unit of lab workload.
   - Abnormal-result analysis was intended but ABNORMAL_FLAG_C
     is unpopulated in the source data — volume/mix only.
   ============================================================ */

USE EpicClaritySim;

DECLARE @window_start datetime2 = '2017-01-01';
DECLARE @window_end   datetime2 = '2022-01-01';   -- exclusive

;WITH lab_only AS (
    /* Genuine lab results only: filtered to clinical lab
       measurement units, excluding vitals and survey items
       that share the LAB_RESULTS table. */
    SELECT
        COMPONENT_NAME,
        YEAR(RESULT_DATE) AS result_year
    FROM LAB_RESULTS
    WHERE RESULT_DATE >= @window_start
      AND RESULT_DATE <  @window_end
      AND COMPONENT_NAME IS NOT NULL
      AND REFERENCE_UNIT IN (
            'mg/dL', 'mmol/L', 'g/dL', 'U/L', 'fL', 'pg',
            '10*3/uL', '10*6/uL', 'K/uL', 'g/L', 'mg/L',
            'ng/mL', 'pg/mL', 'ug/L', 'ug/dL', 'kU/L',
            'mL/min', 'mL/min/{1.73_m2}', 'mg/g', '[iU]/L', '{INR}'
      )
),
lab_volume AS (
    /* Aggregate to one row per lab test: total volume plus a
       per-year breakdown (conditional SUM pivot). */
    SELECT
        COMPONENT_NAME,
        COUNT(*)                                            AS total_volume,
        SUM(CASE WHEN result_year = 2017 THEN 1 ELSE 0 END) AS vol_2017,
        SUM(CASE WHEN result_year = 2018 THEN 1 ELSE 0 END) AS vol_2018,
        SUM(CASE WHEN result_year = 2019 THEN 1 ELSE 0 END) AS vol_2019,
        SUM(CASE WHEN result_year = 2020 THEN 1 ELSE 0 END) AS vol_2020,
        SUM(CASE WHEN result_year = 2021 THEN 1 ELSE 0 END) AS vol_2021
    FROM lab_only
    GROUP BY COMPONENT_NAME
)
SELECT TOP 15
    COMPONENT_NAME        AS [Lab Test],
    total_volume          AS [Total Results 2017-2021],
    vol_2017              AS [2017],
    vol_2018              AS [2018],
    vol_2019              AS [2019],
    vol_2020              AS [2020],
    vol_2021              AS [2021]
FROM lab_volume
ORDER BY total_volume DESC;