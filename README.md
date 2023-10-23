# Claims DBT Sandbox

Based off the Tuva Medicare CCLF Connector, see their readme in README.tuva.md

## Set up

Install dbt 1.2+ using poetry:
- `pip install poetry`
- `poetry install`

Run the following
- `dbt deps`
- `dbt init` and enter your manganese snowflake creds
- `dbt debug`
- `dbt --version` # should have an up-to-date dbt-core and snowflake plugin

If applicable: go to `~/.dbt/profiles.yml` and update role

## Initial Data fetching

Poetry installs a global `bcda` shell for this project pointing to `src/main`

Configure environment in `.env` and `.env.local` for secret values. 
`bcda dataset download` - download the data from CMS
`bcda dataset parse` - parse the data from FIHR to CSV
`bcda dataset upload` - upload the data to snowflake

After this there might be additional processing before we can run this data through Tuva.

## Seed
Claims data is seeded from sample CCLF data available on [CMS's synthetic data](https://bcda.cms.gov/guide.html#try-the-api)
Place these files in the seeds/ folder

If the database is empty then you need to run:
- `dbt seed` - one time to seed the initial tables

## Run
- `dbt build --select path:./models`
- `dbt build --select cms_hcc`
- `dbt build --select pmpm`
