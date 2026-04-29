/*********************************************
 * OPL 22.1.1.0 Model
 * Author: sama
 * Creation Date: Apr 21, 2026 at 7:14:59 PM
 *********************************************/

// Information
{string} Depots = ...;
{string} Hubs = ...;
{string} Zones = ...;

tuple DH { string d; string h; float cost; }; 
tuple HZ { string h; string z; float cost; }; 

{DH} arcDH = ...;
{HZ} arcHZ = ...;

// Parameters
float FixedCost[Hubs] = ...;
float Capacity[Hubs] = ...;
float Demand[Zones] = ...;

// Decision Variables
dvar int+ x1[arcDH]; // Flow from Depot to Hub (Stage 1)
dvar int+ x2[arcHZ]; // Flow from Hub to Zone (Stage 2)
dvar boolean y[Hubs];   // 1 if hub is open

// Objective Function
minimize 
  sum(arc in arcDH) arc.cost * x1[arc] +  // D to H Transport Cost
  sum(arc in arcHZ) arc.cost * x2[arc] +  // H to Z Transport Cost
  sum(h in Hubs) FixedCost[h] * y[h];  // Fixed Operating Cost

subject to {
  // Input at Hub must equal Output to Zones
  forall(h in Hubs)
    ctBalance: sum(arc in arcDH : arc.h == h) x1[arc] == sum(arc in arcHZ : arc.h == h) x2[arc];

  // Flow through Hub cannot exceed Capacity if Open
  forall(h in Hubs)
    ctCapacity: sum(arc in arcHZ : arc.h == h) x2[arc] <= Capacity[h] * y[h];

  // Total Demand must be met by the Hubs
  forall(z in Zones)
    ctDemand: sum(arc in arcHZ : arc.z == z) x2[arc] >= Demand[z];
}

// Post Processing 
execute {
  writeln("Objective Value: ", cplex.getObjValue());
  
  writeln("\n Hub open or closed?");
  for(var h in Hubs) {
    writeln(h, " is ", (y[h] == 1 ? "OPEN" : "CLOSED"));
  }
  
  writeln("\n Depot to Hub Package Flow");
  for(var arc in arcDH) {
    if(x1[arc] > 0) 
      writeln(arc.d, " -> ", arc.h, ": ", x1[arc]);
  }
  
  writeln("\n Hub to Zone Package Flow");
  for(var arc in arcHZ) {
    if(x2[arc] > 0) 
      writeln(arc.h, " -> ", arc.z, ": ", x2[arc]);
  }
}