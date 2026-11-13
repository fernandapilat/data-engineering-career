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