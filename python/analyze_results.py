from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
OUT = ROOT / "python" / "outputs"
OUT.mkdir(exist_ok=True)

orders = pd.read_csv(DATA / "orders.csv", parse_dates=["order_date"])
items = pd.read_csv(DATA / "order_items.csv")
products = pd.read_csv(DATA / "products.csv")
returns = pd.read_csv(DATA / "returns.csv", parse_dates=["return_date"])
customers = pd.read_csv(DATA / "customers.csv", parse_dates=["signup_date"])

# Work only with delivered orders.
delivered = orders[orders["status"] == "Delivered"].copy()
line = items.merge(delivered[["order_id", "customer_id", "order_date", "shipping_cost", "campaign_id"]], on="order_id", how="inner")
line = line.merge(products[["product_id", "product_name", "category", "unit_cost"]], on="product_id", how="left")
line["gross_sales"] = line["quantity"] * line["unit_price"]
line["discount_amount"] = line["gross_sales"] * line["discount_pct"]
line["net_sales"] = line["gross_sales"] - line["discount_amount"]
line["cogs"] = line["quantity"] * line["unit_cost"]

refunds = returns.groupby("order_id", as_index=False)["refund_amount"].sum().rename(columns={"refund_amount": "refunds"})
order_level = line.groupby(["order_id", "customer_id", "order_date", "shipping_cost"], as_index=False).agg(
    net_sales=("net_sales", "sum"),
    cogs=("cogs", "sum")
).merge(refunds, on="order_id", how="left")
order_level["refunds"] = order_level["refunds"].fillna(0)
order_level["net_revenue"] = order_level["net_sales"] - order_level["refunds"]
order_level["contribution_profit"] = order_level["net_revenue"] - order_level["cogs"] - order_level["shipping_cost"]

# KPI output
kpi = pd.DataFrame([{
    "delivered_orders": order_level["order_id"].nunique(),
    "purchasing_customers": order_level["customer_id"].nunique(),
    "net_revenue": order_level["net_revenue"].sum(),
    "aov": order_level["net_revenue"].mean(),
    "contribution_profit": order_level["contribution_profit"].sum(),
    "contribution_margin_pct": 100 * order_level["contribution_profit"].sum() / order_level["net_revenue"].sum(),
}])
kpi.to_csv(OUT / "kpi_summary.csv", index=False)

# Monthly trend
monthly = order_level.assign(month=order_level["order_date"].dt.to_period("M")).groupby("month", as_index=False).agg(
    net_revenue=("net_revenue", "sum"),
    contribution_profit=("contribution_profit", "sum"),
    orders=("order_id", "nunique")
)
monthly["aov"] = monthly["net_revenue"] / monthly["orders"]
monthly.to_csv(OUT / "monthly_kpis.csv", index=False)

plt.figure(figsize=(10, 5))
plt.plot(monthly["month"].astype(str), monthly["net_revenue"], marker="o")
plt.title("Monthly Net Revenue")
plt.xlabel("Month")
plt.ylabel("Net Revenue")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(OUT / "monthly_net_revenue.png", dpi=150)
plt.close()

# Category performance
category = line.groupby("category", as_index=False).agg(
    net_sales=("net_sales", "sum"),
    cogs=("cogs", "sum"),
    units=("quantity", "sum")
)
category["gross_profit"] = category["net_sales"] - category["cogs"]
category["gross_margin_pct"] = 100 * category["gross_profit"] / category["net_sales"]
category = category.sort_values("net_sales", ascending=False)
category.to_csv(OUT / "category_performance.csv", index=False)

plt.figure(figsize=(8, 5))
plt.bar(category["category"], category["net_sales"])
plt.title("Net Sales by Category")
plt.xlabel("Category")
plt.ylabel("Net Sales")
plt.xticks(rotation=20)
plt.tight_layout()
plt.savefig(OUT / "category_sales.png", dpi=150)
plt.close()

# Customer concentration (Pareto-style)
customer_rev = order_level.groupby("customer_id", as_index=False)["net_revenue"].sum().sort_values("net_revenue", ascending=False)
customer_rev["cumulative_share"] = customer_rev["net_revenue"].cumsum() / customer_rev["net_revenue"].sum()
customer_rev.to_csv(OUT / "customer_pareto.csv", index=False)

print("KPI summary")
print(kpi.round(2).to_string(index=False))
print("\nTop categories")
print(category.round(2).to_string(index=False))
print(f"\nOutputs written to: {OUT}")
