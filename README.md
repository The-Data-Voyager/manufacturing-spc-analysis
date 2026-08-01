# Manufacturing SPC Analysis with PostgreSQL

## Project Overview

This project analyzes a manufacturing process using SPC (Statistical Process Control) techniques in PostgreSQL.

The original exercise focused on determining whether product height measurements were within calculated control limits using a rolling window of five measurements.

I extended the project into a more complete analytical pipeline by adding:

- raw and analytics database layers
- data-quality validation
- reusable PostgreSQL views
- SPC analysis for length, width, and height
- comparison of two rolling-window methodologies
- operator-level performance analysis
- exported analytical outputs for further reporting and visualization

---

## Business Problem

A manufacturing process produces parts with three measured dimensions:

- length
- width
- height

Measurements are recorded for different operators.

The objective is to identify measurements that fall outside expected process-control limits and investigate:

1. whether the process appears stable
2. which dimensions generate the most alerts
3. which operators show the highest observed alert rates
4. how the choice of rolling-window methodology affects alert detection

---

## Dataset

The manufacturing dataset contains:

- `item_no`
- `length`
- `width`
- `height`
- `operator`

The source dataset contains:

- 500 manufacturing records
- 20 operators


## Visualizations

### SPC Method Comparison

The previous-only monitoring method produced a substantially higher observed alert rate than the inclusive method.

![SPC Method Alert Rates](images/spc_method_alert_rates.png)

The inclusive method flagged 31.43% of analyzed measurements, compared with 64.00% for the previous-only method.

The difference illustrates how including the current observation in its own reference statistics can materially change SPC (Statistical Process Control) classifications.

---

### Operator Alert Rates

The previous-only SPC method was used to compare observed alert rates across operators.

![Operator Alert Rates](images/operator_alert_rates.png)

Alert rates varied substantially between operators. These values should be interpreted together with the number of measurements available for each operator and should not be treated as direct measures of individual operator performance.

---

### Alerts by Product Dimension

Length and width produced similar numbers of alerts, while height produced fewer.

![Dimension Alert Counts](images/dimension_alert_counts.png)

Using the previous-only method:

- Length: 122 alerts
- Width: 120 alerts
- Height: 99 alerts

---

## Project Architecture

The PostgreSQL workflow follows a layered structure:

```text
CSV source
    |
    v
raw.manufacturing_parts
    |
    v
Data-quality validation
    |
    v
analytics.manufacturing_parts_clean
    |
    +-----------------------------+
    |                             |
    v                             v
Inclusive SPC               Previous-only SPC
    |                             |
    v                             v
Reusable view                Reusable view
    |                             |
    +-------------+---------------+
                  |
                  v
          Method comparison
                  |
                  v
        Operator performance
