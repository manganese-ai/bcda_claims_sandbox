{%- set admit_type = [1,2,3] -%}

with long as (
    select *
    from {{ ref('tmp_create_table') }}
)

, pivoted as (
    select 
        year_month,

        {% for i in admit_type -%}
        sum(case when encounter_admit_type_code = {{ i }} then num_discharges else 0 end) as num_admit_{{ i }}
        {%- if not loop.last -%}
            ,
        {%- endif %}
        {% endfor %}

    from long
    group by year_month
)

select * from pivoted