# Legoprosjekt - ELE130

## Komme i gang

### Prosjektsstruktur

```sh
lego-project
├── build
├── doc
│   ├── bilder
│   │   └── forside
│   │       ├── smiley.pdf
│   │       └── uis_logo.pdf
│   ├── forside.tex
│   ├── kap1_integrasjon.tex
│   ├── kap2_filtrering.tex
│   ├── kap3_derivasjon.tex
│   ├── kap4_manuell_kjoring.tex
│   ├── konklusjon.tex
│   ├── main.tex
│   ├── referanser.bib
│   ├── sammendrag.tex
│   └── vedlegg_timelister.tex
├── src
│   ├── Joystick
│   ├── MineFunksjoner
│   ├── Prosjekt00_TestOppkopling
│   ├── Prosjekt01_NumeriskIntegrasjon
│   ├── Prosjekt02_Filtrering
│   ├── Prosjekt03_NumeriskDerivasjon
│   ├── Prosjekt04_ManuellKjoring
│   └── Prosjekt0X_BeskrivendeTekst
├── LICENSE
├── README.md
└── lego-project.code-workspace
```
Viktige filer og mapper i prosjektet
- `build/` - Inneholder filer som blir generert av LaTeX.
- `doc/` - Inneholder LaTeX-dokumentene til prosjektet.
- `doc/bilder/` - Inneholder bilder som brukes i LaTeX-dokumentene. Bildene organiserer i undermapper etter navnet på LaTeX-dokumentet de brukes i.
- `src/` - Inneholder kildekoden til prosjektet.
- `lego-project.code-workspace` - Visual Studio Code workspace fil med instillinger for prosjektet. Denne filen kan åpnes i Visual Studio Code for å få tilgang til alle prosjektets filer.