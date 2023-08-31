### Notes
When first log on:
- `poetry shell` to activate the environment
- `dbt --version` to make sure the snowflake plugin is working

Run:
- `dbt run` will run everything (creates all the models in the warehouse) in DAG order
- `dbt run --select lindsay+ `will run all the models in the lindsay folder
- runs do NOT allow for testing, so it will run even with failed data
- `dbt run --full-refresh`

Testing:
- `dbt test --select source:lindsay` or `dbt test --select source:src_lindsay` (???) should run tests in the source files, but **it's not working**
- `dbt test --select stg_lindsay` should run tests for the models in the lindsay folder, but it's **not working...**

Build:
- `dbt build` runs and tests at the same time (in DAG order)

Docs:
- `dbt docs generate` will find all documentation you've put in yml files and markdown (??) and make it pretty -- although I think this is mostly for dbt-cloud...
- can use `{% docs <name> %}` ... `{% enddocs %}` in a md file for lots of documentaiton. Then use this reference in a yml file with `description: '{{ doc("<name>") }}'`

Jinga:
- `dbt compile` will write all the jinja code in its analogous sql code so you know what the actual function looked like. The compiled code lives in `target/compiled`
- In a model, `select * from {{ ref ('tmp_stg2') }}` will pull the data built in a table/view in the `tmp_stg2.sql` file
- In a model, putting this block before the sql code will tell dbt to create this as a table instead of a view (which is the default setting): `{{ config(materialized='table') }}`
- ^ you could also do this in the main (?) yml file (I think `dbt_project.yml`) with `+materialized:table` under `models`
- Practice Jinga: http://jinja.quantprogramming.com/
- `{# ... #}` = comment
- `{% ... %}` = run python-y like commands in jinja
    - `{% set var_name = ['evie','cat'] %}`
    - `{%- set var_name = ['evie','cat'] -%}` does the same thing but eliminates annoying white space
- `{{ ... }}` = use the result  
    - `{{ var_name[0] }}` will print out the result
- for loop:
    `{% for i in var_name %}`
        `Item name: {{ i }}`
   ` {% endfor %}`
- if then:
   `{% set temp = 80 %}`
    `{% if temp < 65 %}`
        `Drink some hot tea!`
    `{% else %}`
        `Drink some beer!`
    `{% endif %}`
