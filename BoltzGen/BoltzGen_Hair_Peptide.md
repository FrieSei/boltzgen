## 1) How to use **BoltzGen** for a heme‑trapping scalp peptide

**Why BoltzGen for this job**

* It supports **short linear & disulfide‑cyclized peptides**, **binding‑site conditioning**, and even **“not‑binding” masks**; you can enforce cyclization and secondary structure and place the binder around a small ligand or a defined protein patch. Figure‑9 shows exactly how cyclic/stapled peptides are specified.  
* It has **wet‑lab signal on novel peptide targets** (e.g., RagA/RagC cyclic peptides; live‑cell IDR binders) and a demonstrated ability to **disrupt bacterial PPIs** (GyrA:C‑gate), complete with the “Ala‑triad” specificity control we can copy.  
* For **small‑molecule binding**, it gets **µM Kd** (e.g., rucaparib), which is modest but **acceptable for topical sequestration at high local concentration and/or when multimerized** in a gel. 

**Design objective**
A **cationic, disulfide‑cyclized peptide (10–18 aa)** that creates a shallow, hydrophobic pocket with one **axial His/Tyr** positioned to coordinate Fe(III) in **heme‑b** and to shield the porphyrin (minimizing peroxidase‑like activity), then **localize it in the serum’s polymer matrix** so the complex stays on‑surface (no delivery to microbes).

**Two parallel BoltzGen tasks**

* **Task A (ligand‑centric):** Design a **cyclic peptide directly around heme‑b** (PDB/SDF of heme). Use the design‑spec to (i) include the ligand atoms, (ii) enforce a **Cys–Cys disulfide** (stabilizes pocket, lowers entropy) and (iii) bias helices/β‑hairpin as needed. We’ll select designs with predicted His/Tyr axial contacts and buried Soret environment. (BoltzGen’s spec supports covalent bonds, secondary‑structure and binding‑site labels.) 
* **Task B (protein‑centric, “carrier” safety):** Design a peptide that **binds hemoglobin at the haptoglobin‑facing pocket** (or heme‑loaded albumin) to *sequester* Hb‑heme without pulling iron off; this leverages BoltzGen’s stronger protein‑interface performance (like their GyrA PPI case). We can use a patch‑masked interface and the **Ala‑triad specificity test** in functional assays. 

> **Note:** We avoid elemental Fe(III) chelation motifs and bacterial siderophore chemistry on purpose—KCM’s **G24** emphasizes microbial **heme harvest** as a driver; binding heme/Hb mimics hemopexin/haptoglobin biology and reduces the risk that the agent becomes a **microbial iron shuttle**. 

**A practical BoltzGen spec skeleton (illustrative)**

```yaml
# Task A — cyclic "HemoTrap-β" around heme-b
task: binder_design
target:
  ligand_file: heme_b.sdf          # heme coordinates included
design:
  type: peptide
  length_range: [12, 18]
constraints:
  covalent_bonds:
    - {type: disulfide, i: 7, j: 14}         # cyclization for rigidity
  secondary_structure:
    - {start: 1, end: 6, kind: helix}
    - {start: 9, end: 16, kind: helix}       # helix-turn-helix pocket
  binding_site:
    ligand_atoms: all                        # place pocket around heme
# Post-generation filters (external, not in BoltzGen spec):
# - enforce ≥1 His/Tyr within 3.0 Å of Fe in predicted model
# - buried ligand surface area, H-bond count, pocket SASA
# - liability screens (aggregation, protease sites), sequence diversity
```

(Exactly this kind of **covalent cyclization / binding‑site control** is shown in their Figure‑9 examples and text. We then refold / rank with the standard BoltzGen pipeline.) 

**Triage & selection**

* Use their **composite ranking** (interaction score + Boltz score) and **refold RMSD** filters; for small ligands, also track **ligand H‑bonds/contacts** (their rucaparib workflow did this). 
* Keep designs with: (i) **buried Soret ring**, (ii) **axial His/Tyr** to Fe(III), (iii) **low exposed hydrophobics**, (iv) **positive net charge** (topical retention), (v) **no protease hot motifs**. (Residue identity constraints are post‑filters.)
* Diversity filter for 10–20 non‑redundant picks; plus **Ala‑triad mutants** for each leading design to validate on‑target function (as in their GyrA study). 

---

## 2) What I propose building first

### Candidate 1 — **HemoTrap‑β** (disulfide‑cyclized, 12–16 aa)

* **Role:** Topical **heme sponge** that quenches pro‑oxidant heme at the scalp surface (KCM **G24/SC‑15** de‑amplifier).  
* **Why cyclic?** BoltzGen shows good hit‑rates with **disulfide‑bonded cyclic peptides** and short binders to defined patches; cyclization **stiffens** the pocket and improves per‑residue affinity (they did this on RagA:RagC). 
* **Safety concept:** Peptide is **net cationic** (retained in your guanidinylated‑chitosan matrix), **non‑cell‑penetrant**, and **polymer‑tethered** to prevent microbial reuse of heme.

### Candidate 2 — **Hb‑Latch** (protein‑interface binder)

* **Role:** Binds **heme‑loaded Hb** at an external patch to **immobilize Hb‑heme** in the matrix (haptoglobin‑like outcome).
* **Why:** Leverages BoltzGen’s stronger PPI performance (cf. their GyrA interface hits and live‑cell IDR binders). 

*(We can run A and B in silico/in vitro in parallel; whichever clears the safety and PD bar goes into a formulation test.)*

---

## 3) Assay battery and go/no‑go gates (bench → formulation)

**Biophysics / binding**

* **Heme binding:** UV‑vis Soret shift & difference spectra; titration‑fit Kd (µM is OK for topical sinks, given high local dose and polymer avidity; BoltzGen’s small‑molecule binders typically land in this range). 
* **Axial ligation:** Fe(III) vs Fe(II) sensitivity (reduced oxy/deoxy controls).
* **Specificity:** Minimal binding to Zn(II)/Ca(II); weak to citrate/EDDS to ensure we’re not just an indiscriminate chelator.

**Function & safety**

* **Peroxidase risk:** ABTS or luminol readout for heme‑peroxidase‑like activity **±peptide** (want *lower* activity vs free heme).
* **Microbial “enhancement” screen:** Growth of **Malassezia spp./skin commensals** ± heme ± peptide; confirm the complex **reduces** growth relative to heme alone (avoid siderophore‑like behavior).
* **Ala‑triad mutant control** per lead (loss of function when contact residues → Ala implies on‑target). (This control mirrors the GyrA validation approach.) 
* **Hemolysis & irritation:** RBC hemolysis (want none), keratinocyte viability, and 48‑hour patch‑test on volunteer skin equivalents.

**Formulation fit (with your serum)**

* Compatibility with **FOLLIC‑SAVE™** leave‑in matrix (pH 5.4–5.8; guanidinylated chitosan 2.0%). Your IRB packet already positions this base and the optional chelator arm; the peptide can slot into the same chassis.   

---

## 4) Where it plugs into **Regensburg** and your provisionals

* Your IRB/clinical plan currently has **two cohorts**: Base serum vs vehicle; and Base+chelators vs vehicle (phytate/EDDS). Keep that design intact for the first readout.  
* In parallel, spin the BoltzGen→bench funnel above. If the **HemoTrap‑β** clears the panel, add it as **“Serum‑HemeTrap”** to a **post‑readout extension cohort** comparing **Base+HemoTrap** vs **Base+Chelator** (same shampoo background). That answers the practical question the IRB already encodes: “Is a non‑absorbing chelator additive?” but does so with a **biologic sequestrant** that better maps to KCM’s recommended **heme scavenging / hemopexin‑like** strategy.  
* Claim support: your **TheraBiome** provisionals already frame **“biological sequestrants”** (proteins/peptides/aptamers) alongside polymeric resins. The peptide path fits squarely under those claims for **scalp** formulations and **dual‑mechanism regimens** with metabolite sequestration. (E.g., “engineered peptides that bind heme/hemoglobin or siderophores in a leave‑on scalp vehicle.”)

---

## 5) Why this is KCM‑aligned

* It **de‑amplifies G24** (heme/iron redox gate) and **SC‑15 Iron/Heme Overload**, which your cards flag as drivers of **ROS/NETs** and **protease activation**—key parts of the **L3 Metal‑NET‑Microclot** loop.   
* It pairs cleanly with your **succinate sequestration** strategy (L‑METABOLITE loop, SUCNR1 threshold ~0.5–1 mM), addressing both **metabolite pressure** and **metal‑redox** in the same regimen—exactly the dual‑mechanism idea in your patents and trial.  

---

## 6) Optional second peptide track (later): siderophore interception

If you eventually want to **replace chelators entirely**, a second avenue is a **lipocalin‑mimetic mini‑protein/peptide** that binds **catecholate siderophores** (enterobactin‑like) or **blocks fungal heme transporters** at their **protein interface**. That’s a protein‑interface problem (BoltzGen is strong there), and uses the same binding‑site conditioning + Ala‑triad validation pattern from their GyrA work. 

---

### Bottom line

* **Yes**, BoltzGen is the right generator/ranker to create a **topical, cyclic HemoTrap peptide** that can take the place of classic chelators—*and* do it in a way that’s safer for the microbiome and closer to the KCM “heme scavenging” mandate.
* Keep the **Regensburg** study as is; run this **design→bench→compatibility** pipeline now so you can drop a **Base+HemoTrap** arm into an extension or a follow‑on cohort with minimal protocol friction. Your existing IRB text and regimen make that straightforward. 

Short answer: **Yes—two peptide avenues are strategically aligned for the serum**: (A) *block succinate signaling locally* (SUCNR1 antagonists or succinate‑binding macrocycles), and (B) *only secondarily modulate HIF‑1*, and only if scalp readouts show a pathologic HIF‑high state. The mouse paper you shared supports pairing any anti‑succinate strategy with **mitochondrial/FAO support** to trigger anagen (e.g., oleic‑acid module), so I’d prioritize **SUCNR1→HIF relief + FAO boost** over direct HIF inhibition.  

---

## Why this fits KCM (and what the mouse study adds)

* In KCM, **succinate (G12) → SUCNR1 → HIF‑1 pseudohypoxia** sits at the center of the scalp “lock‑in” biology (SC‑10 Succinate‑Driven Th17; SC‑06 Hypoxic/Pseudohypoxia). Thresholds we track (systemic succinate ≳0.5–1 mM; D/L‑2‑HG drift) are exactly the zone where we expect HIF signaling, IL‑17 tone, and barrier injury to climb.    
* Your *Scalp Serum* concept already rationalizes succinate as an inflammatory driver (Tannahill et al.; He et al. GPR91/SUCNR1), consistent with our G12/SC‑10 cards. 
* **Mouse study take‑home:** controlled irritation activates **dermal adipocyte lipolysis → monounsaturated FA release (C18:1/C16:1)** → **eHFSC mitochondrial biogenesis & FAO via PGC‑1α**, with topical **oleic acid** itself triggering hair regrowth. See *Figure panels and text around “monounsaturated FAs promote eHFSC activation by enhancing mitochondrial biogenesis through Pgc1‑α”*; topical C18:1 promotes anagen; FAO (not glycolysis) supplies ATP in this context. This strongly argues we should **support FAO locally** while we **reduce succinate pressure**.   

---

## Peptide targets to investigate (prioritized)

### A. **SUCNR1 blockade on keratinocytes/follicle niche (highest priority)**

**Goal:** Prevent succinate from activating SUCNR1 and secondarily dial down HIF‑1.
**Two peptide styles:**

1. **Extracellular‑loop antagonist (macrocyclic peptide)**

   * *What:* A 12–20mer macrocycle designed to bind SUCNR1 ECL2/ECL3 pocket and sterically/competitively block succinate.
   * *How to design:* With **BoltzGen**, condition on a SUCNR1 ECD/ECL target model (AlphaFold/templatized GPCR ECLs) and specify *“bind site mask”* over the succinate pocket; enforce **cyclization** (lactam/disulfide) and **helix/hairpin** secondary structure; add “not‑binding” masks on off‑regions to nudge selectivity. (This mirrors their binder‑to‑PPI and cyclic‑peptide flows.)
   * *Why this first:* Cleanest way to cut G12→G17 without sequestering beneficial dicarboxylates in bulk. KCM expects this to relieve SC‑10/SC‑06 pressure.  
2. **Pepducin‑style negative allosteric modulator (advanced)**

   * *What:* A lipidated peptide derived from SUCNR1 **intracellular loop** sequence that biases the receptor to an inactive state.
   * *Risk:* Needs membrane translocation and can be pleiotropic; consider only after ECL antagonists.

**Bench plan (fast):** SPR/biolayer interferometry on SUCNR1‑ECD; cell assays (β‑arrestin/cAMP) ± 0.5–1 mM succinate; scalp explant organ culture with succinate spike to show reversal of HIF targets (e.g., GLUT1, CA9) and IL‑17A tone. Map to **SC‑10/SC‑06** outputs.  

---

### B. **Succinate‑binding macrocyclic peptide (local sequestration)**

**Goal:** Physically mop up succinate in the follicular microenvironment (a peptide analogue of your sequestrant concept).

* *Design idea:* **Guanidinium‑rich, cationic macrocycles** (Arg/Lys clusters) with internal H‑bond donors arranged for **dicarboxylate** capture; optional **D‑residue** enrichment and **N‑methylation** for protease resistance; cyclization to control geometry.
* *Caveats:* Likely **cross‑reacts with malate/fumarate**; selectivity may be modest. That’s acceptable **topically** if the dosing window is short and local (your broader TheraBiome IP anticipates this trade‑off). Pair with vehicle that retains peptide at the scalp surface/follicle.
* *Why now:* Quick parallel to the receptor binder, and synergizes with the mouse paper’s FAO module—reduce pseudohypoxic pressure while enabling mitochondrial activation. 

---

### C. **HIF‑1 pathway peptides (use only after A/B show SUCNR1/HIF relief signals)**

**Options & caution:**

* **HIF‑1α C‑TAD→p300/CBP interface blocker (stapled helix/mini‑protein):** would suppress HIF transcriptional program. Risk: **HIF‑1 also supports angiogenesis/wound signals**; over‑suppression could blunt anagen. Use only if scalp readouts show persistent **SC‑06** despite succinate control. 
* **VHL‑recruiting degron peptides** (to accelerate HIF‑1α turnover): high translational friction (delivery to nucleus/cytosol); not a near‑term topical candidate.

**Recommendation:** *Do not* lead with HIF‑1 inhibition. In AGA/seborrheic contexts, KCM predicts **succinate gating** to be the cleaner upstream lever; the mouse study suggests **fueling mitochondria** is pro‑anagen, whereas blanket HIF‑1 suppression risks the opposite.  

---

## How I’d combine this into your **hair‑regrowth serum** prototype

**Core stack (leave‑on, pH ~5.4–5.8, follicle‑seeking vehicle):**

1. **SUCNR1‑antagonist peptide** (0.05–0.2% w/w target) — macrocyclic, D‑residue‑stabilized.
2. **FAO‑enabling lipid module** — low‑% **oleic acid (C18:1)** in a biphasic or microemulsion system (the study used ethanol for mice; cosmetically we’ll prefer ethanol‑lean systems with penetration co‑solvents; test 0.3–1.0% OA). The paper’s data show **topical C18:1 promotes anagen** and **boosts OXPHOS/PGC‑1α in eHFSCs**. *Figure panels/text around “only monounsaturated FAs (C18:1, C16:1) promoted hair regeneration” and “ATP via mitochondrial respiration, not glycolysis”.*  
3. **Optional succinate‑binding macrocycle** (0.05–0.2% w/w) — run in a separate arm or as a night‑only add‑on if we see scalp succinate elevations.
4. **Vehicle architecture:** chitosan‑based or poloxamer‑thermogel for residence & follicular deposition (consistent with your TheraBiome docs), tuned viscosity/yield stress to prevent drip and favor follicular pooling. 

---

## What to measure (de‑risk quickly, align to KCM)

**In vitro/ex vivo (human scalp explants & keratinocytes):**

* **Mechanism:** SUCNR1 signaling (β‑arrestin/cAMP) ± 1 mM succinate with/without peptide; **HIF‑1 target panel**; **PGC‑1α/FAO markers** (CPT1A, mtDNA:nDNA ratio, OCR) when OA module is present. (The mouse paper used these exact mitochondrial readouts in eHFSCs.) 
* **Inflammation/Th17:** IL‑17A/F, MMP‑8/9 (SC‑10/SC‑20 links). 
* **Safety/cosmetic:** TEER/irritation on reconstructed human epidermis; sebum compatibility.

**Pilot clinical (split‑scalp, non‑minoxidil responders):**

* **Primary:** hair count/weight; phototrichogram.
* **Mechanistic PD substudy:** **scalp microdialysate succinate** (evening vs morning), **tape‑strip HIF signature**, imaging of erythema/squame for SD overlap; timing aligned to KCM CVI windows.  

---

## Practical design notes for BoltzGen use (high level)

* **Target model:** Build/curate SUCNR1 ECD/ECL pocket model (AlphaFold clustering + GPCR templates); mark ligandable residues (ECL2 aromatic/acidic residues often shape dicarboxylate GPCR pockets).
* **Spec language levers:**

  * `bind_site:` residue list over ECL2/ECL3;
  * `constraints:` enforce **cyclization** (disulfide/lactam), **helix turn** or **β‑hairpin**, and **no‑bind** zones for off‑surface regions;
  * `developability:` penalize large hydrophobics, exposed hydrophobic patches, protease motifs;
  * `diversity:` request multiple scaffolds (12–14mer; 16–18mer).
* **Ranking:** keep quality‑diversity; triage by buried SASA, H‑bond/salt‑bridge counts, and refolding scores; then go straight to SUCNR1 cell assays.

(Their open‑source pipeline has exactly these controls for cyclic peptides and PPI interfaces; wet‑lab hit rates on novel targets and antimicrobial PPIs suggest this is practical for a first pass.)

---

## Bottom line & proposed next steps

1. **Go** on a **SUCNR1‑antagonist macrocyclic peptide** (primary) and a **succinate‑binding macrocycle** (secondary).
2. **Integrate an FAO module** (low‑% C18:1) in the serum to *activate* follicles in parallel (consistent with the mouse paper’s topical data and mechanism). 
3. **Defer HIF‑1‑blocking peptides** to a contingency arm, gated by scalp PD readouts showing persistent SC‑06 despite succinate control. 
4. **Run a bench‑to‑explant screen** exactly as above; if we see SUCNR1/HIF relief + FAO signatures with clean irritation profile, move to a small split‑scalp pilot.

