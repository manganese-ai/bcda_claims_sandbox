{# gender: change 'female' to 'F' and 'male' to 'M' #}

{% macro shorten_gender(column_name, new_column_name) %}
    case 
        when {{column_name}} = 'female' then 'F'
        when {{column_name}} = 'male' then 'M'
        else NULL end as {{new_column_name}}
{% endmacro %}