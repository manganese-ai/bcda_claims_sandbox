### HCC process
Trying to understand each step of HCC coding.

1. Raw data fed into database ("staging")
    - Medical Claims `cms_hcc__stg_medical_claim.sql`
    - Patient Eligibility `cms_hcc__stg_eligibility.sql`
    - Condition data (ICD-10 CM codes) `cms_hcc__stg_core_condition.sql`
    - Seeds 
        - Not sure where the raw data is from in our project, but it results in tables starting with `_value_set_`
        - I think maybe they come from CMS?
    - QUESTIONS
        - where do the seed data come from in our synthetic example?
2. Determine member eligibility `cms_hcc__int_members.sql`
    - Terminology
        - Collection year = year the medical services were performed by providers
        - Payment year = the year AFTER the collection year, when the payers (e.g., CMS) pay the providers
    - Steps
        1. Find all healthcare enrollments for each patient
        2. Define the number of months each patient was covered during the collection year.
        3. Filter data to only include enrollments during the collection year.
        4. Define whether an enrollment is New or Continuing. CMS defines a new enrollee as a beneficiary with < 12 months of coverage PRIOR to the payment year.
        5. Combine eligibility info and enrollment status info for the most recent eligibility for each patient
        6. Add age group information (e.g., 0-34, 35-44, 85-89...). This is the same for continuing and new enrollees EXCEPT for ages 65-69. For Continuing patients, this is one group (65-69). For New patients, each of these ages is its own group (65, 66, 67, 68, 69).
        7. Add "medicaid status" information -- Yes if eligible for Medicare AND Medicaid, No if only eligible for Medicare (??).
        8. Add "dual status" information -- whether a patient is eligible for Full, Partial, or None of Medicare (or Medicaid?)
        9. Add "OREC" data (aged, disabled, ESRD, null)
        **Tuva does not add OREC data currently and is only using a proxy for this information**
        10. Add institutional status
        **Tuva does not have this logic added yet and everyone is listed as No**
        11. Add plan segment data
        **Tuva does not include this, as the data is not available at the moment**
    - QUESTIONS
        - I think there's a bug in the code in the `where` statement of "calculate prior coverage" 
        - I don't understand the "medicaid status" [docs here](https://app.snowflake.com/crqfgja/qzb34834/#/data/databases/SANDBOX_CLAIMS/schemas/TERMINOLOGY/table/MEDICARE_DUAL_ELIGIBILITY/data-preview). I think this might be mislabeled: should this be `medicare status` instead of `medicaid status`? Similarly, is "dual status" partial/full/none of medicare or medicaid?
        - Why are ages 65-69 different for Continuing / New enrollees? Is eligibility or risk scores different during those years?
3. Capture demographic factors and coefficients `cms_hcc__int_demographic_factors.sql`
    - Steps
        1. Get patient info from Step #2 above
        2. Get HCC coefficient info from demographic seed file, which has different coeffiecients for combinations of gender, age group, medicaid status, OREC, etc
        3. Combine coefficient data and patient data for new enrollees
        4. Combine coefficient data and patient data for continuing enrollees -- same as new enrollees except also including Dual Status and Institutional Status for Continuing (not New)
        5. Combine coefficient data and patient data for "other" enrollees. 
        ** Tuva Note: The CMS-HCC model does not have factors for ESRD or null medicare status for these edge-cases, we default to 'Aged' and dual_status is Non or Partial.**
        6. Combine all enrollee types together
    4. Get enrollment interaction factors `cms_hcc__int_demographic_factors.sql`
        - Steps
            1. Get patient info from Step #3 above
            2. Get HCC coefficient info from demographic interaction seed file, which has coefficients for combinations of Aged and "Originally Disabled" (and also with Medicaid status, institutional status, etc) for CONTINUING enrollees
            3. Connect Patient ID with a coefficient corresponding to the "Originally disabled" interactions for non-institutional Continuing members >= 65
            4. Connect Patient ID with a coeficient corresponding to interactions of Medicaid and institutional members
            5. Combine patient interaction info (steps 3 and 4 above)
    5. Determine eligible conditions `cms_hcc__int_eligible_conditions.sql`
        - Steps
            1. Get raw medical claims data and raw conditions data (ICD 10 CM codes)
            2. Get seed data about HCPCS codes and whether they were covered during the payment year
            3. Select professional claims that took place during the collection year and are covered during the payment year
            4. Select inpatient claims that took place during the collection year and have bill types that refer to inpatient claims (bill types 11X and 41X)
            5. Select outpatient claims that took place during the collection year, covered in the payment year, and have bill types that refer to outpatient claims (bill types 12X, 13X, 43X, 71X, 73X, 76X, 77X, 85X)
            6. Combine all eligible claims (created in steps 3-5)
            7. Add ICD-10 CM codes to each eligible patient claim
    6. Map HCC codes to patient diagnosis (condition) codes `cms_hcc__int_hcc_mapping.sql`
        - Steps
            1. Pull in data we created in #5 above
            **Note: This has 0 rows in Snowflake -- I think because of the payment/collection year variables**
            2. Pull in seed data that maps eligible diagnosis codes to HCC codes
            **Note: Tuva currently only supports CMS HCC v24**
            3. Add HCC codes to patient data
    7. 

