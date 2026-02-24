# Students Social Media Addiction - Behavioral Analysis (Python)

## Overview

Comprehensive data analysis exploring the relationship between social media usage patterns and their impact on students' academic performance, mental health, sleep quality, and interpersonal relationships.

The project investigates behavioral patterns across 705 students from 26 countries, examining correlations between addiction scores, daily usage hours, and various life quality indicators.

Dataset source: [Kaggle - Social Media Addiction vs Relationships](https://www.kaggle.com/datasets/adilshamim8/social-media-addiction-vs-relationships)

---

## Dataset Characteristics

### Sample Demographics
- **705 students** across 26 countries
- **Age range**: 18-24 years
- **Gender distribution**: 50/50 (353 Female, 352 Male)
- **Academic levels**:
  - Undergraduate: 353 (50.1%)
  - Graduate: 325 (46.1%)
  - High School: 27 (3.8%)

### Key Metrics
- **Addiction Score**: 2-9 scale (mean: 6.4)
- **Daily Usage**: Average hours spent on social media
- **Mental Health Score**: 1-10 self-reported rating
- **Sleep Hours**: Average nightly sleep duration
- **Relationship Conflicts**: 0-5 scale measuring social media-related disputes
- **Academic Performance Impact**: Yes/No binary indicator

### Platforms Tracked
Instagram, TikTok, Twitter, Facebook, Snapchat, LinkedIn, YouTube, and others

---

## Analysis Components

### Demographic Analysis
- **Age Distribution** - student age patterns and clustering
- **Gender Distribution** - balanced male/female representation
- **Academic Level Distribution** - educational stage breakdown
- **Geographic Distribution** - global student participation (26 countries)

### Usage Pattern Analysis
- **Platform Popularity** - most-used social media platforms among students
- **Average Daily Usage** - time spent analysis with distribution visualization
- **Usage by Demographics** - cross-tabulation with age, gender, academic level

### Impact Assessment
- **Academic Performance Correlation** - relationship between usage and grades
- **Mental Health Correlation** - usage patterns vs. mental health scores
- **Sleep Quality Analysis** - sleep hours vs. social media addiction scores
- **Sleep Category Comparison** - boxplot analysis across sleep duration categories

### Behavioral Insights
- **Relationship Conflicts** - social media's role in interpersonal disputes
- **Addiction Severity Segmentation** - grouping by addiction score levels
- **Geographic Addiction Patterns** - choropleth map showing country-level addiction scores

---

## Technical Implementation

### Data Analysis Libraries
- **pandas** - data manipulation and aggregation
- **numpy** - statistical calculations

### Visualization Stack
- **matplotlib** - base plotting and customization
- **seaborn** - statistical visualizations (boxplots, heatmaps, distributions)
- **plotly.express** - interactive choropleth maps

### Statistical Methods
- Correlation analysis (Pearson coefficients)
- Distribution analysis (histograms, KDE plots)
- Categorical comparison (boxplots)
- Aggregation and grouping operations

### Notebook Structure
- Data import and initial exploration
- Feature engineering (Sleep_Category derivation)
- 11 distinct analysis sections with visualizations
- Interactive geographic visualization

---

## Key Findings

### Usage Patterns
- **Mean addiction score**: 6.4/9 (moderate-high addiction prevalence)
- **Average daily usage**: Varies significantly by platform preference
- **Peak usage demographics**: Identification of high-risk groups

### Correlations Identified
- **Sleep-Addiction relationship**: Inverse correlation between sleep quality and addiction scores
- **Academic impact**: Clear patterns between usage and self-reported performance effects
- **Mental health trends**: Correlation between excessive usage and lower mental health scores
- **Relationship conflicts**: Positive correlation with addiction severity

### Geographic Insights
- **Country-level addiction mapping**: Visual representation of global patterns
- **Cultural variations**: Differences in usage patterns across regions
- **Top affected countries**: India leads in sample size (53 students)

---

## Business & Research Applications

### Educational Institutions
- **Intervention programs**: Target high-risk student groups
- **Policy development**: Evidence-based social media guidelines
- **Mental health services**: Prioritize resources for affected demographics

### Health & Wellness
- **Screening tools**: Identify students at risk of addiction
- **Sleep hygiene programs**: Address social media's impact on rest
- **Counseling priorities**: Focus on relationship and mental health support

### Platform Developers
- **Usage time analytics**: Understanding engagement patterns
- **Wellness features**: Design interventions based on behavioral data
- **Demographic targeting**: Age-appropriate content and controls

### Research Community
- **Behavioral science**: Understanding digital addiction mechanisms
- **Cross-cultural studies**: Geographic variation in social media impact
- **Longitudinal tracking**: Framework for ongoing addiction monitoring

---

## Visualizations Produced

1. **Age Distribution** - histogram with density curve
2. **Gender Distribution** - bar chart
3. **Academic Level Distribution** - categorical bar chart
4. **Platform Usage** - comparative bar chart
5. **Daily Usage Hours** - distribution analysis
6. **Academic Performance Impact** - comparative visualization
7. **Mental Health Correlation** - scatter plot with regression line
8. **Sleep Hours Correlation** - bivariate analysis
9. **Relationship Conflicts** - categorical comparison
10. **Addiction by Sleep Category** - boxplot comparison
11. **Geographic Addiction Map** - interactive choropleth (Plotly)

---

## Tools & Technologies

### Programming Language
- Python 3.12

### Core Libraries
- pandas - data manipulation
- matplotlib - static visualizations
- seaborn - statistical graphics
- plotly - interactive maps
- kaggle API - dataset retrieval

### Development Environment
- Jupyter Notebook
- IPython kernel

---

## Files Structure

- `Students_Social_Media_Addiction.ipynb` - complete analysis notebook
- `Students_Social_Media_Addiction.csv` - source dataset (705 students, 13 features)

---

## Reproducibility

The analysis is fully reproducible:
1. Dataset automatically downloadable via Kaggle API
2. All dependencies listed in import statements
3. Sequential execution of notebook cells produces all visualizations
4. No external data files required beyond initial CSV
