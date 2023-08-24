/* 
create "patients" table as a staging table 
this will be combined with the "chronic" table (from `tmp_stg1.sql`)
in the `tmp_combine_stgs.sql` file
*/
with patients as (
select 
    state
    , gender
    , patient_id
    , enrollment_end_date
from {{ source('core','patient') }} p
inner join {{ source('core','eligibility') }} e USING (patient_id)
where p.gender='female'
    and p.state in ('New Jersey','Ohio', 'New York', 'Pennsylvania', 'Illinois', 'Arizona', 'California', 'Texas')
)

select * from patients