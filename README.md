# 📡 Telecom Network Quality Intelligence

### Data Analytics | Python | SQL | Power BI

An end-to-end data analytics project that analyzes telecom network quality using signal strength, Signal-to-Noise Ratio (SNR), signal attenuation, and distance from cell towers.

The project uses Python for data cleaning and exploratory data analysis (EDA), SQL for analytical queries, and Power BI for interactive visualization. It aims to identify network quality issues and help prioritize areas that may require further investigation.

---

## 📌 Project Overview

Telecommunication networks generate data about signal strength, call activity, signal interference, and tower distance. Analyzing these metrics can help identify potential network performance issues.

**Telecom Network Quality Intelligence** transforms raw telecom data into meaningful insights through a complete analytics workflow.

### 🎯 Project Objectives

* Analyze telecom network quality using key performance metrics.
* Clean and transform raw telecom data using Python.
* Identify patterns in signal strength and SNR.
* Investigate the relationship between tower distance and network quality.
* Analyze signal attenuation across different conditions.
* Use SQL to perform structured data analysis.
* Build an interactive Power BI dashboard.
* Identify records that may require further network investigation.

---

## 🛠️ Tech Stack

| Technology   | Purpose                                |
| ------------ | -------------------------------------- |
| Python       | Data cleaning, transformation, and EDA |
| Pandas       | Data manipulation and preprocessing    |
| NumPy        | Numerical operations                   |
| Matplotlib   | Data visualization                     |
| Seaborn      | Statistical visualization              |
| SQL          | Data analysis and aggregation          |
| Power BI     | Interactive dashboard and reporting    |
| CSV          | Dataset storage                        |
| Git & GitHub | Version control and project hosting    |

---

## 📂 Project Structure

```text
Telecom-Network-Quality-Intelligence/
│
├── data/
│   ├── raw/
│   │   └── train.csv
│   │
│   ├── cleaned/
│   │   └── train_cleaned.csv
│   │
│   └── processed/
│       └── eda/
│           └── 20 EDA charts
│
├── python/
│   ├── 01_data_profiling.py
│   ├── 02_data_cleaning.py
│   └── 03_eda.py
│
├── sql/
│   ├── schema.sql
│   ├── 01_basic_analysis.sql
│   ├── 02_signal_analysis.sql
│   ├── 03_snr_analysis.sql
│   ├── 04_attenuation_analysis.sql
│   ├── 05_distance_analysis.sql
│   └── 06_problem_prioritization.sql
│
├── powerbi/
│   └── report.pbix
│
├── requirements.txt
├── .gitignore
└── README.md
```

---

## 🔄 Project Workflow

```text
Raw Telecom Dataset
        |
        ▼
Data Profiling
        |
        ▼
Data Cleaning & Transformation
        |
        ▼
Exploratory Data Analysis
        |
        ▼
SQL-Based Analysis
        |
        ▼
Power BI Dashboard
        |
        ▼
Network Quality Insights
```

### 1. Data Profiling

The `01_data_profiling.py` script examines the raw dataset.

Activities include:

* Checking dataset dimensions.
* Inspecting column names and data types.
* Identifying missing values.
* Reviewing statistical summaries.
* Understanding the initial data quality.

### 2. Data Cleaning

The `02_data_cleaning.py` script prepares the data for analysis.

Activities include:

* Handling missing and invalid values.
* Converting columns to appropriate data types.
* Preparing date and time fields.
* Creating categories for network quality metrics.
* Engineering additional features for analysis.
* Exporting the cleaned dataset.

**Output:** `data/cleaned/train_cleaned.csv`

### 3. Exploratory Data Analysis (EDA)

The `03_eda.py` script explores the cleaned dataset and generates visualizations.

Analysis areas include:

* Signal strength distribution.
* SNR distribution.
* Signal attenuation.
* Distance from cell towers.
* Network quality across environments.
* Relationships between network performance metrics.
* Call-related patterns.
* Time-based trends, where applicable.

**Output:** EDA charts saved in `data/processed/eda/`.

### 4. SQL Analysis

SQL is used to analyze the cleaned data through structured queries.

| SQL File                        | Analysis                                           |
| ------------------------------- | -------------------------------------------------- |
| `schema.sql`                    | Database table definitions, indexes, and views     |
| `01_basic_analysis.sql`         | Overall KPIs, call types, and environment analysis |
| `02_signal_analysis.sql`        | Signal strength performance                        |
| `03_snr_analysis.sql`           | Signal-to-noise ratio analysis                     |
| `04_attenuation_analysis.sql`   | Signal attenuation analysis                        |
| `05_distance_analysis.sql`      | Tower distance and network quality                 |
| `06_problem_prioritization.sql` | Prioritization of potential network issues         |

### 5. Power BI Dashboard

The `report.pbix` file contains the project's interactive Power BI report.

The dashboard is intended to help users explore network quality and compare performance across available categories.

Open the report in Power BI Desktop to explore its visuals and filters.

---

## 📊 Key Analysis Areas

| Metric          | Description                                      | Purpose                                                |
| --------------- | ------------------------------------------------ | ------------------------------------------------------ |
| Signal Strength | Received signal power, commonly measured in dBm  | Examine signal coverage and strength                   |
| SNR             | Signal-to-Noise Ratio                            | Understand signal quality relative to background noise |
| Attenuation     | Reduction in signal strength during transmission | Investigate signal loss                                |
| Tower Distance  | Distance between a user and a cell tower         | Explore how distance relates to network quality        |
| Call Duration   | Length of a call                                 | Analyze call activity                                  |
| Environment     | Recorded environment category                    | Compare network measurements across environments       |

---

## 🚨 Network Problem Prioritization

The project includes a SQL analysis script dedicated to prioritizing potential network problems.

The analysis considers available network quality indicators, such as:

* Weak signal strength.
* Low SNR.
* High attenuation.
* Greater distance from a cell tower.

These indicators can help identify records or locations that may deserve further investigation.

**Important:** This is an analytical, rule-based approach. It does not automatically confirm a network fault or predict future failures. Field measurements and additional operational data would be needed to validate suspected problems.

---

## 📈 Business Applications

This type of analysis can support telecom teams in:

* Investigating areas with weak signal measurements.
* Comparing network quality across environments.
* Understanding the relationship between tower distance and signal performance.
* Identifying measurements that may need further investigation.
* Supporting network maintenance planning.
* Communicating analytical findings through dashboards.

---

## ⚙️ Installation and Setup

### Prerequisites

Install the following tools:

* Python 3.x
* MySQL or another SQL database compatible with your queries
* Power BI Desktop
* Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/sanju/Telecom-Network-Quality-Intelligence.git
```

```bash
cd Telecom-Network-Quality-Intelligence
```

### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Run Data Profiling

```bash
python python/01_data_profiling.py
```

### Step 4: Run Data Cleaning

```bash
python python/02_data_cleaning.py
```

This generates the cleaned dataset in `data/cleaned/`.

### Step 5: Run Exploratory Data Analysis

```bash
python python/03_eda.py
```

The EDA charts are saved in `data/processed/eda/`.

### Step 6: Run SQL Analysis

1. Open your SQL database client.
2. Create or select a database.
3. Execute `sql/schema.sql` after reviewing its table definitions.
4. Import the cleaned dataset into the appropriate table.
5. Run the analysis queries in the `sql/` folder.

Check the SQL scripts for the expected table and column names before importing the data.

### Step 7: Open the Power BI Dashboard

1. Open Power BI Desktop.
2. Open `powerbi/report.pbix`.
3. If prompted, configure the data source.
4. Refresh the data if the report requires it.

---

## 📁 Dataset

The project uses a telecom network dataset stored in:

```text
data/raw/train.csv
```

The dataset contains network measurements and call-related information used for the analysis, including signal strength, SNR, attenuation, tower distance, and other available fields.

The cleaned version is stored at:

```text
data/cleaned/train_cleaned.csv
```

---

## 💡 Key Features

* End-to-end data analytics workflow.
* Python-based data profiling and cleaning.
* Feature engineering for network quality analysis.
* Exploratory data analysis with 20 exported charts.
* SQL scripts organized by analytical topic.
* Rule-based problem prioritization.
* Interactive Power BI report.
* Reproducible project structure.

---

## 🔮 Future Improvements

* Add machine learning models to predict network quality issues.
* Incorporate more network measurements and historical data.
* Build a model to estimate the likelihood of poor signal conditions.
* Add geographic visualizations of tower and user locations, if coordinates are available.
* Automate data ingestion and scheduled reporting.
* Add dashboard alerts for measurements that cross defined thresholds.
* Validate analytical findings against real network maintenance records.

---

## ⚠️ Limitations

* The analysis is limited to the fields and records available in the supplied dataset.
* Correlations between network metrics do not necessarily establish causation.
* Rule-based prioritization is not a trained machine learning model.
* Identified problem areas should be validated with additional measurements before operational decisions are made.
* Dashboard results depend on the data source and refresh configuration.

---

## 👨‍💻 Author

**Sanju**
Computer Science and Engineering Student | Aspiring Data Analyst

**GitHub:** [sanju](https://github.com/sanju)

---

## ⭐ Support

If you find this project useful, consider giving the repository a star ⭐.

This project demonstrates practical skills in Python, SQL, data cleaning, exploratory data analysis, and Power BI reporting.
