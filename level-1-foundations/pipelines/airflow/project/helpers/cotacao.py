"""Helper module for the USD-BRL exchange rate pipeline."""

import json
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
import requests


def buscar_cotacao(url: str) -> dict:
    """Fetches the USD-BRL exchange rate from AwesomeAPI.

    Args:
        url: AwesomeAPI endpoint for USD-BRL.

    Returns:
        Dictionary containing exchange rate data.

    Raises:
        requests.HTTPError: If the API returns an HTTP error status.
        ValueError: If the response does not contain the expected fields.
    """
    response = requests.get(url, timeout=30)
    response.raise_for_status()

    dados = response.json()

    # Validate the presence of the main key in the API response
    if "USDBRL" not in dados:
        raise ValueError("API response does not contain the 'USDBRL' field")

    cotacao = dados["USDBRL"]
    campos_obrigatorios = ["bid", "ask", "high", "low", "create_date"]

    # Ensure all required exchange rate fields exist
    for campo in campos_obrigatorios:
        if campo not in cotacao:
            raise ValueError(f"Required field missing from response: {campo}")

    return cotacao


def salvar_json_bruto(cotacao: dict, pasta_destino: str) -> str:
    """Saves the raw exchange rate JSON.

    Args:
        cotacao: Dictionary returned by the API.
        pasta_destino: Directory where the JSON file will be saved.

    Returns:
        Full path of the saved file.
    """
    # Ensure target directory exists
    Path(pasta_destino).mkdir(parents=True, exist_ok=True)

    data_str = datetime.now().strftime("%Y-%m-%d")
    caminho = Path(pasta_destino) / f"cotacao_{data_str}.json"

    # Persist raw JSON response
    with open(caminho, "w", encoding="utf-8") as f:
        json.dump(cotacao, f, ensure_ascii=False, indent=2)

    return str(caminho)


def consolidar_historico(pasta_raw: str, caminho_consolidado: str) -> str:
    """Consolidates the last 7 days of exchange rates into a single CSV.

    Args:
        pasta_raw: Directory containing daily raw JSON files.
        caminho_consolidado: Path for the final consolidated CSV file.

    Returns:
        Path of the consolidated file.
    """
    # Generate valid date set for the last 7 days window
    hoje = datetime.now().date()
    datas_validas = {
        (hoje - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)
    }

    registros = []
    pasta = Path(pasta_raw)

    # Filter and parse raw JSON files matching the date criteria
    for arquivo in sorted(pasta.glob("cotacao_*.json")):
        data_arquivo = arquivo.stem.replace("cotacao_", "")
        if data_arquivo not in datas_validas:
            continue

        with open(arquivo, "r", encoding="utf-8") as f:
            dados = json.load(f)

        registros.append({
            "data": data_arquivo,
            "abertura": float(dados.get("bid", 0)),
            "maxima": float(dados.get("high", 0)),
            "minima": float(dados.get("low", 0)),
            "fechamento": float(dados.get("ask", 0)),
        })

    # Sort historical records and save to CSV
    df = pd.DataFrame(registros)
    df = df.sort_values("data")

    Path(caminho_consolidado).parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(caminho_consolidado, index=False)

    return caminho_consolidado