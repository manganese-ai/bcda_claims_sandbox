-- pull in medical claim info

{{ config(
     enabled = var('cms_hcc_enabled',var('tuva_marts_enabled',True))
   )
}}
select
      claim_id
    , claim_line_number
    , claim_type
    , patient_id
    , claim_start_date
    , claim_end_date
    , bill_type_code
    , hcpcs_code
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('medical_claim') }}