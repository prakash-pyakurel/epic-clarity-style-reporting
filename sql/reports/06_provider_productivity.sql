/* ============================================================
   06_provider_productivity.sql
   Report 06 — Provider Productivity (Encounter Volume)
   Project : Epic Clarity-Style Clinical Reporting Platform
   Phase   : 3 — Operational Reports
   Stakeholder : Dr. Rebecca Tan, Chief Medical Officer
   ------------------------------------------------------------
   PURPOSE
   Encounter volume per provider, 2017-2021, for annual provider
   review — an objective view of provider workload.

   KEY DECISIONS (full rationale in report-notes.md):
   - Workload measured by ENCOUNTER COUNT. The original plan was
     productivity/RVUs, but RVUs are billing-derived and this
     dataset has no populated billing layer. Encounter count is
     the available, honest workload measure.
   - Providers with at least one encounter only. The ticket
     asked for every provider in the system including zero-
     encounter ones, but CLARITY_SER holds 5,056 providers --
     mostly referring/external/inactive. A workload review of
     working providers should not be padded with thousands of
     zero-encounter rows. Scoped via INNER JOIN; documented.
   - Grouping shown by PROV_TYPE. SPECIALTY_C has no ZC lookup
     table in this database; PROV_TYPE is populated and human-
     readable, and serves the "compare like with like" need.
   - Window 2017-2021, consistent with the whole dashboard
     (CONTACT_DATE spans patient lifetimes).
   - Top 25 by encounter volume -- keeps the review list
     actionable.
   ============================================================ */

USE EpicClaritySim;

DECLARE @window_start datetime2 = '2017-01-01';
DECLARE @window_end   datetime2 = '2022-01-01';   -- exclusive

;WITH provider_encounters AS (
    /* Encounters in the window, joined to their provider.
       INNER JOIN means only providers who actually had
       encounters appear -- the intended scope. */
    SELECT
        ser.PROV_ID,
        ser.PROV_NAME,
        ser.PROV_TYPE
    FROM PAT_ENC AS enc
    INNER JOIN CLARITY_SER AS ser
            ON enc.VISIT_PROV_ID = ser.PROV_ID
    WHERE enc.CONTACT_DATE >= @window_start
      AND enc.CONTACT_DATE <  @window_end
)
SELECT TOP 25
    PROV_NAME              AS [Provider],
    PROV_TYPE              AS [Provider Type],
    COUNT(*)               AS [Encounters 2017-2021]
FROM provider_encounters
GROUP BY PROV_ID, PROV_NAME, PROV_TYPE
ORDER BY [Encounters 2017-2021] DESC;