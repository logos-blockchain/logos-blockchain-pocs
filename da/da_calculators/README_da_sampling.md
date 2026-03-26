# DA Sampling Calculator

**Live:** [da_calculator.html](da_calculator.html)

Interactive calculator for the Logos Blockchain data availability sampling protocol. Models sampling as a binary hypothesis test and allows interactive exploration of how protocol parameters affect Type I error, Type II error, grey zone width, wasted slots, and blockchain security horizon.

---

## Background

Logos Blockchain DA uses column sampling to verify data availability without downloading the entire dataset. A node draws S columns uniformly at random and applies a threshold decision rule: declare the blob available if at least τ out of S samples succeed.

This produces two error types that cannot be minimised independently:

- **Type I error α(τ)** — data is unrecoverable but sampling concludes it is recoverable. Threatens chain safety.
- **Type II error β(τ, Δ)** — data is recoverable but sampling concludes it is unrecoverable. Wastes slots, threatens liveness.

The calculator computes exact hypergeometric expressions for both errors and derives all downstream quantities from them.

---

## Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| N | Total columns = total subnetworks (N = r·K) | 2048 |
| r | RS expansion factor | 2 |
| K | Reconstruction threshold = N/r | 1024 |
| S | Sample size (columns drawn per round) | 20 |
| τ | Acceptance threshold (declare available if ≥ τ successes) | 20 |
| Δ | Grey zone width (derived from ε target) | 500 |
| ε | Error bound target | 10⁻⁴ |
| N_B | Blobs per block | 1024 |
| n | Number of validator nodes | 50 |
| f | Slot fill rate | 1/30 |
| T | Slots per epoch | 388800 |

---

## Tabs

### Detection Probability
Shows P(data detected as recoverable) as a function of N_A/N (fraction of available columns). Illustrates the grey zone between unrecoverable (N_A ≤ K) and certified recoverable (N_A ≥ K+Δ) regions.

### α & β Curves
Plots α(τ) and β(τ, Δ) on a log₁₀ scale as functions of the threshold τ. The intersection of the two curves shows the jointly optimal τ* that minimises max{α, β}.

### Multi-Δ Overlay
Compares α and β curves for multiple Δ values simultaneously, showing how the grey zone width affects the tradeoff.

### τ* vs ε Sweep
Plots the jointly optimal τ*(ε) and Δ*(ε) as functions of the error bound ε for multiple sample sizes S. Shows how tightening ε requires increasing Δ.

### Network Bounds
Shows the network-level error bounds as a function of validator count n:
- Left panel: P(majority accepts unrecoverable block) = 2ⁿ · ε^{N_B·⌈n/2⌉}
- Right panel: P(majority rejects recoverable block) = 2ⁿ · [1−(1−ε)^{N_B}]^{⌈n/2⌉}

### Chernoff Bound
Plots the Chernoff-based bounds for the grey zone regime.

### Block Builder
Shows the q-quantile of the hitting time τ_{N_B,q} — the number of blobs a block builder must consider to fill a block with N_B valid blobs, as a function of ε and N_B.

### Wasted Slots
Shows the average number of wasted slots per epoch as a function of validator count n, across three regimes (Code 2 basic upper bound, Code 3 tight Chernoff upper bound, Code 4 lower bound).

### Blockchain
Shows the median time T₁/₂ to the first invalid block accepted by a majority of validators, as a function of validator count n and error bound ε.

---
