-- Results in table _VALUE_SET_ICD_10_CM_MAPPINGS
-- Unsure where the raw data comes from...

select
    PAYMENT_YEAR,
    DIAGNOSIS_CODE,
    CMS_HCC_V24,
    CMS_HCC_V24_FLAG
from tuva_project_demo.cms_hcc.undefined