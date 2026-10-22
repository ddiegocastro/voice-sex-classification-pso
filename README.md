# Sex Classification from Voice Signals with PSO Feature Selection

Binary classification of speaker sex from **sustained-vowel recordings**, using **MFCC** features, **Particle Swarm Optimization (PSO)** as a wrapper feature selector, and **Random Forest vs. SVM** classifiers. Implemented in MATLAB.

Course project — *Signals and Linear Systems*, Universidad de Monterrey (UDEM). Full write-up in [`docs/report.pdf`](docs/report.pdf).

## Results

| Model | Selected features | Test accuracy | F1 |
|---|---|---|---|
| Random Forest (100 trees) | MFCC 11, 12, 14 | **0.946** | **0.955** |
| SVM (RBF kernel) | MFCC 11, 12, 14 | 0.919 | 0.930 |

PSO consistently reduced the feature space from **14 → 3 coefficients**. Welch's t-tests (used after detecting variance heterogeneity) confirmed significant male/female differences for all three (p < 0.003).

## Pipeline

```
audio (.mp3) ─► band-pass 80–5000 Hz ─► mono ─► 1 s steady-state window ─► MFCC (20 ms Hamming, 10 ms overlap)
            ─► mean over frames ─► z-score (train stats only) ─► PSO wrapper selection (5-fold CV) ─► RF / SVM ─► held-out test
```

| Stage | Choice | Rationale |
|---|---|---|
| Denoising | 4th-order Butterworth band-pass, 80–5000 Hz, `filtfilt` | 80 Hz ≈ lowest male F0; 5 kHz = max energy observed; zero-phase avoids distortion |
| Segment | Middle 1 s of each vowel | Keeps the stationary voiced portion, drops onset/offset |
| Features | 14 MFCC (log-energy + 13 cepstral) + deltas, averaged across frames | Compact spectral-envelope descriptor; one vector per recording |
| Normalization | z-score fitted on the training split, applied to test | Prevents test-set leakage |
| Split | Stratified 80/20 hold-out by sex, `rng(42)` | Class imbalance (more male speakers); reproducible |
| Feature selection | `particleswarm`, 20 particles, threshold 0.5, hybrid `fmincon` | Cost = α·(1 − CV accuracy) + (1 − α)·(n_selected / n_total), α = 0.9 |

## Dataset

185 recordings = 37 speakers (22 male, 15 female, ages 17–23) × 5 vowels, captured on 3 devices (44.1–48 kHz). Raw audio is **not** distributed — see [`data/README.md`](data/README.md).

## Repository structure

```
src/
  MFCC_coeff.m              # filtering, windowing and MFCC extraction for one file
  audio_processing.m        # batch extraction for all speakers/vowels + labels
  extract_features.m        # driver: builds coefficient tables (.csv)
  pso_feature_selection.m   # PSO + SVM / RF training and evaluation
live_scripts/               # original MATLAB Live Scripts (.mlx) with outputs
docs/report.pdf             # IEEE-format project report
```

## How to run

Requirements: MATLAB R2023b+ with Signal Processing, Audio, Statistics and Machine Learning, Global Optimization and Optimization Toolboxes.

1. Place the recordings as described in `data/README.md`.
2. Run `extract_features.m` → produces `coefficients_Mujer.csv` and `coefficients_Hombre.csv`.
3. Load them as `coefficientsMujer` / `coefficientsHombre` and run `pso_feature_selection.m`.

## Limitations

- **Split is per recording, not per speaker:** vowels from the same speaker can appear in both train and test, so reported accuracy is likely optimistic. A speaker-grouped split (e.g. `cvpartition` over speaker IDs / leave-one-speaker-out) is the correct next step.
- Small cohort (37 speakers) and a narrow age range limit generalization.
- Mixed recording devices introduce channel variability that was not explicitly compensated.

## Authors

Diego Adrián Castro Ovalle · Juan Gerardo Barrios García · Monserrat Ayala Muñoz — Biomedical Engineering, UDEM.
