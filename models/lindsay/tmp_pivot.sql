with long as (
    select *
    from {{ ref('tmp_create_table') }}
)

, pivoted as (
    select 
        year_month
        , sum(case when encounter_admit_type_code = 1 then num_discharges else 0 end) as num_admit_1
        , sum(case when encounter_admit_type_code = 2 then num_discharges else 0 end) as num_admit_2
        , sum(case when encounter_admit_type_code = 3 then num_discharges else 0 end) as num_admit_3
    from long
    group by year_month
)

select * from pivoted