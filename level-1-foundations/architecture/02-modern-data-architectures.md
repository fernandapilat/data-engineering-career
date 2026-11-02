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