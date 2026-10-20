# C1 conventions

These choices never change, so no Day has to decide them again.

## Units, signs and numbering

| Thing | Fixed choice |
|---|---|
| Base | per unit on the case's baseMVA (100 MVA in every IEEE case), converted once, inside `build_network` |
| Angles | radians inside the engine; degrees only in case files and reports |
| Voltages | complex NumPy array `V = Vm * exp(1j*Va)`, dtype complex128 |
| Bus numbers | external numbers only in Case and in reports. Solvers see internal indices 0…nb−1 in the order of the bus table after isolated buses are removed (MATPOWER's ext2int order); generators sorted by internal bus |
| Bus types | 1 PQ, 2 PV, 3 reference, 4 isolated; a PV bus with no generator in service becomes PQ |
| Unknowns | `x = [Va at pv then pq, Vm at pq]`, the same order as MATPOWER, so Jacobians compare entry by entry |
| Mismatch | `g = S_calc - S_spec` with `S_calc = V * conj(Ybus @ V)`: real part at pv and pq buses, imaginary part at pq buses |
| Signs | injections positive into the bus; branch flows Sf, St positive into the branch at each end; losses = Sf + St |
| Several generators on one bus | P and Q add; solved Q is split in proportion to the Q ranges (MATPOWER's rule) |
| RATE_A | 0 = unlimited, never a zero-capacity constraint |
| Frequency | 60 Hz for IEEE and ANDES cases; 50 Hz only where a worked example says so |
| Random numbers | `numpy.random.default_rng(seed)` with the seed passed explicitly; ML runs use seeds 0–4 |

## Tolerances: what "agrees" means

| What | Tolerance | Notes |
|---|---|---|
| Newton solve, normal use | max mismatch below 1e-8 pu, at most 10 iterations (MATPOWER's defaults) | Ch 9 |
| Newton solve, validation runs | max mismatch below 1e-10 pu, in both tools | Ch 13 |
| Power-flow voltages | max \|ΔVm\| < 1e-6 pu and max \|ΔVa\| < 1e-6 rad | Ch 13 |
| Flows, generator outputs, totals | below 1e-4 MVA, MW or Mvar | Ch 13 |
| Cross-residual | your mismatch at the reference voltages below 1e-6 pu | Ch 13 |
| Y-bus, B matrices | element-wise max difference below 1e-12 | Ch 6, 11 |
| Jacobian against finite differences | relative error below 1e-6 (central differences, step 1e-6) | Ch 9 |
| OPF | objective within 1e-6 relative, then LMPs, dispatch and voltages | Ch 16 |
| State estimation, zero noise | true state recovered to 1e-10 | Ch 18 |
| Dynamic initialization | every initial state within 1e-6 of the reference; \|\|f\|\| and \|\|g\|\| below 1e-10 | Ch 26, 30 |
| Flat run | every state constant to 1e-8 over 20 s on your own cases, 1e-6 on ANDES cases | Ch 26, 30 |
| Trajectories against ANDES | speeds within 1e-4 pu and voltages within 1e-3 pu, same integrator and step | Ch 30 |
| Eigenvalues | 1e-3 relative | Ch 30 |
| CCT | within the bisection tolerance, 1 ms | Ch 28 |

## Simulation defaults

| Thing | Default |
|---|---|
| Integrator | implicit trapezoidal, h = 1/120 s, Newton tolerance 1e-8 on each step |
| Fault | bolted three-phase at a bus, modelled as a shunt reactance x_f = 1e-4 pu (as ANDES does) |
| Fault time | t = 1.0 s in comparisons with ANDES; t = 0.1 s in CCT studies and datasets |
| Clearing | trip the faulted line at fault time + t_c |
| Horizon | 10 s for validation runs; 5 s for CCT labels |
| Loads in dynamics | constant impedance, converted from the power flow (ANDES's default) |
| Instability | largest rotor-angle difference between any two machines above 180° (ANDES's `ddelta_limit`) |
| Non-convergence | a run whose Newton fails is "non-convergent", a third class, never "unstable" |
| CCT search | bisection on a checked bracket [0.01, 1.0] s, 10 halvings (about 1 ms) |

## Test cases

| Case | Used for |
|---|---|
| 3-bus triangle (built by hand, Ch 6, 9, 12) | hand calculations and the first unit tests |
| case9 (WSCC 9-bus) | small checks; dynamics against Sauer & Pai Examples 7.5 and 8.3; the toy dataset |
| case14, case30, case118 | the L1 validation set; OPF and state estimation in L2 |
| case_ieee30 | the original IEEE 30-bus, for papers that use it |
| case39 | the 39-bus power flow in MATPOWER's version |
| case300 | robustness and speed (bus numbers up to 9533) |
| ANDES smib/SMIB.xlsx | the classical machine against ANDES |
| ANDES kundur/kundur_full.xlsx | GENROU and TGOV1 against ANDES on the two-area system |
| ANDES ieee39/ieee39_full.xlsx | the L2 validation system and the L3 dataset |
