"""Reusable callbacks for Vende+ DAGs."""

import logging

from airflow.models import Variable
from airflow.utils.email import send_email

log = logging.getLogger(__name__)


def notificar_falha(context):
    """Sends an email alert via SMTP Connection upon detecting a task failure."""
    # Extract contextual details from the failed task instance
    dag_id = context["dag"].dag_id
    task_id = context["task_instance"].task_id
    exec_date = context.get("logical_date") or context.get("data_interval_start")
    exception = context.get("exception")

    # Retrieve the alert recipient email from Airflow Variables
    destinatario = Variable.get("email_alertas")

    assunto = f"[Airflow] Failure in {dag_id}.{task_id}"
    corpo = f"""
    <h3>Failure detected in the Vende+ pipeline</h3>
    <ul>
      <li><b>DAG:</b> {dag_id}</li>
      <li><b>Task:</b> {task_id}</li>
      <li><b>Execution Date:</b> {exec_date}</li>
      <li><b>Error:</b> {exception}</li>
    </ul>
    """
    try:
        # Attempt to send the alert email using Airflow's built-in utility
        send_email(to=destinatario, subject=assunto, html_content=corpo)
    except Exception as e:
        # Log the failure without raising it, preventing suppression of the original task error
        log.error("Failed to send alert email: %s", e)