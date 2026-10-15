"""
Helpers for the Vende+ sales pipeline.
This file contains all business logic in Python/Pandas 
(Extraction, Transformation, and Load) isolated from Airflow orchestration.
"""

import os
from pathlib import Path
import pandas as pd

# Quality contract: mandatory columns that the sales CSV must contain
COLUNAS_ESPERADAS = [
    "data",
    "pedido_id",
    "produto",
    "categoria",
    "quantidade",
    "valor_unitario",
]


def extrair_vendas(caminho_arquivo: str) -> dict:
    """
    STEP 1: EXTRACTION AND VALIDATION
    Reads the raw sales CSV and validates if the structure is sound.
    """
    # 1. Check if the physical file exists on disk
    if not os.path.exists(caminho_arquivo):
        raise FileNotFoundError(f"File not found: {caminho_arquivo}")

    # 2. Load the CSV into a Pandas DataFrame
    df = pd.read_csv(caminho_arquivo)

    # 3. Validate if the file is empty
    if df.empty:
        raise ValueError(f"Empty file: {caminho_arquivo}")

    # 4. Validate if all mandatory columns are present
    colunas_faltando = set(COLUNAS_ESPERADAS) - set(df.columns)
    if colunas_faltando:
        raise ValueError(f"Missing columns in the file: {colunas_faltando}")

    # 5. Return useful metadata for Airflow to record in logs
    return {
        "caminho": caminho_arquivo,
        "linhas": len(df),
    }


def transformar_vendas(caminho_entrada: str, caminho_saida: str) -> str:
    """
    STEP 2: TRANSFORMATION (BUSINESS LOGIC)
    Reads raw data, computes business metrics, and aggregates by category.
    """
    df = pd.read_csv(caminho_entrada)

    # Create the total value column (Quantity * Unit Price)
    df["valor_total"] = df["quantidade"] * df["valor_unitario"]

    # Group data by product Category
    resumo = (
        df.groupby("categoria")
        .agg(
            total_pedidos=("pedido_id", "count"),
            valor_total_brl=("valor_total", "sum"),
        )
        .reset_index()
    )

    # Calculate average ticket size and round values to 2 decimal places
    resumo["ticket_medio_brl"] = (
        resumo["valor_total_brl"] / resumo["total_pedidos"]
    ).round(2)
    resumo["valor_total_brl"] = resumo["valor_total_brl"].round(2)

    # Ensure the temporary destination directory exists before saving
    Path(caminho_saida).parent.mkdir(parents=True, exist_ok=True)
    
    # Save the transformed result to an intermediate CSV
    resumo.to_csv(caminho_saida, index=False)

    return caminho_saida


def carregar_resumo(caminho_transformado: str, caminho_final: str) -> str:
    """
    STEP 3: LOAD / FINAL DELIVERY
    Takes the processed file and moves it to the final output directory.
    """
    # Ensure the final output directory exists
    Path(caminho_final).parent.mkdir(parents=True, exist_ok=True)

    # Read the transformed file and write it to the pipeline's final destination
    df = pd.read_csv(caminho_transformado)
    df.to_csv(caminho_final, index=False)

    return caminho_final