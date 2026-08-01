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