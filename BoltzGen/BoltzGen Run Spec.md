**Ready‑to‑edit BoltzGen design‑spec skeletons (YAML)** for the three scalp‑serum–relevant ideas we discussed:

1. a **SUCNR1 (GPR91) extracellular‑loop–blocking cyclic peptide** (SUCNR1 antagonism → dampen the Succinate→HIF‑1 pseudohypoxia “G12 gate”),
2. a **succinate‑binding mini‑protein** (local sequestration), and
3. a **heme‑binding mini‑protein** (peptide alternative to topical iron/hematin chelators).

They use BoltzGen’s native spec language: `entities` (targets, designed chains, small molecules), `binding_types` (bind / not_binding regions), `structure_groups` (make regions flexible/fixed), `secondary_structure`, and explicit `constraints` for disulfide/cyclization—exactly as in the repo’s examples and paper. ([GitHub][1])

---

## 1) SUCNR1 ECL antagonist (cyclic peptide)

> **Goal.** A ~15–17mer disulfide‑cyclized peptide that binds **SUCNR1** extracellular loops (ECL2/ECL3) to antagonize succinate signaling (KCM **G12**). We keep the ECLs **flexible** so the model co‑adapts loop conformation on binding. 

```yaml
# sucnr1_ecl_antagonist.yaml
# Protocol: peptide-anything
# Notes:
# - Use label_asym_id residue indices (NOT auth ids). Verify indices in Mol* (mmCIF). Run `boltzgen check` to visualize binding mask. :contentReference[oaicite:2]{index=2}
# - For disulfide peptides with peptide/nanobody protocols, allow Cys in inverse folding (see CLI below). :contentReference[oaicite:3]{index=3}

entities:
  - file:
      path: data/targets/sucnr1_af.cif   # AFDB/AF3 mmCIF for human SUCNR1 (GPR91)
      include:
        - chain:
            id: A
            # Fill with the extracellular segments only (N-term/ECL1/ECL2/ECL3):
            res_index: <ECL1_RANGE>,<ECL2_RANGE>,<ECL3_RANGE>,<NTERM_ECD_RANGE>
      # Tell the model where to bind vs avoid:
      binding_types:
        - chain:
            id: A
            binding: <ECL2_SITE_RESIDUES>,<ECL3_SITE_RESIDUES>   # e.g., 170..176, 241..248
        - chain:
            id: A
            not_binding: <TM_HELICES_RANGES>                     # exclude TM core to favor ECL binding
      # Make loops flexible so they can reshape on binding:
      structure_groups:
        - group:
            id: ECLS
            res_index: <ECL1_RANGE>,<ECL2_RANGE>,<ECL3_RANGE>,<NTERM_ECD_RANGE>
            visibility: 0     # 0 = leave structure unspecified (flexible) :contentReference[oaicite:4]{index=4}

  # Designed cyclic peptide with two cysteines (disulfide)
  - protein:
      id: P
      # 4–6 design residues, then Cys, then 6 design residues, then Cys, then 3–4 design residues
      sequence: 4..6C6C3..4   # total length ~15–17; edit as needed

# Enforce the disulfide bond between the two Cys
constraints:
  - bond:
      atom1: [P, <CYS_1_POS>, SG]
      atom2: [P, <CYS_2_POS>, SG]

# Optional: bias a short helical face against the GPCR ECL crest
# secondary_structure:
#   - chain:
#       id: P
#       helix: <SPAN>   # e.g., 3..10
```

**Run (quick smoke test, then scale):**

```bash
boltzgen check sucnr1_ecl_antagonist.yaml

boltzgen run sucnr1_ecl_antagonist.yaml \
  --output work/sucnr1_ecl_pep \
  --protocol peptide-anything \
  --num_designs 50 --budget 10 \
  --inverse_fold_avoid ''        # allow Cys with peptide protocol :contentReference[oaicite:5]{index=5}
```

**Why this matters in KCM:** closes **G12 (Succinate/SUCNR1)** to reduce HIF‑1α‑tone and loop gain; aligns with L‑METABOLITE thresholds (≥0.5–1.0 mM succinate → pseudohypoxia).

---

## 2) Succinate‑binding mini‑protein (local sequestration)

> **Goal.** A compact binder for **succinate** (CCD **SUC**) as a physical “soak” in leave‑on serum. Start with a mini‑protein (80–140 aa) and let BoltzGen build a cationic pocket for a dicarboxylate. (BoltzGen small‑molecule binders land in the **µM** range in their paper—acceptable as a first pass for sequestration; raise copy number/formulation residence time.)

```yaml
# succinate_miniprotein.yaml
# Protocol: protein-small_molecule

entities:
  # The designed binder
  - protein:
      id: B
      sequence: 80..140

  # The ligand (succinate)
  - ligand:
      id: L
      ccd: SUC          # PDB chemical component code for succinate
      # (Alternative: provide an SDF/MOL2 file via `path:` if you prefer)  # see repo examples with ligand "ccd" keys :contentReference[oaicite:8]{index=8}

# Optionally bias a helical cradle near the pocket:
# secondary_structure:
#   - chain:
#       id: B
#       helix: <HELICAL_SEGMENTS>
```

**Run (includes affinity step automatically for protein–small molecule):**

```bash
boltzgen run succinate_miniprotein.yaml \
  --output work/succinate_binder \
  --protocol protein-small_molecule \
  --num_designs 1000 --budget 50
```

*Post‑filtering:* prioritize high buried area, ≥3–4 H‑bonds / salt bridges to carboxylates (PLIP counts), good refold RMSD, low hydrophobic patch—these come baked into the pipeline’s analysis/ranking. 

---

## 3) Heme‑binding mini‑protein (peptide alternative to Fe/hematin chelators)

> **Goal.** A **heme (CCD HEM)** binder mini‑protein to mop up free heme/iron at the scalp surface, addressing KCM metal‑protease gate **G24** without small‑molecule chelators. This reduces protease/fenton stress and deprives microbes of heme. 

```yaml
# heme_miniprotein.yaml
# Protocol: protein-small_molecule

entities:
  - protein:
      id: B
      sequence: 90..160     # give the model room for a porphyrin pocket

  - ligand:
      id: H
      ccd: HEM              # heme (protoporphyrin IX + Fe)

# Optional: enforce His/Tyr-lined pocket by redesigning segments, or bias helices:
# design:
#   - chain: { id: B, res_index: <PATCHES_TO_REDESIGN> }
# secondary_structure:
#   - chain: { id: B, helix: <SPAN1>, sheet: <SPAN2> }
```

**Run:**

```bash
boltzgen run heme_miniprotein.yaml \
  --output work/heme_binder \
  --protocol protein-small_molecule \
  --num_designs 1000 --budget 50
```

---

### (Optional) HIF‑1 axis competitor peptide (HIF‑1α C‑TAD ↔ p300/CBP CH1)

> **Goal.** Compete at the HIF‑1α C‑TAD binding site on **p300/CBP CH1** to blunt HIF‑1–driven pseudohypoxia tone downstream of G12. Supply the CH1 domain structure; bind near the C‑TAD hotspot; keep adjacent structured core fixed and allow peripheral loops to flex.

```yaml
# p300_ch1_hif1_competitor.yaml
# Protocol: peptide-anything

entities:
  - file:
      path: data/targets/p300_CH1.cif
      include:
        - chain: { id: A }              # CH1/TAZ1 domain chain
      binding_types:
        - chain: { id: A, binding: <HIF_C-TAD_SITE_RES> }
      structure_groups:
        - group: { id: CORE, res_index: <WELL_STRUCTURED_CORE>, visibility: 1 }
        - group: { id: PERIPH, res_index: <PERIPHERAL_LOOPS>, visibility: 0 }

  - protein:
      id: P
      sequence: 14..20                  # linear peptide; make cyclic if stability needed

# Optionally cyclize (disulfide) for stability:
# constraints:
#   - bond: { atom1: [P, <CYS_1>, SG], atom2: [P, <CYS_2>, SG] }
```

---

## How to use / tune these

1. **Pick indices with label_asym_id** (mmCIF indexing; not author IDs). Check in Mol*; run `boltzgen check` to confirm the colored binding masks. ([GitHub][1])
2. **Start small, then scale.** Do a 50–200‑design dry run to verify masks/geometry, then generate **10k–60k designs** and select a **budget** (e.g., 50–200) for triage. ([GitHub][1])
3. **Protocols:** use `peptide-anything` for short/cyclic peptides; `protein-small_molecule` when the target is a small molecule (succinate/heme)—that also enables the **affinity** predictor. ([GitHub][1])
4. **Cysteines with peptide protocol.** Allow Cys during inverse folding (`--inverse_fold_avoid ''`) when you want disulfides. ([GitHub][1])
5. **Filtering metrics to watch:** refold RMSD (complex & binder‑only), Boltz‑2 confidence, **PLIP H‑bonds/salt bridges**, **buried SASA**, composition outliers (ALA/GLY/GLU/LEU/VAL), hydrophobic patch area. Re‑run filtering with `--steps filtering` and adjust thresholds / weights. 
6. **Small‑molecule binders are harder.** Expect µM Kd at first (paper’s rucaparib/rhodamine designs); compensate with higher local concentration and residence time in the leave‑on matrix, then iterate.

---

## KCM fit (why these three)

* **SUCNR1 ECL peptide**: directly targets **G12 (Succinate/SUCNR1)** to reduce pseudohypoxia and IL‑17‑tilt; matches L‑METABOLITE thresholds (≥0.5–1.0 mM).
* **Succinate binder**: **local sequestration** aligns with your TheraBiome patent concept (metabolite binding at the surface) and lets us **pair** with antimicrobial rinse‑off (selenium, etc.).
* **Heme binder**: addresses the **G24 iron/heme gate** (protease/ROS fuel and microbial heme harvest) without classic chelators—useful for a cosmetic leave‑on. 

---

## One‑liners you can paste to run

```bash
# SUCNR1 ECL cyclic peptide
boltzgen run sucnr1_ecl_antagonist.yaml \
  --output work/sucnr1_ecl_pep --protocol peptide-anything \
  --num_designs 20000 --budget 100 --inverse_fold_avoid ''

# Succinate mini-protein binder
boltzgen run succinate_miniprotein.yaml \
  --output work/succinate_binder --protocol protein-small_molecule \
  --num_designs 20000 --budget 100

# Heme mini-protein binder
boltzgen run heme_miniprotein.yaml \
  --output work/heme_binder --protocol protein-small_molecule \
  --num_designs 20000 --budget 100
```

---

### Notes / references

* **Spec primitives** (`entities`, `binding_types`, `structure_groups`, `secondary_structure`, `constraints`, `ligand: ccd:`) and CLI flags are taken from the BoltzGen README and examples; the paper’s **Design Specification Language** (Fig. 9) shows disulfide cyclization and helicon staples as patterns. ([GitHub][1]) 
* **Pipeline** (design → inverse‑folding → refolding/affinity → analysis → quality‑diversity filtering) and **metrics** guidance taken from the paper.

If you share (a) the **mmCIF** you want to use for SUCNR1 (AFDB/AF3) and (b) the exact **ECL residue ranges**, I’ll fill the placeholders (`<…>`) and hand back fully‑formed YAMLs tuned for your masks and secondary‑structure biases.

[1]: https://github.com/HannesStark/boltzgen "GitHub - HannesStark/boltzgen"
