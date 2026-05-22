-- ============================================================
-- Script:        03_financial_layer_ddl.sql
-- Purpose:       Create financial/revenue cycle tables for mini-Clarity
-- Project:       Epic Clarity-Style Clinical Reporting Platform
-- Author:        Prakash Pyakurel
-- Created:       2026-05-13
-- Database:      EpicClaritySim
-- Dependencies:  Requires reference and clinical layer DDL to be run first
--                (FK references to PATIENT, PAT_ENC, PAT_ENC_HSP,
--                 CLARITY_PAYOR, CLARITY_SER, CLARITY_DEP)
-- Tables Created:
--   HSP_ACCOUNT, CHARGE_DETAIL, ARPB_TRANSACTIONS,
--   CLAIM_INFO, PAYMENT_DETAIL
-- ============================================================

USE EpicClaritySim;
GO

CREATE TABLE HSP_ACCOUNT (
    HSP_ACCOUNT_ID        BIGINT          NOT NULL PRIMARY KEY,
    PRIM_ENC_CSN_ID       BIGINT          NULL,
    PAT_ID                INT             NOT NULL,
    GUARANTOR_ID          INT             NULL,
    ACCT_BASECLS_HA_C     INT             NULL,
    ACCT_STATUS_C         INT             NULL,
    BILLING_STATUS_C      INT             NULL,
    FINANCIAL_CLASS_C     INT             NULL,
    PRIMARY_PAYOR_ID      INT             NULL,
    SECONDARY_PAYOR_ID    INT             NULL,
    ADMIT_DATE            DATE            NULL,
    DISCH_DATE            DATE            NULL,
    ACCT_CLOSE_DATE       DATE            NULL,
    TOT_CHGS              DECIMAL(15,2)   NULL,
    TOT_PMTS              DECIMAL(15,2)   NULL,
    TOT_ADJUSTMENTS       DECIMAL(15,2)   NULL,
    TOT_ACCT_BAL          DECIMAL(15,2)   NULL,
    TOT_INS_BAL           DECIMAL(15,2)   NULL,
    TOT_PAT_BAL           DECIMAL(15,2)   NULL,
    DRG_ID                INT             NULL,
    HOSP_SERV_C           INT             NULL,
    DISCH_DISP_C          INT             NULL,
    BILL_DROP_DATE        DATE            NULL,
    LAST_PMT_DATE         DATE            NULL,
    DAYS_IN_AR            INT             NULL,
    IN_COLLECTIONS_YN     CHAR(1)         NOT NULL DEFAULT 'N',
    BAD_DEBT_YN           CHAR(1)         NOT NULL DEFAULT 'N',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE CHARGE_DETAIL (
    CHARGE_ID             BIGINT          NOT NULL PRIMARY KEY,
    HSP_ACCOUNT_ID        BIGINT          NOT NULL,
    PAT_ID                INT             NOT NULL,
    PAT_ENC_CSN_ID        BIGINT          NULL,
    CHARGE_CODE_ID        INT             NULL,
    CPT_CODE              VARCHAR(10)     NULL,
    REVENUE_CODE          VARCHAR(10)     NULL,
    HCPCS_CODE            VARCHAR(10)     NULL,
    CHARGE_DESCRIPTION    VARCHAR(500)    NULL,
    DEPARTMENT_ID         INT             NULL,
    PERFORMING_PROV_ID    VARCHAR(18)     NULL,
    SERVICE_DATE          DATE            NULL,
    POST_DATE             DATE            NULL,
    QUANTITY              DECIMAL(10,3)   NULL,
    UNIT_PRICE            DECIMAL(15,2)   NULL,
    CHARGE_AMOUNT         DECIMAL(15,2)   NULL,
    ALLOWED_AMOUNT        DECIMAL(15,2)   NULL,
    CONTRACTUAL_ADJ       DECIMAL(15,2)   NULL,
    CHARGE_STATUS_C       INT             NULL,
    REVERSED_YN           CHAR(1)         NOT NULL DEFAULT 'N',
    REVERSAL_REASON_C     INT             NULL,
    MODIFIER_1            VARCHAR(10)     NULL,
    MODIFIER_2            VARCHAR(10)     NULL,
    PLACE_OF_SERVICE_C    INT             NULL,
    DIAGNOSIS_POINTER     VARCHAR(20)     NULL,
    BILL_TYPE_C           INT             NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE ARPB_TRANSACTIONS (
    TX_ID                 BIGINT          NOT NULL PRIMARY KEY,
    ARPB_VISIT_ID         BIGINT          NULL,
    PAT_ID                INT             NOT NULL,
    PAT_ENC_CSN_ID        BIGINT          NULL,
    HSP_ACCOUNT_ID        BIGINT          NULL,
    TX_TYPE_C             INT             NULL,
    TX_AMOUNT             DECIMAL(15,2)   NULL,
    CPT_CODE              VARCHAR(10)     NULL,
    HCPCS_CODE            VARCHAR(10)     NULL,
    PROCEDURE_DESC        VARCHAR(500)    NULL,
    SERVICE_FROM_DATE     DATE            NULL,
    SERVICE_TO_DATE       DATE            NULL,
    POST_DATE             DATE            NULL,
    BILLING_PROV_ID       VARCHAR(18)     NULL,
    SUPERVISING_PROV_ID   VARCHAR(18)     NULL,
    DEPARTMENT_ID         INT             NULL,
    LOCATION_ID           INT             NULL,
    PAYOR_ID              INT             NULL,
    PLACE_OF_SERVICE_C    INT             NULL,
    MODIFIER_1            VARCHAR(10)     NULL,
    MODIFIER_2            VARCHAR(10)     NULL,
    DIAGNOSIS_CODE_1      VARCHAR(20)     NULL,
    DIAGNOSIS_CODE_2      VARCHAR(20)     NULL,
    UNITS                 DECIMAL(10,3)   NULL,
    RVU_WORK              DECIMAL(10,4)   NULL,
    RVU_PE                DECIMAL(10,4)   NULL,
    RVU_MP                DECIMAL(10,4)   NULL,
    RVU_TOTAL             DECIMAL(10,4)   NULL,
    ALLOWED_AMOUNT        DECIMAL(15,2)   NULL,
    CONTRACTUAL_ADJ       DECIMAL(15,2)   NULL,
    DENIED_YN             CHAR(1)         NOT NULL DEFAULT 'N',
    DENIAL_REASON_C       INT             NULL,
    VOID_YN               CHAR(1)         NOT NULL DEFAULT 'N',
    VOID_REASON_C         INT             NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE CLAIM_INFO (
    CLAIM_ID              BIGINT          NOT NULL PRIMARY KEY,
    HSP_ACCOUNT_ID        BIGINT          NOT NULL,
    PAT_ID                INT             NOT NULL,
    PAYOR_ID              INT             NULL,
    CLAIM_STATUS_C        INT             NULL,
    CLAIM_TYPE_C          INT             NULL,
    CLAIM_SEQUENCE_C      INT             NULL,
    BILL_TYPE_CODE        VARCHAR(10)     NULL,
    PAYOR_CLAIM_NUMBER    VARCHAR(50)     NULL,
    SERVICE_FROM_DATE     DATE            NULL,
    SERVICE_TO_DATE       DATE            NULL,
    CLAIM_SUBMITTED_DATE  DATE            NULL,
    CLAIM_RECEIVED_DATE   DATE            NULL,
    CLAIM_PROCESSED_DATE  DATE            NULL,
    TOTAL_BILLED          DECIMAL(15,2)   NULL,
    TOTAL_ALLOWED         DECIMAL(15,2)   NULL,
    TOTAL_PAID            DECIMAL(15,2)   NULL,
    TOTAL_DENIED          DECIMAL(15,2)   NULL,
    TOTAL_ADJUSTED        DECIMAL(15,2)   NULL,
    TOTAL_PAT_RESP        DECIMAL(15,2)   NULL,
    DENIAL_CODE           VARCHAR(20)     NULL,
    DENIAL_REASON         VARCHAR(500)    NULL,
    REMARK_CODE           VARCHAR(20)     NULL,
    REJECTION_REASON_C    INT             NULL,
    APPEAL_STATUS_C       INT             NULL,
    APPEAL_DATE           DATE            NULL,
    APPEAL_DECISION_DATE  DATE            NULL,
    ORIGINAL_CLAIM_ID     BIGINT          NULL,
    RESUBMISSION_YN       CHAR(1)         NOT NULL DEFAULT 'N',
    DAYS_TO_PAY           INT             NULL,
    DAYS_IN_AR            INT             NULL,
    BILLING_PROV_NPI      VARCHAR(10)     NULL,
    RENDERING_PROV_ID     VARCHAR(18)     NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE PAYMENT_DETAIL (
    PAYMENT_ID            BIGINT          NOT NULL PRIMARY KEY,
    HSP_ACCOUNT_ID        BIGINT          NOT NULL,
    PAT_ID                INT             NOT NULL,
    CLAIM_ID              BIGINT          NULL,
    PAYMENT_SOURCE_C      INT             NULL,
    PAYMENT_TYPE_C        INT             NULL,
    PAYOR_ID              INT             NULL,
    PAYMENT_AMOUNT        DECIMAL(15,2)   NOT NULL,
    PAYMENT_DATE          DATE            NULL,
    POST_DATE             DATE            NULL,
    SERVICE_DATE          DATE            NULL,
    CHECK_NUMBER          VARCHAR(50)     NULL,
    EOB_REFERENCE_NUMBER  VARCHAR(50)     NULL,
    TRANSACTION_REF       VARCHAR(50)     NULL,
    PAYMENT_METHOD_C      INT             NULL,
    APPLIED_TO_CHARGE_ID  BIGINT          NULL,
    APPLIED_TO_CPT        VARCHAR(10)     NULL,
    ADJUSTMENT_CODE       VARCHAR(20)     NULL,
    ADJUSTMENT_REASON     VARCHAR(500)    NULL,
    PATIENT_RESP_FLAG_YN  CHAR(1)         NOT NULL DEFAULT 'N',
    REVERSED_YN           CHAR(1)         NOT NULL DEFAULT 'N',
    REVERSAL_REASON_C     INT             NULL,
    POSTED_BY_USER_ID     VARCHAR(18)     NULL,
    BATCH_ID              VARCHAR(50)     NULL,
    DEPOSIT_DATE          DATE            NULL,
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO
