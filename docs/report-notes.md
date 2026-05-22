# Report Notes — Epic Clarity Reporting Platform
# Phase 3 working notes: per-report decisions + interview stories
# (Source material for the Phase 5 report docs and README.)

---

## Report 01 — Inpatient LOS: Observed vs Expected

**Stakeholder:** Dr. Eleanor Voss, Medical Director Clinical Quality
**SQL file:** sql/reports/01_los_observed_expected.sql
**Status:** Locked.

### Key decisions made
- Inpatient only (ADT_PAT_CLASS_C = 1) — Emergency encounters
  have no usable LOS in the source data (admit = discharge).
- Date window 2017-2021, not the requested "last 12 months" —
  Synthea generates lifetime histories (discharges span
  1928-2021), so no recent rolling window is meaningful.
- 30-day outlier cap on LOS — distribution showed real stays
  run 1-5 days; artifacts reached 4,969 days. Same cap applied
  to the report AND the EXPECTED_LOS backfill so they reconcile.
- O/E ratio = SUM(observed)/SUM(expected), not avg-of-averages.
- EXPECTED_LOS is an age-band-average proxy, not a risk model —
  documented as a simplification.
- Minimum-volume flag at 30 discharges — bands below it are
  marked "Low volume", not suppressed.

### Interview story — "tell me about working with messy data"
"I built an inpatient length-of-stay report. The stakeholder
asked for 'the last 12 months,' but when I profiled the data I
found the discharge dates spanned almost a century — it was
synthetic lifetime data, not a recent snapshot. So I anchored to
a dense, defensible 5-year window instead and documented why. I
also caught outlier stays — one was 13 years long — contaminating
the expected-LOS benchmark, so I capped at 30 days and made sure
the same cap applied to both the metric and the benchmark so
they'd reconcile. And I added a minimum-volume flag, because one
age band had only 6 cases and a raw ratio there would have
misled the committee. The report ships with its limitations
labeled, not hidden."

---

## Report 02 — 30-Day Inpatient Readmission Rate

**Stakeholder:** Marcus Reilly RN, Care Transitions Coordinator
**SQL file:** sql/reports/02_readmissions_30day.sql
**Status:** Locked.

### Key decisions made
- Index = inpatient discharge; readmission = a later inpatient
  admission by the same patient within 30 days.
- Each index discharge counts ONCE if it had >= 1 readmission.
  The ticket asked to count every bounce-back separately — wrong
  for a rate (numerator could exceed denominator, rate > 100%).
- EXISTS used to enforce one-per-discharge counting structurally.
- Grain = quarter, not the requested month. Monthly buckets held
  1-5 discharges and swung 0%-80% — noise, not signal. Quarterly
  pools enough discharges for a readable trend.
- Low-volume reliability flag at 30 discharges (reused from R01).
- Planned readmissions not excluded — no flag in source data.

### Known limitation (documented, not a bug)
Absolute readmission rates run higher than real-world benchmarks
(~15-20%) because Synthea generates inpatient encounters more
densely than actual hospital utilization. The report's value is
the relative trend across quarters, not the absolute percentage.

### Interview story — "a stakeholder asked for the wrong thing"
"A care-transitions coordinator asked me for a 30-day readmission
report grouped by month, and to count every bounce-back. Two
problems. Counting every bounce-back breaks a rate — the
numerator can exceed the denominator. A readmission rate is
one-yes-or-no per discharge, so I used an EXISTS check to enforce
that. And monthly grain was too sparse — 1 to 5 discharges a
month produced rates swinging from 0 to 80 percent, pure noise. I
showed him the data was too thin for monthly and proposed
quarterly, which gave a stable trend he could actually act on. I
also flagged that the absolute rate runs high because the
synthetic data over-generates encounters — so the trend is the
signal, not the headline number."

---

## Report 03 — ED Encounter Volume by Age Band and Year

**Stakeholder:** Dr. Priya Anand, ED Operations Director
**SQL file:** sql/reports/03_ed_volume.sql
**Status:** Locked.

### Scope journey (three decisions, all data-driven)
1. ED Throughput (original plan) — not buildable. Every ED
   timing column unpopulated (ED_ARRIVAL/DEPARTURE_TIME,
   CHECKIN/ROOM/CHECKOUT_DTTM).
2. ED Disposition — not reliable. DISCH_DISP_C fully NULL;
   inferring admission via same-day inpatient link gave only
   ~13 admissions in 2017-2021 and an age pattern that ran
   backwards (0% admit for 65-79 and 80+). Sanity check failed,
   so not shipped.
3. ED Volume by age band & year — fully supported. Counts only
   confirmed-populated columns; infers nothing.

### Key decisions made
- ED encounter = ADT_PAT_CLASS_C = 4, CONTACT_DATE 2017-2021.
- Age band measured at the ED visit date.
- Year columns built with conditional SUM (pivot pattern).
- Low-volume reliability flag at 30 (reused from R01/R02).

### Interview story — "knowing when not to ship something"
"My ED report went through three versions. I scoped ED
throughput, then found every ED timing column was empty. I
moved to ED disposition, but the disposition field was NULL so
I inferred admissions by linking ED visits to same-day
inpatient stays — and the result came out clinically backwards,
zero percent admit rate for the oldest patients, which is
impossible. That told me the inference wasn't trustworthy, so I
didn't ship it. I built ED volume by age band instead, which
the data fully supports and which produced a realistic
demographic pattern. The lesson I'd point to: a report that
fails its own sanity check shouldn't go out, even if the SQL
runs clean."

---

## Report 04 — Chronic Disease Registry

**Stakeholder:** Dr. Samuel Okafor, Medical Director Population Health
**SQL file:** sql/reports/04_chronic_disease_registry.sql
**Status:** Locked.

### Scope note
Substituted report. The original Revenue Cycle layer (AR aging
by payor) could not be built — every financial column in
HSP_ACCOUNT and CLAIM_INFO was unpopulated; Synthea generates
no billing layer. Re-scoped to a Population Health report on
the fully-populated clinical data.

### Key decisions made
- Conditions identified by PROBLEM_DESCRIPTION text — ICD10_CODE
  is unpopulated. Text matching documented as less precise.
- Active problems only (PROBLEM_STATUS_C = 1). Ticket asked for
  all entries; 79% are Resolved, and an outreach registry must
  count current conditions, not historical ones.
- COUNT(DISTINCT PAT_ID) — headcount, one patient per condition.
- Condition list curated from conditions genuinely present;
  classic registry conditions absent from the data (type 2
  diabetes, COPD, heart failure) were not invented.

### Interview story — "making the correct call before you know if it matters"
"I built a chronic disease registry for a care-management
outreach program. The stakeholder asked me to count every
problem-list entry regardless of status, but 79% of entries
were marked Resolved. For a registry driving live outreach you
have to count active conditions only — otherwise the care team
contacts people about conditions they no longer have. I filtered
to active status and documented it. Interestingly, when I ran
it, the active-only counts came out almost identical to the
all-status counts for these conditions — but that doesn't
change the decision. You make the methodologically correct
choice because it's correct, not because you've confirmed it
happens to matter that run."

---

## Report 05 — Lab Test Volume & Test Mix

**Stakeholder:** Janet Liu, Laboratory Operations Manager
**SQL file:** sql/reports/05_lab_volume.sql
**Status:** Locked.

### Key decisions made
- DATA-MEANING FINDING: the table named LAB_RESULTS actually
  holds ALL clinical observations — vital signs, SDOH survey
  items, and genuine lab tests. An unfiltered "top tests by
  volume" returned blood pressure and survey questions, not labs.
- Genuine lab tests isolated by REFERENCE_UNIT — true labs
  report in clinical lab units (mg/dL, mmol/L, g/dL, U/L, etc.);
  vitals (mm[Hg], kg, /min) and surveys (NULL, {score}) excluded.
  A defined, unambiguous unit list is used and documented.
- Window 2017-2021, not the requested "whole history"
  (RESULT_DATE runs to 1932 — Synthea lifetime data).
- Top 15 lab tests by total volume; conditional-SUM pivot for
  the per-year trend.
- Abnormal-result analysis intended but ABNORMAL_FLAG_C is
  unpopulated — volume and test mix only.

### Interview story — "a table that didn't mean what it was named"
"I built a lab volume report off a table called LAB_RESULTS. My
first run came back with blood pressure and survey questions as
the 'top lab tests' — which made no sense. When I profiled it I
found the table actually held every clinical observation, not
just labs: vitals and SDOH surveys were mixed in, and they're
recorded far more often than labs. I isolated the genuine lab
tests by reference unit — real labs report in units like mg/dL
and mmol/L, which vitals and surveys don't — and documented the
filter. The lesson: a column or table name is a hint, not a
guarantee. You profile what's actually in it."

---

## Report 06 — Provider Productivity (Encounter Volume)

**Stakeholder:** Dr. Rebecca Tan, Chief Medical Officer
**SQL file:** sql/reports/06_provider_productivity.sql
**Status:** Locked.

### Key decisions made
- Workload measured by encounter count. Original plan was
  productivity/RVUs, but RVUs are billing-derived and this
  dataset has no billing layer. Encounter count is the honest
  available measure.
- Providers with >= 1 encounter only. Ticket asked for every
  provider in the system; CLARITY_SER holds 5,056, mostly
  referring/external/inactive. INNER JOIN scopes to working
  providers — the correct method and the simpler SQL are the
  same thing here.
- Grouped by PROV_TYPE — SPECIALTY_C has no ZC lookup table;
  PROV_TYPE is populated and readable.
- Window 2017-2021, consistent with the dashboard.
- Top 25 by volume — keeps the review list actionable.

### Interview story — "the join type is the decision"
"I built a provider productivity report. The CMO asked for
every provider in the system, including ones with zero
encounters. But the provider table had 5,000-plus entries,
mostly external and inactive providers, while only a few
hundred actually saw patients. Padding a workload review with
thousands of zero rows would bury the people being reviewed. I
scoped it with an INNER JOIN — which structurally returns only
providers who had encounters — and documented why. The point I
took from it: choosing INNER versus LEFT JOIN isn't a syntax
detail, it's a scoping decision about who belongs in the report."

---