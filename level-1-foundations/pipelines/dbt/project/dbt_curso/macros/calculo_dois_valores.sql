{% macro calculo_dois_valores(valor1, valor2) %}
    {# 
      Macro: calculo_dois_valores
      Description: Takes two numeric values/columns as arguments and generates 
                   an inline SQL addition expression.
      Params:
        - valor1: First numeric value or column reference
        - valor2: Second numeric value or column reference
    #}
    {{ valor1 }} * {{ valor2 }}
{% endmacro %}