{{ config(
     enabled = var('cms_hcc_enabled',var('tuva_marts_enabled',True))
   )
}}

-- pull in demographic info
-- combine a few columns into one description column (e.g., New / Male / 70-74 / Non-Medicaid / Partial / Disabled / Non-Institutional)
with demographic_factors as (

    select
          patient_id
        /* concatenate demographic risk factors */
        , enrollment_status
            || ' / '
            || gender
            || ' / '
            || age_group
            || ' / '
            || case
                when medicaid_status = 'Yes' then 'Medicaid'
                else 'Non-Medicaid'
                end
            || ' / '
            || dual_status
            || ' / '
            || orec
            || ' / '
            || case
                when institutional_status = 'Yes' then 'Institutional'
                else 'Non-Institutional'
                end
          as description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_demographic_factors') }}

)

-- pull in "default" columns from demographic data (e.g., enrollment status default == True/False)
, demographic_defaults as (

    select
          patient_id
        , enrollment_status_default
        , medicaid_dual_status_default
        , institutional_status_default
    from {{ ref('cms_hcc__int_demographic_factors') }}

)

-- pull in disease factor info
, disease_factors as (

    select
          patient_id
        , hcc_description || ' (HCC ' || hcc_code || ')' as description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_disease_factors') }}

)

-- pull in enrollment interaction info
, enrollment_interactions as (

    select
          patient_id
        , description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_enrollment_interaction_factors') }}

)

-- pull in disabled interaction info
, disabled_interactions as (

    select
          patient_id
        , description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_disabled_interaction_factors') }}

)

-- pull in disease interaction info
, disease_interactions as (

    select
          patient_id
        , description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_disease_interaction_factors') }}

)

-- pull in number of HCCs info
, hcc_counts as (

    select
          patient_id
        , description
        , coefficient
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_hcc_count_factors') }}

)

-- combine all risk factors and their coefficients for each patient
, unioned as (

    select * from demographic_factors
    union all
    select * from disease_factors
    union all
    select * from enrollment_interactions
    union all
    select * from disabled_interactions
    union all
    select * from disease_interactions
    union all
    select * from hcc_counts

)

-- add defaults
, add_defaults as (

    select
          unioned.patient_id
        , demographic_defaults.enrollment_status_default
        , demographic_defaults.medicaid_dual_status_default
        , demographic_defaults.institutional_status_default
        , unioned.description as risk_factor_description
        , unioned.coefficient
        , unioned.model_version
        , unioned.payment_year
    from unioned
         left join demographic_defaults
         on unioned.patient_id = demographic_defaults.patient_id

)

-- cast appropriately
, add_data_types as (

    select
          cast(patient_id as {{ dbt.type_string() }}) as patient_id
        , cast(enrollment_status_default as boolean) as enrollment_status_default
        , cast(medicaid_dual_status_default as boolean) as medicaid_dual_status_default
        , cast(institutional_status_default as boolean) as institutional_status_default
        , cast(risk_factor_description as {{ dbt.type_string() }}) as risk_factor_description
        , round(cast(coefficient as {{ dbt.type_numeric() }}),3) as coefficient
        , cast(model_version as {{ dbt.type_string() }}) as model_version
        , cast(payment_year as integer) as payment_year
        , cast('{{ dbt_utils.pretty_time(format="%Y-%m-%d %H:%M:%S") }}' as {{ dbt.type_timestamp() }}) as date_calculated
    from add_defaults

)

-- final select
select
      patient_id
    , enrollment_status_default
    , medicaid_dual_status_default
    , institutional_status_default
    , risk_factor_description
    , coefficient
    , model_version
    , payment_year
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from add_data_types