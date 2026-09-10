# Data Engineering: dbt - Modern Data Transformations

## 1. Introduction and Environment Setup

### 1.1. What is dbt and where does it fit?

**a) Concept and Purpose of dbt**
* **What dbt stands for:** *Data Build Tool*.
* **Main goal:** Transform data within the modern Analytics Engineering ecosystem using SQL.

**b) Where dbt fits in the data pipeline (The "T" in ELT)**
* **What dbt DOES NOT do:**
  * It does not perform data ingestion or extraction (e.g., fetching from APIs, reading files directly).
  * It does not load raw data into the database/warehouse.
* **What dbt DOES:**
  * Operates exclusively **after** data has been loaded into the database.
  * Transforms, organizes, standardizes, and prepares raw data for analysis and consumption.

**c) How dbt Works in Practice**
* **SQL Models:** Transformations are written as SQL queries and organized into models within the project.
* **In-database Execution:** dbt does not process data in its own memory. It pushes SQL queries to leverage the processing power of the Data Warehouse / Database itself.
* **Output:** Automatically creates curated `tables` or `views` directly inside the database.
* **Key Advantages:** High scalability and performance by utilizing native database processing capabilities.

**d) Hands-on Course Project**
* **Scenario:** Real-world e-commerce dataset containing inconsistencies, duplicates, and lack of standardization.
* **Project Deliverables:**
  * Cleaning and handling raw data issues.
  * Building structured, layered analytical models.
  * Implementing automated data quality tests.
  * Generating comprehensive project documentation.
  * Building an end-to-end data transformation pipeline.

### 1.2. Case Study Overview

**a) Business Context**
* **Scenario:** E-commerce company selling products online with existing customer, order, and product records.
* **Core Problem:** Operational systems generate raw data that is unorganized and not prepared for analytical querying or decision-making.
* **Engineering Scope:** Focus strictly on transforming existing database records into reliable analytical models (excluding ingestion/extraction).

**b) Dataset Overview and Data Quality Issues**
* **Target Entities:**
  * Customers (basic profiles: names, emails).
  * Orders (transaction records per customer).
  * Order Items (granular products purchased within each order).
  * Products (item catalog details).
* **Identified Data Quality Problems:**
  * Null or duplicate email addresses.
  * Inconsistent date formatting across tables.
  * Numerical prices incorrectly stored as text string types.
  * Invalid or null values.
  * Fully duplicate records.
  * Orphaned records (e.g., orders lacking associated customer IDs or nonexistent products).

**c) Transformation Strategy with dbt**
* **Layered Architecture Approach:**
  1. Cleaning and standardizing raw inputs.
  2. Integrating and enriching business rules across models.
  3. Building final, production-ready analytical tables for BI and dashboards.
* **Next Steps:** Setting up the local development environment and installing necessary tooling.

### 1.3. Creating the Raw Layer

**a) Concept of the Raw Layer**
* **Definition:** The entry point of the pipeline holding unrefined, unprocessed data as delivered by source operational systems.
* **Characteristics:** Contains native flaws, duplicates, null values, and inconsistent formatting without pre-cleansing.
* **Purpose:** Serves as the immutable source of truth that dbt will transform into reliable analytical datasets.

**b) Database Setup and Local Working Directory**
* **Database Creation:** Configured a PostgreSQL database named `dbt_curso` via pgAdmin.
* **Directory Structure:** Created a local project root (`/dbt`) containing three primary working subfolders:
  * `/dados` (Raw source CSV files: `clientes.csv`, `produtos.csv`, `pedidos.csv`, `itens_pedido.csv`).
  * `/esquemas` (Schema definitions).
  * `/SQL` (DDL and DML scripts).

**c) Schema Definition and Execution**
* Executed script `01_criar_tabelas_raw.sql` to instantiate the target `raw` schema and source tables (`clientes`, `produtos`, `pedidos`, `itens_pedido`).

**d) Data Loading**
* Executed script `02_carregar_csv_raw.sql` using PostgreSQL's native `COPY` command to populate the tables with raw data from the CSV files.

**e) Initial Data Exploration & Verification**
* Verified data ingestion by executing basic `SELECT` queries on `raw.clientes` and `raw.pedidos`.
* **Observed anomalies in ingested data:**
  * Null email addresses in `raw.clientes`.
  * Duplicate records in `raw.clientes`.
  * Non-standardized date formats stored as string types across multiple tables (`data_cadastro`, `data_pedido`, `data_validade`).

**f) Next Steps**
* Initialize the dbt project and configure database connection credentials.

### 1.4. Environment Setup

**a) Software & Tooling Requirements**
* **Python (v3.11.9):** Downloaded 64-bit Windows installer from the official site (`python.org`).
  * **Critical Step:** Enabled *Add python.exe to PATH* during setup.
  * **Verification Commands:**
    * Check Python: `python --version`
    * Check pip: `python -m pip --version`
    * Upgrade pip: `python -m pip install --upgrade pip`

* **Visual Studio Code (VS Code):** Installed as the primary IDE (`code.visualstudio.com`).
  * **Configuration:** Configured to always *Run as Administrator*.
  * **Extensions:** Installed the official **Python** extension.

* **PostgreSQL & pgAdmin 4:** Database engine and graphical management tool.
  * Installed default components (Database Server, pgAdmin 4, Command Line Tools).
  * Default Port: `5432`
  * Configured superuser (`postgres`) credentials and verified connection via `localhost` inside pgAdmin 4.

* **dbt Core & Postgres Adapter:** Transformation framework and PostgreSQL connector.
  * **Installation Command:** `python -m pip install dbt-core dbt-postgres`
  * **Verification Command:** `dbt --version` (verifies both core package and active Postgres adapter plugin).

**b) Next Steps**
* Initialize the dbt workspace and connect it to the target PostgreSQL database.