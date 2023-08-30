### HCC process
Trying to understand each step of HCC coding.

**Terminology:**
- Collection year = year the medical services were performed by providers
- Payment year = the year AFTER the collection year, when the payers (e.g., CMS) pay the providers

**Process:**
1. Raw data fed into database ("staging")
    - a. Medical Claims `cms_hcc__stg_medical_claim.sql`
    - b. Patient Eligibility `cms_hcc__stg_eligibility.sql`
    - c. Condition data (ICD-10 CM codes) `cms_hcc__stg_core_condition.sql`
    - d. Seeds: Not sure where the raw data is from in our project, but it results in tables starting with `_value_set_`. I think maybe they come from CMS?
2. Determine member eligibility `cms_hcc__int_members.sql`
    - a. Find all healthcare enrollments for each patient
    - b. Define the number of months each patient was covered during the collection year.
    - c. Filter data to only include enrollments during the collection year.
    - d. Define whether an enrollment is New or Continuing. CMS defines a new enrollee as a beneficiary with < 12 months of coverage PRIOR to the payment year.
    - e. Combine eligibility info and enrollment status info for the most recent eligibility for each patient
    - f. Add age group information (e.g., 0-34, 35-44, 85-89...). This is the same for continuing and new enrollees EXCEPT for ages 65-69. For Continuing patients, this is one group (65-69). For New patients, each of these ages is its own group (65, 66, 67, 68, 69).
    - g. Add "medicaid status" information -- Yes if eligible for Medicare AND Medicaid, No if only eligible for Medicare (??).
    - h. Add "dual status" information -- whether a patient is eligible for Full, Partial, or None of Medicare (or Medicaid?)
    - i. Add "OREC" data (aged, disabled, ESRD, null)
    **Tuva does not add OREC data currently and is only using a proxy for this information**
    - j. Add institutional status
    **Tuva does not have this logic added yet and everyone is listed as No**
    - k. Add plan segment data
    **Tuva does not include this, as the data is not available at the moment**
3. Capture demographic factors and coefficients `cms_hcc__int_demographic_factors.sql`
    - a. Get patient info from Step #2 above
    - b. Get HCC coefficient info from demographic seed file, which has different coeffiecients for combinations of gender, age group, medicaid status, OREC, etc
    - c. Combine coefficient data and patient data for new enrollees
    - d. Combine coefficient data and patient data for continuing enrollees -- same as new enrollees except also including Dual Status and Institutional Status for Continuing (not New)
    - e. Combine coefficient data and patient data for "other" enrollees. 
    ** Tuva Note: The CMS-HCC model does not have factors for ESRD or null medicare status for these edge-cases, we default to 'Aged' and dual_status is Non or Partial.**
    - f. Combine all enrollee types together
4. Get enrollment interaction factors `cms_hcc__int_enrollment_interaction_factors.sql`
    - a. Get patient info from Step #3 above
    - b. Get HCC coefficient info from demographic interaction seed file, which has coefficients for combinations of Aged and "Originally Disabled" (and also with Medicaid status, institutional status, etc) for CONTINUING enrollees
    - c. Connect Patient ID with a coefficient corresponding to the "Originally disabled" interactions for non-institutional Continuing members >= 65
    - d. Connect Patient ID with a coeficient corresponding to interactions of Medicaid and institutional members
    - e. Combine patient interaction info (steps c and d above)
5. Determine eligible conditions `cms_hcc__int_eligible_conditions.sql`
    - a. Get raw medical claims data and raw conditions data (ICD 10 CM codes)
    - b. Get seed data about HCPCS codes and whether they were covered during the payment year
    - c. Select professional claims that took place during the collection year and are covered during the payment year
    - d. Select inpatient claims that took place during the collection year and have bill types that refer to inpatient claims (bill types 11X and 41X)
    - e. Select outpatient claims that took place during the collection year, covered in the payment year, and have bill types that refer to outpatient claims (bill types 12X, 13X, 43X, 71X, 73X, 76X, 77X, 85X)
    - f. Combine all eligible claims (created in steps c-e above)
    - g. Add ICD-10 CM codes to each eligible patient claim
6. Map HCC codes to patient diagnosis (condition) codes `cms_hcc__int_hcc_mapping.sql`
    - a. Pull in data we created in #5 above
    **Note: This has 0 rows in Snowflake -- I think because of the payment/collection year variables**
    - b. Pull in seed data that maps eligible diagnosis codes to HCC codes
    **Note: Tuva currently only supports CMS HCC v24**
    - c. Add HCC codes to patient data
7. Account for groups of HCCs that have a disease hierarchy `cms_hcc__int_hcc_hierarchy.sql`
    - *Background*: For some conditions (but not all), CMS has come up with a hierarchy of which conditions from the group is most (to least) severe. For a given disease category (e.g., Cancers), they say which HCC code is "highest / most severe" (e.g., HCC code 8, which corresponds to Metastatic Cancer and Acute Leukemia) and which HCC codes to exclude, if the patient has multiple conditions in that category (e.g., HCC codes 9, 10, 11, and 12, corresponding to Lung and Other Severe Cancers, Lymphoma and Other Cancers, Colorectal, Bladder, and Other Cancers, and HCC 12 (not sure)).
    - a. Get data from #6 above
    - b. Get seed data regarding disease hierarchy (HCC codes and description)
    - c. Select HCCs that do NOT have a hierarchy
    - d. Select HCCs that DO have a hierarchy for evaluation in steps 5-7
    - e. Group by patient and HCC codes to account for multiple HCC combinations. Here, the minimum HCC is included (following CMS's severity logic)
    - f. Select lower-level HCCs in the hierarchy
    - g. Select top-level HCCs not included in previous steps
    - h. Combine patients from steps e-g above
8. Add disease coefficients to patient data `cms_hcc__int_disease_factors.sql`
    - a. Pull in demographic info from # 3 and HCC hierarchy info from # 7 
    - b. Get seed data that gives coefficients for combinations of HCC codes and patient info (e.g., OREC, institutional status) for Continuing enrollees
    - c. Combine demographic and HCC info for each patient
    - d. Add disease-related coefficients to patient data
9. Add disease interaction coefficients to patient data `cms_hcc__int_disease_interaction_factors.sql`
    - a. Pull in demographic info from # 3 and HCC hierarchy info from # 7 
    - b. Get seed data that gives coefficients for combinations of MULTIPLE HCC codes (e.g., Immune Disorders (HCC 47) and Cancer (HCCs 8-12)) and patient info (e.g., OREC, institutional status) for Continuing enrollees
    - c. Combine demographic and HCC info for each patient
    - d. Add disease interaction-related coefficients to patient data
10. Add disabled interaction coefficients to patient data `cms_hcc__int_disabled_interaction_factors.sql`
    - a. Pull in demographic info from # 3 and HCC hierarchy info from # 7 
    - b. Get seed data that gives coefficients for HCC codes for disabled, Continuing enrollees (e.g., Disabled & Congestive Heart Failure, HCC 85)
    - c. Combine demographic and HCC info for each patient
    - d. Add disabled/HCC interaction-related coefficients to patient data
11. Add coefficients for total number of "payment HCCs" to patient data `cms_hcc__int_hcc_count_factors.sql`
    - a. Pull in demographic info from # 3 and HCC hierarchy info from # 7 
    - b. Get seed data that gives coefficients for the total number of "payment HCCs" (4, 5, 6, 7, 8, 9, 10+ payment HCCs) and patient info (e.g., OREC, institutional status) for Continuing enrollees
    - c. Count the number of HCC codes per patient. If patient has > 10 HCC codes, recode to "10+"
    - d. Add coefficients for number of HCC codes to patient data
12. Combine all patient risk factors `cms_hcc__patient_risk_factors.sql`
    - a. Combine demographic info from # 3, enrollment interaction info from # 4, disease factor info from # 8, disease interaction info from # 9, disabled interaction info from # 10, and total number of HCCs info from #11
13. Calculate patient risk scores `cms_hcc__patient_risk_scores.sql`
    - a. Pull in seed data that has adjustment factors based on the payment year (to normalize costs year to year?)
    - b. Pull in patient risk factor info from # 12
    - c. Calculate the raw risk score for each patient by summing up all the coefficients for that payment year (e.g., Patient 123 has a different raw risk score for 2018, 2019, 2020...)
    - d. Calculate the normalized risk score for each patient (for that payment year) by dividing the raw risk score by the normalization factor for that payment year
    - e. Calculate the payment risk score for each patient (for that payment year) by multiplying the normalized risk score by (1-adjustment), where the adjustment is set by MA (?).
    **Note: The adjustment is the same for each year in our data, so I'm not sure what it's doing.**

**Questions:**
    1. Where do the seed data come from in our synthetic example?
    2. I think there's a bug in the code in the `where` statement of "calculate prior coverage" in `cms_hcc__int_members.sql`
    3. I don't understand the "medicaid status" [docs here](https://app.snowflake.com/crqfgja/qzb34834/#/data/databases/SANDBOX_CLAIMS/schemas/TERMINOLOGY/table/MEDICARE_DUAL_ELIGIBILITY/data-preview). Similarly, is "dual status" partial/full/none of medicare or medicaid?
    4. Why are ages 65-69 different for Continuing / New enrollees in `cms_hcc__int_members.sql`? Is eligibility or risk scores different during those years?
    5. In `cms_hcc__int_disease_interaction_factors.sql`, not sure why you need the `disease_interactions` cte after the `demographics_with_interactions` cte
    6. Why is the coefficient data only for Continuing enrollees and not New enrollees?
    7. Where do the cost normalizing ratios come from in `cms_hcc__patient_risk_scores.sql`? CMS or Tuva? 
    8. What is the "MA coding pattern adjustment" that's used to calculate the payment risk score in `cms_hcc__patient_risk_scores.sql`? Currently it is the same for each year in our data, so I'm not sure what it's doing.