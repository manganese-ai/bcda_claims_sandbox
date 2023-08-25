-- this uses the `tmp_macro.sql` file in the `macros` folder
-- the name of the specific macro in that file is `shorten_gender`

select 
    patient_id
    , gender
    , {{ shorten_gender('gender','renamed_gender') }}
from {{ source('core','patient') }}
limit 10