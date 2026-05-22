-- ================================================================
-- 01_populate_zc.sql
-- ================================================================
-- Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
-- Phase:   2 - ETL  |  Stage: 2.1 - Populate ZC_ lookup tables
-- Purpose: Insert reference values into all 60 ZC_ lookup tables.
--
-- Code convention: sequential integers from 1 within each table.
-- Source-driven tables use values confirmed from Synthea CSVs;
-- standard-driven tables use standard healthcare/Epic values.
--
-- Run order: After all DDL (01-04). Safe to re-run only after
--            truncating - see validation notes at end.
-- ================================================================

USE EpicClaritySim;
GO

-- ================================================================
-- PART 1 - SOURCE-DRIVEN & JUDGMENT-CALL TABLES
-- ================================================================

-- ---- ZC_SEX (Synthea: F, M  +  standard Unknown) ----
INSERT INTO ZC_SEX (SEX_C, NAME, ABBR) VALUES
(1, 'Male', 'M'),
(2, 'Female', 'F'),
(3, 'Unknown', 'UNK');
GO

-- ---- ZC_RACE (Synthea: 6 values) ----
INSERT INTO ZC_RACE (RACE_C, NAME, ABBR) VALUES
(1, 'White', 'WHT'),
(2, 'Black or African American', 'BLK'),
(3, 'Asian', 'ASN'),
(4, 'Native Hawaiian or Other Pacific Islander', 'HAW'),
(5, 'American Indian or Alaska Native', 'NAT'),
(6, 'Other Race', 'OTH');
GO

-- ---- ZC_ETHNICITY (Synthea: hispanic, nonhispanic) ----
INSERT INTO ZC_ETHNICITY (ETHNICITY_C, NAME, ABBR) VALUES
(1, 'Hispanic or Latino', 'HISP'),
(2, 'Not Hispanic or Latino', 'NONHISP');
GO

-- ---- ZC_MARITAL_STATUS (Synthea: M, S  +  standard extras) ----
INSERT INTO ZC_MARITAL_STATUS (MARITAL_STATUS_C, NAME, ABBR) VALUES
(1, 'Single', 'S'),
(2, 'Married', 'M'),
(3, 'Divorced', 'D'),
(4, 'Widowed', 'W'),
(5, 'Unknown', 'UNK');
GO

-- ---- ZC_LANGUAGE (no Synthea source - standard set) ----
INSERT INTO ZC_LANGUAGE (PRIMARY_LANGUAGE_C, NAME, ABBR) VALUES
(1, 'English', 'ENG'),
(2, 'Spanish', 'SPA'),
(3, 'Chinese', 'CHI'),
(4, 'Vietnamese', 'VIE'),
(5, 'French', 'FRE'),
(6, 'Arabic', 'ARA'),
(7, 'Other', 'OTH'),
(8, 'Unknown', 'UNK');
GO

-- ---- ZC_COUNTRY (no Synthea source - minimal) ----
INSERT INTO ZC_COUNTRY (COUNTRY_C, NAME, ABBR) VALUES
(1, 'United States', 'USA'),
(2, 'Other', 'OTH'),
(3, 'Unknown', 'UNK');
GO

-- ---- ZC_PAT_STATUS (standard Epic patient statuses) ----
INSERT INTO ZC_PAT_STATUS (PAT_STATUS_C, NAME, ABBR) VALUES
(1, 'Alive', 'ALIVE'),
(2, 'Deceased', 'DEC'),
(3, 'Inactive', 'INACT');
GO

-- ---- ZC_ENC_TYPE (Synthea ENCOUNTERCLASS: 6 values) ----
INSERT INTO ZC_ENC_TYPE (ENC_TYPE_C, NAME, ABBR) VALUES
(1, 'Ambulatory', 'AMB'),
(2, 'Emergency', 'EMER'),
(3, 'Inpatient', 'INP'),
(4, 'Outpatient', 'OUTP'),
(5, 'Urgent Care', 'URG'),
(6, 'Wellness', 'WELL');
GO

-- ---- ZC_VISIT_TYPE (no Synthea source - standard set) ----
INSERT INTO ZC_VISIT_TYPE (VISIT_TYPE_C, NAME, ABBR) VALUES
(1, 'New Patient', 'NEW'),
(2, 'Follow-Up', 'FU'),
(3, 'Annual Physical', 'PHYS'),
(4, 'Acute / Sick Visit', 'ACUTE'),
(5, 'Procedure Visit', 'PROC'),
(6, 'Telehealth', 'TELE');
GO

-- ---- ZC_DEP_SPECIALTY (Synthea providers: 63 specialties) ----
INSERT INTO ZC_DEP_SPECIALTY (SPECIALTY_C, NAME, ABBR) VALUES
(1,  'Advanced Heart Failure and Transplant Cardiology', NULL),
(2,  'Allergy/Immunology', NULL),
(3,  'Anesthesiology', NULL),
(4,  'Anesthesiology Assistant', NULL),
(5,  'Audiologist', NULL),
(6,  'Cardiac Electrophysiology', NULL),
(7,  'Cardiovascular Disease (Cardiology)', NULL),
(8,  'Certified Nurse Midwife', NULL),
(9,  'Certified Registered Nurse Anesthetist', NULL),
(10, 'Chiropractic', NULL),
(11, 'Clinical Nurse Specialist', NULL),
(12, 'Clinical Psychologist', NULL),
(13, 'Clinical Social Worker', NULL),
(14, 'Colorectal Surgery (Proctology)', NULL),
(15, 'Dermatology', NULL),
(16, 'Diagnostic Radiology', NULL),
(17, 'Emergency Medicine', NULL),
(18, 'Endocrinology', NULL),
(19, 'Family Practice', NULL),
(20, 'Gastroenterology', NULL),
(21, 'General Practice', NULL),
(22, 'General Surgery', NULL),
(23, 'Geriatric Medicine', NULL),
(24, 'Geriatric Psychiatry', NULL),
(25, 'Hand Surgery', NULL),
(26, 'Hematology/Oncology', NULL),
(27, 'Hospice/Palliative Care', NULL),
(28, 'Hospitalist', NULL),
(29, 'Infectious Disease', NULL),
(30, 'Internal Medicine', NULL),
(31, 'Interventional Cardiology', NULL),
(32, 'Interventional Pain Management', NULL),
(33, 'Interventional Radiology', NULL),
(34, 'Nephrology', NULL),
(35, 'Neurology', NULL),
(36, 'Neurosurgery', NULL),
(37, 'Nurse Practitioner', NULL),
(38, 'Obstetrics/Gynecology', NULL),
(39, 'Occupational Therapy', NULL),
(40, 'Ophthalmology', NULL),
(41, 'Optometry', NULL),
(42, 'Oral Surgery', NULL),
(43, 'Orthopedic Surgery', NULL),
(44, 'Osteopathic Manipulative Medicine', NULL),
(45, 'Otolaryngology', NULL),
(46, 'Pain Management', NULL),
(47, 'Pathology', NULL),
(48, 'Pediatric Medicine', NULL),
(49, 'Physical Medicine and Rehabilitation', NULL),
(50, 'Physical Therapy', NULL),
(51, 'Physician Assistant', NULL),
(52, 'Plastic and Reconstructive Surgery', NULL),
(53, 'Podiatry', NULL),
(54, 'Psychiatry', NULL),
(55, 'Pulmonary Disease', NULL),
(56, 'Radiation Oncology', NULL),
(57, 'Registered Dietitian or Nutrition Professional', NULL),
(58, 'Rheumatology', NULL),
(59, 'Speech Language Pathologist', NULL),
(60, 'Sports Medicine', NULL),
(61, 'Thoracic Surgery', NULL),
(62, 'Urology', NULL),
(63, 'Vascular Surgery', NULL);
GO

-- ---- ZC_STATE (standard: 50 states + DC) ----
INSERT INTO ZC_STATE (STATE_C, NAME, ABBR) VALUES
(1, 'Alabama', 'AL'), (2, 'Alaska', 'AK'), (3, 'Arizona', 'AZ'),
(4, 'Arkansas', 'AR'), (5, 'California', 'CA'), (6, 'Colorado', 'CO'),
(7, 'Connecticut', 'CT'), (8, 'Delaware', 'DE'),
(9, 'District of Columbia', 'DC'), (10, 'Florida', 'FL'),
(11, 'Georgia', 'GA'), (12, 'Hawaii', 'HI'), (13, 'Idaho', 'ID'),
(14, 'Illinois', 'IL'), (15, 'Indiana', 'IN'), (16, 'Iowa', 'IA'),
(17, 'Kansas', 'KS'), (18, 'Kentucky', 'KY'), (19, 'Louisiana', 'LA'),
(20, 'Maine', 'ME'), (21, 'Maryland', 'MD'), (22, 'Massachusetts', 'MA'),
(23, 'Michigan', 'MI'), (24, 'Minnesota', 'MN'), (25, 'Mississippi', 'MS'),
(26, 'Missouri', 'MO'), (27, 'Montana', 'MT'), (28, 'Nebraska', 'NE'),
(29, 'Nevada', 'NV'), (30, 'New Hampshire', 'NH'), (31, 'New Jersey', 'NJ'),
(32, 'New Mexico', 'NM'), (33, 'New York', 'NY'),
(34, 'North Carolina', 'NC'), (35, 'North Dakota', 'ND'),
(36, 'Ohio', 'OH'), (37, 'Oklahoma', 'OK'), (38, 'Oregon', 'OR'),
(39, 'Pennsylvania', 'PA'), (40, 'Rhode Island', 'RI'),
(41, 'South Carolina', 'SC'), (42, 'South Dakota', 'SD'),
(43, 'Tennessee', 'TN'), (44, 'Texas', 'TX'), (45, 'Utah', 'UT'),
(46, 'Vermont', 'VT'), (47, 'Virginia', 'VA'), (48, 'Washington', 'WA'),
(49, 'West Virginia', 'WV'), (50, 'Wisconsin', 'WI'), (51, 'Wyoming', 'WY');
GO

-- ---- ZC_PAYOR_TYPE (standard payor types) ----
INSERT INTO ZC_PAYOR_TYPE (PAYOR_TYPE_C, NAME, ABBR) VALUES
(1, 'Commercial', 'COMM'),
(2, 'Medicare', 'MCARE'),
(3, 'Medicaid', 'MCAID'),
(4, 'Self-Pay', 'SELF'),
(5, 'Other Government', 'GOVT'),
(6, 'Workers Compensation', 'WC');
GO


-- ================================================================
-- PART 2 - STANDARD-DRIVEN TABLES (standard healthcare/Epic values)
-- ================================================================

-- ---- Encounter / hospital lookups ----
INSERT INTO ZC_APPT_STATUS (APPT_STATUS_C, NAME, ABBR) VALUES
(1, 'Scheduled', 'SCH'), (2, 'Completed', 'COMP'), (3, 'Canceled', 'CANC'),
(4, 'No Show', 'NOSHOW'), (5, 'Arrived', 'ARR'), (6, 'In Progress', 'INPROG');
GO

INSERT INTO ZC_CANCEL_REASON (CANCEL_REASON_C, NAME, ABBR) VALUES
(1, 'Patient Request', 'PT'), (2, 'Provider Unavailable', 'PROV'),
(3, 'Rescheduled', 'RESCH'), (4, 'Weather', 'WX'), (5, 'Other', 'OTH');
GO

INSERT INTO ZC_LEVEL_OF_SERVICE (LEVEL_OF_SERVICE_C, NAME, ABBR) VALUES
(1, 'Level 1 - Minimal', 'L1'), (2, 'Level 2 - Low', 'L2'),
(3, 'Level 3 - Moderate', 'L3'), (4, 'Level 4 - Moderate-High', 'L4'),
(5, 'Level 5 - High', 'L5');
GO

INSERT INTO ZC_HOSP_ADMSN_TYPE (HOSP_ADMSN_TYPE_C, NAME, ABBR) VALUES
(1, 'Emergency', 'EMER'), (2, 'Urgent', 'URG'), (3, 'Elective', 'ELEC'),
(4, 'Newborn', 'NEWB'), (5, 'Trauma', 'TRAU');
GO

INSERT INTO ZC_ADM_SOURCE (ADM_SOURCE_C, NAME, ABBR) VALUES
(1, 'Physician Referral', 'PHYS'), (2, 'Emergency Room', 'ER'),
(3, 'Transfer from Hospital', 'XFER'), (4, 'Clinic Referral', 'CLIN'),
(5, 'Other', 'OTH');
GO

INSERT INTO ZC_PAT_CLASS (ADT_PAT_CLASS_C, NAME, ABBR) VALUES
(1, 'Inpatient', 'INP'), (2, 'Outpatient', 'OUTP'),
(3, 'Observation', 'OBS'), (4, 'Emergency', 'EMER'),
(5, 'Day Surgery', 'DAYSURG');
GO

INSERT INTO ZC_DISCH_DISP (DISCH_DISP_C, NAME, ABBR) VALUES
(1, 'Home / Self Care', 'HOME'), (2, 'Transfer to SNF', 'SNF'),
(3, 'Transfer to Another Hospital', 'XFER'), (4, 'Home Health Care', 'HHC'),
(5, 'Left Against Medical Advice', 'AMA'), (6, 'Expired', 'EXP'),
(7, 'Hospice', 'HOSP');
GO

INSERT INTO ZC_DISCH_DEST (DISCH_DEST_C, NAME, ABBR) VALUES
(1, 'Home', 'HOME'), (2, 'Skilled Nursing Facility', 'SNF'),
(3, 'Rehabilitation Facility', 'REHAB'), (4, 'Another Acute Hospital', 'ACUTE'),
(5, 'Hospice Facility', 'HOSP'), (6, 'Other', 'OTH');
GO

INSERT INTO ZC_HOSP_SERV (HOSP_SERV_C, NAME, ABBR) VALUES
(1, 'Medicine', 'MED'), (2, 'Surgery', 'SURG'), (3, 'Obstetrics', 'OB'),
(4, 'Pediatrics', 'PEDS'), (5, 'Cardiology', 'CARD'),
(6, 'Orthopedics', 'ORTHO'), (7, 'Critical Care', 'CCU');
GO

INSERT INTO ZC_ACCOMMODATION (ACCOMMODATION_C, NAME, ABBR) VALUES
(1, 'Private Room', 'PVT'), (2, 'Semi-Private Room', 'SEMI'),
(3, 'Ward', 'WARD'), (4, 'Intensive Care', 'ICU');
GO

-- ---- Problem list lookups ----
INSERT INTO ZC_PROBLEM_STATUS (PROBLEM_STATUS_C, NAME, ABBR) VALUES
(1, 'Active', 'ACT'), (2, 'Resolved', 'RES'), (3, 'Inactive', 'INACT');
GO

INSERT INTO ZC_PRIORITY (PRIORITY_C, NAME, ABBR) VALUES
(1, 'Routine', 'ROUT'), (2, 'Urgent', 'URG'), (3, 'STAT', 'STAT'),
(4, 'ASAP', 'ASAP');
GO

-- ---- Order / medication / lab lookups ----
INSERT INTO ZC_DOSE_UNIT (DOSE_UNIT_C, NAME, ABBR) VALUES
(1, 'Milligram', 'MG'), (2, 'Gram', 'G'), (3, 'Milliliter', 'ML'),
(4, 'Microgram', 'MCG'), (5, 'Unit', 'UNIT'), (6, 'Tablet', 'TAB'),
(7, 'Capsule', 'CAP');
GO

INSERT INTO ZC_FREQUENCY (FREQUENCY_C, NAME, ABBR) VALUES
(1, 'Once Daily', 'QD'), (2, 'Twice Daily', 'BID'),
(3, 'Three Times Daily', 'TID'), (4, 'Four Times Daily', 'QID'),
(5, 'Every Hour', 'Q1H'), (6, 'As Needed', 'PRN'), (7, 'At Bedtime', 'QHS');
GO

INSERT INTO ZC_ROUTE (ROUTE_C, NAME, ABBR) VALUES
(1, 'Oral', 'PO'), (2, 'Intravenous', 'IV'), (3, 'Intramuscular', 'IM'),
(4, 'Subcutaneous', 'SUBQ'), (5, 'Topical', 'TOP'), (6, 'Inhalation', 'INH'),
(7, 'Rectal', 'PR');
GO

INSERT INTO ZC_ORDER_STATUS (ORDER_STATUS_C, NAME, ABBR) VALUES
(1, 'Active', 'ACT'), (2, 'Completed', 'COMP'), (3, 'Discontinued', 'DC'),
(4, 'Pending', 'PEND'), (5, 'Canceled', 'CANC'), (6, 'On Hold', 'HOLD');
GO

INSERT INTO ZC_ORDER_TYPE (ORDER_TYPE_C, NAME, ABBR) VALUES
(1, 'Medication', 'MED'), (2, 'Laboratory', 'LAB'), (3, 'Imaging', 'IMG'),
(4, 'Procedure', 'PROC'), (5, 'Referral', 'REF'), (6, 'Nursing', 'NURS');
GO

INSERT INTO ZC_DISCONTINUED_REASON (DISCONTINUED_REASON_C, NAME, ABBR) VALUES
(1, 'Therapy Complete', 'COMP'), (2, 'Adverse Reaction', 'ADV'),
(3, 'Ineffective', 'INEFF'), (4, 'Patient Request', 'PT'),
(5, 'Provider Decision', 'PROV'), (6, 'Other', 'OTH');
GO

INSERT INTO ZC_PROC_CATEGORY (PROC_CATEGORY_C, NAME, ABBR) VALUES
(1, 'Laboratory', 'LAB'), (2, 'Imaging', 'IMG'), (3, 'Surgical', 'SURG'),
(4, 'Diagnostic', 'DIAG'), (5, 'Therapeutic', 'THER'),
(6, 'Preventive', 'PREV');
GO

INSERT INTO ZC_RESULT_STATUS (RESULT_STATUS_C, NAME, ABBR) VALUES
(1, 'Final', 'FINAL'), (2, 'Preliminary', 'PREL'), (3, 'Pending', 'PEND'),
(4, 'Corrected', 'CORR'), (5, 'Canceled', 'CANC');
GO

INSERT INTO ZC_SPECIMEN_TYPE (SPECIMEN_TYPE_C, NAME, ABBR) VALUES
(1, 'Blood', 'BLD'), (2, 'Urine', 'UR'), (3, 'Serum', 'SER'),
(4, 'Tissue', 'TIS'), (5, 'Swab', 'SWAB'), (6, 'Other', 'OTH');
GO

INSERT INTO ZC_BODY_SITE (BODY_SITE_C, NAME, ABBR) VALUES
(1, 'Head', 'HEAD'), (2, 'Chest', 'CHEST'), (3, 'Abdomen', 'ABD'),
(4, 'Upper Extremity', 'UE'), (5, 'Lower Extremity', 'LE'),
(6, 'Back', 'BACK'), (7, 'Other', 'OTH');
GO

INSERT INTO ZC_LATERALITY (LATERALITY_C, NAME, ABBR) VALUES
(1, 'Left', 'L'), (2, 'Right', 'R'), (3, 'Bilateral', 'BIL'),
(4, 'Not Applicable', 'NA');
GO

INSERT INTO ZC_ORD_VALUE (ORD_VALUE_C, NAME, ABBR) VALUES
(1, 'Positive', 'POS'), (2, 'Negative', 'NEG'), (3, 'Normal', 'NORM'),
(4, 'Abnormal', 'ABN'), (5, 'Inconclusive', 'INC');
GO

INSERT INTO ZC_ABNORMAL_FLAG (ABNORMAL_FLAG_C, NAME, ABBR) VALUES
(1, 'Normal', 'N'), (2, 'High', 'H'), (3, 'Low', 'L'),
(4, 'Critical High', 'HH'), (5, 'Critical Low', 'LL'),
(6, 'Abnormal', 'A');
GO

-- ---- Reference layer lookups ----
INSERT INTO ZC_DEPT_TYPE (DEPT_TYPE_C, NAME, ABBR) VALUES
(1, 'Inpatient Unit', 'INP'), (2, 'Outpatient Clinic', 'OUTP'),
(3, 'Emergency Department', 'ED'), (4, 'Surgical Suite', 'SURG'),
(5, 'Diagnostic', 'DIAG'), (6, 'Ancillary', 'ANC');
GO

INSERT INTO ZC_LOC_TYPE (LOC_TYPE_C, NAME, ABBR) VALUES
(1, 'Hospital', 'HOSP'), (2, 'Clinic', 'CLIN'),
(3, 'Ambulatory Surgery Center', 'ASC'), (4, 'Urgent Care', 'URG'),
(5, 'Other', 'OTH');
GO

INSERT INTO ZC_TIME_ZONE (TIME_ZONE_C, NAME, ABBR) VALUES
(1, 'Eastern', 'ET'), (2, 'Central', 'CT'), (3, 'Mountain', 'MT'),
(4, 'Pacific', 'PT'), (5, 'Alaska', 'AKT'), (6, 'Hawaii', 'HT');
GO

INSERT INTO ZC_FINANCIAL_CLASS (FINANCIAL_CLASS_C, NAME, ABBR) VALUES
(1, 'Commercial', 'COMM'), (2, 'Medicare', 'MCARE'),
(3, 'Medicaid', 'MCAID'), (4, 'Self-Pay', 'SELF'),
(5, 'Workers Compensation', 'WC'), (6, 'Other', 'OTH');
GO

INSERT INTO ZC_PAYOR_GROUP (PAYOR_GROUP_C, NAME, ABBR) VALUES
(1, 'Government', 'GOVT'), (2, 'Private Insurance', 'PRIV'),
(3, 'Managed Care', 'MC'), (4, 'Self-Pay', 'SELF');
GO

-- ---- Financial layer lookups ----
INSERT INTO ZC_ACCT_BASECLS (ACCT_BASECLS_HA_C, NAME, ABBR) VALUES
(1, 'Inpatient', 'INP'), (2, 'Outpatient', 'OUTP'),
(3, 'Emergency', 'EMER'), (4, 'Observation', 'OBS');
GO

INSERT INTO ZC_ACCT_STATUS (ACCT_STATUS_C, NAME, ABBR) VALUES
(1, 'Open', 'OPEN'), (2, 'Closed', 'CLOSED'), (3, 'Billed', 'BILLED'),
(4, 'In Collections', 'COLL'), (5, 'Bad Debt', 'BADDEBT');
GO

INSERT INTO ZC_BILLING_STATUS (BILLING_STATUS_C, NAME, ABBR) VALUES
(1, 'Not Billed', 'NOTBILL'), (2, 'Billed', 'BILLED'),
(3, 'Paid', 'PAID'), (4, 'Partially Paid', 'PARTPAID'),
(5, 'Denied', 'DENIED'), (6, 'In Appeal', 'APPEAL');
GO

INSERT INTO ZC_CHARGE_STATUS (CHARGE_STATUS_C, NAME, ABBR) VALUES
(1, 'Posted', 'POST'), (2, 'Pending', 'PEND'), (3, 'Reversed', 'REV'),
(4, 'Billed', 'BILLED'), (5, 'Paid', 'PAID');
GO

INSERT INTO ZC_REVERSAL_REASON (REVERSAL_REASON_C, NAME, ABBR) VALUES
(1, 'Billing Error', 'ERR'), (2, 'Duplicate Charge', 'DUP'),
(3, 'Service Not Rendered', 'NOSVC'), (4, 'Coding Correction', 'CODE'),
(5, 'Other', 'OTH');
GO

INSERT INTO ZC_PLACE_OF_SERVICE (PLACE_OF_SERVICE_C, NAME, ABBR) VALUES
(1, 'Office', 'OFF'), (2, 'Inpatient Hospital', 'INP'),
(3, 'Outpatient Hospital', 'OUTP'), (4, 'Emergency Room', 'ER'),
(5, 'Ambulatory Surgical Center', 'ASC'), (6, 'Home', 'HOME'),
(7, 'Telehealth', 'TELE');
GO

INSERT INTO ZC_BILL_TYPE (BILL_TYPE_C, NAME, ABBR) VALUES
(1, 'Inpatient Hospital', 'INP'), (2, 'Outpatient Hospital', 'OUTP'),
(3, 'Professional', 'PROF'), (4, 'Emergency', 'EMER');
GO

INSERT INTO ZC_CLAIM_STATUS (CLAIM_STATUS_C, NAME, ABBR) VALUES
(1, 'Submitted', 'SUB'), (2, 'In Process', 'PROC'), (3, 'Paid', 'PAID'),
(4, 'Denied', 'DENIED'), (5, 'Partially Paid', 'PARTPAID'),
(6, 'Appealed', 'APPEAL'), (7, 'Closed', 'CLOSED');
GO

INSERT INTO ZC_CLAIM_TYPE (CLAIM_TYPE_C, NAME, ABBR) VALUES
(1, 'Institutional', 'INST'), (2, 'Professional', 'PROF'),
(3, 'Dental', 'DENT'), (4, 'Pharmacy', 'RX');
GO

INSERT INTO ZC_CLAIM_SEQUENCE (CLAIM_SEQUENCE_C, NAME, ABBR) VALUES
(1, 'Primary', 'PRIM'), (2, 'Secondary', 'SEC'), (3, 'Tertiary', 'TERT');
GO

INSERT INTO ZC_REJECTION_REASON (REJECTION_REASON_C, NAME, ABBR) VALUES
(1, 'Invalid Patient Information', 'PTINFO'),
(2, 'Missing Authorization', 'AUTH'),
(3, 'Invalid Procedure Code', 'PROC'),
(4, 'Coverage Terminated', 'COVTERM'), (5, 'Other', 'OTH');
GO

INSERT INTO ZC_APPEAL_STATUS (APPEAL_STATUS_C, NAME, ABBR) VALUES
(1, 'Not Appealed', 'NONE'), (2, 'Appeal Filed', 'FILED'),
(3, 'Appeal Approved', 'APPR'), (4, 'Appeal Denied', 'DEN'),
(5, 'Appeal Pending', 'PEND');
GO

INSERT INTO ZC_PAYMENT_SOURCE (PAYMENT_SOURCE_C, NAME, ABBR) VALUES
(1, 'Insurance', 'INS'), (2, 'Patient', 'PT'),
(3, 'Government Program', 'GOVT'), (4, 'Other', 'OTH');
GO

INSERT INTO ZC_PAYMENT_TYPE (PAYMENT_TYPE_C, NAME, ABBR) VALUES
(1, 'Insurance Payment', 'INSPAY'), (2, 'Patient Payment', 'PTPAY'),
(3, 'Adjustment', 'ADJ'), (4, 'Refund', 'REFUND'),
(5, 'Write-Off', 'WRITEOFF');
GO

INSERT INTO ZC_PAYMENT_METHOD (PAYMENT_METHOD_C, NAME, ABBR) VALUES
(1, 'Check', 'CHK'), (2, 'Electronic Funds Transfer', 'EFT'),
(3, 'Credit Card', 'CC'), (4, 'Cash', 'CASH'), (5, 'Other', 'OTH');
GO

INSERT INTO ZC_TX_TYPE (TX_TYPE_C, NAME, ABBR) VALUES
(1, 'Charge', 'CHG'), (2, 'Payment', 'PMT'), (3, 'Adjustment', 'ADJ'),
(4, 'Refund', 'REF'), (5, 'Transfer', 'XFER');
GO

INSERT INTO ZC_DENIAL_REASON (DENIAL_REASON_C, NAME, ABBR) VALUES
(1, 'Not Medically Necessary', 'NOTMED'),
(2, 'Service Not Covered', 'NOTCOV'),
(3, 'Authorization Required', 'AUTH'),
(4, 'Duplicate Claim', 'DUP'),
(5, 'Timely Filing Exceeded', 'TIMELY'), (6, 'Other', 'OTH');
GO

INSERT INTO ZC_VOID_REASON (VOID_REASON_C, NAME, ABBR) VALUES
(1, 'Entered in Error', 'ERR'), (2, 'Duplicate', 'DUP'),
(3, 'Patient Cancellation', 'PTCANC'), (4, 'Other', 'OTH');
GO

-- ================================================================
-- End of 01_populate_zc.sql  -  60 ZC_ tables populated
-- ================================================================