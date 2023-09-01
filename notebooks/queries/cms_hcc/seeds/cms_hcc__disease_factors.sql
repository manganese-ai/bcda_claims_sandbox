-- Results in table _VALUE_SET_DISEASE_FACTORS
-- Unsure where the raw data comes from...

select
    MODEL_VERSION,
    FACTOR_TYPE,
    ENROLLMENT_STATUS,
    MEDICAID_STATUS,
    DUAL_STATUS,
    OREC,
    INSTITUTIONAL_STATUS,
    HCC_CODE,
    DESCRIPTION,
    COEFFICIENT
from tuva_project_demo.cms_hcc.undefined