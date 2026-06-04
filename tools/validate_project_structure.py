import os
import json

def validate_project():
    print("Starting Project Validation...")
    errors = []
    
    # 1. Check for essential files
    essential_files = [
        "project.godot",
        "ORIGINAL_PLAN_REQUIREMENTS.md",
        "IMPLEMENTATION_STATUS.md",
        "ASSET_SOURCING_PLAN.md",
        "ASSET_CREDITS.md",
        "ASSET_VALIDATION.md"
    ]
    
    for f in essential_files:
        if not os.path.exists(f):
            errors.append(f"Missing essential file: {f}")

    # 2. Check data folder and JSONs
    data_files = [
        "data/customers/customer_archetypes.json",
        "data/orders/order_modifiers.json",
        "data/orders/ingredients.json",
        "data/drama/chaos_events.json",
        "data/drama/employee_drama_events.json",
        "data/drama/shady_actions.json",
        "data/drama/punishments.json",
        "data/corporate/corporate_mandates.json",
        "data/reviews/review_templates.json",
        "data/hr/hr_templates.json"
    ]
    
    for df in data_files:
        if not os.path.exists(df):
            errors.append(f"Missing data file: {df}")
        else:
            try:
                with open(df, 'r') as f:
                    json.load(f)
            except json.JSONDecodeError:
                errors.append(f"Invalid JSON in: {df}")

    # 3. Check for brand names (Simple check)
    brand_names = ["McDonalds", "Starbucks", "Burger King", "Taco Bell", "Wendy's", "Chick-fil-A"]
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith(".gd"):
                with open(os.path.join(root, file), 'r') as f:
                    content = f.read()
                    for brand in brand_names:
                        if brand in content:
                            errors.append(f"Potential brand name found in {file}: {brand}")

    if errors:
        print("\n❌ VALIDATION FAILED:")
        for e in errors:
            print(f"- {e}")
        return False
    else:
        print("\n✅ VALIDATION PASSED: Project structure is healthy.")
        return True

if __name__ == "__main__":
    validate_project()
