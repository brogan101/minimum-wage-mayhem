# Phase 11 — Fireable Offenses / Dirty Employee / Suspicion / Consequence Layer

## Start Condition

Do not start Phase 11 until:
- MVP full solo shift works.
- EventLog works.
- Shift results work.
- V16 career/write-up systems are at least partially wired.
- V17 maximum chaos exists structurally.
- V18 workplace mischief exists structurally.

## Goal

Add a consequence-heavy dirty-employee layer where shady/fireable actions are tempting, funny, dangerous, and deeply connected to progression.

## Required Data

Load:

- `data/fireable/offense_categories.json`
- `data/fireable/fireable_offenses.json`
- `data/fireable/caught_levels.json`
- `data/fireable/firing_routes.json`
- `data/fireable/shady_manager_promotion_outcomes.json`
- `data/fireable/ui_choice_templates.json`
- `data/fireable/weird_fireable_events.json`
- `data/fireable/coworker_fireable_activity.json`
- `data/fireable/manager_coverups.json`
- `data/fireable/consequence_matrix.json`
- `data/fireable/end_shift_consequence_recap.json`
- `data/shady/tip_jar_actions.json`
- `data/shady/register_misconduct_actions.json`
- `data/shady/inventory_misconduct_actions.json`
- `data/shady/food_karma_actions.json`
- `data/shady/abstract_impairment_events.json`

## Required Managers

Add/connect:

- `scripts/consequences/SuspicionManager.gd`
- `scripts/consequences/FireableOffenseManager.gd`
- `scripts/consequences/ShadyChoiceManager.gd`
- `scripts/consequences/TipJarManager.gd`
- `scripts/consequences/RegisterIntegrityManager.gd`
- `scripts/consequences/InventoryMisconductManager.gd`
- `scripts/consequences/FoodKarmaManager.gd`
- `scripts/consequences/AbstractImpairmentManager.gd`
- `scripts/consequences/ManagerCoverupManager.gd`
- `scripts/consequences/FiringRecoveryManager.gd`

## Phase 11 Tasks

1. Load fireable offense data.
2. Track suspicion state.
3. Add UI-choice interaction templates.
4. Add abstract dirty employee choices to objects like tip jar, register, food bag, manager tablet, HR printer, security monitor, and break room items.
5. Roll detection using suspicion, witnesses, cameras, manager type, coworker loyalty, and chaos level.
6. Apply caught levels.
7. Generate HR/report/review/training outcomes.
8. Update promotion/demotion/fired risk.
9. Add firing-but-not-over routes.
10. Save career incident history.
11. Run validation.

## Acceptance

Phase 11 is ready when:

- Shady choices are UI-driven and abstract.
- Suspicion changes.
- Detection rolls work.
- Caught levels trigger consequences.
- Tip jar/register/inventory/food-karma/impairment systems have data and managers.
- Coworker/manager dirty events exist.
- Firing does not always mean permanent game-over.
- Shady player can still become manager through performance/politics, but caught behavior has real consequences.
- Validation passes.

## Do Not Do

- Do not add real-world crime instructions.
- Do not show realistic food tampering steps.
- Do not name real illegal drugs or provide usage details.
- Do not make theft or harm optimal.
- Do not make firing instant for every bad choice.
- Do not let this layer override normal clean play.
