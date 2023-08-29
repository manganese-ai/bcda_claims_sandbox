-- Results in table _VALUE_SET_DEMOGRAPHIC_FACTORS
-- Unsure where the raw data comes from...

select
    MODEL_VERSION,
    FACTOR_TYPE,
    ENROLLMENT_STATUS,
    PLAN_SEGMENT,
    GENDER,
    AGE_GROUP,
    MEDICAID_STATUS,
    DUAL_STATUS,
    OREC,
    INSTITUTIONAL_STATUS,
    COEFFICIENT
from tuva_project_demo.cms_hcc.undefined