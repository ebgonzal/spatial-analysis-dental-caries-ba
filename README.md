
## Influence of Social and Spatial Factors in Caries Prevalence

This repository contains the data engineering pipeline and spatial feature engineering workflows designed to analyze the prevalence of dental caries among school-aged children in Buenos Aires, evaluating the impact of socio-demographic and spatial determinants.

---

## 🛠️ Project Architecture & Data Pipeline

The workflow follows data engineering best practices, structured within a cloud-based environment (Databricks) using Python as the primary language for geospatial data manipulation and enrichment. 

The project structure is organized as follows:
* data/raw: Raw census layers (.shp) and health records.
* data/processed: Enriched final dataset (GeoPackage / Parquet).
* notebooks: Processing pipelines in Databricks (01_spatial_feature_engineering.ipynb).
* .gitignore: Data and temporary files exclusion.
* requirements.txt: Project dependencies (Geopandas, Pandas, etc.).
* README.md: Repository documentation & portfolio landing page.

---

## ⚙️ Spatial Feature Engineering

The core of this project involves transforming raw alphanumeric and geometric census data into standardized features optimized for statistical and predictive modeling. The key techniques applied include:

1. Normalization & Scale Control: Converting absolute population counts into relative rates and percentages per census radius (e.g., % of population aged 0 to 3, % of population over 17, % of retirement pension recipients).
2. Small Area Effects Mitigation: Implementing methodological handling and imputation for census tracts with critically low or zero population denominators to prevent socio-economic indicator distortion.
3. Geospatial Enrichment: Integrating census tract geometries with localized social vulnerability indicators and urban environment spatial factors.

---

## 🚀 Technologies Used

* Cloud Environment: Databricks
* Language: Python 3.x
* Core Libraries: geopandas, pandas, shapely
* Cartographic Validation: QGIS

---

## 📊 How to Run This Project

1. Clone this repository into your local environment or Databricks workspace:
   git clone [https://github.com/your-username/spatial-analysis-dental-caries-ba.git](https://github.com/your-username/spatial-analysis-dental-caries-ba.git)

2. Install the required dependencies:
   pip install -r requirements.txt

3. Execute the processing notebook located in the notebooks directory, pointing to your local census data sources.