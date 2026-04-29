/*********************************************
 * OPL 22.1.1.0 Data
 * Author: sama
 * Creation Date: Apr 22, 2026 at 10:12:02 PM
 *********************************************/
 
// Sets
{string} Depots = ...;
{string} Hubs = ...;
{string} Zones = ...;

// Tuples
tuple DH { string d; string h; float cost; }; 
tuple HZ { string h; string z; float cost; }; 

{DH} arcDH = ...;
{HZ} arcHZ = ...;

// Parameters
float FixedCost[Hubs] = ...;
float Capacity[Hubs] = ...;
float Demand[Zones] = ...;

// DECISION VARIABLES: All are now float+
dvar float+ x1[arcDH]; 
dvar float+ x2[arcHZ]; 
dvar float+ y[Hubs]; 

// Objective Function
minimize 
  sum(arc in arcDH) arc.cost * x1[arc] + 
  sum(arc in arcHZ) arc.cost * x2[arc] + 
  sum(h in Hubs) FixedCost[h] * y[h];

subject to {
  // 1. Flow Conservation
  forall(h in Hubs)
    ctBalance: sum(arc in arcDH : arc.h == h) x1[arc] == sum(arc in arcHZ : arc.h == h) x2[arc];

  // 2. Capacity Constraint
  forall(h in Hubs)
    ctCapacity: sum(arc in arcHZ : arc.h == h) x2[arc] <= Capacity[h] * y[h];

  // 3. Demand Constraint
  forall(z in Zones)
    ctDemand: sum(arc in arcHZ : arc.z == z) x2[arc] >= Demand[z];

  // 4. Bound Constraint: y must be between 0 and 1
  forall(h in Hubs)
    ctHubBound: y[h] <= 1; 
}

// Sensitivity Analysis
execute {
  writeln("SENSITIVITY ANALYSIS");

  writeln("\n Dual Values (Shadow Prices)");
  for(var h in Hubs) {
    writeln("Capacity_", h, "\t =", ctCapacity[h].dual);
  }
  for(var z in Zones) {
    writeln("Demand_", z, "\t =", ctDemand[z].dual);
  }

  writeln("\n Reduced Costs");
  for(var arc in arcDH) {
    writeln("x1_", arc.d, "_", arc.h, "\t =", x1[arc].reducedCost);
  }
  for(var arc in arcHZ) {
    writeln("x2_", arc.h, "_", arc.z, "\t =", x2[arc].reducedCost);
  }
}