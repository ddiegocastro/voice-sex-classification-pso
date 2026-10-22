# Data

The raw recordings are **not included**: they are voice samples from student volunteers and are personal data.

Expected layout to reproduce the pipeline:

```
data/audios/
├── Mujer/   V001_M_A.mp3, V001_M_E.mp3, ... V0NN_M_U.mp3
└── Hombre/  V001_H_A.mp3, V001_H_E.mp3, ... V0NN_H_U.mp3
```

One sustained vowel (A, E, I, O, U) per file, `V<speaker id>_<M|H>_<vowel>.mp3`.
Note: `audio_processing.m` resolves `audios/` relative to its own folder; adjust the path if you keep data under `data/`.
