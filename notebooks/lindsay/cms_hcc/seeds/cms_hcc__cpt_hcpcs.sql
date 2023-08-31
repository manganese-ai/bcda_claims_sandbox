-- Results in table _VALUE_SET_CPT_HCPCS
-- Unsure where the raw data comes from...

select
    PAYMENT_YEAR,
    HCPCS_CPT_CODE,
    INCLUDED_FLAG
from tuva_project_demo.cms_hcc.undefined