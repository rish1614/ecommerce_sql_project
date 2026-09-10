from pathlib import Path
import pandas as pd
import subprocess


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "python" / "outputs" / "kpi_summary.csv"


def run_sql_file(sql_file: str) -> str:
    sql_path = ROOT / "sql" / sql_file

    result = subprocess.run(
        [
            "docker",
            "exec",
            "-i",
            "ecommerce-postgres",
            "psql",
            "-U",
            "analyst",
            "-d",
            "ecommerce_analytics",
            "-t",
            "-A",
            "-F",
            ",",
        ],
        input=sql_path.read_text(),
        text=True,
        capture_output=True,
        check=True,
    )

    return result.stdout.strip()


def main() -> None:
    python_kpi = pd.read_csv(OUTPUT).iloc[0]

    sql_output = run_sql_file("13_validation.sql")
    values = sql_output.split(",")

    sql_kpi = {
        "delivered_orders": int(values[0]),
        "purchasing_customers": int(values[1]),
        "net_revenue": float(values[2]),
        "aov": float(values[3]),
    }

    checks = {
        "delivered_orders": (
            sql_kpi["delivered_orders"],
            int(python_kpi["delivered_orders"]),
        ),
        "purchasing_customers": (
            sql_kpi["purchasing_customers"],
            int(python_kpi["purchasing_customers"]),
        ),
        "net_revenue": (
            round(sql_kpi["net_revenue"], 2),
            round(float(python_kpi["net_revenue"]), 2),
        ),
        "aov": (
            round(sql_kpi["aov"], 2),
            round(float(python_kpi["aov"]), 2),
        ),
    }

    print("\nSQL vs Python validation")
    print("=" * 70)

    all_match = True

    for metric, (sql_value, python_value) in checks.items():
        match = sql_value == python_value
        all_match &= match

        status = "PASS" if match else "FAIL"

        print(
            f"{metric:25} "
            f"SQL={sql_value:<20} "
            f"Python={python_value:<20} "
            f"{status}"
        )

    print("=" * 70)

    if all_match:
        print("All shared KPIs match.")
    else:
        print("At least one KPI does not match.")


if __name__ == "__main__":
    main()

