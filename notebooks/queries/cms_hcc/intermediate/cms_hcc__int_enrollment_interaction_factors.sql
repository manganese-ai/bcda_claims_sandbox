{{ config(
     enabled = var('cms_hcc_enabled',var('tuva_marts_enabled',True))
   )
}}
/*
The hcc_model_version var has been set here so it gets compiled.
*/

{% set model_version_compiled = var('cms_hcc_model_version') -%}

-- get info from previous script, cms_hcc__int_demographic_factors
with demographics as (

    select
          patient_id
        , enrollment_status
        , gender
        , age_group
        , medicaid_status
        , dual_status
        , orec
        , institutional_status
        , enrollment_status_default
        , medicaid_dual_status_default
        , institutional_status_default
        , model_version
        , payment_year
    from {{ ref('cms_hcc__int_demographic_factors') }}

)

-- get info from seed file
-- has coefficients for combinations of Aged and "Originally Disabled" (and also with Medicaid status, institutional status, etc) for CONTINUING enrollees
, seed_interaction_factors as (

    select
          model_version
        , gender
        , enrollment_status
        , medicaid_status
        , dual_status
        , orec
        , institutional_status
        , description
        , coefficient
    from {{ ref('cms_hcc__enrollment_interaction_factors') }}
    where model_version = '{{ model_version_compiled }}'

)

-- connect Patient ID with a coeficient corresponding to the "Originally disabled" interactions for non-institutional Continuing members >= 65
, non_institutional_interactions as (

    select
          demographics.patient_id
        , demographics.model_version
        , demographics.payment_year
        , seed_interaction_factors.description
        , seed_interaction_factors.coefficient
    from demographics
         inner join seed_interaction_factors
         on demographics.gender = seed_interaction_factors.gender
         and demographics.enrollment_status = seed_interaction_factors.enrollment_status
         and demographics.medicaid_status = seed_interaction_factors.medicaid_status
         and demographics.dual_status = seed_interaction_factors.dual_status
         and demographics.institutional_status = seed_interaction_factors.institutional_status
    where demographics.institutional_status = 'No'
    and demographics.orec = 'Disabled'
    and demographics.age_group in (
          '65-69'
        , '70-74'
        , '75-79'
        , '80-84'
        , '85-89'
        , '90-94'
        , '>=95'
    )

)

-- connect Patient ID with a coeficient corresponding to interactions of Medicaid and institutional members
, institutional_interactions as (

    select
          demographics.patient_id
        , demographics.model_version
        , demographics.payment_year
        , seed_interaction_factors.description
        , seed_interaction_factors.coefficient
    from demographics
         inner join seed_interaction_factors
         on demographics.enrollment_status = seed_interaction_factors.enrollment_status
         and demographics.institutional_status = seed_interaction_factors.institutional_status
    where demographics.institutional_status = 'Yes'
    and demographics.medicaid_status = 'Yes'

)

-- combine patient interaction info
, unioned as (

    select * from non_institutional_interactions
    union all
    select * from institutional_interactions

)

-- cast into appropriate types
, add_data_types as (

    select
          cast(patient_id as {{ dbt.type_string() }}) as patient_id
        , cast(description as {{ dbt.type_string() }}) as description
        , round(cast(coefficient as {{ dbt.type_numeric() }}),3) as coefficient
        , cast(model_version as {{ dbt.type_string() }}) as model_version
        , cast(payment_year as integer) as payment_year
        , cast('{{ dbt_utils.pretty_time(format="%Y-%m-%d %H:%M:%S") }}' as {{ dbt.type_timestamp() }}) as date_calculated
    from unioned

)

-- final select
select
      patient_id
    , description
    , coefficient
    , model_version
    , payment_year
    , '{{ var('tuva_last_run')}}' as tuva_last_run
from add_data_types