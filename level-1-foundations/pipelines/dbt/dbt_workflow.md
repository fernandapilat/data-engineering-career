# dbt Workflow & Setup Guide

This guide compiles the essential steps to connect dbt to your database or Data Warehouse, along with a reference of the main utility CLI commands for daily operations.

---

## 1. Connecting dbt to Your Data Warehouse

The connection between your dbt project and the target database is managed through the **`profiles.yml`** file, located in your local user directory:
* **Windows:** `C:\Users\<Your_Username>\.dbt\profiles.yml`
* **Linux/Mac:** `~/.dbt/profiles.yml`

> **Note:** The top-level profile key (e.g., `my_project`) must match the profile name specified in your `dbt_project.yml` file.

### Connection Examples (`profiles.yml`)

#### Option A: PostgreSQL
```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: postgres
      password: your_password
      port: 5432
      dbname: target_database
      schema: public
      threads: 4
```

#### Option B: Google BigQuery
```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-gcp-project-id
      dataset: dbt_staging
      threads: 4
      keyfile: C:\path\to\your\gcp-key.json
```

#### Option C: Snowflake
```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: xy12345.us-east-1
      user: your_username
      password: your_password
      role: TRANSFORMER
      database: YOUR_DATABASE
      warehouse: COMPUTE_WH
      schema: dbt_staging
      threads: 4
```

### Connection Validation Steps

1. Activate your virtual environment (`.\venv\Scripts\Activate.ps1`).
2. Ensure the correct database adapter is installed (e.g., `pip install dbt-postgres`, `dbt-bigquery`, or `dbt-snowflake`).
3. Create or update the `profiles.yml` file in the `.dbt` directory.
4. Run the diagnostic command in your terminal:
   ```bash
   dbt debug
   ```
   *If configured correctly, the terminal output will end with `Connection test: OK`.*

---

## 2. Essential dbt CLI Commands

### Diagnostics and Dependencies
| Command | Description |
| :--- | :--- |
| `dbt debug` | Validates database connectivity, credentials, and project configuration files (`profiles.yml` and `dbt_project.yml`). |
| `dbt deps` | Downloads and updates all dbt packages declared in `packages.yml`. |
| `dbt parse` | Checks YAML and Jinja syntax across the project without executing queries against the target database. |

### Model Execution (`run`)
| Command | Description |
| :--- | :--- |
| `dbt run` | Compiles and runs all transformation models across the project. |
| `dbt run --select model_name` | Executes only the specified model. |
| `dbt run --select +model_name` | Executes the specified model and all of its upstream dependencies. |
| `dbt run --select model_name+` | Executes the specified model and all of its downstream dependencies. |
| `dbt run --select path:models/staging` | Executes all models contained within a specific directory. |

### Testing, Quality, and Recovery
| Command | Description |
| :--- | :--- |
| `dbt test` | Executes all data quality tests declared in schema configuration files (`schema.yml`). |
| `dbt test --select model_name` | Runs data quality tests associated with a specific model. |
| `dbt retry` | Re-executes only the nodes that failed during the previous `dbt run` or `dbt build` execution. |

### Combined Workflows and Data Loading
| Command | Description |
| :--- | :--- |
| `dbt seed` | Loads static CSV files from the `seeds/` directory into the target database. |
| `dbt snapshot` | Executes snapshot strategies (SCD Type 2) defined in the project. |
| `dbt build` | Executes seeds, models, snapshots, and tests in DAG dependency order. |

### Documentation and Lineage
| Command | Description |
| :--- | :--- |
| `dbt docs generate` | Compiles project metadata and generates the `catalog.json` and `manifest.json` documentation files. |
| `dbt docs serve` | Launches a local web server to inspect model documentation, column descriptions, and the Directed Acyclic Graph (DAG). |