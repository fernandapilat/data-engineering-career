{% macro agregacao_soma(campo) %}
    {# 
      Macro: agregacao_soma
      Description: Wraps a specified column or expression in a SQL SUM() aggregation function.
      Params:
        - campo: The target numeric column or expression to be aggregated.
    #}
    SUM({{ campo }})
{% endmacro %}