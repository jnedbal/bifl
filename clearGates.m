function clearGates(in)
global figs

% Reset gate parameters
figs.gates(in).pos = [];
figs.gates(in).gName = [];
figs.gates(in).hElli = [];
figs.gates(in).nrElli = 0;
figs.gates(in).hRect = [];
figs.gates(in).nrRect = 0;
figs.gates(in).hCheck = [];
figs.gates(in).checked = [];
figs.gates(in).hDelBut = [];
figs.gates(in).hEdit = [];
figs.gates(in).gates = [];