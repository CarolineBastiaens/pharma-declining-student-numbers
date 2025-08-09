# Declining student numbers in Pharmaceutical Sciences
Analysis of enrollment and graduation trends over the past 9 years in Flanders, using PostgreSQL for data processing and Power BI for building an interactive dashboard.


### Project overview
This project investigates the declining enrollment numbers in Pharmaceutical Sciences programs in Flanders, Belgium. While working at the University of Leuven, I noticed fewer students entering and graduating each year. This raised the question: Is this trend unique to Leuven or a broader pattern across all universities?

Using publicly available datasets, I combined, cleaned, and analyzed data in PostgreSQL before visualizing insights in Power BI. The aim is to identify key trends and compare the various institutions to one another.


### Data sources
- [Flanders Education Data Portal](https://www.onderwijs.vlaanderen.be/nl/onderwijsstatistieken/dataloep-aan-de-slag-met-cijfers-over-onderwijs/download-je-dataset-uit-dataloep) - Student enrollment and graduation numbers by year, institution and program
- [Statbel](https://statbel.fgov.be/nl/over-statbel/methodologie/classificaties/geografie) - NIS codes for geographical analysis


### Tools & technologies
- **PostgreSQL** - Data cleaning, transformation and analysis
- **DBeaver** - Database management & query execution
- **Visual Studio Code** - SQL script version control
- **Power BI** - Data visualization & dashboard creation
- **PowerPoint** - Stakeholder presentation


### Process
**1. Collect** - Downloaded CSVs from official sources

**2. Clean** - Harmonized column values, corrected errors, merged datasets

**3. Model** - Built dimension and fact tables; created aggregation tables for trend analysis

**4. Visualize** - Designed an interactive dashboard in Power BI

**5. Present** - Created a PowerPoint presentation for sharing the main insights


### Key insights
- Three out of four universities face a structural decline in student enrollment.
- The University of Leuven has maintained its market share among students entering higher education for the first time, but has seen a sharp drop in the number of graduates.
- Ghent University shows recovery after a temporary dip and is the only university showing growth.
- The University of Leuven is experiencing a disproportionally high student attrition rate.


### Limitations
- Source data distinguishes generation students (students entering higher education for the first time) but not program-specific first-timers.
- Graduation timing per student is unknown; many take longer than the typical three years.
- No data on timing of curriculum changes at institutions.


### Repository contents
- 01-data/raw-sample/ — Samples of raw data
- 01-data/clean-sample/ — Samples of cleaned data
- 02-sql/ — SQL scripts
- 03-powerbi/dashboard-teaser.pdf - Screenshot of the interactive dashboard
- 04-docs/data-log.xlsx - Data processing notes
- 04-docs/presentation.pdf - PowerPoint with main insights

Note that the dashboard and presentation are in Dutch.


### Contact
**Caroline Bastiaens**: [LinkedIn](https://www.linkedin.com/in/bastiaenscaroline/)
