# DA Calculators

Interactive parametric calculators for the Logos Blockchain Data Availability layer. Both calculators run entirely in the browser with no dependencies beyond the bundled libraries.

## Calculators

### [DA Sampling Calculator](da_calculator.html)

Explores the statistical properties of the Logos Blockchain DA sampling protocol. Models data availability sampling as a binary hypothesis test and provides interactive tools to sweep parameter spaces and observe how sampling configuration affects error bounds and chain growth dynamics.

### [Adversary Attack Surface Calculator](adversary_calculator.html)

Analyses the capabilities of an adversary who controls a fraction of DA nodes. Models two complementary attacks — making available data appear unavailable (Attack A, liveness threat) and making unavailable data appear available (Attack B, safety threat) — and shows how each protocol parameter shapes the adversary's effective capability as a function of the adversarial node fraction p_d.

## Usage

Open either HTML file directly in a browser. No build step or server required.

## Related Documents

- [Data Availability — Statistical Properties of Sampling](https://www.notion.so/Data-availability-statistical-properties-of-sampling-2d1261aa09df805facbcfd8184009928)
- [Adversary — Selective Availability Attack](https://www.notion.so/nomos-tech/Adversary-Selective-Availability-Attack-General-Analysis-32f261aa09df80ac922be1d774095321)
