-- Results in table _VALUE_SET_ENROLLMENT_INTERACTION_FACTORS
-- Unsure where the raw data comes from...

select
    MODEL_VERSION,
    FACTOR_TYPE,
    GENDER,
    ENROLLMENT_STATUS,
    MEDICAID_STATUS,
    DUAL_STATUS,
    OREC,
    INSTITUTIONAL_STATUS,
    DESCRIPTION,
    COEFFICIENT
from tuva_project_demo.cms_hcc.undefined