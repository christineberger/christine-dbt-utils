{% macro require_enforced_contracts(results, model_paths=[]) %}
    {%- if execute %}
        {%- if env_var('DBT_ENVIRONMENT') in ('DEV', 'CI') %}
            {%- set macro_ns = namespace(path_models=[], error=false, models_without_enforced_contracts=[]) %}
            {%- set model_results = results | selectattr('node.resource_type', 'eq', 'model') %}
                
            {%- if model_paths | length == 0 %}
                {%- set macro_ns.path_models = model_results %}
            {%- else %}
                {%- for path in model_paths %}
                    {%- for result in model_results %}
                        {%- if result.node.path.startswith(path) %}
                        {%- do macro_ns.path_models.append(result) %}
                        {%- endif %}
                    {%- endfor %}
                {%- endfor %}
            {%- endif %}

            {%- for model in macro_ns.path_models %}
                {%- if model.node.config.contract.enforced == false %}
                    {%- set macro_ns.error = true %}
                    {%- do macro_ns.models_without_enforced_contracts.append(model.node.path) %}
                {%- endif %}
            {%- endfor %}

            {%- if macro_ns.error %}
                {%- set preface_paths = "\n⚠️ Contracts must be enforced in these `/models/` subfolders: " ~ model_paths %}
                {%- set preface_models = "\n⛔️ The following models are missing enforced contracts:" %}
                {%- set errored_models = "\n    - " ~ macro_ns.models_without_enforced_contracts | join('\n    - ') %}
                
                {%- set error_message = preface_paths ~ preface_models ~ errored_models %}

                {%- do exceptions.raise_compiler_error(error_message) %}
            {%- endif %}
        {%- else %}
            {%- do log('Skipped contract enforcement check (checks are only implemented in development and CI builds)', info=true) %}
        {%- endif %}
    {%- endif %}
{% endmacro %}
