/* 
combine "chronic" and "patient" tables (from `tmp_stg1.sql` and `tmp_stg2.sql`)
*/

-- create this as a table
{{ config(materialized='table') }}

-- bring in chronic table from `tmp_stg1.sql`
with chronic as (
    select * from {{ ref ('tmp_stg1') }}
)

-- bring in patients table  from `tmp_stg2.sql`
, patients as (
    select * from {{ ref ('tmp_stg2') }}
)

-- combine them
, combined as (
select
    c.patient_id
    , c.multiple
    , p.state
    , p.gender
    , p.enrollment_end_date
from chronic c
inner join patients p
on c.patient_id = p.patient_id
)

select *
from combined
where multiple = 1
order by patient_id