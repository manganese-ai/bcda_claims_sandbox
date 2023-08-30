### PMPM process
Medical and pharmacy spend Per Member Per Month

**Process:**
1. Get medical claim data `pmpm__stg_medical_claim.sql`
    - a. Pull in info from `SANDBOX_CLAIMS.core.medical_claim` (not sure how this was populated in our synthetic example)
2. Get pharmacy claim data `pmpm__stg_pharmacy_claim.sql`
    - a. Pull in info from `SANDBOX_CLAIMS.core.pharmacy_claim` (not sure how this was populated in our synthetic example)
3. Get member months data `pmpm__stg_member_months.sql`
    - *Note*: This relies on the `member_months` folder -- below, I'm simply simplying those steps
    - a. Pull in eligibility info from `SANDBOX_CLAIMS.core.eligibility`
    - b. For every patient, create one row for each month they are eligible for covereage (aka during their enrollment period) and who the payer is (e.g., medicare)
4. Get service category data `pmpm__stg_service_category_grouper.sql`
    - *Note*: This relies on the `pmpm__stg_member_months` folder -- below, I'm simply simplying those steps
    - a. Pull in medical claim info from `SANDBOX_CLAIMS.core.medical_claim`
    - b. Pull out professional medical claims -- for each claim number, have one row for each claim line
        - Acute inpatient: place of service code = 21
        - Ambulance: place of service code = 41, 42; HCPCS code between A0425 and A0436
        - Ambulatory surgery: place of service code = 24; NOT in DME
        - Dialysis: place of service code = 65
        - DME (Durable Medical Equipment): HCPCS code between E0100 and E8002
        - ER: place of service code = 23
        - Home health: place of service code = 12; NOT in DME
        - Hospice: place of service code = 34
        - Inpatient psychiatric: place of service code = 51, 55, 56
        - Inpatient rehab: place of service code = 61
        - Lab: place of service code = 81
        - Office visit: place of service code = 11, 02
        - Outpatient hospital / clinic: place of service code = 15, 17, 19, 22, 49, 50, 60, 71, 72
        - Outpatient psychiatric: place of service code = 52, 53, 57, 58
        - Outpatient rehab: place of service code = 62
        - Skilled nursing: place of service code = 31, 32; NOT in DME
        - Urgent care: place of service code = 20
    - c. Pull out institutional medical claims -- for each claim number, have one row for each claim line
        - Acute inpatient: revenue center code = 0100, 0101, 0110, 0111, 0112, 0113, 0114, 0116, 0117, 0118, 0119, 0120, 0121, 0122, 0123, 0124, 0126, 0127, 0128, 0129, 0130, 0131, 0132, 0133, 0134, 0136, 0137, 0138, 0139, 0140, 0141, 0142, 0143, 0144, 0146, 0147, 0148, 0149, 0150, 0151, 0152, 0153, 0154, 0156, 0157, 0158, 0159, 0160, 0164, 0167, 0169, 0170, 0171, 0172, 0173, 0174, 0179, 0190, 0191, 0192, 0193, 0194, 0199, 0200, 0201, 0202, 0203, 0204, 0206, 0207, 0208,0209, 0210, 0211, 0212, 0213, 0214, 0219, 1000, 1001, 1002; has a non-null MS DRG code; has a non-null ARG DRG code; bill type code starts with 11, 12
        - Dialysis: bill type code starts with 72
        - ER: revenue center code = 0450, 0451, 0452, 0459, 0981; bill type code starts with 13, 71, 73
        - Home health: bill type code starts with 31, 32, 33
        - Hospice: bill type code starts with 81, 82
        - Lab: bill type code starts with 14
        - Outpatient hospital / clinic: bill type code starts with 13, 71, 73; NOT in urgent care / ER
        - Outpatient psychiatric: bill type code starts with 52
        - Skilled nursing: bill type code starts with 21, 22
        - Urgent care: revenue center code = 0456; bill type code starts with 13, 71, 73
    - d. Combine all professional and institutional claims
    - e. Add a second service category group (in addition to the labels like "dialysis" or "urgent care" above):
        - Ancillary: ambulance (*professional claims only*), durable medical equipment (*professional claims only*), lab
        - Inpatient: acute inpatient, inpatient psychiatric, inpatient rehab, skilled nursing
        - Office Visit: office visit
        - Outpatient: ambulatory surgery, dialysis, ER, home health, hospice, outpatient hospital / clinic, outpatient psychiatric, outpatient rehab (*professional claims only*), urgent care
        - Other: null
    - f. Final result of this process: table with claim number, claim line number, claim type (institutional or professional), service category 1 (ancillary, inpatient, office visit, outpatient, other), service category 2 (e.g., dialysis, urgent care)
5. For each patient, match their service categories with patient spend `pmpm__patient_spend_with_service_categories.sql`
    - a. Join patient medical claim info (patient ID, paid amount, allowed amount) with the service category info from # 4 (service categories 1 and 2) on the claim ID / claim line number
    - b. Group patient medical spend (paid / allowed amounts) and service categories for each month
    - c. Pull in pharmacy claim info from # 2
    - d. Group patient pharmacy spend (paid / allowed amounts) and service categories (null for pharmacy) for each month 
    - e. Combine medical and pharmacy spend per patient, per month
    - f. Sum paid amount PMPM, sum allowed amount PMPM -- for each service category
    - Result: table with patient id, year/month, service category 1, service category 2, total paid, total allowed
6. Calculate allowed / paid amounts per service category 
    - a. Allowed spend by category 1 (ancillary, inpatient, office visit, outpatient, other, pharmacy) `pmpm__service_category_1_allowed_pivot.sql`
    - b. Paid amount per service category 1 `pmpm__service_category_1_paid_pivot.sql`
    - c. Allowed amount per service category 2(e.g., dialysis, urgent care) `pmpm__service_category_2_allowed_pivot.sql`
    - d. Paid amount per service category 2 `pmpm__service_category_2_paid_pivot.sql`
    - Steps for each of these: Pull in info from #5; Sum total allowed per category
7. Combine all allowed/paid information PER PATIENT. `pmpm__pmpm_prep.sql`. Table with columns:
    - Patient ID
    - Month/year
    - Paid columns: inpatient, outpatient, office visit, ancillary, pharmacy, other, ambulance, ambulatory surgery, dialysis, durable medical equipment, emergency department, home health, hospice, inpatient psychiatric, inpatient rehabilitation, lab, office visit, outpatient hospital / clinic, outpatient psychiatric, outpatient rehabilitation, skilled nursing, urgent care
    - Allowed columns: inpatient, outpatient, office visit, ancillary, pharmacy, other, ambulance, ambulatory surgery, dialysis, durable medical equipment, emergency department, home health, hospice, inpatient psychiatric, inpatient rehabilitation, lab, office visit, outpatient hospital / clinic, outpatient psychiatric, outpatient rehabilitation, skilled nursing, urgent care
    - Total paid
    - Medical (non-pharmacy) paid
    - Total allowed
    - Medical (non-pharmacy) allowed
8. Calculate allowed/paid amounts per "member months" `pmpm__pmpm.sql`
    - a. Calculate "member months": number of rows that belong to each year/month (e.g., 2016-04) -- this eliminates all patient ID information (e.g., 907 member months in 2016-04)
    - b. Calculate allowed/paid spend for each year/month by summing the allowed (or paid) amount for each service category and dividing it by the number of member months for that year/month
    - Resulting table has columns: year/month, number of member months, total paid, medical paid, all paid columns above, total allowed, medical allowed, all allowed columns above
  


