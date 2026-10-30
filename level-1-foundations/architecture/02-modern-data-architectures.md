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