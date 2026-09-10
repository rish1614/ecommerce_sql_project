# Business Findings and Recommendations

## Executive Summary

This project analyzes a synthetic e-commerce business covering the calendar year 2025. The current validated KPI analysis reports 70,437 delivered orders from 16,595 purchasing customers and net revenue of 3,567,554,022.14 under the project's defined revenue methodology.

The most important current signals are:

1. **Q4 is the strongest revenue period.** October, November, and December are materially higher than most earlier months, with December the highest month in the verified monthly output.
2. **Refunds and discounts are material deductions from gross sales.** Gross sales are 4,047,389,652.39, while discounts total 337,195,367.89 and refunds total 142,640,262.36.
3. **Revenue should be evaluated alongside retention and profitability.** The project contains customer repeat behavior, return, product-margin, and regional contribution-profit analyses specifically to avoid revenue-only decision making.

## 1. Executive KPIs

| KPI | Verified value |
|---|---:|
| Delivered orders | 70,437 |
| Purchasing customers | 16,595 |
| Gross sales | 4,047,389,652.39 |
| Discounts | 337,195,367.89 |
| Refunds | 142,640,262.36 |
| Net revenue | 3,567,554,022.14 |
| AOV | 50,648.86 |

## 2. Revenue trend

The verified monthly net-revenue series is:

| Month | Net revenue |
|---|---:|
| January | 300,693,127.56 |
| February | 247,183,821.04 |
| March | 270,875,286.57 |
| April | 258,665,327.37 |
| May | 297,030,669.54 |
| June | 259,262,380.08 |
| July | 296,273,882.69 |
| August | 270,587,912.88 |
| September | 266,580,393.52 |
| October | 369,526,538.78 |
| November | 356,501,340.20 |
| December | 374,373,341.92 |

### Interpretation

The major pattern is a clear Q4 uplift. December is the highest month in the verified series, while February is the lowest.

The correct next analytical step is decomposition:

```text
Revenue change
   ↓
Order volume vs AOV
   ↓
Customer mix
   ↓
Category mix
   ↓
Campaign periods
```

Do not claim that campaigns caused the Q4 uplift without causal evidence.

## 3. Customer findings

The customer-analysis SQL is designed to identify:

- highest-value customers;
- repeat versus one-time customers;
- customers with no delivered purchases;
- RFM-style high-value behavior.

### Values to populate after final run

```text
Purchasing customers: __________________
Repeat customers: ______________________
Repeat-customer rate: __________________%
One-time customers: ____________________
Top customer revenue: ___________________
Customers needed to reach ~80% revenue: ___
```

### Interpretation framework

If one-time buyers represent a large share of purchasing customers, the primary opportunity is retention rather than simply acquiring more first-time buyers.

If revenue is highly concentrated among a small group of customers, management should monitor concentration risk and build retention plans for high-value segments.

## 4. Product and category findings

The product-analysis workflow identifies:

- top products by revenue;
- top three products within each category;
- category sales share;
- gross profit and gross margin.

### Values to populate after final run

```text
Top category by sales: __________________
Top category by gross profit: ___________
Top category by gross margin: ___________
Highest-revenue product: ________________
Highest-return product: _________________
```

### Interpretation framework

Revenue leaders should not automatically receive more promotional support. A product with high sales but low margin or high return rate may create less value than a smaller but more profitable product.

## 5. Returns findings

Verified total return events:

```text
6,479
```

The return-analysis SQL ranks return reasons by events, units, and refund amount.

### Values to populate after final run

```text
Largest return reason by events: ________
Largest return reason by refund value: ___
Total units returned: ____________________
Total refunds: ___________________________
Highest-return category/product: _________
```

### Interpretation framework

The dominant return reason should be investigated operationally. For example, different reasons imply different interventions; product quality, fulfillment accuracy, expectation setting, and sizing issues are not the same problem.

## 6. Profitability findings

The project calculates:

```text
Contribution Profit
= Net Revenue − COGS − Shipping Cost
```

### Values to populate after final run

```text
Total contribution profit: ______________
Overall contribution margin: ____________%
Highest-profit region: ___________________
Highest-margin region: __________________
Highest-profit category/product: _________
```

### Interpretation framework

Management should compare revenue leadership with contribution-profit leadership. A region or category with lower revenue can still be strategically attractive if it produces stronger contribution margin.

## 7. Acquisition and campaign findings

The project contains acquisition-channel and campaign-level descriptive analysis.

### Values to populate after final run

```text
Top acquisition channel by revenue: ______
Top acquisition channel by AOV: __________
Top campaign by revenue: _________________
Top campaign by AOV: _____________________
```

### Important limitation

The analysis is descriptive rather than causal. Campaign revenue cannot by itself establish incremental ROI because the dataset does not include randomized controls or a complete causal attribution framework.

## 8. Recommendations

### Recommendation 1 — Improve repeat purchasing

Use customer segmentation to identify one-time buyers and high-value customers who have become inactive. The objective is to increase repeat purchasing without assuming that every customer should receive the same intervention.

### Recommendation 2 — Prioritize profitable growth

Use contribution profit and margin alongside sales when deciding which categories, products, or regions deserve additional promotional investment.

### Recommendation 3 — Investigate high-return products

Rank products and categories by return rate and refund value. Pair the ranking with return reasons so that operational teams can target the underlying problem rather than simply reacting to the refund amount.

### Recommendation 4 — Decompose Q4 growth

Q4 is visibly stronger in the verified revenue series. Before allocating additional budget, determine whether the uplift comes from order volume, higher AOV, customer mix, category mix, campaign activity, or a combination.

### Recommendation 5 — Treat campaign performance as a starting point

Use the campaign table to prioritize deeper testing, but do not present descriptive campaign revenue as proof of incremental ROI.

## 9. Limitations

- The dataset is synthetic and therefore does not represent actual company performance.
- Cost and shipping fields are generated assumptions.
- The churn threshold is a project assumption.
- Customer segment thresholds are project-defined rules.
- Campaign attribution is descriptive rather than causal.
- Missing customer attributes are retained rather than imputed or dropped.

## 10. Final management message

> The business shows strong Q4 demand, meaningful deductions from discounts and refunds, and clear opportunities to improve customer retention and profitability. The next decision layer should focus on decomposing growth, identifying profitable customer/product segments, and reducing avoidable returns rather than optimizing on top-line revenue alone.
