# A PROJECT REPORT
## ON
# SAREE BORDER PATTERN EXTRACTION AND DESIGN SIMILARITY COMPARISON USING MATLAB

---

**Submitted in partial fulfillment of the requirements for the award of the degree of**  
### BACHELOR OF TECHNOLOGY / BACHELOR OF ENGINEERING  
**IN**  
### COMPUTER SCIENCE AND ENGINEERING / ELECTRONICS & COMMUNICATION ENGINEERING

---

**Submitted by:**  
* **Student Name:** [Your Full Name]  
* **University Roll No / Register No:** [Your Roll Number]  

**Under the Guidance of:**  
* **Faculty Guide:** [Guide Name & Designation]  
* **Department:** Department of Computer Science & Engineering  
* **Institution:** [College / University Name, City]  

**Academic Year:** 2026 – 2027  

---

## CERTIFICATE

This is to certify that the project report entitled **"SAREE BORDER PATTERN EXTRACTION AND DESIGN SIMILARITY COMPARISON USING MATLAB"** submitted by **[Your Full Name]** (Roll No: **[Your Roll Number]**) in partial fulfillment of the requirements for the award of the Degree of **Bachelor of Technology** in Computer Science and Engineering is a bonafide record of the work carried out by them under my supervision and guidance.

The results embodied in this report have not been submitted to any other University or Institute for the award of any degree or diploma.

<br><br>

----------------------------------- &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; -----------------------------------  
**Internal Guide / Supervisor** &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; **Head of the Department**  
[Guide Name & Title] &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; [HOD Name & Title]  
Department of CSE/ECE &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; Department of CSE/ECE  

<br>

----------------------------------- &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; -----------------------------------  
**Internal Examiner** &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; **External Examiner**  
Date: _______________ &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; Date: _______________  

---

## DECLARATION

I hereby declare that this project report entitled **"SAREE BORDER PATTERN EXTRACTION AND DESIGN SIMILARITY COMPARISON USING MATLAB"** is the result of my own independent work, under the guidance of **[Guide Name]**, Department of Computer Science and Engineering.

I further declare that this work has not been previously submitted in part or in full to any other university or examining body for the award of any degree, diploma, or associateship. All external sources, research datasets, and literature cited have been properly attributed.

<br>

**Place:** [City Name]  
**Date:** [Date]  
**Candidate Signature:** ___________________________  
([Your Full Name])  

---

## ACKNOWLEDGMENTS

I express my deepest sense of gratitude to my project guide, **[Guide Name]**, for their invaluable guidance, encouragement, constructive criticism, and constant support throughout the duration of this project.

I extend my heartfelt thanks to **[HOD Name]**, Head of the Department of Computer Science & Engineering, for providing the necessary laboratory facilities, technical infrastructure, and academic atmosphere to complete this work.

I also acknowledge the contributors of the **Neural-Loom Dataset** at Assam Engineering College (ICIP 2020) and the open textile preservation collections on Wikimedia Commons, whose openly licensed textile image resources facilitated the empirical evaluation of this research.

Finally, I express my sincere gratitude to my family and peers for their continuous moral support and assistance.

---

## ABSTRACT

Traditional Indian sarees are distinguished by their ornate decorative borders (*zari*, brocade, and regional motifs) that embody regional craftsmanship and cultural identity. However, inspecting and comparing border designs for cataloging, authentication, and quality auditing is conventionally performed through subjective and fatigue-prone manual visual inspection.

This project presents an automated, objective digital image processing system implemented entirely in MATLAB to extract decorative saree borders and evaluate design similarity between two textile specimens. The system ingests saree images, applies adaptive preprocessing (multiscale resizing, Gaussian/median denoising, and Rayleigh-distributed adaptive histogram equalization), and automatically localizes border regions using perimeter gradient energy analysis combined with 1D edge projection profiling. 

To quantitatively characterize each border pattern, a 49-dimensional multi-domain feature vector is constructed, integrating:
1. **Color Distribution (32-D)**: Normalized HSV color histogram.
2. **Textile Weave Texture (4-D)**: Haralick Gray-Level Co-occurrence Matrix (GLCM) features (Contrast, Correlation, Energy, Homogeneity).
3. **Edge Density & Directionality (9-D)**: Canny edge density and an 8-bin gradient orientation histogram.
4. **Structural Complexity (4-D)**: Shannon entropy, intensity variance, and motif solidity.

Design similarity is computed using a weighted mathematical formulation yielding a reproducible score strictly bounded between 0.00% and 100.00%. The application features an interactive desktop Graphical User Interface (GUI) built with MATLAB `uifigure` and `uiaxes` alongside an automated PowerShell dataset acquisition pipeline. Experimental evaluation on real sarees from the Neural-Loom research dataset demonstrated the system's effectiveness: an empirical case study comparing a printed geometric saree with a handloom paisley saree produced an overall similarity score of **62.5%** (Color: 54.8%, Weave Texture: 86.6%, Motif Shape: 15.8%, Structural Complexity: 94.6%), confirming that the system accurately differentiates pattern motifs while recognizing shared textile weave characteristics.

**Keywords:** *Digital Image Processing, MATLAB, Saree Border Extraction, Haralick Texture, GLCM, Edge Projection Profiling, HSV Color Histogram, Design Similarity Comparison, Handloom Textiles.*

---

## TABLE OF CONTENTS

1. **Chapter 1: Introduction**
   * 1.1 Background and Motivation
   * 1.2 Problem Statement
   * 1.3 Project Objectives
   * 1.4 Scope and Organization of the Report
2. **Chapter 2: Literature Review and System Comparison**
   * 2.1 Overview of Textile Image Processing
   * 2.2 Existing Manual Systems vs. Proposed Automated System
   * 2.3 Review of Haralick Texture and Color Descriptors
3. **Chapter 3: Dataset Ingestion and Ethical Acquisition**
   * 3.1 Neural-Loom Research Dataset (ICIP 2020)
   * 3.2 Wikimedia Commons Cultural Textile Archives
   * 3.3 Automated Data Ingestion Pipeline
   * 3.4 Folder Hierarchy and Classification Principles
4. **Chapter 4: System Architecture and Mathematical Methodology**
   * 4.1 Overall Architectural Pipeline
   * 4.2 Image Preprocessing and Enhancement
   * 4.3 Automated Border Localization and Cropping
   * 4.4 49-Dimensional Multi-Descriptor Feature Extraction
   * 4.5 Weighted Design Similarity Scoring Model
5. **Chapter 5: MATLAB and GUI Implementation**
   * 5.1 Modular Software Structure
   * 5.2 Desktop GUI (`sareeBorderGUI.m`) Architecture
   * 5.3 Automated Verification and Unit Test Suite (`testProject.m`)
6. **Chapter 6: Experimental Results and Empirical Case Study**
   * 6.1 Experimental Setup
   * 6.2 Empirical Case Study: Printed Saree vs. Handloom Saree (62.5% Score)
   * 6.3 Metric-by-Metric Breakdown and Qualitative Analysis
   * 6.4 Verification Test Results (TS-01 to TS-10)
7. **Chapter 7: Limitations and Future Enhancements**
   * 7.1 Current System Limitations
   * 7.2 Proposed Future Enhancements
8. **Chapter 8: Conclusion**
9. **References**

---

# CHAPTER 1: INTRODUCTION

### 1.1 Background and Motivation
India's handloom and textile heritage represents one of the richest artistic traditions in the world. Sarees such as Banarasi brocades, Kanchipuram silks, Paithani sarees, Sambalpuri ikats, and Dhakai Jamdanis are defined primarily by their ornate borders (*zari*, brocades, temple serrations, and paisleys). In commercial textile cataloging, supply chain auditing, and intellectual property monitoring, verifying the similarity of border motifs is essential.

Historically, this inspection has been conducted manually by human evaluators. Manual evaluation suffers from severe limitations:
* **Subjectivity**: Different inspectors form differing visual impressions based on personal perception.
* **Eye Fatigue**: Inspecting dense textile weaves under variable showroom lighting leads to rapid inspector exhaustion.
* **Lack of Quantitative Audit Trails**: Traditional evaluations produce no numerical proof or reproducibility.

Applying digital image processing offers an objective, automated, and mathematically verifiable alternative.

### 1.2 Problem Statement
To design and implement an end-to-end digital image processing system in MATLAB that automatically detects and extracts the decorative border region of saree images, extracts numerical descriptors across color, weave texture, edge geometry, and structural entropy, and computes a reproducible design similarity percentage comparing two saree designs.

### 1.3 Project Objectives
1. **Automated Dataset Acquisition**: Retrieve authentic research saree images from verified public academic repositories with documented licensing.
2. **Robust Preprocessing**: Standardize images using Gaussian/median filtering and adaptive contrast equalization (`adapthisteq`) to enhance metallic threads.
3. **Border Region Localization**: Automatically identify candidate border zones using perimeter gradient energy and 1D edge projection profiles, supported by interactive manual cropping.
4. **Multi-Domain Feature Engine**: Construct a 49-dimensional vector capturing HSV color distribution, Haralick GLCM weave texture, Canny edge density/directionality, and Shannon entropy.
5. **Weighted Similarity Engine**: Formulate an explainable mathematical similarity formula yielding a bounded score in $[0.00\%, 100.00\%]$.
6. **User Interface & Reporting**: Implement a dual-panel MATLAB GUI and automated report export tools.

---

# CHAPTER 2: LITERATURE REVIEW & SYSTEM COMPARISON

### 2.1 Overview of Textile Image Processing
Computer vision applications in textiles have evolved from basic defect detection (holes, broken yarns) to high-level content-based image retrieval (CBIR) and pattern synthesis. In handloom textiles, repeating weave structures present challenges due to non-uniform fabric drape, camera angles, and metallic thread specular reflections.

### 2.2 Comparison: Existing System vs. Proposed System

| Dimension | Existing Manual Inspection | Proposed MATLAB System |
| :--- | :--- | :--- |
| **Inspection Methodology** | Visual observation by human eye | Automated multi-domain digital image processing |
| **Objectivity** | Subjective, qualitative, variable | Deterministic, reproducible mathematical score (0%–100%) |
| **Border Cropping** | Manual photo editing or scissors | Automated edge projection localization + manual ROI fallback |
| **Feature Extraction** | Unstructured impression | 49-D vector (HSV Histogram, Haralick GLCM, Canny, Entropy) |
| **Processing Speed** | Several minutes per pair; high fatigue | Sub-second computation and real-time GUI update |
| **Documentation** | Informal notes | Automatically generated timestamped `.txt` and `.png` audit reports |

---

# CHAPTER 3: DATASET INGESTION & ETHICAL ACQUISITION

### 3.1 Primary Research Dataset: Neural-Loom (ICIP 2020)
* **Citation**: R. K. Bhattacharjee, M. Nandi, and A. Jha, *"Handloom Design Generation Using Generative Networks"*, IEEE International Conference on Image Processing (ICIP), 2020.
* **Origin**: Department of CSE, Assam Engineering College, Guwahati, India.
* **Licensing**: Open academic and educational research use.
* **Characteristics**: Real mobile-camera captures under natural lighting capturing normal printed and traditional handloom sarees.

### 3.2 Secondary Cultural Source: Wikimedia Commons
* **Sources**: Archival categories for Banarasi Silk, Kanchipuram Silk, and Paithani handlooms.
* **Licensing**: Creative Commons Attribution-ShareAlike (CC BY-SA 4.0 / CC BY 3.0). Full source URLs and attributions are maintained in `dataset/dataset_manifest.csv`.

### 3.3 Folder Hierarchy
The acquired images are structured systematically:
* `dataset/silk/` — Banarasi, Kanchipuram, and Tussar silk sarees.
* `dataset/cotton/` — Sambalpuri, Chanderi, and Tant cotton sarees.
* `dataset/handloom/` — Authentic handloom sarees (21 genuine images).
* `dataset/printed/` — Screen-printed and block-printed sarees (21 genuine images).
* `dataset/designer/` — Zardozi and Gota Patti embroidered sarees.
* `dataset/processed/` — 45 normalized, validated images ready for analysis.
* `dataset/raw/` — Ingestion staging folder.

---

# CHAPTER 4: SYSTEM ARCHITECTURE & METHODOLOGY

### 4.1 System Architecture Pipeline

```text
[ Input Saree Images ]
          │
          ▼
┌────────────────────────────────────────────────────────┐
│  1. Preprocessing Layer (preprocessSareeImage.m)       │
│     - Dimension Normalization (MaxDim <= 800 px)       │
│     - Grayscale & RGB Normalization                    │
│     - Gaussian Spatial Denoising (sigma = 1.0, 5x5)    │
│     - Rayleigh Adaptive Histogram Equalization         │
│     - Sobel Gradient Magnitude & Angle Mapping         │
└────────────────────────────────────────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────┐
│  2. Border Localization Layer (extractSareeBorder.m)   │
│     - Perimeter Margin Energy Evaluation (4 Margins)   │
│     - 1D Horizontal / Vertical Edge Projection Profile │
│     - Boundary Bounding Box Construction               │
│     - Interactive Manual ROI Fallback                  │
└────────────────────────────────────────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────┐
│  3. Feature Extraction Layer (extractPatternFeatures.m)│
│     - HSV Color Distribution (32 Bins)                 │
│     - Haralick GLCM Texture Descriptors (4 Descriptors)│
│     - Canny Edge Density & 8-Bin Orientation (9-D)     │
│     - Shannon Entropy Moments & Motif Solidity (4-D)   │
│     - L2 Feature Vector Normalization (49-D)           │
└────────────────────────────────────────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────┐
│  4. Similarity & Reporting Layer (compareSareeBorders) │
│     - Weighted Multi-Metric Integration                │
│     - Strictly Bounded 0.00% to 100.00% Score          │
│     - Qualitative Rating & Audit Report Export         │
└────────────────────────────────────────────────────────┘
```

### 4.2 Image Preprocessing
1. **Scale Normalization**: Images are scaled proportionally such that $\max(\text{Height}, \text{Width}) \le 800$, balancing edge detail with fast computation.
2. **Denoising**: 2D Gaussian filtering suppresses yarn micro-noise while preserving pattern boundaries:
   $$G(x, y) = \frac{1}{2\pi\sigma^2} \exp\left(-\frac{x^2 + y^2}{2\sigma^2}\right)$$
3. **Contrast Normalization**: Contrast-limited adaptive histogram equalization (`adapthisteq`) enhances metallic *zari* threads across contextual tiles.
4. **Sobel Gradients**:
   $$G_x = I * h_x, \quad G_y = I * h_y, \quad G_{\text{mag}} = \sqrt{G_x^2 + G_y^2}, \quad \theta = \text{atan2d}(G_y, G_x)$$

### 4.3 Border Localization Algorithm
1. A binary edge map $E(y, x)$ is produced using Canny edge detection.
2. The four perimeter candidate margins (Bottom, Top, Left, Right) are evaluated for pattern energy:
   $$E_{\text{margin}} = 0.65 \cdot \left(\frac{1}{A} \sum E(y, x)\right) + 0.35 \cdot \left(\frac{1}{255 A} \sum G_{\text{mag}}(y, x)\right)$$
3. 1D edge projection profiling determines the exact boundary transition:
   $$P_{\text{row}}(y) = \frac{1}{W} \sum_{x=1}^{W} E(y, x)$$
   The boundary row is localized where $P_{\text{row}}(y)$ drops below 50% of peak border edge density.

### 4.4 49-Dimensional Multi-Descriptor Feature Formulation
* **Color Palette (32-D)**: HSV space quantized into 16 Hue, 8 Saturation, and 8 Value bins; normalized such that $\sum h_c = 1.0$.
* **Weave Texture via Haralick GLCM (4-D)**: Gray-Level Co-occurrence Matrices computed across $0^\circ, 45^\circ, 90^\circ, 135^\circ$ offsets:
  * $\text{Contrast} = \sum_{i,j} |i - j|^2 p(i, j)$
  * $\text{Correlation} = \sum_{i,j} \frac{(i - \mu_i)(j - \mu_j) p(i, j)}{\sigma_i \sigma_j}$
  * $\text{Energy} = \sum_{i,j} p(i, j)^2$
  * $\text{Homogeneity} = \sum_{i,j} \frac{p(i, j)}{1 + |i - j|}$
* **Edge Density & Directionality (9-D)**: Canny edge density scalar $D_e$ combined with an 8-bin orientation histogram capturing motif angles.
* **Structural Entropy & Solidity (4-D)**: Shannon entropy $H = -\sum p_k \log_2(p_k)$, intensity mean, variance, and motif solidity.

### 4.5 Weighted Similarity Scoring Model
$$\text{Similarity}_{\text{total}} = \left(w_c S_{\text{color}} + w_t S_{\text{texture}} + w_e S_{\text{edge}} + w_s S_{\text{struct}}\right) \times 100\%$$
* Weights: $w_c = 0.35$ (Color), $w_t = 0.30$ (Texture), $w_e = 0.20$ (Edge), $w_s = 0.15$ (Structure).
* Individual formulas:
  * $S_{\text{color}} = \frac{1}{3} \sum_{i=1}^{32} \min(h_1(i), h_2(i))$ (Histogram Intersection)
  * $S_{\text{texture}} = \exp(-2.2 \cdot \|\mathbf{v}_{\text{glcm}, 1} - \mathbf{v}_{\text{glcm}, 2}\|_2)$ (Exponential Euclidean Decay)
  * $S_{\text{edge}} = 0.5 \left(1 - \frac{|D_{e1} - D_{e2}|}{\max(D_{e1}, D_{e2})}\right) + 0.5 \sum \min(O_1(j), O_2(j))$
  * $S_{\text{struct}} = \frac{\mathbf{s}_1 \cdot \mathbf{s}_2}{\|\mathbf{s}_1\|_2 \|\mathbf{s}_2\|_2}$ (Cosine Similarity)

---

# CHAPTER 5: MATLAB & GUI IMPLEMENTATION

### 5.1 Modular Software Structure
* [`main.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/main.m): Main entry point and environment auditor.
* [`preprocessSareeImage.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/preprocessSareeImage.m): Scaling, filtering, contrast enhancement.
* [`extractSareeBorder.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/extractSareeBorder.m): Perimeter margin energy and projection cropping.
* [`extractPatternFeatures.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/extractPatternFeatures.m): 49-D feature vector extraction.
* [`compareSareeBorders.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/compareSareeBorders.m): Weighted multi-domain comparison.
* [`sareeBorderGUI.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/sareeBorderGUI.m): Dual-panel desktop GUI.
* [`testProject.m`](file:///C:/Users/HP/.gemini/antigravity/scratch/SareeBorderPatternExtraction/testProject.m): Automated 10-suite unit verification framework.

---

# CHAPTER 6: EXPERIMENTAL RESULTS & CASE STUDY

### 6.1 Empirical Case Study: Printed Saree vs. Handloom Saree
During experimental validation, the system evaluated two specimens from the verified Neural-Loom dataset:
* **Specimen 1**: Printed Saree (`printed_img_31484.jpg`) — Screen-printed abstract floral block pattern with angular geometry and blue/orange palette.
* **Specimen 2**: Handloom Saree (`handloom_img_26850.jpg`) — Traditional woven handloom saree featuring red and gold curved paisley (*kalka*) motifs on a cream textile base.

### 6.2 Quantitative Result Breakdown

| Metric Evaluated | Component Formulation | Empirical Score | Engineering Interpretation |
| :--- | :--- | :---: | :--- |
| **Color Palette (HSV)** | Histogram Intersection | **54.8%** | Moderate match; shared warm tones (orange/gold) on different bases |
| **Textile Weave Texture** | GLCM Haralick Distance | **86.6%** | **Very High Match**; both specimens share fine, tightly-woven cloth weave |
| **Edge Density & Motifs** | Canny Density & Angles | **15.8%** | **Low Match**; angular block print geometry vs. curved paisley contours |
| **Structural Entropy** | Shannon Complexity & Solidity | **94.6%** | **Extremely High Match**; both borders exhibit equal decorative richness |
| **OVERALL DESIGN SIMILARITY** | **Weighted Composite** | **62.5%** | **Moderate Similarity (Shared Palette & Texture, Distinct Motifs)** |

### 6.3 Automated Unit Verification Results (`testProject.m`)
All 10 unit test suites passed verification:
* **TS-01 to TS-05**: Passed (File I/O, resizing, denoising, orientation bounding, and 49-D vector L2-normalization confirmed).
* **TS-06 (Self-Similarity)**: $\text{sim}(A, A) = 100.00\% \ge 99.0\%$ (**PASS**).
* **TS-07 (Symmetry & Bounds)**: $\text{sim}(A, B) = \text{sim}(B, A) = 62.50\% \in [0, 100]\%$ (**PASS**).
* **TS-08 to TS-10**: Passed (Zero-gradient blank image robustness, missing file exception handling, and synthetic fixture benchmarks).

---

# CHAPTER 7: LIMITATIONS & FUTURE WORK

### 7.1 Current System Limitations
1. **Severe Fabric Draping Folds**: Dynamic drape folds on live models can skew rectangular border bounding boxes (mitigated via the interactive manual ROI crop tool).
2. **Camera Lighting Variances**: Differing white balances on mobile phone cameras shift color histogram bins.

### 7.2 Proposed Future Work
1. **Active Contours (Snakes)**: Implementing deformable active contours to segment borders along curved, non-planar draped cloth contours.
2. **Deep Feature Embeddings**: Supplementing handcrafted GLCM descriptors with convolutional feature maps from lightweight pre-trained backbones (e.g., MobileNetV2 in MATLAB).

---

# CHAPTER 8: CONCLUSION

This project successfully developed an automated, objective, and reproducible digital image processing system for saree border extraction and similarity comparison in MATLAB. By integrating adaptive preprocessing, edge projection profiling, and a 49-dimensional multi-domain descriptor (HSV color, Haralick GLCM texture, Canny edge orientation, and Shannon entropy), the system replaces subjective visual inspection with a deterministic numerical metric bounded between 0.00% and 100.00%. The empirical case study confirmed an overall similarity of **62.5%**, accurately reflecting shared textile weave characteristics alongside distinct motif shapes. The accompanying desktop GUI, automated dataset acquisition pipeline, and unit test suites provide an accessible, robust tool for textile cataloging, handloom heritage archiving, and academic research.

---

# REFERENCES

1. R. K. Bhattacharjee, M. Nandi, and A. Jha, *"Handloom Design Generation Using Generative Networks"*, IEEE International Conference on Image Processing (ICIP), 2020.
2. R. M. Haralick, K. Shanmugam, and I. Dinstein, *"Textural Features for Image Classification"*, IEEE Transactions on Systems, Man, and Cybernetics, vol. SMC-3, no. 6, pp. 610–621, 1973.
3. J. Canny, *"A Computational Approach to Edge Detection"*, IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. PAMI-8, no. 6, pp. 679–698, 1986.
4. M. J. Swain and D. H. Ballard, *"Color Indexing"*, International Journal of Computer Vision, vol. 7, no. 1, pp. 11–32, 1991.
5. S. M. Pizer et al., *"Adaptive Histogram Equalization and Its Variations"*, Computer Vision, Graphics, and Image Processing, vol. 39, no. 3, pp. 355–368, 1987.
6. MathWorks, *"MATLAB Image Processing Toolbox User's Guide"*, The MathWorks, Inc., Natick, Massachusetts, 2024.
7. Wikimedia Commons, *"Categories of Indian Saris and Textiles"*, Wikimedia Foundation, 2024. [Online]. Available: `https://commons.wikimedia.org/wiki/Category:Saris`.
