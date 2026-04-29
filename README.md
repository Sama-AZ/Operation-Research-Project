(Generated with the Help of AI)

# Operation-Research-Project
# Last-Mile Delivery Network Optimization
## ISEE-301.601 Operations Research Project — Group 3

**Course:** Operations Research (ISEE-301.601)
**Semester:** Spring 2026
**Instructor:** Dr. Dua Weraikat
**Teaching Assistant:** Engineer Basil Al Tanji
**Institution:** Rochester Institute of Technology of Dubai

### Team Members

| Name | Student ID |
|------|-----------|
| Ameera Ismail | 762003350 |
| Isabela Planta | 391000602 |
| Sama Abu Zeid | 771000090 |



## 1. Project Overview

This project formulates and solves a facility location and transportation problem for last-mile package delivery in Dubai. Packages flow from a depot (JAFZA) through three hubs (Silicon High Bay, Warsan, Academic City) to four demand zones in Dubai Silicon Oasis (Cedre Villas, Silicon Gates, Semmer Villas, plus a Dummy node to balance supply and demand).

The model is implemented as a Mixed Integer Linear Program (MILP) in IBM ILOG CPLEX Optimization Studio (OPL) and decides:

1. Which hubs to keep open (binary decision variable y[h])
2. How many units to ship from the depot to each hub ( x1[arc] )
3. How many units each hub delivers to each zone ( x2[arc] )

The goal is to minimize total cost which includes transportation cost from depot to hubs + transportation cost from hubs to zones + fixed operating cost of open hubs.

### Optimal Solution

| Metric | Value |
|--------|-------|
| Objective (Total Cost) | **6,010.89 AED** |
| Solver | CPLEX MILP |
| Optimality Gap | 0% |
| Solve Time | 0.01 seconds |
| Hubs Opened | All 3 (SiliconHighBay, Warsan, AcademicCity) |



## 2. Repository Contents

| File | Description |
|------|-------------|
| README.md | This file — project overview and instructions |
| OR Project.mod | **Phase 4** — main MILP model (objective, decision variables, constraints, post-processing output) |
| OR Project.dat | **Phase 4** — input data (depots, hubs, zones, costs, capacities, demands) |
| OR Project LP.mod | **Phase 5** — LP-relaxed version that prints shadow prices and reduced costs for sensitivity analysis |
| OR Project LP.dat | **Phase 5** — same data as Phase 4, used with the LP model |

In OPL, the '.dat' file is the data step: all input parameters (per-unit transport costs, hub fixed costs, hub capacities, zone demands) live there and are consumed by the '.mod' file at solve time.



## 3. Model Structure (matches the code)

### Sets

- Depots = {"JAFZA"}
- Hubs = {"SiliconHighBay", "Warsan", "AcademicCity"}
- Zones = {"CedreVillas", "SiliconGates", "SemmerVillas", "Dummy"}
- arcDH — set of depot to hub arcs (each carries a `cost`)
- arcHZ — set of hub to zone arcs (each carries a `cost`)

### Parameters

- FixedCost[Hubs] = fixed operating cost of each hub
- Capacity[Hubs] = capacity of each hub
- Demand[Zones] = demand of each zone

### Decision Variables (in the `.mod`)

- x1[arcDH] — integer ≥ 0, flow from Depot to Hub (Stage 1)
- x2[arcHZ] — integer ≥ 0, flow from Hub to Zone (Stage 2)
- y[Hubs] — binary(1 if hub is open and 0 if closed)

### Objective Function

minimize
  sum(arc in arcDH) arc.cost * x1[arc] +
  sum(arc in arcHZ) arc.cost * x2[arc] +
  sum(h in Hubs) FixedCost[h] * y[h];

### Constraints

- ctBalance — for each hub, input from depot equals output to zones
- ctCapacity — flow out of each hub cannot exceed its capacity, and only if it is open: sum(...) x2[arc] <= Capacity[h] * y[h]
- ctDemand — every zone must receive at least its demand: sum(...) x2[arc] >= Demand[z]

For Phase 5, `OR Project LP.mod` relaxes the integer/binary variables (dvar float+) so CPLEX can return shadow prices and reduced costs.



## 4. Phase 5 Sensitivity Analysis

| Scenario | ΔZ | New Objective |
|----------|-----|---------------|
| SiliconHighBay capacity +1 unit | −$0.84 | $6,010.05 |
| AcademicCity capacity +1 unit | −$0.57 | $6,010.32 |
| Warsan capacity +1 unit | −$0.27 | $6,010.62 |
| All demands +20% | +$1,511.11 | **$7,522 (Infeasible)** |
| All fixed costs −10% | −$114.70 | $5,896.19 |
| Vehicle range increases (all unused routes feasible) | −$525.43 | $5,485.46 |

### Managerial Recommendations

1. Expand Silicon High Bay first — every extra unit of capacity saves $0.84.
2. Negotiate fixed operating costs — a 10% reduction saves $114.70 with zero operational risk.
3. Invest in longer-range vehicles — would unlock unused routes and save up to $525.43.
4. Plan ahead for demand growth — a 20% rise in demand creates an 878.8-unit shortfall and breaks the network.
