-- pull in condition / diagnosis info

{{ config(
     enabled = var('cms_hcc_enabled',var('tuva_marts_enabled',True))
   )
}}
select
      claim_id
    , patient_id
    , code_type
    , code
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from {{ ref('core__condition') }}