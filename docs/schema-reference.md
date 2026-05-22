# Schema Reference — EpicClaritySim
# Epic Clarity-Style Clinical Reporting & Analytics Platform

> Ground-truth reference for the database. Use this when writing SQL so
> column names and types are exact, not guessed.
>
> Generated from live schema export (INFORMATION_SCHEMA / sys catalog).
> Last verified: 2026-05-16, after Phase 2 ETL.

---

## 1. Summary

- **Database:** `EpicClaritySim` (SQL Server 2022)
- **Total tables:** 76 — 22 base tables + 54 `ZC_` lookup tables
- **Base tables:** 441 columns total across the 22
- **Primary keys:** every table has one; `PROBLEM_LIST` is the only
  composite key (`PAT_ID` + `PROBLEM_LIST_ID`)
- **Foreign keys:** NONE enforced. This is deliberate and authentic to
  real Epic Clarity — relationships are documented conventions, not
  engine-enforced. Referential integrity is the ETL's responsibility;
  joins rely on knowing the data model.

### Key conventions
- `_C` columns: integer category codes → resolved via a `ZC_` table
- `ZC_` tables: lookup/dictionary tables (code, NAME, ABBR)
- `_YN` columns: char(1) yes/no flags, default 'N' (or 'Y')
- `_DT` / date columns: `date`; `_DTTM` / time columns: `datetime2`
- `REC_CREATE_DATE`: every base table has it, defaults to `getdate()`
- Prefixes: `CLARITY_` reference, `HSP_` hospital billing,
  `ORDER_` orders, `ARPB_` professional billing

---

## 2. Load Order (ETL dependency order)

ZC_ lookup tables → reference layer → PATIENT → PAT_ENC →
PAT_ENC_HSP → clinical detail → financial layer.

(No enforced FKs, so this order is self-imposed discipline, not
engine-enforced.)

---

## 3. Base Tables — Columns

Notation: column name — type — NULL? (PK marks primary key).
`getdate()` defaults and `_YN` defaults noted where they apply.

### REFERENCE LAYER

#### CLARITY_DEP — departments
- DEPARTMENT_ID — int — NOT NULL — PK
- DEPARTMENT_NAME — varchar(100) — NOT NULL
- SPECIALTY_C — int — NULL
- LOCATION_ID — int — NULL
- DEPT_TYPE_C — int — NULL
- SERV_AREA_ID — int — NULL
- REV_LOC_ID — int — NULL
- DEPT_ABBREVIATION — varchar(20) — NULL
- EXTERNAL_NAME — varchar(100) — NULL
- PHONE — varchar(20) — NULL
- ACTIVE_YN — char(1) — NOT NULL — default 'Y'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### CLARITY_LOC — locations
- LOCATION_ID — int — NOT NULL — PK
- LOC_NAME — varchar(100) — NOT NULL
- LOC_ABBR — varchar(20) — NULL
- LOC_TYPE_C — int — NULL
- ADDRESS_LINE_1 — varchar(200) — NULL
- ADDRESS_LINE_2 — varchar(200) — NULL
- CITY — varchar(100) — NULL
- STATE_C — int — NULL
- ZIP — varchar(10) — NULL
- COUNTY — varchar(100) — NULL
- PHONE — varchar(20) — NULL
- FAX — varchar(20) — NULL
- SERV_AREA_ID — int — NULL
- PARENT_LOC_ID — int — NULL
- TIME_ZONE_C — int — NULL
- LATITUDE — decimal(9,6) — NULL
- LONGITUDE — decimal(9,6) — NULL
- ACTIVE_YN — char(1) — NOT NULL — default 'Y'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### CLARITY_SER — providers / staff
- PROV_ID — varchar(18) — NOT NULL — PK
- PROV_NAME — varchar(200) — NOT NULL
- PROV_FIRST_NAME — varchar(100) — NULL
- PROV_LAST_NAME — varchar(100) — NULL
- PROV_MIDDLE_NAME — varchar(100) — NULL
- PROV_TYPE — varchar(20) — NULL
- NPI — varchar(10) — NULL
- DEA_NUMBER — varchar(20) — NULL
- SPECIALTY_C — int — NULL
- SUB_SPECIALTY_C — int — NULL
- PRIMARY_DEPT_ID — int — NULL
- PRIMARY_LOC_ID — int — NULL
- EXTERNAL_USER_YN — char(1) — NOT NULL — default 'N'
- EMPLOYEE_YN — char(1) — NOT NULL — default 'Y'
- HIRE_DATE — date — NULL
- TERM_DATE — date — NULL
- EMAIL — varchar(200) — NULL
- PHONE — varchar(20) — NULL
- PAGER — varchar(20) — NULL
- ACTIVE_YN — char(1) — NOT NULL — default 'Y'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_CREATE_USER_ID — varchar(18) — NULL
- REC_UPDATE_DATE — datetime2 — NULL
- REC_UPDATE_USER_ID — varchar(18) — NULL

#### CLARITY_PAYOR — insurance payors
- PAYOR_ID — int — NOT NULL — PK
- PAYOR_NAME — varchar(200) — NOT NULL
- PAYOR_ABBR — varchar(20) — NULL
- PAYOR_TYPE_C — int — NULL
- FINANCIAL_CLASS_C — int — NULL
- PARENT_PAYOR_ID — int — NULL
- CONTRACT_NUMBER — varchar(50) — NULL
- PAYOR_GROUP_C — int — NULL
- EFFECTIVE_FROM_DATE — date — NULL
- EFFECTIVE_TO_DATE — date — NULL
- ADDRESS_LINE_1 — varchar(200) — NULL
- ADDRESS_LINE_2 — varchar(200) — NULL
- CITY — varchar(100) — NULL
- STATE_C — int — NULL
- ZIP — varchar(10) — NULL
- PHONE — varchar(20) — NULL
- FAX — varchar(20) — NULL
- CLAIMS_SUBMISSION_URL — varchar(500) — NULL
- ELECTRONIC_PAYOR_ID — varchar(20) — NULL
- ACTIVE_YN — char(1) — NOT NULL — default 'Y'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

### CLINICAL LAYER

#### PATIENT
- PAT_ID — int — NOT NULL — PK
- PAT_MRN_ID — varchar(20) — NOT NULL
- PAT_FIRST_NAME — varchar(100) — NULL
- PAT_MIDDLE_NAME — varchar(100) — NULL
- PAT_LAST_NAME — varchar(100) — NULL
- PAT_SUFFIX — varchar(20) — NULL
- PAT_MAIDEN_NAME — varchar(100) — NULL
- BIRTH_DATE — date — NULL
- DEATH_DATE — date — NULL
- DECEASED_YN — char(1) — NOT NULL — default 'N'
- SEX_C — int — NULL
- MARITAL_STATUS_C — int — NULL
- RACE_C — int — NULL
- ETHNICITY_C — int — NULL
- PAT_STATUS_C — int — NULL
- PRIMARY_LANGUAGE_C — int — NULL
- INTERP_NEEDED_YN — char(1) — NOT NULL — default 'N'
- ADD_LINE_1 — varchar(200) — NULL
- ADD_LINE_2 — varchar(200) — NULL
- CITY — varchar(100) — NULL
- STATE_C — int — NULL
- ZIP — varchar(10) — NULL
- COUNTY — varchar(100) — NULL
- COUNTRY_C — int — NULL
- HOME_PHONE — varchar(20) — NULL
- WORK_PHONE — varchar(20) — NULL
- MOBILE_PHONE — varchar(20) — NULL
- EMAIL_ADDRESS — varchar(200) — NULL
- SSN — varchar(11) — NULL
- PCP_PROV_ID — varchar(18) — NULL
- REG_DATE — date — NULL
- ACTIVE_YN — char(1) — NOT NULL — default 'Y'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### PAT_ENC — encounters (base)
- PAT_ENC_CSN_ID — bigint — NOT NULL — PK
- PAT_ID — int — NOT NULL
- CONTACT_DATE — date — NOT NULL
- ENC_TYPE_C — int — NULL
- DEPARTMENT_ID — int — NULL
- LOCATION_ID — int — NULL
- VISIT_PROV_ID — varchar(18) — NULL
- REFERRING_PROV_ID — varchar(18) — NULL
- PRIMARY_PAYOR_ID — int — NULL
- APPT_TIME — datetime2 — NULL
- APPT_LENGTH — int — NULL
- CHECKIN_DTTM — datetime2 — NULL
- ROOM_DTTM — datetime2 — NULL
- PROV_ENTER_DTTM — datetime2 — NULL
- CHECKOUT_DTTM — datetime2 — NULL
- ENC_CLOSED_YN — char(1) — NOT NULL — default 'N'
- APPT_STATUS_C — int — NULL
- CANCEL_REASON_C — int — NULL
- NO_SHOW_YN — char(1) — NOT NULL — default 'N'
- CHIEF_COMPLAINT — varchar(500) — NULL
- VISIT_TYPE_C — int — NULL
- LEVEL_OF_SERVICE_C — int — NULL
- HOSP_ADMSN_TYPE_C — int — NULL
- BP_SYSTOLIC — int — NULL
- BP_DIASTOLIC — int — NULL
- TEMPERATURE — decimal(4,1) — NULL
- PULSE — int — NULL
- RESPIRATIONS — int — NULL
- HEIGHT_CM — decimal(5,1) — NULL
- WEIGHT_KG — decimal(5,2) — NULL
- BMI — decimal(4,1) — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### PAT_ENC_HSP — hospital encounter extension
(shares PAT_ENC_CSN_ID with PAT_ENC; only inpatient/emergency encounters)
- PAT_ENC_CSN_ID — bigint — NOT NULL — PK
- PAT_ID — int — NOT NULL
- HOSP_ADMSN_TIME — datetime2 — NULL
- HOSP_DISCH_TIME — datetime2 — NULL
- INP_ADM_DATE — date — NULL
- OBS_ADMIT_DTTM — datetime2 — NULL
- ADM_SOURCE_C — int — NULL
- ADM_TYPE_C — int — NULL
- ADT_PAT_CLASS_C — int — NULL
- DISCH_DISP_C — int — NULL
- DISCH_DEPT_ID — int — NULL
- DISCH_DEST_C — int — NULL
- ADT_ARRIVAL_TIME — datetime2 — NULL
- ED_ARRIVAL_TIME — datetime2 — NULL
- ED_DEPARTURE_TIME — datetime2 — NULL
- HOSP_SERV_C — int — NULL
- ADMITTING_PROV_ID — varchar(18) — NULL
- ATTENDING_PROV_ID — varchar(18) — NULL
- DISCH_PROV_ID — varchar(18) — NULL
- DRG_ID — int — NULL
- ACCOMMODATION_C — int — NULL
- LOS_HRS — decimal(8,2) — NULL
- EXPECTED_LOS — decimal(8,2) — NULL
- READMIT_FLAG_YN — char(1) — NOT NULL — default 'N'
- DEATH_DURING_STAY_YN — char(1) — NOT NULL — default 'N'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### PROBLEM_LIST — diagnoses
COMPOSITE PRIMARY KEY: (PROBLEM_LIST_ID, PAT_ID)
- PROBLEM_LIST_ID — bigint — NOT NULL — PK part 1
- PAT_ID — int — NOT NULL — PK part 2
- DX_ID — int — NULL
- SNOMED_CODE — varchar(20) — NULL
- ICD10_CODE — varchar(20) — NULL
- PROBLEM_DESCRIPTION — varchar(500) — NULL
- NOTED_DATE — date — NULL
- RESOLVED_DATE — date — NULL
- PROBLEM_STATUS_C — int — NULL
- CHRONIC_YN — char(1) — NOT NULL — default 'N'
- PRINCIPAL_PR_YN — char(1) — NOT NULL — default 'N'
- PRIORITY_C — int — NULL
- NOTED_PROV_ID — varchar(18) — NULL
- DIAG_ENC_CSN_ID — bigint — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### ORDER_MED — medication orders
- ORDER_MED_ID — bigint — NOT NULL — PK
- PAT_ID — int — NOT NULL
- PAT_ENC_CSN_ID — bigint — NULL
- MEDICATION_ID — int — NULL
- RXNORM_CODE — varchar(20) — NULL
- MEDICATION_NAME — varchar(500) — NULL
- DOSE — decimal(10,3) — NULL
- DOSE_UNIT_C — int — NULL
- FREQUENCY_C — int — NULL
- ROUTE_C — int — NULL
- ORDER_STATUS_C — int — NULL
- ORDER_TYPE_C — int — NULL
- ORDERING_DATE — datetime2 — NULL
- START_DATE — date — NULL
- END_DATE — date — NULL
- REFILLS_REMAINING — int — NULL
- REFILLS_ORIGINAL — int — NULL
- QUANTITY — decimal(10,2) — NULL
- AUTHRZING_PROV_ID — varchar(18) — NULL
- ORDERING_PROV_ID — varchar(18) — NULL
- PHARMACY_ID — int — NULL
- DISCONTINUED_DATE — datetime2 — NULL
- DISCONTINUED_REASON_C — int — NULL
- REASON_FOR_ORDER — varchar(500) — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### ORDER_PROC — procedure orders
- ORDER_PROC_ID — bigint — NOT NULL — PK
- PAT_ID — int — NOT NULL
- PAT_ENC_CSN_ID — bigint — NULL
- PROC_ID — int — NULL
- CPT_CODE — varchar(10) — NULL
- SNOMED_CODE — varchar(20) — NULL
- PROC_NAME — varchar(500) — NULL
- PROC_CATEGORY_C — int — NULL
- IS_LAB_YN — char(1) — NOT NULL — default 'N'
- IS_IMAGING_YN — char(1) — NOT NULL — default 'N'
- ORDER_STATUS_C — int — NULL
- RESULT_STATUS_C — int — NULL
- ORDER_TYPE_C — int — NULL
- ORDERING_DATE — datetime2 — NULL
- SCHEDULED_DATE — datetime2 — NULL
- RESULT_DATE — datetime2 — NULL
- SPECIMEN_TYPE_C — int — NULL
- SPECIMEN_TAKEN_DTTM — datetime2 — NULL
- BODY_SITE_C — int — NULL
- LATERALITY_C — int — NULL
- AUTHRZING_PROV_ID — varchar(18) — NULL
- ORDERING_PROV_ID — varchar(18) — NULL
- PERFORMING_PROV_ID — varchar(18) — NULL
- REASON_FOR_ORDER — varchar(500) — NULL
- DIAGNOSIS_CODE — varchar(20) — NULL
- PRIORITY_C — int — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### LAB_RESULTS
- RESULT_ID — bigint — NOT NULL — PK
- PAT_ID — int — NOT NULL
- PAT_ENC_CSN_ID — bigint — NULL
- ORDER_PROC_ID — bigint — NULL
- COMPONENT_ID — int — NULL
- LOINC_CODE — varchar(20) — NULL
- COMPONENT_NAME — varchar(500) — NULL
- ORD_VALUE — varchar(500) — NULL
- ORD_NUM_VALUE — decimal(20,5) — NULL
- ORD_VALUE_C — int — NULL
- REFERENCE_LOW — varchar(50) — NULL
- REFERENCE_HIGH — varchar(50) — NULL
- REFERENCE_UNIT — varchar(50) — NULL
- ABNORMAL_FLAG_C — int — NULL
- RESULT_STATUS_C — int — NULL
- SPECIMEN_TYPE_C — int — NULL
- SPECIMEN_TAKEN_DTTM — datetime2 — NULL
- RESULT_DATE — datetime2 — NULL
- RESULT_TIME — datetime2 — NULL
- RESULTING_LAB_ID — int — NULL
- PERFORMING_PROV_ID — varchar(18) — NULL
- RESULTED_BY_USER_ID — varchar(18) — NULL
- COMMENTS — varchar(2000) — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

### FINANCIAL LAYER

#### HSP_ACCOUNT — hospital billing accounts
(loaded 1:1 per claim — documented ETL simplification)
- HSP_ACCOUNT_ID — bigint — NOT NULL — PK
- PRIM_ENC_CSN_ID — bigint — NULL
- PAT_ID — int — NOT NULL
- GUARANTOR_ID — int — NULL
- ACCT_BASECLS_HA_C — int — NULL
- ACCT_STATUS_C — int — NULL
- BILLING_STATUS_C — int — NULL
- FINANCIAL_CLASS_C — int — NULL
- PRIMARY_PAYOR_ID — int — NULL
- SECONDARY_PAYOR_ID — int — NULL
- ADMIT_DATE — date — NULL
- DISCH_DATE — date — NULL
- ACCT_CLOSE_DATE — date — NULL
- TOT_CHGS — decimal(15,2) — NULL
- TOT_PMTS — decimal(15,2) — NULL
- TOT_ADJUSTMENTS — decimal(15,2) — NULL
- TOT_ACCT_BAL — decimal(15,2) — NULL
- TOT_INS_BAL — decimal(15,2) — NULL
- TOT_PAT_BAL — decimal(15,2) — NULL
- DRG_ID — int — NULL
- HOSP_SERV_C — int — NULL
- DISCH_DISP_C — int — NULL
- BILL_DROP_DATE — date — NULL
- LAST_PMT_DATE — date — NULL
- DAYS_IN_AR — int — NULL
- IN_COLLECTIONS_YN — char(1) — NOT NULL — default 'N'
- BAD_DEBT_YN — char(1) — NOT NULL — default 'N'
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### CHARGE_DETAIL
- CHARGE_ID — bigint — NOT NULL — PK
- HSP_ACCOUNT_ID — bigint — NOT NULL
- PAT_ID — int — NOT NULL
- PAT_ENC_CSN_ID — bigint — NULL
- CHARGE_CODE_ID — int — NULL
- CPT_CODE — varchar(10) — NULL
- REVENUE_CODE — varchar(10) — NULL
- HCPCS_CODE — varchar(10) — NULL
- CHARGE_DESCRIPTION — varchar(500) — NULL
- DEPARTMENT_ID — int — NULL
- PERFORMING_PROV_ID — varchar(18) — NULL
- SERVICE_DATE — date — NULL
- POST_DATE — date — NULL
- QUANTITY — decimal(10,3) — NULL
- UNIT_PRICE — decimal(15,2) — NULL
- CHARGE_AMOUNT — decimal(15,2) — NULL
- ALLOWED_AMOUNT — decimal(15,2) — NULL
- CONTRACTUAL_ADJ — decimal(15,2) — NULL
- CHARGE_STATUS_C — int — NULL
- REVERSED_YN — char(1) — NOT NULL — default 'N'
- REVERSAL_REASON_C — int — NULL
- MODIFIER_1 — varchar(10) — NULL
- MODIFIER_2 — varchar(10) — NULL
- PLACE_OF_SERVICE_C — int — NULL
- DIAGNOSIS_POINTER — varchar(20) — NULL
- BILL_TYPE_C — int — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### CLAIM_INFO
- CLAIM_ID — bigint — NOT NULL — PK
- HSP_ACCOUNT_ID — bigint — NOT NULL
- PAT_ID — int — NOT NULL
- PAYOR_ID — int — NULL
- CLAIM_STATUS_C — int — NULL
- CLAIM_TYPE_C — int — NULL
- CLAIM_SEQUENCE_C — int — NULL
- BILL_TYPE_CODE — varchar(10) — NULL
- PAYOR_CLAIM_NUMBER — varchar(50) — NULL
- SERVICE_FROM_DATE — date — NULL
- SERVICE_TO_DATE — date — NULL
- CLAIM_SUBMITTED_DATE — date — NULL
- CLAIM_RECEIVED_DATE — date — NULL
- CLAIM_PROCESSED_DATE — date — NULL
- TOTAL_BILLED — decimal(15,2) — NULL
- TOTAL_ALLOWED — decimal(15,2) — NULL
- TOTAL_PAID — decimal(15,2) — NULL
- TOTAL_DENIED — decimal(15,2) — NULL
- TOTAL_ADJUSTED — decimal(15,2) — NULL
- TOTAL_PAT_RESP — decimal(15,2) — NULL
- DENIAL_CODE — varchar(20) — NULL
- DENIAL_REASON — varchar(500) — NULL
- REMARK_CODE — varchar(20) — NULL
- REJECTION_REASON_C — int — NULL
- APPEAL_STATUS_C — int — NULL
- APPEAL_DATE — date — NULL
- APPEAL_DECISION_DATE — date — NULL
- ORIGINAL_CLAIM_ID — bigint — NULL
- RESUBMISSION_YN — char(1) — NOT NULL — default 'N'
- DAYS_TO_PAY — int — NULL
- DAYS_IN_AR — int — NULL
- BILLING_PROV_NPI — varchar(10) — NULL
- RENDERING_PROV_ID — varchar(18) — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### PAYMENT_DETAIL
- PAYMENT_ID — bigint — NOT NULL — PK
- HSP_ACCOUNT_ID — bigint — NOT NULL
- PAT_ID — int — NOT NULL
- CLAIM_ID — bigint — NULL
- PAYMENT_SOURCE_C — int — NULL
- PAYMENT_TYPE_C — int — NULL
- PAYOR_ID — int — NULL
- PAYMENT_AMOUNT — decimal(15,2) — NOT NULL
- PAYMENT_DATE — date — NULL
- POST_DATE — date — NULL
- SERVICE_DATE — date — NULL
- CHECK_NUMBER — varchar(50) — NULL
- EOB_REFERENCE_NUMBER — varchar(50) — NULL
- TRANSACTION_REF — varchar(50) — NULL
- PAYMENT_METHOD_C — int — NULL
- APPLIED_TO_CHARGE_ID — bigint — NULL
- APPLIED_TO_CPT — varchar(10) — NULL
- ADJUSTMENT_CODE — varchar(20) — NULL
- ADJUSTMENT_REASON — varchar(500) — NULL
- PATIENT_RESP_FLAG_YN — char(1) — NOT NULL — default 'N'
- REVERSED_YN — char(1) — NOT NULL — default 'N'
- REVERSAL_REASON_C — int — NULL
- POSTED_BY_USER_ID — varchar(18) — NULL
- BATCH_ID — varchar(50) — NULL
- DEPOSIT_DATE — date — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

#### ARPB_TRANSACTIONS — professional billing transactions (unified ledger)
- TX_ID — bigint — NOT NULL — PK
- ARPB_VISIT_ID — bigint — NULL
- PAT_ID — int — NOT NULL
- PAT_ENC_CSN_ID — bigint — NULL
- HSP_ACCOUNT_ID — bigint — NULL
- TX_TYPE_C — int — NULL
- TX_AMOUNT — decimal(15,2) — NULL
- CPT_CODE — varchar(10) — NULL
- HCPCS_CODE — varchar(10) — NULL
- PROCEDURE_DESC — varchar(500) — NULL
- SERVICE_FROM_DATE — date — NULL
- SERVICE_TO_DATE — date — NULL
- POST_DATE — date — NULL
- BILLING_PROV_ID — varchar(18) — NULL
- SUPERVISING_PROV_ID — varchar(18) — NULL
- DEPARTMENT_ID — int — NULL
- LOCATION_ID — int — NULL
- PAYOR_ID — int — NULL
- PLACE_OF_SERVICE_C — int — NULL
- MODIFIER_1 — varchar(10) — NULL
- MODIFIER_2 — varchar(10) — NULL
- DIAGNOSIS_CODE_1 — varchar(20) — NULL
- DIAGNOSIS_CODE_2 — varchar(20) — NULL
- UNITS — decimal(10,3) — NULL
- RVU_WORK — decimal(10,4) — NULL
- RVU_PE — decimal(10,4) — NULL
- RVU_MP — decimal(10,4) — NULL
- RVU_TOTAL — decimal(10,4) — NULL
- ALLOWED_AMOUNT — decimal(15,2) — NULL
- CONTRACTUAL_ADJ — decimal(15,2) — NULL
- DENIED_YN — char(1) — NOT NULL — default 'N'
- DENIAL_REASON_C — int — NULL
- VOID_YN — char(1) — NOT NULL — default 'N'
- VOID_REASON_C — int — NULL
- REC_CREATE_DATE — datetime2 — NOT NULL — default getdate()
- REC_UPDATE_DATE — datetime2 — NULL

---

## 4. ZC_ Lookup Tables (60 total)

Every `ZC_` table has the same 3-column shape:
`<concept>_C` (int, PK) — `NAME` (varchar) — `ABBR` (varchar, nullable).

Original 6 (Phase 1): ZC_SEX, ZC_MARITAL_STATUS, ZC_PAT_STATUS,
ZC_STATE, ZC_DEP_SPECIALTY, ZC_PAYOR_TYPE.

Added 54 (Phase 1.5, file 04_zc_reference_ddl.sql): ZC_RACE,
ZC_ETHNICITY, ZC_LANGUAGE, ZC_COUNTRY, ZC_ENC_TYPE, ZC_APPT_STATUS,
ZC_CANCEL_REASON, ZC_VISIT_TYPE, ZC_LEVEL_OF_SERVICE,
ZC_HOSP_ADMSN_TYPE, ZC_ADM_SOURCE, ZC_PAT_CLASS, ZC_DISCH_DISP,
ZC_DISCH_DEST, ZC_HOSP_SERV, ZC_ACCOMMODATION, ZC_PROBLEM_STATUS,
ZC_PRIORITY, ZC_DOSE_UNIT, ZC_FREQUENCY, ZC_ROUTE, ZC_ORDER_STATUS,
ZC_ORDER_TYPE, ZC_DISCONTINUED_REASON, ZC_PROC_CATEGORY,
ZC_RESULT_STATUS, ZC_SPECIMEN_TYPE, ZC_BODY_SITE, ZC_LATERALITY,
ZC_ORD_VALUE, ZC_ABNORMAL_FLAG, ZC_DEPT_TYPE, ZC_LOC_TYPE,
ZC_TIME_ZONE, ZC_FINANCIAL_CLASS, ZC_PAYOR_GROUP, ZC_ACCT_BASECLS,
ZC_ACCT_STATUS, ZC_BILLING_STATUS, ZC_CHARGE_STATUS,
ZC_REVERSAL_REASON, ZC_PLACE_OF_SERVICE, ZC_BILL_TYPE,
ZC_CLAIM_STATUS, ZC_CLAIM_TYPE, ZC_CLAIM_SEQUENCE,
ZC_REJECTION_REASON, ZC_APPEAL_STATUS, ZC_PAYMENT_SOURCE,
ZC_PAYMENT_TYPE, ZC_PAYMENT_METHOD, ZC_TX_TYPE, ZC_DENIAL_REASON,
ZC_VOID_REASON.

### Frequently-needed ZC_ code values

ZC_SEX: 1 Male, 2 Female, 3 Unknown
ZC_RACE: 1 White, 2 Black or African American, 3 Asian,
  4 Native Hawaiian or Other Pacific Islander,
  5 American Indian or Alaska Native, 6 Other Race
ZC_ETHNICITY: 1 Hispanic or Latino, 2 Not Hispanic or Latino
ZC_MARITAL_STATUS: 1 Single, 2 Married, 3 Divorced, 4 Widowed,
  5 Unknown
ZC_PAT_STATUS: 1 Alive, 2 Deceased, 3 Inactive
ZC_ENC_TYPE: 1 Ambulatory, 2 Emergency, 3 Inpatient, 4 Outpatient,
  5 Urgent Care, 6 Wellness
ZC_ORDER_STATUS: 1 Active, 2 Completed, 3 Discontinued, 4 Pending,
  5 Canceled, 6 On Hold
ZC_ORDER_TYPE: 1 Medication, 2 Laboratory, 3 Imaging, 4 Procedure,
  5 Referral, 6 Nursing
ZC_RESULT_STATUS: 1 Final, 2 Preliminary, 3 Pending, 4 Corrected,
  5 Canceled
ZC_PROBLEM_STATUS: 1 Active, 2 Resolved, 3 Inactive
ZC_PRIORITY: 1 Routine, 2 Urgent, 3 STAT, 4 ASAP
ZC_ABNORMAL_FLAG: 1 Normal, 2 High, 3 Low, 4 Critical High,
  5 Critical Low, 6 Abnormal
ZC_PAT_CLASS: 1 Inpatient, 2 Outpatient, 3 Observation,
  4 Emergency, 5 Day Surgery
ZC_CLAIM_STATUS: 1 Submitted, 2 In Process, 3 Paid, 4 Denied,
  5 Partially Paid, 6 Appealed, 7 Closed
ZC_CLAIM_TYPE: 1 Institutional, 2 Professional, 3 Dental, 4 Pharmacy
ZC_PAYOR_TYPE: 1 Commercial, 2 Medicare, 3 Medicaid, 4 Self-Pay,
  5 Other Government, 6 Workers Compensation
ZC_TX_TYPE: 1 Charge, 2 Payment, 3 Adjustment, 4 Refund, 5 Transfer
ZC_CHARGE_STATUS: 1 Posted, 2 Pending, 3 Reversed, 4 Billed, 5 Paid
ZC_ACCT_STATUS: 1 Open, 2 Closed, 3 Billed, 4 In Collections,
  5 Bad Debt

(For ZC_ tables not listed above — e.g. ZC_STATE, ZC_DEP_SPECIALTY —
query the table directly; their value sets are large.)

---

## 5. ETL Data Notes (relevant when writing reports)

- Synthea data is Massachusetts-based: all patient/org STATE_C = 22 (MA).
- ENC_TYPE_C distribution in PAT_ENC: ambulatory 20,124 / emergency
  2,168 / inpatient 1,728 / outpatient 10,837 / urgentcare 2,564 /
  wellness 24,038.
- PAT_ENC_HSP holds only emergency + inpatient encounters (3,896).
- MARITAL_STATUS_C is NULL for minors (Synthea only records it for
  adults) — expected, not a data error.
- Some ORDER_PROC / LAB_RESULTS rows may have NULL PAT_ENC_CSN_ID
  (Synthea data not always encounter-linked) — expected.
- PROC_CATEGORY_C in ORDER_PROC was set to a generic default (3) during
  ETL — Synthea doesn't categorize procedures.
- HSP_ACCOUNT is 1:1 with CLAIM_INFO (same ID range, one account per
  claim).

---

## 6. Schema Export Queries (re-run anytime to refresh this file)

```sql
-- All tables, columns, types
USE EpicClaritySim;
GO
SELECT t.TABLE_NAME, c.ORDINAL_POSITION, c.COLUMN_NAME, c.DATA_TYPE,
       c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE,
       c.IS_NULLABLE, c.COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.TABLES AS t
INNER JOIN INFORMATION_SCHEMA.COLUMNS AS c
    ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION;

-- Primary keys
SELECT tc.TABLE_NAME, kcu.COLUMN_NAME, kcu.ORDINAL_POSITION
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;

-- Foreign keys (returns 0 rows by design — no enforced FKs)
SELECT fk.name AS FK_NAME, tp.name AS PARENT_TABLE,
       cp.name AS PARENT_COLUMN, tr.name AS REFERENCED_TABLE,
       cr.name AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables AS tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns AS cp
    ON fkc.parent_object_id = cp.object_id
   AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns AS cr
    ON fkc.referenced_object_id = cr.object_id
   AND fkc.referenced_column_id = cr.column_id
ORDER BY tp.name, fk.name;
```
