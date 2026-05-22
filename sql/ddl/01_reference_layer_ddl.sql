-- ============================================================
-- Script:        01_reference_layer_ddl.sql
-- Purpose:       Create reference/lookup tables for mini-Clarity
-- Project:       Epic Clarity-Style Clinical Reporting Platform
-- Author:        Prakash Pyakurel
-- Created:       2026-05-13
-- Database:      EpicClaritySim
-- Tables Created:
--   CLARITY_DEP, CLARITY_LOC, CLARITY_SER, CLARITY_PAYOR
--   ZC_SEX, ZC_MARITAL_STATUS, ZC_PAT_STATUS, ZC_STATE,
--   ZC_DEP_SPECIALTY, ZC_PAYOR_TYPE
-- ============================================================


USE EpicClaritySim;
GO

SELECT DB_NAME() AS CurrentDatabase;


CREATE TABLE CLARITY_DEP (
    DEPARTMENT_ID         INT             NOT NULL PRIMARY KEY,
    DEPARTMENT_NAME       VARCHAR(100)    NOT NULL,
    SPECIALTY_C           INT             NULL,
    LOCATION_ID           INT             NULL,
    DEPT_TYPE_C           INT             NULL,
    SERV_AREA_ID          INT             NULL,
    REV_LOC_ID            INT             NULL,
    DEPT_ABBREVIATION     VARCHAR(20)     NULL,
    EXTERNAL_NAME         VARCHAR(100)    NULL,
    PHONE                 VARCHAR(20)     NULL,
    ACTIVE_YN             CHAR(1)         NOT NULL DEFAULT 'Y',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE CLARITY_LOC (
    LOCATION_ID           INT             NOT NULL PRIMARY KEY,
    LOC_NAME              VARCHAR(100)    NOT NULL,
    LOC_ABBR              VARCHAR(20)     NULL,
    LOC_TYPE_C            INT             NULL,
    ADDRESS_LINE_1        VARCHAR(200)    NULL,
    ADDRESS_LINE_2        VARCHAR(200)    NULL,
    CITY                  VARCHAR(100)    NULL,
    STATE_C               INT             NULL,
    ZIP                   VARCHAR(10)     NULL,
    COUNTY                VARCHAR(100)    NULL,
    PHONE                 VARCHAR(20)     NULL,
    FAX                   VARCHAR(20)     NULL,
    SERV_AREA_ID          INT             NULL,
    PARENT_LOC_ID         INT             NULL,
    TIME_ZONE_C           INT             NULL,
    LATITUDE              DECIMAL(9,6)    NULL,
    LONGITUDE             DECIMAL(9,6)    NULL,
    ACTIVE_YN             CHAR(1)         NOT NULL DEFAULT 'Y',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

CREATE TABLE CLARITY_SER (
    PROV_ID               VARCHAR(18)     NOT NULL PRIMARY KEY,
    PROV_NAME             VARCHAR(200)    NOT NULL,
    PROV_FIRST_NAME       VARCHAR(100)    NULL,
    PROV_LAST_NAME        VARCHAR(100)    NULL,
    PROV_MIDDLE_NAME      VARCHAR(100)    NULL,
    PROV_TYPE             VARCHAR(20)     NULL,
    NPI                   VARCHAR(10)     NULL,
    DEA_NUMBER            VARCHAR(20)     NULL,
    SPECIALTY_C           INT             NULL,
    SUB_SPECIALTY_C       INT             NULL,
    PRIMARY_DEPT_ID       INT             NULL,
    PRIMARY_LOC_ID        INT             NULL,
    EXTERNAL_USER_YN      CHAR(1)         NOT NULL DEFAULT 'N',
    EMPLOYEE_YN           CHAR(1)         NOT NULL DEFAULT 'Y',
    HIRE_DATE             DATE            NULL,
    TERM_DATE             DATE            NULL,
    EMAIL                 VARCHAR(200)    NULL,
    PHONE                 VARCHAR(20)     NULL,
    PAGER                 VARCHAR(20)     NULL,
    ACTIVE_YN             CHAR(1)         NOT NULL DEFAULT 'Y',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_CREATE_USER_ID    VARCHAR(18)     NULL,
    REC_UPDATE_DATE       DATETIME2       NULL,
    REC_UPDATE_USER_ID    VARCHAR(18)     NULL
);
GO

CREATE TABLE CLARITY_PAYOR (
    PAYOR_ID              INT             NOT NULL PRIMARY KEY,
    PAYOR_NAME            VARCHAR(200)    NOT NULL,
    PAYOR_ABBR            VARCHAR(20)     NULL,
    PAYOR_TYPE_C          INT             NULL,
    FINANCIAL_CLASS_C     INT             NULL,
    PARENT_PAYOR_ID       INT             NULL,
    CONTRACT_NUMBER       VARCHAR(50)     NULL,
    PAYOR_GROUP_C         INT             NULL,
    EFFECTIVE_FROM_DATE   DATE            NULL,
    EFFECTIVE_TO_DATE     DATE            NULL,
    ADDRESS_LINE_1        VARCHAR(200)    NULL,
    ADDRESS_LINE_2        VARCHAR(200)    NULL,
    CITY                  VARCHAR(100)    NULL,
    STATE_C               INT             NULL,
    ZIP                   VARCHAR(10)     NULL,
    PHONE                 VARCHAR(20)     NULL,
    FAX                   VARCHAR(20)     NULL,
    CLAIMS_SUBMISSION_URL VARCHAR(500)    NULL,
    ELECTRONIC_PAYOR_ID   VARCHAR(20)     NULL,
    ACTIVE_YN             CHAR(1)         NOT NULL DEFAULT 'Y',
    REC_CREATE_DATE       DATETIME2       NOT NULL DEFAULT GETDATE(),
    REC_UPDATE_DATE       DATETIME2       NULL
);
GO

-- ========================================
-- ZC_* Lookup Tables (Category Code Translations)
-- ========================================

CREATE TABLE ZC_SEX (
    SEX_C                 INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(100)    NOT NULL,
    ABBR                  VARCHAR(10)     NULL
);
GO

CREATE TABLE ZC_MARITAL_STATUS (
    MARITAL_STATUS_C      INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(100)    NOT NULL,
    ABBR                  VARCHAR(10)     NULL
);
GO

CREATE TABLE ZC_PAT_STATUS (
    PAT_STATUS_C          INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(100)    NOT NULL,
    ABBR                  VARCHAR(10)     NULL
);
GO

CREATE TABLE ZC_STATE (
    STATE_C               INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(100)    NOT NULL,
    ABBR                  VARCHAR(10)     NULL
);
GO

CREATE TABLE ZC_DEP_SPECIALTY (
    SPECIALTY_C           INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(200)    NOT NULL,
    ABBR                  VARCHAR(20)     NULL
);
GO

CREATE TABLE ZC_PAYOR_TYPE (
    PAYOR_TYPE_C          INT             NOT NULL PRIMARY KEY,
    NAME                  VARCHAR(100)    NOT NULL,
    ABBR                  VARCHAR(20)     NULL
);
GO


---

## UPDATE — 2026-05-16 — Phase 1.5: ZC_ Reference Table Extension

A schema audit identified that many `_C` category columns across the
22 base tables had no matching `ZC_` lookup table. Phase 1 had built
only 6 `ZC_` tables.

**Action taken:** Created `sql/ddl/04_zc_reference_ddl.sql` — 54 new
`ZC_` lookup tables, each the standard 3-column shape
(`<concept>_C` INT PK, `NAME` VARCHAR(100), `ABBR` VARCHAR(20)).
Ran successfully 2026-05-16.

**Current ZC_ table count: 60** (6 from Phase 1 + 54 new).
**Total tables in EpicClaritySim: 76** (22 base + 54 new ZC_).

All 60 `ZC_` tables verified: correct 3-column structure, no
duplicates. As of this update the new `ZC_` tables are created but
still EMPTY — population is ETL Stage 2.1.

DDL files now in `sql/ddl/`:
- 01_reference_layer_ddl.sql
- 02_clinical_layer_ddl.sql
- 03_financial_layer_ddl.sql
- 04_zc_reference_ddl.sql  (new)