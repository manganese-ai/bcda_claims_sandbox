/*
ended up in cclf.tables
*/

-- make it a table instead of a view
{{
    config (
        materialized='table'
    )
}}

-- note: our pharmacy claim table didn't populate (0 rows)
select
    claim_type
    , count(distinct claim_id)
    , sum(paid_amount) as total_payments
from core.medical_claim
group by 1

union

select
    'pharmacy' as claim_type
    , count(distinct claim_id)
    , sum(paid_amount) as total_payments
from core.pharmacy_claim