/* 
create "chronic" table as a staging table 
this will be combined with the "patients" table (from `tmp_stg2.sql`)
in the `tmp_combine_stgs.sql` file
*/

with chronic as (
select 
    patient_id
    , asthma
    , alcohol_use_disorders
    , anemia
    , COALESCE(asthma,0) + COALESCE(alcohol_use_disorders,0) + COALESCE(anemia,0) AS multiple
from {{ source ('chronic_conditions','cms_chronic_conditions_wide') }} 
)

select * from chronic