/*
ended up in cclf.tables
*/

-- make it a table instead of a view
{{ config (materialized='table') }}

with stay as (
select 
    date_part(year, encounter_end_date) || lpad(date_part(month, encounter_end_date),2,0) as year_month
    , encounter_end_date - encounter_start_date as length_of_stay
    , encounter_admit_type_code
from acute_inpatient._int_acute_inpatient_claims_with_encounter_data
)

select
    year_month
    , encounter_admit_type_code
    , count(1) as num_discharges
    , avg(length_of_stay) as avg_length
from stay
group by 
    year_month
    , encounter_admit_type_code
order by 
    year_month
    , num_discharges desc
limit 20
    