{% macro require_enforced_contract() %}
    {%- if env_var('DBT_ENVIRONMENT') in ('DEV', 'CI') %}
        {%- if execute %}
        {%- if model.access == 'public' and model.contract.enforced == false %}
            {%- set message = "\n⚠️ Missing contract enforcement, which must be applied for public models." %}
            {%- do exceptions.raise_compiler_error(message) %}
        {%- else %}
            select 'pass' as check_status
        {%- endif %}
        {%- endif %}
    {%- else %}
        -- no-op
        select 'no-op' as check_status
    {%- endif %}
{% endmacro %}
