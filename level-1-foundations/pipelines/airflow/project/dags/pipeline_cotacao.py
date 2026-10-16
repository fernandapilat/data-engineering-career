"""USD-BRL exchange rate pipeline DAG — daily fetch via AwesomeAPI and 7-day history consolidation."""

from datetime import datetime, timedelta

from airflow.decorators import dag, task

import helpers.cotacao as cotacao_helper
from helpers.callbacks import notificar_falha

url_api = "https://economia.awesomeapi.com.br/last/USD-BRL"
pasta_raw = "/opt/airflow/data/cotacao/raw"
caminho_consolidado = "/opt/airflow/data/cotacao/consolidated/historico_7dias.csv"


args_padrao = {
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
    "on_failure_callback": notificar_falha,
}


@dag(
    dag_id="pipeline_cotacao",
    description="Fetches USD-BRL exchange rate and consolidates the last 7 days history",
    start_date=datetime(2025, 1, 14),
    schedule=None,
    catchup=False,
    default_args=args_padrao,
    tags=["exchange_rate", "financial"],
)
def pipeline_cotacao():

    @task()
    def buscar_e_salvar_cotacao():
        """Fetches exchange rate from the API and saves the raw JSON to the raw folder."""
        cotacao = cotacao_helper.buscar_cotacao(url_api)
        cotacao_helper.salvar_json_bruto(cotacao, pasta_raw)

    @task()
    def consolidar():
        """Reads the JSON files from the last 7 days and generates the consolidated CSV."""
        cotacao_helper.consolidar_historico(pasta_raw, caminho_consolidado)

    buscar_e_salvar_cotacao() >> consolidar()


pipeline_cotacao()