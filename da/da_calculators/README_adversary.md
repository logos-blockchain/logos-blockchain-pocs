# Adversary Attack Surface Calculator

**Live:** [adversary_calculator.html](adversary_calculator.html)

Interactive calculator for analysing the capabilities of an adversary who controls a fraction of DA nodes in the Logos Blockchain DA layer. Derives general formulas for two complementary attacks and shows how each protocol parameter shapes the adversary's effective capability as a function of the adversarial node fraction p_d.

---

## Background

This calculator assumes a **silence-only adversary model**: adversarial nodes simply do not respond to sampling requests. They do not send false proofs or invalid data. The analysis of adversarial nodes that respond with equivocating proofs is a separate topic.

Two attacks are modelled:

**Attack A — Available → Unavailable (Type II exploitation)**
The data is genuinely available. The adversary instructs controlled nodes to withhold responses from targeted validators, causing them to observe fewer than τ successes and declare the data unavailable. This is a liveness threat: honest leaders waste slots, validators develop split views, chain growth slows.

**Attack B — Unavailable → Available (Type I exploitation)**
The adversary is the encoder. It disperses data only to its fully controlled subnetworks and withholds from the rest. Validators that happen to sample only adversarially controlled subnetworks receive valid responses and incorrectly conclude the data is available. This is a safety threat.

---

## Parameters

| Parameter | Description | Default |
| --- | --- | --- |
| N | Total subnetworks = total columns in expanded data | 2048 |
| e | RS expansion factor | 2 |
| R | Nodes assigned to each subnetwork | 5 |
| S | Subnetworks sampled per validation round | 20 |
| τ | Acceptance threshold (declare available if ≥ τ successes out of S) | 13 |
| t | Nodes queried per subnetwork before declaring it failed (1 ≤ t ≤ R) | 5 |
| p_d | Adversarial node fraction (%) | 33 |

---

## Core Formulas

**Subnetwork failure probability** — probability all t queried nodes are adversarial given a adversarial nodes out of R:

```
P_fail(a, R, t) = C(a,t) / C(R,t)    for a ≥ t,  else 0
```

**Effective subnetwork failure probability** — averaged over the adversarial occupancy distribution:

```
P_fail_eff(p_d, R, t) = Σ_{a=t}^{R} B(R, a, p_d) · P_fail(a, R, t)
```

**Attack A probability** — validator needs S−τ+1 failures:

```
P_A(p_d, R, t, S, τ) = Σ_{j=S−τ+1}^{S} C(S,j) · P_fail_eff^j · (1−P_fail_eff)^{S−j}
```

**Attack B probability** — adversary needs τ hits from Y_full = N·p_d^R captured subnetworks:

```
P_B(p_d, R, N, S, τ) = Σ_{g=τ}^{S} Hypergeometric(N, Y_full, S, g)
```

---

## Regime Thresholds

The adversarial fraction p_d determines which attack regime the network is in:

| Regime | Condition | Threat |
| --- | --- | --- |
| Safe | p_d < (τ/S)^{1/R} | Neither attack effective |
| Attack A only | (τ/S)^{1/R} ≤ p_d < (1−1/e)^{1/R} | Liveness risk |
| Attack A + B | p_d ≥ (1−1/e)^{1/R} | Liveness + safety risk |

The Attack B threshold (1−1/e)^{1/R} always exceeds 0.5 for any e ≥ 2 and R ≥ 1. No sub-majority adversary can threaten global data recovery in expectation.

---

## Tabs

### Attack A vs B
Shows both P_A and P_B as functions of p_d at current parameters. The regime bar shows which zone the current p_d falls in, with a teal marker.

### τ effect
Shows P_A and P_B curves for multiple τ values simultaneously. τ is the sole parameter with opposite effects on the two attacks:
- Higher τ → Attack A easier (S−τ+1 failures needed, decreasing)
- Higher τ → Attack B harder (τ hits needed, increasing)

Regime bars show how the Attack A threshold shifts with τ while the Attack B threshold stays fixed.

### t effect
Shows P_A for multiple t values and P_B for multiple t values. All P_B curves are identical — t has zero effect on Attack B. P_A curves decrease as t increases, with t=R eliminating all partial-capture contribution.

### R effect
Shows both P_A and P_B curves for R ∈ {1, 3, 5, 7, 10}. Both attacks collapse exponentially as R increases. Both regime thresholds shift right. R is the primary structural defence parameter.

---
