## Goal
This folder was created to test some simple queries on the synthetic (Syntegra) data in the Tuva CCLF schema. 

The primary aims are to (1) get familiar with the dbt structure and (2) test the connection between local code (e.g., VSCode) and what populates on Snowflake.

I tried to name everything with `lindsay` and/or `tmp` so we can delete it later, if need be.

## Files
#### SQL

In Snowflake, all of these end up saving in the CCLF schema in SANDBOX_CLAIMS.

**Basic**:
- `tmp_create_view.sql`: query to get the number of pharmacy and medical claims and the amount paid by claim type. Defaults to be a view (instead of table). 
- `tmp_create_table.sql`: query to get the average length of stay in an inpatient setting. We use Jinja code to tell it to be saved as a table, instead of a view.

**Combining multliple models**:
- `tmp_stg1.sql`: creates view for patients with multiple chronic conditions. It is a staging table because it modifies source data, but is not the final table that can be used for business value.
- `tmp_stg2.sql`: creates view for female patients from certain states. It is also a staging table.
- `tmp_combine_stgs.sql`: combines the views from `tmp_stg1.sql` and `tmp_stg2.sql`. Uses Jinja to reference these two models. Saved as a table since it is the "final" version of this data.

**Incorporating Jinja**:
- `tmp_pivot.sql`: SQL query that makes a pivoted version of the table from `ref_create_table.sql` 
- `tmp_pivot_jinja.sql`: the same query as `tmp_pivot.sql`, but written with Jinja logic.

**Trying a basic macro**:
- `macros/tmp_macro.sql`: a simple macro written in Jinja to change 'female' to 'F' and 'male' to 'M'
- `tmp_testing_macro.sql`: using the Jinja macro above in a simple SQL query

#### YML
- `src_lindsay.yml`: describes the data *sources* -- the raw Syntegra data (e.g., SANDBOX_CLAIMS.core.patient). Can add tests to these files, to check, for example, if the patient_id column has all unique and non-null values.
    - *I can't get these tests to run correctly...keep getting an error*
- `stg_lindsay.yml`: describes the data *models* -- the SQL code (e.g., tmp_combine_stages.sql). Can add tests to these models in the same way you can test the raw data.
    - *I can't get these tests to run correctly...keep getting an error*


#### MD
- `lindsay_notes.md`: simple notes about dbt commands (e.g., `dbt run` vs `dbt build`) and Jinja code.
- `model_doc.md`: Jinja code describing a specific sql model (`tmp_combine_stgs`). This is referenced in the yml file (`stg_lindsay.yml`), in the description line under this model name.