"""
Daily sales processing pipeline DAG for Vende+.
"""

from datetime import datetime, timedelta

import helpers.vendas as vendas_helper
from airflow.decorators import dag, task
from airflow.models import Variable
from airflow.sensors.filesystem import FileSensor

from helpers.callbacks import notificar_falha


# Default arguments applied to all tasks in the DAG
ARGS_PADRAO = {
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "on_failure_callback": notificar_falha,
}


@dag(
    dag_id="pipeline_vendas",
    start_date=datetime(2025, 1, 14),
    schedule="0 7 * * *",
    catchup=False,
    tags=["vendas"],
    default_args=ARGS_PADRAO,
)
def pipeline_vendas():
    
    @task
    def extrair_vendas(**context):
        """
        Task 1: Extracts raw sales data using the helper module.
        Reads the path configured via Airflow Variables based on the execution date (ds).
        """
        ds = context["ds"]
        dir_input = Variable.get("vendas_dir_input")
        caminho = f"{dir_input}/vendas_{ds}.csv"
        
        resultado = vendas_helper.extrair_vendas(caminho)
        print(f"File read: {resultado['caminho']} — {resultado['linhas']} lines")
        return resultado

    @task
    def transformar_vendas(**context):
        """
        Task 2: Transforms raw data into a category summary using the helper module.
        Reads from input and saves an intermediate summary to the temporary directory.
        """
        ds = context["ds"]
        dir_input = Variable.get("vendas_dir_input")
        dir_temp = Variable.get("vendas_dir_temp")
        
        caminho_entrada = f"{dir_input}/vendas_{ds}.csv"
        caminho_saida = f"{dir_temp}/resumo_categoria_{ds}.csv"
        
        vendas_helper.transformar_vendas(caminho_entrada, caminho_saida)
        print(f"Intermediate summary saved to: {caminho_saida}")

    @task
    def carregar_resumo(**context):
        """
        Task 3: Loads the processed summary into the final destination directory.
        Receives metadata from the extraction task to log total processed rows.
        """
        ds = context["ds"]
        dir_temp = Variable.get("vendas_dir_temp")
        dir_output = Variable.get("vendas_dir_output")
        
        caminho_transformado = f"{dir_temp}/resumo_categoria_{ds}.csv"
        caminho_final = f"{dir_output}/resumo_categoria_{ds}.csv"
        
        vendas_helper.carregar_resumo(caminho_transformado, caminho_final)
        print(f"Final summary available at: {caminho_final}")
    

    # Task instantiation
    t_extrair = extrair_vendas()
    t_transformar = transformar_vendas()
    t_carregar = carregar_resumo()

    # Task execution flow (Dependency chaining)
    t_extrair >> t_transformar >> t_carregar


# Instantiate the DAG so Airflow can detect it
pipeline_vendas()