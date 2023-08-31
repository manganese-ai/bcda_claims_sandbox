-- Results in table _VALUE_SET_DISABLED_INTERACTION_FACTORS
-- Unsure where the raw data comes from...

select
    MODEL_VERSION,
    FACTOR_TYPE,
    ENROLLMENT_STATUS,
    INSTITUTIONAL_STATUS,
    SHORT_NAME,
    DESCRIPTION,
    HCC_CODE,
    COEFFICIENT
from tuva_project_demo.cms_hcc.undefined