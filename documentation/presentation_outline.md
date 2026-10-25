# College Presentation Outline & Speaker Notes (10 Slides)

## Title: Saree Border Pattern Extraction and Design Similarity Comparison Using MATLAB

---

### Slide 1: Title & Introduction
* **Header**: Saree Border Pattern Extraction & Design Similarity Comparison
* **Sub-header**: Final Year / Semester Digital Image Processing Project
* **Student Details**: [Your Name] | Department of Computer Science & Engineering / Electronics
* **Supervisor**: [Faculty Guide / Professor Name] | [College / University Name]
* **Technology**: MATLAB `.m` Implementation | Image Processing Toolbox | Windows VS Code
* **Speaker Notes**:
  > *"Respected guide, external examiners, and dear peers, good morning. Today, I am presenting my image processing project titled 'Saree Border Pattern Extraction and Design Similarity Comparison Using MATLAB'. The project focuses on automating the visual localization of ornate saree borders and computing a quantitative design similarity percentage between textile designs using multi-feature computer vision descriptors."*

---

### Slide 2: Problem Statement & Motivation
* **Key Challenges**:
  * Indian sarees (Banarasi, Kanchipuram, Paithani, Sambalpuri) possess intricate decorative borders (*zari*, brocades, temple serrations, paisley motifs).
  * Manual visual inspection for textile cataloging, design patent verification, and counterfeit detection is slow, subjective, and prone to human eye fatigue.
  * Saree imagery suffers from drape folds, diverse lighting, colored backgrounds, and non-uniform cloth textures.
* **Problem Formulation**:
  * Automatically segment the decorative border margin from full-body saree photographs.
  * Quantify visual motifs using mathematical descriptors without relying on subjective human judgment.
* **Speaker Notes**:
  > *"Traditional Indian textiles represent centuries of craftsmanship. However, in modern e-commerce and handloom certification, comparing two saree borders is done manually. Human inspectors can disagree on similarity, and subtle pattern variations often go unnoticed. Our problem statement is to build an end-to-end, reproducible MATLAB pipeline that automatically locates the border and calculates an objective similarity percentage from 0 to 100%."*

---

### Slide 3: Project Objectives & Scope
* **Core Objectives**:
  1. Automated dataset acquisition pipeline with verified licensing and provenance.
  2. Noise-resilient image preprocessing (adaptive contrast equalization and filtering).
  3. Margin energy localization and 1D edge projection profiling for automatic border cropping.
  4. 49-dimensional multi-descriptor feature representation (Color, Texture, Edges, Shape).
  5. Weighted similarity scoring model with qualitative interpretation.
  6. Comprehensive MATLAB desktop GUI (`uifigure` / `uiaxes`) for interactive evaluation.
* **Scope & Boundaries**:
  * Pure MATLAB `.m` implementation without Python, OpenCV, or external C dependencies.
  * Designed to run seamlessly from VS Code on Windows.
* **Speaker Notes**:
  > *"To solve this, our scope covers six major deliverables: first, automated data downloading; second, adaptive preprocessing; third, automatic border cropping with a manual override option; fourth, mathematical feature extraction; fifth, a weighted similarity engine; and sixth, an intuitive desktop GUI where any non-technical user can upload two images and get immediate, transparent comparison metrics."*

---

### Slide 4: Dataset Acquisition & Ethical Data Handling
* **Data Sources**:
  * **Neural-Loom Dataset**: Assam Engineering College academic research dataset (ICIP 2020) containing authentic cell-phone captured normal and handloom sarees.
  * **Wikimedia Commons Textile Collections**: Open CC-BY-SA licensed archival sarees (Banarasi silk, Kanchipuram silk, Sambalpuri cotton, Paithani handloom).
* **Automation Tools**:
  * `downloadDataset.m`: Automated MATLAB `websave` script with integrity validation.
  * `downloadDataset.ps1`: Automated Windows PowerShell downloader.
  * `organizeDataset.m`: Validates image headers, removes duplicates, sorts into `dataset/silk/`, `dataset/cotton/`, etc.
  * `prepareDataset.m`: Audits dataset counts and provides calibration benchmarks.
* **Speaker Notes**:
  > *"A critical priority for this project was automated dataset handling. We acquired real saree images from the legitimate Neural-Loom research dataset published at ICIP 2020, combined with open Creative Commons heritage collections. We implemented automated downloaders in both MATLAB and PowerShell. The scripts check file integrity, detect duplicates, and maintain a complete CSV manifest recording source URLs, licenses, and attributions."*

---

### Slide 5: System Architecture & Workflow Pipeline
* **Four-Tier Architecture**:
  1. **Data Ingestion Tier**: Verified downloading, duplicate pruning, folder sorting.
  2. **Preprocessing Tier**: Resizing to 800px max dimension, grayscale conversion, Gaussian/median filtering, adaptive histogram equalization (`adapthisteq`), Sobel gradient mapping.
  3. **Feature Extraction Tier**: HSV color histogram (32-D), Haralick GLCM features (4-D), Canny edge density & orientation (9-D), structural moments & entropy (4-D).
  4. **Comparison & UI Tier**: Weighted metric calculation, qualitative rating, desktop GUI display, and report exportation.
* **Speaker Notes**:
  > *"This slide presents our system architecture. The pipeline begins with raw image input. It scales the image for uniform computation, enhances contrast to reveal fine metallic threads, and calculates gradient energy. The extracted border patch is passed through four independent feature engines, forming a normalized 49-dimensional descriptor that fuels the comparison stage."*

---

### Slide 6: Border Extraction Algorithm
* **Detection Logic**:
  * Saree borders exhibit significantly higher high-frequency edge density and gradient variance than the main body cloth.
  * **Margin Energy Analysis**: The image's four perimeter zones (Bottom, Top, Left, Right) are evaluated using:
    $$E_{\text{margin}} = 0.65 \cdot \text{EdgeDensity} + 0.35 \cdot \text{MeanGradient}$$
  * **Boundary Localization**: 1D edge projection profiles ($P(y) = \frac{1}{W}\sum E(y, x)$) determine the precise transition where the ornate pattern gives way to the plainer field.
  * **Interactive Fallback**: When saree folds or complex drapes obscure the automatic detector, a manual crop tool enables the user to select the region of interest.
* **Speaker Notes**:
  > *"How does the computer know where the border is? Saree borders are characterized by dense metallic zari or contrasting thread weaves. We calculate the edge density and gradient energy across the four outer margins. For standard catalog photos, the margin with the highest energy corresponds to the border. The transition boundary is refined using 1D edge projection profiling. If a saree has irregular folds, our GUI provides an interactive manual cropping tool as a reliable fallback."*

---

### Slide 7: Multi-Descriptor Feature Extraction
* **1. Color Distribution (32-D)**:
  * Converted to HSV color space.
  * Quantized into 16 Hue, 8 Saturation, and 8 Value bins; normalized to sum to 1.0.
* **2. Texture Characterization (GLCM Haralick Features - 4-D)**:
  * Gray-Level Co-occurrence Matrix computed across $0^\circ, 45^\circ, 90^\circ, 135^\circ$ offsets.
  * Extracts: *Contrast* (intensity variation), *Correlation* (linear dependency), *Energy* (uniformity), and *Homogeneity* (closeness to matrix diagonal).
* **3. Edge Density & Motif Directionality (9-D)**:
  * Canny edge density scalar $D_e \in [0, 1]$.
  * 8-bin gradient orientation histogram capturing motif angles (e.g., paisley curves vs. diagonal chevrons).
* **4. Structural & Entropy Descriptors (4-D)**:
  * Shannon entropy (pattern complexity), intensity standard deviation, and motif solidity.
* **Speaker Notes**:
  > *"To thoroughly capture the design, we extract 49 numerical features across four complementary domains: Color in HSV space captures the thread and zari palette; Haralick GLCM features capture the weave texture and coarseness; Canny edge density and gradient angle histograms capture the motif geometry; and Shannon entropy quantifies pattern complexity. All features are concatenated and L2-normalized."*

---

### Slide 8: Similarity Formula & Mathematical Model
* **Composite Weighted Model**:
  $$\text{Similarity}_{\text{total}} = w_c \cdot S_{\text{color}} + w_t \cdot S_{\text{texture}} + w_e \cdot S_{\text{edge}} + w_s \cdot S_{\text{struct}}$$
* **Component Formulations**:
  * $S_{\text{color}} = \frac{1}{3} \sum \min(h_1(i), h_2(i))$ (Histogram Intersection)
  * $S_{\text{texture}} = \exp(-2.2 \cdot \| v_{\text{glcm}, 1} - v_{\text{glcm}, 2} \|_2)$ (Exponential Euclidean Decay)
  * $S_{\text{edge}} = 0.5 \left(1 - \frac{|D_{e1} - D_{e2}|}{\max(D_{e1}, D_{e2})}\right) + 0.5 \sum \min(O_1(j), O_2(j))$
  * $S_{\text{struct}} = \frac{s_1 \cdot s_2}{\|s_1\| \|s_2\|}$ (Cosine Similarity)
* **Weights**: $w_c = 0.35, w_t = 0.30, w_e = 0.20, w_s = 0.15$ (Sums to 1.0)
* **Score Normalization**: Strictly clamped to $[0.00\%, 100.00\%]$.
* **Speaker Notes**:
  > *"Our similarity engine combines these domains using a weighted formula. Color receives 35% weight, weave texture 30%, edge density and orientation 20%, and structural entropy 15%. Self-comparison yields near 100%, while mathematically distinct designs drop proportionally. We include qualitative interpretation labels and an academic disclaimer noting that mathematical similarity reflects visual descriptor correlation, not legal copyright identity."*

---

### Slide 9: Desktop GUI & Experimental Testing
* **Interactive MATLAB Desktop GUI (`sareeBorderGUI.m`)**:
  * Dual-panel layout displaying original saree images with neon green border bounding boxes.
  * Dedicated axes showing high-resolution extracted border pattern crops.
  * Orientation dropdowns, border width sliders, and interactive manual crop buttons.
  * Real-time metric breakdown badges (Color %, Texture %, Edge %, Structural %).
  * Export buttons for side-by-side comparison figures and text audit reports.
* **Automated Unit & Integration Testing (`testProject.m`)**:
  * 10 distinct test suites validating image loading, orientation bounds, feature normalization, self-similarity ($\ge 99\%$), mathematical symmetry, and error handling for missing files.
* **Speaker Notes**:
  > *"Here is the graphical user interface running in MATLAB. On the left is Saree 1, and on the right is Saree 2. The user uploads two images, clicks Extract, and the green box highlights the detected border. Clicking 'Compare Designs' computes the similarity breakdown and displays the overall percentage. The testProject suite verifies all 10 modules automatically, confirming that self-comparison achieves over 99% and that all mathematical properties hold."*

---

### Slide 10: Conclusion, Limitations & Future Work
* **Key Achievements**:
  * Built a 100% native MATLAB image processing system for saree border extraction and similarity comparison.
  * Fully automated dataset downloading and organization without third-party Python dependencies.
  * Integrated multi-descriptor feature extraction combining color, texture, edge geometry, and entropy.
  * Delivered an accessible desktop GUI and automated test verification.
* **Limitations**:
  * Severe fabric folds, crushed textiles, or extreme perspective skew can obscure rectangular border cropping.
  * Lighting variations across uncalibrated phone cameras can shift color histogram intersections.
* **Future Work**:
  * Incorporating deep feature embeddings (e.g., lightweight CNN / ResNet feature maps in MATLAB).
  * Polygon / active contour (snake) border segmentation for non-linear draped textiles.
* **Speaker Notes**:
  > *"In conclusion, this project provides a robust, objective image-processing solution for saree border analysis, implemented entirely in MATLAB .m files with zero Python dependencies. While extreme drape folds remain a challenge best handled by our manual crop tool, future iterations can incorporate deformable snakes or CNN embeddings. Thank you for your time and attention. I am now open to your questions."*
