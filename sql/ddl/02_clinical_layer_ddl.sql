-- ============================================================
-- Script:        02_clinical_layer_ddl.sql
-- Purpose:       Create clinical tables for mini-Clarity
--                (patients, encounters, hospital admissions, 
--                 problems, orders, lab results)
-- Project:       Epic Clarity-Style Clinical Reporting Platform
-- Author:        Prakash Pyakurel
-- Created:       2026-05-13
-- Database:      EpicClaritySim
-- Dependencies:  Requires 01_reference_layer_ddl.sql to be run first
--                (FK references to CLARITY_DEP, CLARITY_LOC,
--                 CLARITY_SER, CLARITY_PAYOR, ZC_* tables)
-- Tables Created:
--   PATIENT, PAT_ENC, PAT_ENC_HSP, PROBLEM_LIST, ORDER_MED, 
--   ORDER_PROC, LAB_RESULTS
-- ============================================================

USE EpicClaritySim;
GO

CREATE TABLE PATIENT (
    PAT_ID                INT             NOT NULL PRIMARY KEY,
    PAT_MRN_ID            VARCHAR(20)     NOT NULL,
    PAT_FIRST_NAME        VARCHAR(100)    NULL,
    PAT_MIDDLE_NAME       VARCHAR(100)    NULL,
    PAT_LAST_NAME         VARCHAR(100)    NULL,
    PAT_SUFFIX            VARCHAR(20)     NULL,
    PAT_MAIDEN_NAME       VARCHAR(100)    NULL,
    BIRTH_DATE            DATE            NULL,
    DEATH_DATE            DATE            NULL,
    DECEASED_YN           CHAR(1)         NOT NULL DEFAULT 'N',
    SEX_C                 INT             NULL,
    MARITAL_STATUS_C      INT             NULL,
    RACE_C                INT             NULL,
    ETHNICITY_C           INT             NULL,
    PAT_STATUS_C          INT             NULL,
    PRIMARY_LANGUAGE_C    INT             NULL,
    INTERP_NEEDED_YN      CHAR(1)         NOT NULL DEFAULT 'N',
    ADD_LINE_1            VARCHAR(200)    NULL,
    ADD_LINE_2            VARCHAR(200)    NULL,
    CITY                  VARCHAR(100)    NULL,
    STATE_C               INT             NULL,
    ZIP                   VARCHAR(10)     NULL,
    COUNTY                VARCHAR(100)    NULL,
    COUNTRY_C             INT             NULL,
    HOME_PHONE            VARCHAR(20)     NULL,
    WORK_PHONE            VARCHAR(20)     NULL,
    MOBILE_PHONE          VARCHAR(20)     NULL,
    EMAIL_ADDRESS         VARCHAR(200)    NULL,
    SSN                   VARCHAR(11)     NULL,
    PCP_PROV_ID           VARCHAR(18)     NULL,
    REG_DATE              DATE            NULL,
    ACTIVE_YN             CHAR(1)         NOT NULL DEFAULT 'Y',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO


CREATE TABLE PAT_ENC (
    PAT_ENC_CSN_ID        BIGINT          NOT NULL PRIMARY KEY,
    PAT_ID                INT             NOT NULL,
    CONTACT_DATE          DATE            NOT NULL,
    ENC_TYPE_C            INT             NULL,
    DEPARTMENT_ID         INT             NULL,
    LOCATION_ID           INT             NULL,
    VISIT_PROV_ID         VARCHAR(18)     NULL,
    REFERRING_PROV_ID     VARCHAR(18)     NULL,
    PRIMARY_PAYOR_ID      INT             NULL,
    APPT_TIME             DATETIME2       NULL,
    APPT_LENGTH           INT             NULL,
    CHECKIN_DTTM          DATETIME2       NULL,
    ROOM_DTTM             DATETIME2       NULL,
    PROV_ENTER_DTTM       DATETIME2       NULL,
    CHECKOUT_DTTM         DATETIME2       NULL,
    ENC_CLOSED_YN         CHAR(1)         NOT NULL DEFAULT 'N',
    APPT_STATUS_C         INT             NULL,
    CANCEL_REASON_C       INT             NULL,
    NO_SHOW_YN            CHAR(1)         NOT NULL DEFAULT 'N',
    CHIEF_COMPLAINT       VARCHAR(500)    NULL,
    VISIT_TYPE_C          INT             NULL,
    LEVEL_OF_SERVICE_C    INT             NULL,
    HOSP_ADMSN_TYPE_C     INT             NULL,
    BP_SYSTOLIC           INT             NULL,
    BP_DIASTOLIC          INT             NULL,
    TEMPERATURE           DECIMAL(4,1)    NULL,
    PULSE                 INT             NULL,
    RESPIRATIONS          INT             NULL,
    HEIGHT_CM             DECIMAL(5,1)    NULL,
    WEIGHT_KG             DECIMAL(5,2)    NULL,
    BMI                   DECIMAL(4,1)    NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE PAT_ENC_HSP (
    PAT_ENC_CSN_ID        BIGINT          NOT NULL PRIMARY KEY,
    PAT_ID                INT             NOT NULL,
    HOSP_ADMSN_TIME       DATETIME2       NULL,
    HOSP_DISCH_TIME       DATETIME2       NULL,
    INP_ADM_DATE          DATE            NULL,
    OBS_ADMIT_DTTM        DATETIME2       NULL,
    ADM_SOURCE_C          INT             NULL,
    ADM_TYPE_C            INT             NULL,
    ADT_PAT_CLASS_C       INT             NULL,
    DISCH_DISP_C          INT             NULL,
    DISCH_DEPT_ID         INT             NULL,
    DISCH_DEST_C          INT             NULL,
    ADT_ARRIVAL_TIME      DATETIME2       NULL,
    ED_ARRIVAL_TIME       DATETIME2       NULL,
    ED_DEPARTURE_TIME     DATETIME2       NULL,
    HOSP_SERV_C           INT             NULL,
    ADMITTING_PROV_ID     VARCHAR(18)     NULL,
    ATTENDING_PROV_ID     VARCHAR(18)     NULL,
    DISCH_PROV_ID         VARCHAR(18)     NULL,
    DRG_ID                INT             NULL,
    ACCOMMODATION_C       INT             NULL,
    LOS_HRS               DECIMAL(8,2)    NULL,
    EXPECTED_LOS          DECIMAL(8,2)    NULL,
    READMIT_FLAG_YN       CHAR(1)         NOT NULL DEFAULT 'N',
    DEATH_DURING_STAY_YN  CHAR(1)         NOT NULL DEFAULT 'N',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE PROBLEM_LIST (
    PROBLEM_LIST_ID       BIGINT          NOT NULL,
    PAT_ID                INT             NOT NULL,
    DX_ID                 INT             NULL,
    SNOMED_CODE           VARCHAR(20)     NULL,
    ICD10_CODE            VARCHAR(20)     NULL,
    PROBLEM_DESCRIPTION   VARCHAR(500)    NULL,
    NOTED_DATE            DATE            NULL,
    RESOLVED_DATE         DATE            NULL,
    PROBLEM_STATUS_C      INT             NULL,
    CHRONIC_YN            CHAR(1)         NOT NULL DEFAULT 'N',
    PRINCIPAL_PR_YN       CHAR(1)         NOT NULL DEFAULT 'N',
    PRIORITY_C            INT             NULL,
    NOTED_PROV_ID         VARCHAR(18)     NULL,
    DIAG_ENC_CSN_ID       BIGINT          NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL,
    PRIMARY KEY (PAT_ID, PROBLEM_LIST_ID)
);
GO

CREATE TABLE ORDER_MED (
    ORDER_MED_ID          BIGINT          NOT NULL PRIMARY KEY,
    PAT_ID                INT             NOT NULL,
    PAT_ENC_CSN_ID        BIGINT          NULL,
    MEDICATION_ID         INT             NULL,
    RXNORM_CODE           VARCHAR(20)     NULL,
    MEDICATION_NAME       VARCHAR(500)    NULL,
    DOSE                  DECIMAL(10,3)   NULL,
    DOSE_UNIT_C           INT             NULL,
    FREQUENCY_C           INT             NULL,
    ROUTE_C               INT             NULL,
    ORDER_STATUS_C        INT             NULL,
    ORDER_TYPE_C          INT             NULL,
    ORDERING_DATE         DATETIME2       NULL,
    START_DATE            DATE            NULL,
    END_DATE              DATE            NULL,
    REFILLS_REMAINING     INT             NULL,
    REFILLS_ORIGINAL      INT             NULL,
    QUANTITY              DECIMAL(10,2)   NULL,
    AUTHRZING_PROV_ID     VARCHAR(18)     NULL,
    ORDERING_PROV_ID      VARCHAR(18)     NULL,
    PHARMACY_ID           INT             NULL,
    DISCONTINUED_DATE     DATETIME2       NULL,
    DISCONTINUED_REASON_C INT             NULL,
    REASON_FOR_ORDER      VARCHAR(500)    NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO


CREATE TABLE ORDER_PROC (
    ORDER_PROC_ID         BIGINT          NOT NULL PRIMARY KEY,
    PAT_ID                INT             NOT NULL,
    PAT_ENC_CSN_ID        BIGINT          NULL,
    PROC_ID               INT             NULL,
    CPT_CODE              VARCHAR(10)     NULL,
    SNOMED_CODE           VARCHAR(20)     NULL,
    PROC_NAME             VARCHAR(500)    NULL,
    PROC_CATEGORY_C       INT             NULL,
    IS_LAB_YN             CHAR(1)         NOT NULL DEFAULT 'N',
    IS_IMAGING_YN         CHAR(1)         NOT NULL DEFAULT 'N',
    ORDER_STATUS_C        INT             NULL,
    RESULT_STATUS_C       INT             NULL,
    ORDER_TYPE_C          INT             NULL,
    ORDERING_DATE         DATETIME2       NULL,
    SCHEDULED_DATE        DATETIME2       NULL,
    RESULT_DATE           DATETIME2       NULL,
    SPECIMEN_TYPE_C       INT             NULL,
    SPECIMEN_TAKEN_DTTM   DATETIME2       NULL,
    BODY_SITE_C           INT             NULL,
    LATERALITY_C          INT             NULL,
    AUTHRZING_PROV_ID     VARCHAR(18)     NULL,
    ORDERING_PROV_ID      VARCHAR(18)     NULL,
    PERFORMING_PROV_ID    VARCHAR(18)     NULL,
    REASON_FOR_ORDER      VARCHAR(500)    NULL,
    DIAGNOSIS_CODE        VARCHAR(20)     NULL,
    PRIORITY_C            INT             NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO


CREATE TABLE LAB_RESULTS (
    RESULT_ID             BIGINT          NOT NULL PRIMARY KEY,
    PAT_ID                INT             NOT NULL,
    PAT_ENC_CSN_ID        BIGINT          NULL,
    ORDER_PROC_ID         BIGINT          NULL,
    COMPONENT_ID          INT             NULL,
    LOINC_CODE            VARCHAR(20)     NULL,
    COMPONENT_NAME        VARCHAR(500)    NULL,
    ORD_VALUE             VARCHAR(500)    NULL,
    ORD_NUM_VALUE         DECIMAL(20,5)   NULL,
    ORD_VALUE_C           INT             NULL,
    REFERENCE_LOW         VARCHAR(50)     NULL,
    REFERENCE_HIGH        VARCHAR(50)     NULL,
    REFERENCE_UNIT        VARCHAR(50)     NULL,
    ABNORMAL_FLAG_C       INT             NULL,
    RESULT_STATUS_C       INT             NULL,
    SPECIMEN_TYPE_C       INT             NULL,
    SPECIMEN_TAKEN_DTTM   DATETIME2       NULL,
    RESULT_DATE           DATETIME2       NULL,
    RESULT_TIME           DATETIME2       NULL,
    RESULTING_LAB_ID      INT             NULL,
    PERFORMING_PROV_ID    VARCHAR(18)     NULL,
    RESULTED_BY_USER_ID   VARCHAR(18)     NULL,
    COMMENTS              VARCHAR(2000)   NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO