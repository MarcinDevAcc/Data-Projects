# Students Social Media Addiction - Exploratory Data Analysis (Python)

## Overview

Exploratory data analysis examining associations between social media usage patterns and self-reported academic performance, mental health, sleep duration, and relationship conflicts.

The project analyzes behavioral patterns across **705 students from 26 countries**, focusing on relationships between addiction scores, daily usage hours, and selected quality-of-life indicators.

Dataset source: [Kaggle - Social Media Addiction vs Relationships](https://www.kaggle.com/datasets/adilshamim8/social-media-addiction-vs-relationships)

---

## Dataset Scope

### Sample Demographics
- **705 students** across 26 countries
- **Age range**: 18-24 years
- **Gender distribution**: 353 Female, 352 Male
- **Academic levels**:
  - Undergraduate: 353 (50.1%)
  - Graduate: 325 (46.1%)
  - High School: 27 (3.8%)

### Key Metrics
- **Addiction Score**: 2-9 scale (mean: 6.4)
- **Daily Usage**: Average hours spent on social media
- **Mental Health Score**: 1-10 self-reported rating
- **Sleep Hours**: Average nightly sleep duration
- **Relationship Conflicts**: 0-5 scale
- **Academic Performance Impact**: Yes/No self-reported indicator

### Platforms Tracked
Instagram, TikTok, Twitter, Facebook, Snapchat, LinkedIn, YouTube, and others.

---

## Analysis Components

### Demographic Analysis
- Age distribution
- Gender distribution
- Academic-level distribution
- Geographic distribution across 26 countries

### Usage Pattern Analysis
- Platform popularity
- Daily usage-hour distribution
- Usage comparison by demographic groups

### Association Analysis
- Daily usage and self-reported academic impact
- Social media usage and mental health score
- Sleep hours and addiction score
- Relationship conflicts and addiction score
- Sleep-category comparison using boxplots

### Geographic Analysis
- Country-level addiction-score comparison
- Interactive choropleth visualization

---

## Technical Implementation

### Data Analysis Libraries
- **pandas** - data manipulation and aggregation
- **numpy** - numerical calculations

### Visualization Stack
- **matplotlib** - base plotting
- **seaborn** - statistical visualizations
- **plotly.express** - interactive geographic visualization

### Statistical Methods
- Pearson correlation analysis
- Distribution analysis
- Grouped aggregation
- Categorical comparison
- Scatter plots and regression visualization

### Notebook Structure
- Data import and initial exploration
- Feature engineering (`Sleep_Category`)
- 11 analysis sections
- Static and interactive visualizations

---

## Key Insights

### Sample Characteristics
- **Mean addiction score**: 6.4/9 across the analyzed sample
- **Platform usage**: Daily usage levels vary across preferred-platform groups
- **Demographic coverage**: The dataset includes students from 26 countries and three academic levels

### Associations Identified
- **Sleep and addiction score**: Higher addiction scores are associated with lower sleep duration
- **Mental health**: Higher usage / addiction measures are associated with lower self-reported mental health scores
- **Relationship conflicts**: Higher addiction scores are associated with more reported conflicts
- **Academic performance**: Usage patterns differ between students who report academic impact and those who do not

### Geographic Analysis
- Country-level differences can be compared through the interactive choropleth map
- India has the largest sample representation with 53 students

> These findings describe associations within the dataset and should not be interpreted as evidence of causation.

---

## Analytical Applications

- **Behavioral exploration** - compare usage patterns across demographic groups
- **Association analysis** - examine relationships between social media use, sleep, mental health, and conflicts
- **Geographic comparison** - visualize country-level differences within the sample
- **Further research** - identify relationships that could be tested using larger or longitudinal datasets

---

## Visualizations Produced

1. **Age Distribution** - histogram with density curve
2. **Gender Distribution** - bar chart
3. **Academic Level Distribution** - categorical bar chart
4. **Platform Usage** - comparative bar chart
5. **Daily Usage Hours** - distribution analysis
6. **Academic Performance Impact** - comparative visualization
7. **Mental Health Association** - scatter plot with regression line
8. **Sleep Hours Association** - bivariate analysis
9. **Relationship Conflicts** - categorical / correlation analysis
10. **Addiction by Sleep Category** - boxplot comparison
11. **Geographic Addiction Map** - interactive choropleth

---

## Tools & Technologies

### Programming Language
- Python 3.12

### Core Libraries
- pandas
- numpy
- matplotlib
- seaborn
- plotly
- Kaggle API

### Development Environment
- Jupyter Notebook
- IPython kernel

---

## Files Structure

- `Students_Social_Media_Addiction.ipynb` - complete analysis notebook
- `Students_Social_Media_Addiction.csv` - source dataset (705 students, 13 features)

---

## Reproducibility

The analysis is reproducible through sequential notebook execution:

1. Dataset can be downloaded using the Kaggle API
2. Required libraries are imported directly in the notebook
3. Notebook cells reproduce the analysis and visualizations
4. No additional external data sources are required beyond the source dataset
