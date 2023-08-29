-- Results in table _VALUE_SET_DISEASE_INTERACTION_FACTORS
-- Unsure where the raw data comes from...

select
    MODEL_VERSION,
    FACTOR_TYPE,
    ENROLLMENT_STATUS,
    MEDICAID_STATUS,
    DUAL_STATUS,
    OREC,
    INSTITUTIONAL_STATUS,
    SHORT_NAME,
    DESCRIPTION,
    HCC_CODE_1,
    HCC_CODE_2,
    COEFFICIENT
from tuva_project_demo.cms_hcc.undefined