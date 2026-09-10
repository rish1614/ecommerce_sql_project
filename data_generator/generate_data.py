from __future__ import annotations

import csv
import random
from datetime import date, timedelta
from pathlib import Path

import numpy as np
import pandas as pd
from faker import Faker

SEED = 42
random.seed(SEED)
np.random.seed(SEED)
Faker.seed(SEED)
fake = Faker("en_IN")

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
DATA.mkdir(exist_ok=True)

N_CUSTOMERS = 20_000
N_ORDERS = 80_000
N_PRODUCTS = 500

START = date(2025, 1, 1)
END = date(2025, 12, 31)
DAYS = (END - START).days + 1

states_regions = {
    "Delhi": "North", "Haryana": "North", "Punjab": "North", "Uttar Pradesh": "North",
    "Rajasthan": "North", "Maharashtra": "West", "Gujarat": "West", "Goa": "West",
    "Karnataka": "South", "Tamil Nadu": "South", "Telangana": "South", "Kerala": "South",
    "West Bengal": "East", "Odisha": "East", "Bihar": "East", "Jharkhand": "East",
}
states = list(states_regions)

cities_by_state = {
    "Delhi": ["New Delhi", "Dwarka", "Rohini"],
    "Haryana": ["Gurugram", "Faridabad", "Panipat"],
    "Punjab": ["Ludhiana", "Amritsar", "Jalandhar"],
    "Uttar Pradesh": ["Noida", "Lucknow", "Kanpur"],
    "Rajasthan": ["Jaipur", "Jodhpur", "Udaipur"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur"],
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara"],
    "Goa": ["Panaji", "Margao", "Vasco da Gama"],
    "Karnataka": ["Bengaluru", "Mysuru", "Mangaluru"],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
    "Telangana": ["Hyderabad", "Warangal", "Nizamabad"],
    "Kerala": ["Kochi", "Thiruvananthapuram", "Kozhikode"],
    "West Bengal": ["Kolkata", "Durgapur", "Siliguri"],
    "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela"],
    "Bihar": ["Patna", "Gaya", "Muzaffarpur"],
    "Jharkhand": ["Ranchi", "Jamshedpur", "Dhanbad"],
}

categories = {
    "Electronics": ["Phones", "Laptops", "Audio", "Accessories"],
    "Home": ["Kitchen", "Furniture", "Storage", "Decor"],
    "Fashion": ["Men", "Women", "Footwear", "Bags"],
    "Beauty": ["Skincare", "Haircare", "Makeup", "Personal Care"],
    "Sports": ["Fitness", "Running", "Outdoor", "Sportswear"],
}
brands = ["Aster", "Nova", "Orion", "Vertex", "Mira", "Pulse", "UrbanX", "Zenith", "Nexa", "Prime"]
acq_channels = ["Organic", "Paid Search", "Social", "Referral", "Email"]
order_channels = ["Organic", "Paid Search", "Social", "Referral", "Email"]
payment_methods = ["UPI", "Credit Card", "Debit Card", "Net Banking", "Wallet", "COD"]
return_reasons = ["Damaged", "Wrong Item", "Not as Expected", "Size Issue", "Changed Mind"]

# -------------------------
# Products -------------------------
product_rows = []
for pid in range(1, N_PRODUCTS + 1):
    category = random.choice(list(categories))
    subcategory = random.choice(categories[category])
    brand = random.choice(brands)
    # Keep price/cost realistic and positively correlated.
    base = {
        "Electronics": random.randint(800, 85000),
        "Home": random.randint(500, 30000),
        "Fashion": random.randint(400, 12000),
        "Beauty": random.randint(250, 7000),
        "Sports": random.randint(500, 18000),
    }[category]
    cost = round(base * random.uniform(0.45, 0.75), 2)
    list_price = round(base * random.uniform(1.05, 1.35), 2)
    product_rows.append({
        "product_id": pid,
        "product_name": f"{brand} {subcategory} Product {pid:04d}",
        "category": category,
        "subcategory": subcategory,
        "brand": brand,
        "unit_cost": cost,
        "list_price": list_price,
    })
products = pd.DataFrame(product_rows)
products.to_csv(DATA / "products.csv", index=False)

# -------------------------
# Campaigns -------------------------
campaigns = pd.DataFrame([
    [1, "New Year Sale", "Email", "2025-01-01", "2025-01-20", 90000],
    [2, "Republic Day Offer", "Social", "2025-01-21", "2025-01-31", 70000],
    [3, "Spring Refresh", "Paid Search", "2025-03-01", "2025-03-31", 110000],
    [4, "Summer Upgrade", "Social", "2025-05-01", "2025-05-31", 130000],
    [5, "Monsoon Deals", "Email", "2025-07-01", "2025-07-31", 100000],
    [6, "Festive Preview", "Paid Search", "2025-09-01", "2025-09-30", 160000],
    [7, "Diwali Mega Sale", "Social", "2025-10-15", "2025-11-05", 220000],
    [8, "Year End Clearance", "Email", "2025-12-01", "2025-12-31", 140000],
], columns=["campaign_id", "campaign_name", "channel", "start_date", "end_date", "budget"])
campaigns.to_csv(DATA / "campaigns.csv", index=False)

# -------------------------
# Customers -------------------------
customer_rows = []
for cid in range(1, N_CUSTOMERS + 1):
    state = random.choice(states)
    signup_date = START - timedelta(days=random.randint(0, 720))
    # Slightly different acquisition mix.
    acquisition = random.choices(acq_channels, weights=[32, 20, 20, 12, 16], k=1)[0]
    city = random.choice(cities_by_state[state]) if random.random() > 0.02 else None
    customer_rows.append({
        "customer_id": cid,
        "customer_name": fake.name(),
        "signup_date": signup_date,
        "gender": random.choices(["Female", "Male", "Other"], weights=[48, 48, 4], k=1)[0],
        "age": int(np.clip(np.random.normal(34, 10), 18, 70)),
        "city": city,
        "state": state,
        "region": states_regions[state],
        "acquisition_channel": acquisition if random.random() > 0.015 else None,
    })
customers = pd.DataFrame(customer_rows)
customers.to_csv(DATA / "customers.csv", index=False)

# -------------------------
# Orders -------------------------
customer_ids = np.arange(1, N_CUSTOMERS + 1)
# Popularity weights create a realistic long tail.
customer_order_weights = np.random.lognormal(mean=0, sigma=0.9, size=N_CUSTOMERS)
customer_order_weights /= customer_order_weights.sum()
selected_customers = np.random.choice(customer_ids, size=N_ORDERS, p=customer_order_weights)

# Seasonal effect: stronger Q4 and campaign periods.
def sample_order_date() -> date:
    weights = np.ones(DAYS)
    for i in range(DAYS):
        d = START + timedelta(days=i)
        month = d.month
        if month in (10, 11, 12):
            weights[i] *= 1.35
        if month in (1, 5, 7):
            weights[i] *= 1.10
    weights /= weights.sum()
    idx = np.random.choice(np.arange(DAYS), p=weights)
    return START + timedelta(days=int(idx))

order_rows = []
for oid in range(1, N_ORDERS + 1):
    customer_id = int(selected_customers[oid - 1])
    order_date = sample_order_date()
    status = random.choices(["Delivered", "Shipped", "Cancelled"], weights=[0.88, 0.07, 0.05], k=1)[0]
    # Campaign assignment is sparse.
    campaign_id = random.choice(range(1, 9)) if random.random() < 0.38 else None
    payment = random.choices(payment_methods, weights=[30, 24, 18, 8, 10, 10], k=1)[0]
    shipping_cost = round(random.uniform(40, 220), 2)
    order_rows.append({
        "order_id": oid,
        "customer_id": customer_id,
        "order_date": order_date,
        "status": status,
        "payment_method": payment,
        "shipping_cost": shipping_cost,
        "campaign_id": campaign_id,
    })
orders = pd.DataFrame(order_rows)

# Keep nullable campaign IDs as integers in the CSV.
orders["campaign_id"] = orders["campaign_id"].astype("Int64")

orders.to_csv(DATA / "orders.csv", index=False)

# -------------------------
# Order items -------------------------
product_probs = np.random.lognormal(mean=0, sigma=0.8, size=N_PRODUCTS)
product_probs /= product_probs.sum()
item_rows = []
item_id = 1
for row in orders.itertuples(index=False):
    n_items = random.choices([1, 2, 3, 4, 5], weights=[40, 30, 18, 9, 3], k=1)[0]
    chosen = np.random.choice(np.arange(1, N_PRODUCTS + 1), size=n_items, replace=False, p=product_probs)
    for pid in chosen:
        p = products.iloc[int(pid) - 1]
        quantity = random.choices([1, 2, 3, 4], weights=[72, 20, 6, 2], k=1)[0]
        discount_pct = random.choice([0.00, 0.00, 0.05, 0.10, 0.15, 0.20])
        item_rows.append({
            "order_item_id": item_id,
            "order_id": row.order_id,
            "product_id": int(pid),
            "quantity": quantity,
            "unit_price": round(float(p["list_price"]), 2),
            "discount_pct": discount_pct,
        })
        item_id += 1
order_items = pd.DataFrame(item_rows)
order_items.to_csv(DATA / "order_items.csv", index=False)


# -------------------------
# Returns: sample from delivered order items only
# -------------------------
delivered_order_ids = set(orders.loc[orders.status == "Delivered", "order_id"].astype(int))
eligible = order_items[order_items.order_id.isin(delivered_order_ids)].copy()
return_mask = np.random.random(len(eligible)) < 0.045
return_candidates = eligible[return_mask]
return_rows = []
rid = 1
for r in return_candidates.itertuples(index=False):
    return_qty = random.randint(1, int(r.quantity))
    order_date = orders.loc[orders.order_id == r.order_id, "order_date"].iloc[0]
    # Most returns occur within 30 days.
    return_date = min(END, order_date + timedelta(days=random.randint(2, 30)))
    reason = random.choice(return_reasons)
    refund = round(return_qty * float(r.unit_price) * (1 - float(r.discount_pct)), 2)
    return_rows.append({
        "return_id": rid,
        "order_id": int(r.order_id),
        "order_item_id": int(r.order_item_id),
        "return_date": return_date,
        "return_qty": return_qty,
        "reason": reason,
        "refund_amount": refund,
    })
    rid += 1
returns = pd.DataFrame(return_rows)
returns.to_csv(DATA / "returns.csv", index=False)

print("Generated:")
for f in ["customers.csv", "products.csv", "campaigns.csv", "orders.csv", "order_items.csv", "returns.csv"]:
    p = DATA / f
    print(f"  {f}: {sum(1 for _ in open(p, encoding='utf-8')) - 1:,} rows")
