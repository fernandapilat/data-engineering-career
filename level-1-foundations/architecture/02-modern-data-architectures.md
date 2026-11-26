# Modern Data Architectures: DW, Data Lake, and Lakehouse

## 1. Transactional and Analytical Systems (OLTP vs. OLAP)
### 1.1 Overview and Architecture Roadmap
* **Objectives:**
  * Master modern analytical data architectures from the ground up, moving from operational systems to Data Warehouses, Data Lakes, Lakehouses, and Business Intelligence consumption.
  * Focus on core architectural principles and the synergy between different components of a data ecosystem.
* **Structure and Practical Case Study ("Minishop"):**
  * **Operational Foundation:** Explore transactional vs. analytical systems (OLTP vs. OLAP) and build the operational database for a sample e-commerce project ("Minishop").
  * **Data Warehousing and Modeling:** Study dimensional modeling, facts, and dimensions, and implement the Minishop Data Warehouse.
  * **ETL Processes:** Learn extraction, transformation, and loading mechanics (lookups, surrogate keys, Slowly Changing Dimensions (SCD), time dimensions, and load policies) applied to Minishop.
  * **Modern Architectures:** Transition into advanced paradigms, exploring Data Lake layers, flows, and the hybrid **Lakehouse** architecture.
  * **Consumption and Governance:** Build semantic layers for BI consumption (e.g., Power BI) and establish data governance policies to ensure quality and trust.
* **The Engineering Mindset:**
  * Writing SQL or building ad-hoc queries is only part of the role; true expertise in data engineering and architecture lies in understanding how the entire ecosystem connects to drive business value.

### 1.2 What is OLTP (Online Transaction Processing)
* **Definition & Core Purpose:**
  * **OLTP (Online Transaction Processing):** Operational database systems designed to support, record, and automate day-to-day business transactions (e.g., placing orders, updating inventory, processing payments).
  * Serves as the operational backbone of an enterprise; if the OLTP system fails, core business activities come to a complete halt.
* **Key Characteristics:**
  * **High Concurrency:** Handles thousands of simultaneous read/write operations cleanly without data corruption through lock management and isolation levels.
  * **Low Latency:** Optimized for targeted, point-lookup queries (typically indexed by primary keys) executing in milliseconds.
  * **Normalized Data Structures:** Highly normalized tables (3NF) to eliminate redundancy, ensure single-point-of-truth updates, and preserve operational integrity.
  * **ACID Guarantees:**
    * **Atomicity:** All steps in a transaction succeed, or the entire transaction rolls back (all-or-nothing).
    * **Consistency:** The database transitions strictly from one valid state to another, enforcing constraints.
    * **Isolation:** Concurrent execution of transactions yields the same state as if executed serially.
    * **Durability:** Committed transactions persist permanently, even in the event of system failures.
* **The "Minishop" Operational Flow:**
  * Placing an order triggers an atomic chain of events: generating the order header $\rightarrow$ inserting order line items $\rightarrow$ debiting inventory quantities $\rightarrow$ generating payment records.
* **Architectural Anti-Pattern:**
  * **Mixing Operational and Analytical Workloads:** Executing heavy analytical queries (e.g., historical revenue aggregation) directly against OLTP databases consumes hardware resources, creates table locks, increases latency, and degrades the end-user experience.

### 1.3 What is OLAP (Online Analytical Processing)
* **Definition & Core Purpose:**
  * **OLAP (Online Analytical Processing):** Analytical systems designed to query, aggregate, and process historical data to generate strategic business insights, performance dashboards, and executive reporting.
  * While OLTP records the *present* to run daily operations, OLAP analyzes the *past* to drive business strategy and long-term growth.
* **Key Characteristics:**
  * **Historical Perspective:** Stores large volumes of historical data across months, years, or decades to identify macro trends and seasonal patterns.
  * **Complex Aggregations:** Optimized for read-heavy, analytical queries involving joins, window functions, and functions like `SUM`, `AVG`, and `COUNT` across millions of rows.
  * **Read-Optimized Data Modeling:** Utilizes dimensional modeling patterns (e.g., Star Schema with central Fact tables and surrounding Dimension tables) rather than 3NF normalization to maximize query performance.
  * **Batch Data Loading:** Data is ingested periodically (daily, weekly, or monthly batch loads) rather than via real-time, low-latency individual row writes.
* **The "Minishop" Analytical Flow:**
  * Connects transactional operational data to a dimensional structure:
    * **Fact Table:** Stores numerical metrics (e.g., total sales revenue, order quantities).
    * **Dimension Tables:** Provide context (e.g., customer demographics, product categories, and time/calendar dimensions).
* **Architectural Trade-Off & Comparison:**
  * **OLTP:** *Runs the business.* Focuses on detail-level accuracy, row-level point lookups, and ACID-guaranteed atomic writes.
  * **OLAP:** *Evolves the business.* Focuses on aggregated views, multi-dimensional slicing and dicing, and mass read performance.
  * **Separation of Concerns:** Isolating OLAP workloads into dedicated analytical environments prevents table locking, resource contention, and operational degradation during checkout or payment processing.

### 1.4 Comparing OLTP and OLAP (Side-by-Side Architectural Summary)
* **Architectural Purpose:**
  * **OLTP (Operational):** Drives the daily operations of the business in real time (*runs the business*).
  * **OLAP (Strategic):** Delivers aggregated historical perspectives for decision-making (*evolves the business*).
* **Side-by-Side Comparison:**

| Dimension | OLTP (Online Transaction Processing) | OLAP (Online Analytical Processing) |
| :--- | :--- | :--- |
| **Primary Focus** | Day-to-day operations & live transactions | Strategic analysis & historical trends |
| **Time Horizon** | Present state / Real-time operational data | Historical data (months, years, decades) |
| **Query Nature** | Targeted point-lookups, simple CRUD actions | Complex queries, joins, windowing & aggregations |
| **Data Structure** | Highly normalized (3NF) to eliminate redundancy | Dimensional / Multi-dimensional (Star/Snowflake Schema) |
| **Optimization Target** | High concurrency, low latency, write consistency | High read throughput, massive scan performance |
| **Data Modifications** | Continuous real-time insert/update operations | Scheduled periodic batch loads |
| **Primary Users** | End-users, operational staff, automated APIs | Analysts, data scientists, executives, managers |
| **System Failure Impact**| Immediate loss of sales or operational outage | Delayed business intelligence & reporting |

* **Architectural Key Takeaways:**
  * **OLTP vs. OLAP Mindset:** OLTP records *what* happens (details); OLAP explains *why* it happened (aggregations).
  * **Workload Isolation:** Running heavy analytical workloads against operational databases creates contention for CPU, RAM, and storage I/O, leading to table locks and degraded user experience.
  * **Roadmap for "Minishop":** Moving forward, Minishop will establish two explicit, decoupled environments—a transactional OLTP database driving the application, and an analytical environment laying the groundwork for the Data Warehouse.

### 1.5 Designing the Minishop Operational OLTP System
* **Context & Core Objective:**
  * Before designing Data Warehouses or analytical layers, the operational **OLTP (Online Transaction Processing)** system must be explicitly defined as it serves as the single source of truth for all downstream analytical pipelines.
  * **Minishop Business Scope:** An e-commerce platform processing physical product sales online—handling customer registration, product catalog browsing by categories, cart checkout, order processing, payments, inventory movements, and invoicing.

* **Conceptual Data Modeling (Chen ERD Methodology):**
  * **Requirements Gathering:** Conducted interviews with key business stakeholders to identify operational workflows, business rules, and entities.
  * **Entity-Relationship Identification:** Extracted nouns (Entities & Attributes) and verbs (Relationships) from business specifications:
    * **Entities:** `Customer`, `Order`, `OrderItem`, `Product`, `Category`, `Inventory`, `Invoice`.
    * **Relationships:** Customer *places* Order, Order *contains* OrderItem, OrderItem *references* Product, Product *belongs to* Category, OrderItem *debits* Inventory, Order *generates* Invoice.
  * **Cardinality Definition:** Evaluated operational rules to assign exact relationship bounds:
    * `Customer` to `Order`: $1 : N$ (One customer can place multiple orders; an order belongs to exactly one customer).
    * `Order` to `OrderItem`: $1 : N$ (An order contains one or more line items).
    * `OrderItem` to `Product`: $N : 1$ / $0 : N$ (A product can exist without being sold; an item line references one specific product).
    * `Product` to `Category`: $N : 1$ / $0 : 1$ (Categories can exist before products are assigned).
    * `Order` to `Invoice`: $1 : 1$ (Business rule: direct single payment/invoice per order).
    * `OrderItem` to `Inventory`: $1 : 1$ (Each ordered item triggers a specific inventory reduction movement).

* **Architectural Takeaways:**
  * **Business Rule Validation:** ER Diagrams (Chen notation) represent the *conceptual model*. Validating cardinailities directly with business domain experts ensures that the logical schema faithfully mirrors operational realities.
  * **Transition to Logical Design:** The conceptual ER diagram provides the blueprint for translating business entities and relationships into physical relational database artifacts (Tables, Columns, Primary Keys, and Foreign Keys).

### 1.6 Logical OLTP Modeling and Schema Implementation
* **Conceptual-to-Logical Mapping Rules:**
  * **Entities to Tables:** Strong entities identified in the conceptual model (`Customer`, `Order`, `Product`, `Category`, `OrderItem`, `Invoice`, `Inventory`) map directly to relational tables.
  * **Attributes to Columns:** Entity properties become table attributes. Each table receives a Primary Key (PK) to uniquely identify individual records (e.g., `customer_id`, `order_id`).
  * **1:N Relationships (Foreign Keys):** Implemented by placing a Foreign Key (FK) on the "N" side of the relationship (e.g., `customer_id` added to `Order`, `category_id` added to `Product`).
* **Special Relational Implementations in Minishop:**
  * **Composite Primary Key (`OrderItem`):** The item table resolves relationships between `Order` and `Product` ($1 : N$) using a composite Primary Key made of `(order_id, product_id)`, which also function as Foreign Keys.
  * **1:1 Relationships & Unique Constraints (`Invoice`):** Decoupled into a standalone entity rather than an attribute on `Order` to support future financial/billing domain expansion. Enforced via a `UNIQUE` constraint on `order_id`.
  * **Decoupled Inventory Control (`Inventory`):** Designed as an independent entity to log individual inventory stock movements (debits/credits) tied to orders, allowing scalable integration with future procurement systems.

* **Complete Minishop OLTP Blueprint:**
  * Establishes a 3NF normalized schema enforcing referential integrity, low-latency writes, and strict transaction isolation—completing the operational baseline for the course.

### 1.7 Supplemental Reading: Definition of Cardinalities
* **Concept and Importance:**
  * **Cardinalities:** Quantitative rules that define how instances of one entity relate to instances of another, establishing minimum and maximum occurrences allowed.
  * Ensure the data model accurately reflects business constraints and preserves stored data integrity.
* **Business Question Approach:**
  * Using practical operational questions (e.g., "How many orders can a customer place?", "How many items does each order include?") to determine relationship types ($1:1$, $1:N$, or $N:N$).
  * Promotes direct validation with domain experts to align the conceptual model with operational reality.
* **Impact on the Data Model:**
  * Guides the transition from conceptual to logical models by defining the correct application of primary and foreign keys.
  * Many-to-many ($N:N$) relationships require associative tables to eliminate ambiguities and simplify future queries.
  * Prevents structural inconsistencies, such as orphaned records or business rule violations.
* **Practical Considerations:**
  * Involves handling exceptions, edge cases, and optional relationships that allow null values or the absence of records.
  * Requires balancing operational flexibility with referential integrity constraints.

## 2: Data Warehouse and Dimensional Modeling

### 2.1 Concept of the Data Warehouse
* **Introduction & Business Motivation:**
  * While operational OLTP systems (like the Minishop e-commerce app) handle day-to-day transactions, they struggle with complex, historical queries (e.g., multi-year revenue aggregation by category for recurring customers).
  * Executing heavy analytical queries directly against OLTP databases creates resource contention, locking, and severe performance degradation that can impact customer sales.
* **Bill Inmon's Classical Definition:**
  * **Subject-Oriented:** Focuses on core business themes (e.g., sales, customers, products) rather than individual application processes.
  * **Integrated:** Consolidates and harmonizes data from diverse operational sources (MySQL transactional databases, external payment gateways, marketing systems, flat files) into a single source of truth.
  * **Non-Volatile:** Preserves historical states by loading data without altering past records, ensuring analytical stability over time.
  * **Time-Variant:** Tracks the evolution of business data across months, years, or decades to enable historical trend analysis, seasonal tracking, and forecasting.
* **Architectural & Modeling Differences:**
  * Adopts dimensional modeling structures (such as the Star Schema with a central Fact table and surrounding Dimension tables) to simplify joins and accelerate mass aggregations.
  * Separates operational execution from strategic intelligence, allowing OLTP and Data Warehouse systems to coexist and complement each other without resource friction.


### 2.2 Foundations of Dimensional Modeling
* **Core Philosophy:**
  * Unlike relational OLTP modeling (which centers on processes and normalization), **Dimensional Modeling** is driven by business questions: *What* do we want to analyze, and *How* do we want to analyze it?
* **Indicators vs. Dimensions:**
  * **Indicators (Metrics/Measures):** Numerical, measurable facts that answer *What* is being analyzed (e.g., total sales revenue, units sold).
  * **Dimensions (Perspectives):** Contextual attributes that answer *How* metrics are observed, sliced, and diced (e.g., by customer, product, region, or time).
* **The Indicator-Dimension Matrix:**
  * A analytical design tool placing Dimensions as columns and Indicators as rows to identify meaningful intersections and business contexts.
  * Inputs are gathered by interviewing business users regarding decision-making needs rather than system mechanics.
* **Granularity & Dimension Organization:**
  * **Input (Leaf) Level:** The root entity directly tied to the generation of the indicator (e.g., `Customer` is the input level for sales transactions, while `City` is a higher-level attribute/hierarchy).
  * **Hierarchical Levels vs. Attributes:**
    * **Hierarchical Levels:** Formal entities with unique codes/descriptors forming structured parent-child relationships (e.g., $Day \rightarrow Month \rightarrow Quarter \rightarrow Year$ or $City \rightarrow State \rightarrow Country$).
    * **Attributes:** Descriptive, low-cardinality flags or text buckets (e.g., age bracket `[Young, Adult, Senior]` or city type `[Capital, Interior]`).
* **The Central Role of the Time Dimension:**
  * In OLTP, time is a simple operational timestamp. In a Data Warehouse, **Time** is a required, fully structured dimension.
  * Acts as the universal analytical axis present across all indicators, incorporating calendar hierarchies, fiscal periods, holidays, and business flags to enable trend detection and seasonality analysis.

### 2.3 Translating the Matrix into Physical Tables (Star, Snowflake, and Parent-Child Schemas)
* **Transitioning to Physical Design:**
  * Once dimensions, input (leaf) levels, hierarchical levels, and attributes are mapped in the Indicator-Dimension Matrix, they must be translated into physical Data Warehouse tables.
  * The two foundational dimensional architectures for physical implementation are the **Star Schema** and the **Snowflake Schema**.
* **Star Schema vs. Snowflake Schema:**

| Characteristic | Star Schema | Snowflake Schema |
| :--- | :--- | :--- |
| **Structure** | Central Fact table surrounded by fully denormalized Dimension tables | Central Fact table surrounded by normalized, multi-table Dimension hierarchies |
| **Join Complexity** | Low (single-hop joins from Fact to Dimension) | High (multi-hop joins across hierarchical sub-tables) |
| **Query Performance** | Superior read and aggregation throughput | Slower due to increased join overhead |
| **Storage & Redundancy** | Higher storage footprint due to repeated upper-level attributes | Minimal data redundancy; smaller storage footprint |
| **Schema Maintenance** | Harder to modify or add new attributes to large tables | Easier structural updates and attribute modifications |

* **Handling Regular vs. Irregular (Ragged) Hierarchies:**
  * **Regular Hierarchies:** Every leaf member traverses the exact same number of intermediate levels to reach the root (e.g., $City \rightarrow State \rightarrow Country$). Supported cleanly by both Star and Snowflake schemas.
  * **Irregular (Ragged) Hierarchies:** Occur when intermediate levels are skipped (e.g., Principality of Monaco, where the city maps directly to the country without an intermediate state level).
    * *Snowflake Limitation:* Structurally rigid; struggles to represent missing intermediate tables.
    * *Star Workaround:* Requires allowing `NULL` values in intermediate level columns.
* **Parent-Child Modeling for Complex Hierarchies:**
  * Stores hierarchical relationships as self-referencing node pairs (`child_id`, `parent_id`) within a single table rather than fixed level columns (root nodes have `parent_id = NULL`).
  * **Pros:** Accommodates both regular and irregular hierarchies of arbitrary depth dynamically.
  * **Cons:** Requires complex recursive self-joins (`WITH RECURSIVE`) to aggregate data, which can degrade query performance on massive Data Warehouse volumes.

### 2.4 Building the Minishop Data Warehouse (Dimensional Matrix Design)
* **Expanding the Analytical Scope Beyond OLTP:**
  * Designing a Data Warehouse requires blending technical OLTP schema analysis with executive stakeholder interviews to align the model with business strategy rather than mere operational mechanics.
  * **Derived & Enriched Attributes:** Added demographic and channel dimensions not explicitly isolated in basic transactional setups (e.g., customer address $\rightarrow$ City/State; birth date $\rightarrow$ Age Bracket; sales channel $\rightarrow$ Web/Mobile App; product promotion flags; invoice due dates).
* **Iterative & Incremental Data Warehouse Strategy:**
  * Enterprise Data Warehouses are implemented incrementally by business domain (starting with Sales, then expanding to Inventory, Procurement, and Finance) while maintaining shared conformed dimensions across domains.
* **Indicators (Metrics) & Business Context:**
  * **Commercial Metrics:** Quantity Sold, Average Unit Price, and Total Order Value.
  * **Inventory Metrics:** Inventory Outflow (tracking stock deductions tied to sales).
  * **Financial Metrics:** Accounts Receivable (to be collected) and Overdue Balance (past-due invoices).
* **Evaluating Indicator-Dimension Intersections (Business Relevance vs. Technical Feasibility):**
  * Even if foreign keys allow joining two entities technically, intersections must only be modeled if they provide actionable managerial value:
    * **Sales Indicators:** Cross with `Customer`, `City`, `State`, `Age Bracket`, `Product`, `Category`, `Promotion Status`, `Access Channel`, and `Time`.
    * **Inventory Outflow:** Cross only with `Product`, `Category`, and `Time` (warehouse operations do not require slicing stock deductions by customer age brackets).
    * **Financial Indicators:** Cross with `Customer` (and geographic/demographic derivatives), `Time`, and `Aging List` (financial due-date buckets such as 0–15 days, 16–30 days), omitting product-level granularity.
* **Business Terminology Alignment:**
  * Dimension names must reflect business vocabulary rather than technical source column names (e.g., naming the payment delinquency bucket dimension **Aging List** per finance team conventions).

### 2.5 Fact Tables, Degenerate Attributes, and Surrogate Keys
* **Grouping Indicators into Fact Tables:**
  * Analyze the Indicator-Dimension Matrix row by row: indicators sharing the exact same set of intersecting dimensions belong together in the same **Fact Table**.
  * **Composite Primary Keys:** A Fact table's granularity is defined by the composite Primary Key formed by the leaf-level Foreign Keys of its intersecting dimensions. Events matching the exact same dimension combination are aggregated rather than duplicated.
* **Degenerate Attributes (Degenerate Dimensions):**
  * Operational identifiers directly tied to a business event that do not justify their own standalone dimension table (e.g., `order_number`, `invoice_number`).
  * Stored directly inside the Fact table.
  * **Granularity & Performance Tradeoff:** Including degenerate attributes increases fact table granularity (preventing row consolidation and multiplying row counts) and widens the table. They should only be included when genuinely required for strategic decisions; otherwise, operational details belong in auxiliary drill-through tables.
* **Surrogate Keys (SK):**
  * Sequential, meaningless integer identifiers generated internally within the Data Warehouse to serve as the Primary Key for dimension leaf levels and Foreign Keys inside Fact tables.
  * **Natural Keys (NK):** Original business identifiers from source OLTP systems are retained as regular attributes within dimension tables for lineage and tracking, never as primary join keys.
  * **Architectural Benefits:**
    * **Join Performance:** Integer-to-integer joins execute significantly faster than string, composite, or long alphanumeric key joins across billions of fact rows.
    * **Storage & Indexing:** Compact integer keys reduce disk footprint and produce smaller, faster database indexes (including for the `Time` dimension, where dates are mapped to integer keys).

### 2.6 Completing the Minishop Data Warehouse Schema (Dimensions, Fact Tables, and Mixed Modeling)
* **Consolidating Dimensions (Column-wise Analysis):**
  * Candidates sharing the exact same indicator intersections are evaluated to form unified dimensions:
    * **`Customer` Dimension (Star Schema):** Consolidates `Customer` (input/leaf level), `City`, and `State` into a formal geographic hierarchy ($\text{State} \rightarrow \text{City} \rightarrow \text{Customer}$), while `Age Bracket` (derived from birth date) is stored as a descriptive attribute.
    * **`Product` Dimension (Snowflake Schema):** Consolidates `Product` (leaf level) and `Category` (upper level) into a normalized two-table hierarchy ($\text{Category} \rightarrow \text{Product}$) for instructional demonstration.
    * **Independent Dimensions (`Promotion` & `Access Channel`):** Although sharing similar intersections, they exhibit a many-to-many ($N:M$) relationship with products and orders (any product can be bought on promotion across any device channel), keeping them as standalone dimensions.
    * **`Aging List` Dimension:** Standalone financial dimension categorizing receivable and overdue intervals.
    * **`Time` Dimension:** Standardized universal axis crossing all facts, containing calendar hierarchies ($\text{Year} \rightarrow \text{Semester} \rightarrow \text{Quarter} \rightarrow \text{Bimester} \rightarrow \text{Month} \rightarrow \text{Week} \rightarrow \text{Day}$) and operational flags (weekday, weekend, holiday).

* **Defining the Minishop Fact Tables (Row-wise Analysis):**
  * Grouping indicators with identical dimension intersections yields three distinct Fact tables, each anchored by composite Primary/Foreign Surrogate Keys (`PK`, `SK`, `FK`):
    1. **`FACT_SALES` (`FATO 1`):**
       * *Keys:* `customer_sk`, `product_sk`, `promotion_sk`, `access_sk`, `time_sk`
       * *Measures:* `quantity`, `unit_price`, `total_value`
    2. **`FACT_INVENTORY` (`FATO 2`):**
       * *Keys:* `product_sk`, `time_sk`
       * *Measures:* `inventory_outflow`
    3. **`FACT_FINANCIAL` (`FATO 3`):**
       * *Keys:* `customer_sk`, `aging_list_sk`, `time_sk`
       * *Measures:* `accounts_receivable`, `overdue_balance`

* **Architectural Takeaways:**
  * **Hybrid vs. Standardized Schemas:** While Minishop combines Star (`Customer`) and Snowflake (`Product`) implementations didactically, production Data Warehouses generally standardize on a single paradigm (predominantly Star Schema).
  * **Operational vs. Analytical Coexistence:** The finalized architecture pairs the normalized OLTP operational database with the decoupled dimensional DW, setting the stage for **ETL (Extract, Transform, Load)** pipelines to clean, transform, and populate the warehouse.

  ### 2.7 Supplemental Reading: Input Dimension in Dimensional Modeling
* **Conceptual Definition:**
  * The **Input (Leaf) Dimension** represents the direct origin of the business event that generates an indicator.
  * Unlike descriptive attributes or upper hierarchical levels used for grouping and slicing, the input dimension serves as the atomic starting point of analysis, intrinsically tied to the original transaction.
* **Fundamental Role in the Analytical Structure:**
  * Establishes the primary anchor entity around which the entire dimension table is organized (e.g., `Customer` is the input dimension for a sale, while `City` and `State` are built on top as hierarchical roll-ups).
  * Ensures that all metrics remain strictly aligned with the business logic of the initial event, preventing analytical misinterpretations or aggregation conflicts.
* **Selection Criteria for Input Dimensions:**
  * **Origin of the Indicator:** The entity born alongside the metric at the moment the event occurs (e.g., the customer executing the purchase).
  * **Direct Relationship with the Transaction:** Connects directly to the operational event without requiring intermediate entity lookups (unlike geographic cities, which depend on customer records).
  * **Business Domain Alignment:** Reflects how domain specialists conceptually view the transaction's root subject without derived transformations.
* **Impact on Dimensional Design:**
  * Anchoring dimensions at the true leaf level enables clean hierarchy construction, avoids structural redundancy, and supports fast, accurate analytical queries.

## 3: ETL Process in the Data Warehouse

### 3.1 Introduction to the ETL Process
* **Operationalizing the Data Warehouse:**
  * A dimensional model with empty tables has no business value until populated; **ETL (Extract, Transform, Load)** bridges operational sources (such as the Minishop OLTP database) and the analytical Data Warehouse.
  * ETL is not a raw table copy—it converts operational records into consistent, business-aligned analytical memory across multiple heterogeneous sources (transactional databases, APIs, web services, partner feeds, spreadsheets).
* **Core ETL Stages:**
  * **Extract (E):** Reliably pulls raw data from operational databases, files, or external APIs/services without yet applying complex business logic.
  * **Transform (T):** Applies business rules, standardizes formats, cleanses/validates data, derives analytical attributes, and resolves keys—housing most of the warehouse's business logic.
  * **Load (L):** Writes transformed records into Dimension and Fact tables while enforcing data integrity, versioning, and historical consistency.
* **Key-Lookup & Surrogate Key Mechanics:**
  * **Lookup (referred to as `LOCAP` in the lecture):** Resolves natural keys from source systems against dimension tables—either checking if a dimension member already exists (**Dimension Lookup**) or translating natural keys into surrogate keys when loading Fact tables (**Fact Lookup**).
  * **Surrogate Keys (SK) vs. Natural Keys (NK):** Sequential integer surrogate keys anchor dimension leaf levels and fact foreign keys for fast joins and indexing, while natural keys remain stored as attributes for source traceability.
  * **Slowly Changing Dimensions — SCD Type 2:** When a tracked attribute changes over time (e.g., a customer moves to a new city), SCD Type 2 inserts a **new row** with a **new surrogate key** for the same natural key rather than overwriting history, preserving point-in-time analytical accuracy.
* **Initial vs. Incremental Loads:**
  * **Initial Load:** Populates the Data Warehouse for the first time with the available historical baseline from source systems.
  * **Incremental Load:** Periodically ingests only new or modified records since the last successful run to keep the warehouse current efficiently.

### 3.2 Lookup and Surrogate Keys
* **Surrogate Key (SK) Characteristics & Role:**
  * Unique integer identifiers (often auto-incremented) assigned inside the Data Warehouse to replace source natural keys as dimension primary keys and fact foreign keys.
  * Can be generated sequentially or via non-sequential unique integer strategies; the strict requirement is uniqueness within the scope of the key.
  * **Performance Advantage:** Integer joins, indexes, and storage footprints outperform string, composite, or alphanumeric joins at analytical scale.
  * **Dual ETL Lifecycle:** Created and stored on dimension leaf tables first, then referenced as foreign keys when loading fact tables.
* **Dimension Load & Lookup Logic:**
  * Uses the **Natural Key (NK)** from the source system as the reference key to check whether a dimension member already exists in the DW.
  * **Initial Load:** Dimension starts empty; every incoming natural key is new, triggering an insert and a newly generated SK.
  * **Subsequent Loads (SCD Type 1 Behavior):**
    * If the NK does not exist in the dimension, a new row is inserted with a new SK.
    * If the NK already exists, existing attributes are overwritten in place (`UPDATE`) with the incoming values rather than doing expensive column-by-column equality checks, reusing the existing SK.
* **Fact Table Load & Lookup Logic:**
  * Incoming fact rows arrive carrying source natural keys.
  * The ETL performs a **Fact Lookup** against each related dimension table to resolve each natural key into its corresponding dimension SK before inserting the fact record.
  * Under **SCD Type 1** (where historical attribute states are not preserved), resolving the SK by NK is direct and unambiguous, setting up the transition to **SCD Type 2** historical tracking policies.

### 3.3 Slowly Changing Dimensions (SCD)
* **Why Dimension Update Policies Matter:**
  * Overwriting attributes in place when a tracked dimension attribute changes (such as a customer moving to a new city) shifts historical fact aggregations onto the new attribute value, distorting past reporting.
* **Classic SCD Types:**
  * **SCD Type 1 (Overwrite):** Overwrites existing attribute values in place without keeping history; reuses the same Surrogate Key. Best suited for non-historical corrections (e.g., fixing spelling typos).
  * **SCD Type 2 (Historical Versioning):** Preserves full history by closing out the previous version and inserting a new row with a new Surrogate Key for the same Natural Key whenever a tracked attribute changes (e.g., customer address, age bracket, risk tier, branch/region).
  * **SCD Type 3 (Limited History):** Retains current and previous values in dedicated columns; rarely used in practice.
* **Resolving the Right Surrogate Key in SCD Type 2:**
  * **Current Flag (`IsCurrent` / Active Flag):** Marks the active row as `true` and prior rows as `false`. Works for forward loads, but fails during historical backfills/reprocessing because loading past events against the current row misattributes older facts to newer states.
  * **Effective Date Ranges (`StartDate`, `EndDate`):** Each dimension version carries validity boundaries (typically spanning database min/max boundary dates for initial/open-ended versions, with prior versions closed the day before a change). Fact lookups match both the **Natural Key** and the **event date falling within `[StartDate, EndDate]`**, ensuring accurate point-in-time attribution for both ongoing and retroactive loads.

### 3.4 Time Dimension and Fact Load Policies
* **Time Dimension Design & SCD Type 1 Behavior:**
  * **Smart Integer Surrogate Keys:** Commonly formatted as `YYYYMMDD` (e.g., `20250101`), allowing straightforward numeric conversion from source dates and fast lookups/joins.
  * **Naturally SCD Type 1:** Calendar attributes (month, quarter, year, day of week) are immutable over time, so historical versioning (SCD Type 2) is not needed; the primary challenge is ensuring complete date coverage so fact foreign keys never fail.
* **Strategies for Populating the Time Dimension:**
  * **Fixed Broad Range ("Lazy" Approach):** Pre-generates a wide date span (e.g., `2000`–`2099`). Guarantees coverage, but inflates the dimension with unused dates.
  * **Fact-Driven Dates Only:** Generates dates strictly present in fact records. Avoids unused rows, but creates **gaps** (e.g., non-trading days like Sundays) that cause artificial drops or breaks in time-series charts.
  * **Continuous Min-to-Max Range (Recommended):** Determines the minimum and maximum dates present in the fact data and generates every contiguous day across `[MinDate, MaxDate]`, balancing storage efficiency with gap-free time-series reporting.
* **Fact Table Load & Reprocessing Policies:**
  * **Natural Key / Degenerate Key Upsert:** Matches incoming records via a fact natural/degenerate identifier (e.g., document/invoice number) to insert new rows or overwrite existing ones. Limited when avoiding degenerate attributes or handling reversals/deletions.
  * **Composite Surrogate Key Upsert:** Uses the composite key of dimension SKs to detect existing vs. new rows; works when granularity allows uniqueness, but becomes tricky under complex reversals or backfills.
  * **Time-Window Delete & Reload (Recommended "Winning" Strategy):** Identifies the date range (`[StartDate, EndDate]`) of the incoming batch, deletes existing fact rows within that period, and reloads the full period with resolved lookups. Cleanly handles inserts, updates, reversals, and source deletions simultaneously—at the cost of reading and reloading the entire period batch rather than delta rows alone.

### 3.5 Designing the Minishop ETL Process
* **ETL Implementation Approaches:**
  * **Database Stored Procedures (SQL):** Executes transformations inside the database engine. High performance when OLTP and DW share the same database platform/server, but increases SQL/procedural maintenance complexity and struggles with external sources (APIs, flat files).
  * **General-Purpose Programming Languages (e.g., Python, C#, Java):** Offers maximum flexibility to connect to diverse sources, APIs, and files and apply custom logic, but requires building lookups, incremental controls, error handling, and external schedulers (e.g., `cron`, Task Scheduler) from scratch.
  * **Specialized ETL Tools:** Provide built-in connectors, visual transformation libraries, lookup/SCD components, scheduling, and parallelism to speed up enterprise delivery, at the cost of licensing fees, team training, and vendor lock-in.
* **Applying SCD Policies to Minishop Dimensions:**
  * **`Product` (SCD Type 1):** Product variants/modifications typically receive a new SKU/identifier rather than mutating an existing item's identity in place, so overwriting is sufficient.
  * **`Promotion` & `Time` (SCD Type 1):** Simple/static or immutable structures where historical versioning adds no analytical value.
  * **`Customer` (SCD Type 2):** Customers retain their natural identifier while evolving over time (e.g., moving cities, changing age bracket), requiring historical versions tracked via `ValidFrom` and `ValidTo` validity dates and distinct surrogate keys (`ID_CLIENTE`).
* **Minishop `CLIENTE` Dimension Schema (SCD Type 2):**
  * Keys & core fields: `ID_CLIENTE` (`PK`/`SK`), `COD_CLIENTE`, `NOME_CLIENTE`
  * Geographic hierarchy & attribute: `COD_CIDADE`, `NOME_CIDADE`, `COD_ESTADO`, `NOME_ESTADO`, `FAIXA_ETARIA`
  * Effective date tracking: `VALID_FROM`, `VALID_TO`

### 3.6 Orchestrating the Minishop ETL Pipeline
* **Global Time-Window Parameters (`Data_Inicial`, `Data_Final`):**
  * Drive batch extraction, delete-and-reload reprocessing, and scheduled automation (e.g., dynamically computed rolling windows such as the last 30 days running daily at `01:00 AM`, or monthly runs on the 5th business day).
* **Dimension Load Workflows:**
  * **`Product` (Snowflake, SCD Type 1):** Joins OLTP `PRODUTO` and `CATEGORIA`, runs SCD Type 1 lookup, and loads `CATEGORIA` **before** `PRODUTO` to satisfy foreign key constraints.
  * **`Customer` (SCD Type 2):** Reads `CLIENTE`, derives city/state from address and age bracket from birth date in parallel, applies SCD Type 2 lookup (new SK when new or tracked location/attributes change), and loads `CLIENTE`.
  * **`Access` (`ACESSOS`, SCD Type 1):** Selects `DISTINCT` sales channel values from orders within `[Data_Inicial, Data_Final]`, applies SCD Type 1 lookup, and inserts any new channels.
  * **`Promotion` (`PROMOÇÃO`, SCD Type 1):** Uses constant boolean values (`TRUE` / `FALSE`) with SCD Type 1 lookup.
  * **`Aging List` (SCD Type 1):** Populates receivable and overdue aging buckets from a constant definition set using SCD Type 1 lookup.
  * **`Time` (`TEMPO`, SCD Type 1):** Generates contiguous days across `[Data_Inicial, Data_Final]`, formats integer keys as `YYYYMMDD`, computes calendar/holiday/business-day attributes in parallel, and loads via SCD Type 1 lookup.
* **Fact Table Load Workflows (Delete-and-Reload per Window):**
  * **`FACT_SALES` (`FATO 1`):** Deletes existing rows in `[Data_Inicial, Data_Final]`, joins orders/items/products in the window, performs SCD Type 2 `Customer` lookup (matching customer + order date against validity range) plus SCD Type 1 lookups for `Product`, `Access`, `Promotion`, and `YYYYMMDD` `Time`, and inserts quantity, unit price, and item value.
  * **`FACT_INVENTORY` (`FATO 2`):** Deletes `[Data_Inicial, Data_Final]` in parallel with reading inventory movements in the window, resolves `Product` and `YYYYMMDD` `Time` SKs, and inserts stock outflow.
  * **`FACT_FINANCIAL` (`FATO 3`):** Deletes `[Data_Inicial, Data_Final]`, reads invoices in the window, resolves `Customer` (SCD Type 2 by date) and `YYYYMMDD` `Time` SKs, calculates days overdue or days until due relative to load/reference date, classifies each invoice into an `Aging List` bucket (`CASE`), looks up `Aging List` SK, and inserts invoice amounts.
* **End-to-End Orchestration & Next Frontier:**
  * Execute independent dimension loads first (respecting parent-child order like `CATEGORIA` $\rightarrow$ `PRODUTO`), then execute Fact loads in parallel once dimensions are updated—setting the stage for modern **Data Lake** concepts.

### 3.7 Supplemental Reading: SCD Type 3 (Limited History)
* **Conceptual Definition:**
  * Preserves limited attribute history—typically the **current value** alongside **one previous value**—without generating new dimension rows or surrogate keys.
  * Ideal when analytical questions compare the present state against the immediately preceding state rather than requiring a complete historical timeline.
* **Mechanics & Schema Pattern:**
  * Adds companion column(s) (e.g., `previous_<attribute>`) to store the prior value while updating the primary column in place.
  * Example (`categoria_risco`): before overwriting `categoria_risco` with the new value, copy the existing value into `categoria_risco_anterior` on the same row.
* **Tradeoffs (Pros & Cons):**
  * **Pros:** Simpler implementation than SCD Type 2; avoids row multiplication, surrogate key versioning, and effective-date range management; supports direct side-by-side comparison in a single row.
  * **Cons:** Cannot track full change history or older states beyond the retained prior snapshot; less flexible than SCD Type 2 when point-in-time historical accuracy across multiple changes is required.

## 4: Data Lake Architecture and Implementation

### 4.1 Introduction to the Data Lake
* **Limitations of the Classical Data Architecture (`OLTP -> ETL -> DW`):**
  * **Volume & Source Proliferation:** Exponentially growing data volumes and dozens/hundreds of diverse internal and external systems (APIs, microservices, payment/marketing platforms, social feeds) increase ETL complexity.
  * **Format Diversity:** Semi-structured and unstructured data (JSON, application logs, CSVs, event streams) do not fit naturally into traditional relational Data Warehouses without heavy pre-processing.
  * **Source Coupling & Reprocessing Risk:** Direct ETL queries against operational sources create runtime dependencies and risk losing historical accuracy if source data is mutated, purged, or schemas change.
  * **Storage Cost & Raw Data Loss:** Traditional analytical storage historically carried higher costs for raw volumes, often discarding unprocessed source data rather than retaining it.
* **Core Data Lake Concept:**
  * A centralized repository storing massive volumes of raw data in its native format—structured, semi-structured, or unstructured—at lower storage cost.
  * **Schema-on-Read vs. Schema-on-Write:** Traditional Data Warehouses enforce **Schema-on-Write** (data must conform to a predefined schema before landing), whereas Data Lakes adopt **Schema-on-Read** (raw data lands as-is, and structure is applied when queried/processed), enabling faster ingestion and greater flexibility.
* **Modern Coexistence with the Data Warehouse:**
  * Rather than replacing the Data Warehouse, the Data Lake often acts as an intermediate raw-data landing and preservation layer, feeding curated transformations into the Data Warehouse (and other analytical consumers) without repeatedly hitting operational OLTP systems.

### 4.2 Data Lake Architecture
* **Ingestion-First & Cost-Effective Storage:**
  * Prioritizes fast ingestion and raw preservation of structured, semi-structured, and unstructured data (relational extracts, CSVs, JSONs, application logs, system events, sensor streams) over heavy upfront transformation.
  * Built on distributed object/file storage (such as Amazon S3, Azure Data Lake Storage, Google Cloud Storage, and Hadoop-based ecosystems) to scale to petabytes at low cost compared to traditional relational analytical storage.
* **Directory Layout & File Formats:**
  * Stores data as organized directory hierarchies (e.g., partitioned/grouped by source, entity, or generation date) rather than relational database tables.
  * Combines interchange formats (`CSV`, `JSON`) with columnar analytical formats (`Parquet`, `ORC`) optimized for large-scale distributed processing.
* **Multi-Tiered Architecture (Bronze, Silver, Gold):**
  * **Raw / Bronze Layer:** Stores ingested data in its native, untransformed state as a historical source copy.
  * **Staged / Silver Layer:** Applies initial cleansing, standardization, format normalization, and conversion into analytical-friendly structures/formats.
  * **Curated / Gold Layer:** Organizes and refines datasets for downstream consumption, reporting, and analytical modeling.
* **Central Hub for Diverse Consumers & Reprocessing:**
  * Decouples historical reprocessing from operational OLTP systems—enabling new transformations or backfills directly from stored lake data.
  * Serves multiple downstream workloads simultaneously: BI dashboards via the Data Warehouse, Data Science/Machine Learning pipelines, and distributed analytics engines.

### 4.3 Data Flows with a Data Lake
* **Shift from Direct ETL to Decoupled Ingestion and Transformation:**
  * **Classical Direct ETL (`Sources -> ETL -> DW`):** Transforms data before landing in the analytical store, coupling transformation logic directly to source schemas/formats and often discarding raw source records.
  * **Lake-Centric Two-Stage Flow (`Sources -> EL -> Data Lake -> ETL/ELT -> DW & Consumers`):** Separates raw data capture from downstream transformation, turning the Data Lake into a centralized intermediate source.
* **Two Primary Processing Pipelines:**
  1. **Ingestion Flow (`EL` — Extract & Load):** Extracts data from operational databases, APIs, logs, and external sources and writes raw records to the Data Lake quickly with minimal upfront transformation.
  2. **Transformation & Distribution Flow (`ETL` from the Lake):** Reads stored lake data (Bronze/Silver/Gold) to cleanse, standardize, enrich, and aggregate records for the Data Warehouse, BI tools, Data Science, and Machine Learning workloads.
* **Architectural Benefits of Decoupling:**
  * **Modularity & Independent Scaling:** Ingestion and transformation run on separate schedules and engines tailored to each workload's scale and complexity.
  * **Self-Contained Reprocessing:** Raw historical snapshots remain in the lake, allowing new transformations, schema adaptations, or backfills without hitting operational systems again.

### 4.4 Implementing the Minishop Data Lake (Bronze, Silver, Gold & File Formats)
* **Evolving the Minishop Pipeline to a Lake-Centric Flow:**
  * Decouples direct OLTP reads from downstream dimensional ETL: ingestion dumps operational extracts into the Data Lake, and the ETL pipeline reads prepared datasets from the lake rather than querying transactional tables directly.
  * Buckets/directories organize datasets by domain/state (e.g., `Cliente`, `Vendas` for product/category/order/item, `Financeiro` for invoice, `Logística` for inventory) and time partitions (e.g., year/month folders).
* **File Formats in the Data Lake (`CSV`, `Parquet`, `Avro`):**
  * **Mixed Formats by Scale & Use Case:** Smaller tables or lightweight exchanges often use `CSV` or `JSON`, while high-volume datasets (facts, order items, events, logs) favor binary formats (`Parquet` or `Avro`) for compression and performance.
  * **`Parquet` (Columnar Binary):** Open-source columnar storage format (typically compressed with `Snappy` or `Gzip`, framed with `PAR1` magic headers/footers) optimized for fast analytical scans and reduced disk footprint; writable in Python via `DataFrame.to_parquet(..., index=False)`.
  * **`Avro` (Row-Oriented Binary with Schema):** Stores binary records paired with a JSON schema (embedded or external), well suited for data exchange/integration and big data pipelines; writable in Python via `fastavro.writer` with a parsed JSON schema.
* **Bronze, Silver, and Gold Tiers in Minishop:**
  * **Bronze (Raw):** Untransformed dumps of OLTP tables (`CLIENTE`, `PRODUTO`, `CATEGORIA`, `PEDIDO`, `ITEM`, `FATURA`, `ESTOQUES`) preserving raw source state.
  * **Silver (Staged / Prepared):** Applies technical preparation and joins prior to DW loading—such as extracting city/state and age bracket for customers, pre-joining orders and items in sales, and partitioning by period—simplifying and speeding up the DW ETL.
  * **Gold (Curated):** Holds pre-aggregated or specialized analytical datasets (e.g., monthly revenue, volume, average price summaries) for flexible reporting, operational/management slices, or data science, while the dimensional DW remains the structured engine for standard BI queries.
  * **Pragmatic Adoption:** Not every lake needs all three tiers from day one; teams often start with Bronze and Silver and add Gold as analytical maturity grows.

### 4.5 Supplemental Reading: Parquet Format in the Data Lake
* **Columnar Storage Layout:**
  * Stores data by column rather than by row, allowing analytical queries and transformations to read only the columns required instead of scanning entire records.
  * Cuts I/O volume and speeds up analytical scans and aggregations.
* **Compression & Analytical Performance:**
  * Grouping uniform column values enables stronger compression and encoding schemes, lowering storage footprint while accelerating read throughput at scale.
* **ETL & Python Integration:**
  * Reading pre-compressed, column-pruned Parquet files simplifies and speeds up downstream ETL pipelines feeding a Data Warehouse.
  * Example (`pandas` + `pyarrow`): `df.to_parquet('dados.parquet', engine='pyarrow')`.

## 5: Lakehouse Architecture

### 5.1 Introduction to the Lakehouse
* **Why Re-Evaluate Separate Data Lake & Data Warehouse Tiers:**
  * Keeping a file-based Data Lake (`CSV`, `JSON`, `Parquet`, `Avro`) separate from a relational/dimensional Data Warehouse often requires moving and duplicating curated datasets through additional ETL steps.
  * When Gold-tier consolidated datasets already exist in the lake, a natural question arises: can analytical structures be queried directly over lake storage without redundant data movement?
* **Core Lakehouse Concept:**
  * Converges Data Lake flexibility and low-cost scalable file storage with Data Warehouse analytical capabilities—exposing lake files as structured analytical tables queryable via SQL with governance and versioning.
  * Cuts unnecessary data movement between storage and analytics layers while preserving raw data storage and modern distributed processing.
* **Evolution, Not Automatic Erasure:**
  * Emerges as a continuous architectural evolution alongside existing Data Lake and Data Warehouse patterns rather than forcing an all-or-nothing replacement.
  * Requires clear boundary definitions across raw/tiered lake storage, Gold datasets, Lakehouse tables, and traditional DW structures (to be detailed in upcoming lessons and applied to Minishop).

  ### 5.2 Lakehouse Architecture Components
* **Architectural Pattern, Not a Single Product:**
  * Combines existing storage, file formats, metadata catalogs, and query/processing engines so files in a Data Lake can be queried like analytical tables without redundant data movement into a separate DW.
* **Core Layers of a Lakehouse:**
  * **Scalable Storage Layer:** Distributed/object storage (e.g., `HDFS`, `Amazon S3`, `Azure Data Lake`, `Google Cloud Storage`) holding files organized in directories and partitions (e.g., by date or region) at low cost.
  * **Optimized File Formats:** Analytical formats such as `Parquet` and `Avro` (and columnar compression with internal metadata) that outperform plain text formats like `CSV` during large-scale scans.
  * **Metadata Catalog Layer:** Maps file locations, schemas, column types, and formats into table abstractions so query engines know how to read the files (e.g., `Hive Metastore`, `AWS Glue Catalog`).
  * **Analytical Processing Engines:** Execute SQL and distributed analytics directly over lake files (e.g., `Apache Spark`, `Trino`, `Presto`, `DuckDB`).

### 5.3 Roles of the Data Lake (Gold), Data Warehouse, and Lakehouse
* **Complementary Rather Than Competing Layers:**
  * Each layer serves a distinct analytical purpose and governance profile; avoiding unnecessary duplication keeps the architecture simpler and easier to maintain.
* **Comparison Across Core Dimensions:**

| Dimension | Data Lake (Gold Tier) | Data Warehouse | Lakehouse |
| :--- | :--- | :--- | :--- |
| **Primary Goal** | Prepare, cleanse, standardize, and enrich operational data into flexible analytical datasets | Structure curated business metrics and historical models for consistent BI reporting | Query large lake-stored datasets directly as analytical tables without mandatory DW movement |
| **Storage Format** | Files in lake storage (`Parquet`, `Avro`, `JSON`, `CSV`) | Tables inside an analytical database engine | Lake files exposed via a metadata/table abstraction layer |
| **Data Modeling** | Closer to source/domain structure after standardization | Structured dimensional/multidimensional schema (facts & dimensions, OLAP) | Table abstractions over lake files supporting SQL analytics |
| **Primary Use Cases** | Data exploration, Data Science, Machine Learning, dataset preparation | Corporate reports, executive dashboards, official KPIs, financial analysis | Direct SQL/analytical queries over large volumes in the lake |
| **Governance** | Intermediate governance balancing structure and exploratory flexibility | Strongest governance for official enterprise metrics and definitions | Governance applied on analytical table definitions over lake files |
| **Performance** | Varies by file format, compression, and layout/partitioning | Consistently high for structured analytical/OLAP workloads | High when paired with columnar formats (`Parquet`) and distributed query engines |
| **Data Volume & Duplication** | Very large volumes; acts as source/foundation for downstream layers | Typically a curated, consolidated subset; often replicates/moves data | Handles very large volumes on scalable lake storage while reducing data duplication |
| **Typical Tooling** | `Spark`, `Python`, programming frameworks | Analytical SQL, ETL/ELT tools, BI platforms | `Spark`, `Trino`, and SQL engines querying lake files as tables |