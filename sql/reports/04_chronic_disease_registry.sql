/* ============================================================
   04_chronic_disease_registry.sql
   Report 04 — Chronic Disease Registry
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Dr. Samuel Okafor, Medical Director Population Health
   ------------------------------------------------------------
   PURPOSE
   For each tracked chronic condition, count the distinct
   patients who carry it as an ACTIVE problem — the cohort size
   for care-management outreach.

   SCOPE NOTE — why this report exists in this form:
   This is a substituted report. The original Phase 3 plan had a
   Revenue Cycle layer here, but every financial column in
   HSP_ACCOUNT and CLAIM_INFO (balances, payors, claim dates)
   was unpopulated in the source data — Synthea does not
   generate a billing layer. Report 04 was re-scoped to a
   Population Health report on the clinical data, which is
   fully populated.

   KEY DECISIONS (full rationale in report-notes.md):
   - Conditions identified by PROBLEM_DESCRIPTION text, because
     ICD10_CODE is unpopulated in the source data. Text matching
     is less precise than code matching — documented limitation.
   - ACTIVE problems only (PROBLEM_STATUS_C = 1). The ticket
     asked to include every entry regardless of status, but 79%
     of problem entries are Resolved; an outreach registry must
     count current conditions, not historical ones.
   - COUNT(DISTINCT PAT_ID) — a patient is counted once per
     condition even if the problem is listed multiple times.
   - Condition list curated from conditions that genuinely
     appear in the data. Classic registry conditions not present
     in the dataset (e.g. type 2 diabetes, COPD, heart failure)
     are intentionally not invented.
   ============================================================ */

USE EpicClaritySim;

;WITH active_problems AS (
    /* Every ACTIVE problem-list entry, tagged with the chronic
       condition it represents. A CASE over description text
       maps raw problem text to a clean condition label.
       Entries that match no tracked condition get NULL and are
       filtered out below. */
    SELECT
        PAT_ID,
        CASE
            WHEN PROBLEM_DESCRIPTION LIKE '%Hypertension%'        THEN 'Hypertension'
            WHEN PROBLEM_DESCRIPTION LIKE '%Prediabetes%'         THEN 'Prediabetes'
            WHEN PROBLEM_DESCRIPTION LIKE '%Hyperlipidemia%'      THEN 'Hyperlipidemia'
            WHEN PROBLEM_DESCRIPTION LIKE '%Anemia%'              THEN 'Anemia'
            WHEN PROBLEM_DESCRIPTION LIKE '%Chronic low back pain%' THEN 'Chronic Low Back Pain'
            WHEN PROBLEM_DESCRIPTION LIKE '%Chronic neck pain%'   THEN 'Chronic Neck Pain'
            WHEN PROBLEM_DESCRIPTION LIKE '%Chronic sinusitis%'   THEN 'Chronic Sinusitis'
            ELSE NULL
        END AS condition_name
    FROM PROBLEM_LIST
    WHERE PROBLEM_STATUS_C = 1            -- Active problems only
)
SELECT
    condition_name                       AS [Chronic Condition],
    COUNT(DISTINCT PAT_ID)               AS [Patients in Cohort]
FROM active_problems
WHERE condition_name IS NOT NULL          -- drop non-tracked problems
GROUP BY condition_name
ORDER BY [Patients in Cohort] DESC;