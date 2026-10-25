# Saree Border Pattern Extraction & Design Similarity Comparison Using MATLAB

[![MATLAB](https://img.shields.io/badge/Language-MATLAB%20.m-orange.svg)](https://www.mathworks.com/)
[![Toolbox](https://img.shields.io/badge/Toolbox-Image%20Processing-blue.svg)](https://www.mathworks.com/products/image.html)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20VS%20Code-brightgreen.svg)]()
[![No Python](https://img.shields.io/badge/Python%20Free-100%25%20MATLAB-success.svg)]()

A complete college image-processing project implemented strictly in **MATLAB `.m` files** with an automated dataset acquisition pipeline, high-precision border extraction algorithms, multi-descriptor texture/color feature extraction, quantitative similarity comparison, a modern desktop graphical user interface (GUI), automated verification tests, and college documentation.

---

## 📌 Project Overview

Traditional Indian sarees feature elaborate decorative borders (*zari*, brocade, temple serrations, paisley motifs, ikat geometry) woven along edges that distinguish regional craftsmanship (e.g., Banarasi, Kanchipuram, Paithani, Sambalpuri, Jamdani). 

This project provides an automated, objective computer-vision solution to:
1. **Localize and isolate the decorative border** from whole saree images using edge projection profiles, gradient energy, and texture variance.
2. **Characterize pattern morphology** using 49-dimensional quantitative feature vectors combining HSV color distribution, Haralick Gray-Level Co-occurrence Matrix (GLCM) texture features, Canny edge density/directionality, and structural entropy.
3. **Compute a normalized design similarity score (0% to 100%)** between any two saree borders with full qualitative assessments.

---

## 🗂️ Project Directory Structure

```text
SareeBorderPatternExtraction/
├── main.m                           # Primary entry point (launches GUI or console menu)
├── sareeBorderGUI.m                 # Modern dual-panel desktop GUI (uifigure & uiaxes)
├── preprocessSareeImage.m           # Scaling, grayscale conversion, denoising & contrast enhancement
├── extractSareeBorder.m             # Edge-projection border localization & cropping
├── extractPatternFeatures.m         # 49-D feature vector extraction (Color, GLCM, Edge, Structure)
├── compareSareeBorders.m            # Weighted multi-descriptor similarity calculation
├── downloadDataset.m                # Automated MATLAB dataset downloader (websave & validation)
├── downloadDataset.ps1              # Automated Windows PowerShell fallback downloader
├── organizeDataset.m                # Validates images, detects duplicates, organizes categories
├── prepareDataset.m                 # Audits dataset counts and creates calibration benchmarks
├── runDemo.m                        # Non-interactive automated end-to-end demonstration
├── testProject.m                    # Comprehensive 10-suite automated unit & integration test
├── requirements.md                  # Detailed environment, hardware, and toolbox requirements
├── README.md                        # Master setup, workflow, and user documentation
│
├── dataset/                         # Saree image repository
│   ├── raw/                         # Staging area for incoming downloads
│   ├── processed/                   # Validated images standardized for analysis
│   ├── silk/                        # Banarasi, Kanchipuram, Mysore silk sarees
│   ├── cotton/                      # Sambalpuri, Chanderi, Tant, Pochampally sarees
│   ├── designer/                    # Zardozi, Gota Patti, Chikankari sarees
│   ├── printed/                     # Kalamkari, Bagh block print, Bandhani sarees
│   ├── handloom/                    # Patola, Paithani, Jamdani, Ilkal, Kasavu sarees
│   ├── unclassified/                # Saree images with unspecified textile composition
│   ├── dataset_manifest.csv         # Provenance catalog with URLs, licenses, and attributions
│   └── organized_manifest.csv       # Technical manifest (dimensions, color type, file size)
│
├── output/                          # Output exports and generated artifacts
│   ├── extracted_borders/           # Cropped border image exports
│   ├── comparisons/                 # Side-by-side comparison visualization plots
│   └── reports/                     # Saved similarity audit reports
│
└── documentation/                   # College academic deliverables
    ├── project_report.md            # Complete academic project report with math and results
    ├── presentation_outline.md      # 10-slide presentation outline with speaker notes
    └── algorithm_flowchart.md       # Visual pipeline flowcharts and sequence diagrams
```

---

## 💻 Beginner-Friendly Setup Guide (VS Code on Windows)

Follow this step-by-step guide to run the project from **Visual Studio Code** on Windows:

### Step 1: Open the Project in VS Code
1. Launch **Visual Studio Code**.
2. Go to **File** ➔ **Open Folder...** (or press `Ctrl+K, Ctrl+O`).
3. Select the folder:
   ```text
   C:\Users\HP\.gemini\antigravity\scratch\SareeBorderPatternExtraction
   ```
4. Click **Select Folder**. The project file tree will appear in the VS Code Explorer side panel.

### Step 2: Verify MATLAB Installation
1. Open the integrated terminal in VS Code (**Terminal** ➔ **New Terminal** or press `Ctrl+\``).
2. Check if MATLAB is registered on your Windows system PATH:
   ```powershell
   Get-Command matlab -ErrorAction SilentlyContinue
   ```
3. **If MATLAB is installed**: It will display the path (e.g., `C:\Program Files\MATLAB\R2023b\bin\matlab.exe`).
4. **If MATLAB is NOT found**: 
   * MATLAB must be installed to execute `.m` scripts. Download and install MATLAB (R2018a or newer with Image Processing Toolbox) from [MathWorks Portal](https://www.mathworks.com/).
   * Add the MATLAB `bin` folder (e.g., `C:\Program Files\MATLAB\R202X\bin`) to your Windows System Environment Variable `PATH`.

### Step 3: Install the MATLAB Extension for VS Code
1. Click the **Extensions** icon on the left activity bar (or press `Ctrl+Shift+X`).
2. Search for:
   ```text
   MATLAB
   ```
3. Install the official extension published by **MathWorks** (`mathworks.matlab`).
4. This enables MATLAB code syntax highlighting, auto-completion, linting, and interactive execution directly inside VS Code.

### Step 4: Download the Verified Saree Dataset
You have two automated ways to acquire the dataset without manual downloading:

* **Option A (From Windows PowerShell Terminal in VS Code)**:
  Run the provided PowerShell fallback downloader:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\downloadDataset.ps1
  ```
* **Option B (From MATLAB)**:
  Run the automated MATLAB download function:
  ```matlab
  downloadDataset
  ```
Both options connect to legitimate, verified academic repositories (Neural Loom project at Assam Engineering College / ICIP 2020) and open Creative Commons textile archives (Wikimedia Commons), verify file sizes, check image integrity, and automatically organize the images into `dataset/silk/`, `dataset/cotton/`, etc.

### Step 5: Launch the Application Entry Point (`main.m`)
To launch the primary project entry point:

* **From MATLAB Desktop / Command Window**:
  Navigate to the project directory and type:
  ```matlab
  main
  ```
* **From Windows Terminal / PowerShell (Headless or Direct Launch)**:
  ```powershell
  matlab -nosplash -r "main"
  ```
  *(In MATLAB R2019a+, you can also use: `matlab -batch "main"`)*

This launches the interactive desktop graphical interface (`sareeBorderGUI`).

---

## 🖥️ Graphical User Interface (GUI) Guide

The desktop GUI (`sareeBorderGUI.m`) is organized into an intuitive dual-panel layout:

```text
+-----------------------------------------------------------------------------------------------+
|  SAREE BORDER PATTERN EXTRACTION & DESIGN SIMILARITY SYSTEM                                   |
+-----------------------------------------------+-----------------------------------------------+
|  SAREE 1 (REFERENCE)                          |  SAREE 2 (TARGET)                             |
|  [Upload Saree 1] [Orientation] [Width Slider]|  [Upload Saree 2] [Orientation] [Width Slider]|
|  [Extract Border] [Manual Crop]               |  [Extract Border] [Manual Crop]               |
|                                               |                                               |
|  [ Axes 1: Original Image with Green BBox ]   |  [ Axes 3: Original Image with Green BBox ]   |
|                                               |                                               |
|  [ Axes 2: Extracted Border 1 Pattern Crop ]  |  [ Axes 4: Extracted Border 2 Pattern Crop ]  |
|  Border 1 Features: (Color, Texture, Edge)    |  Border 2 Features: (Color, Texture, Edge)    |
+-----------------------------------------------+-----------------------------------------------+
|  [ COMPARE DESIGNS ]                          |  OVERALL SIMILARITY: 88.4% (High Similarity)  |
|  [ Save Comparison & Report ]                 |  Color: 89.1% | Texture: 87.5% | Edge: 89.0%  |
|  [ Reset All ]                                |  Quick Samples: [Silk] [Cotton] [Handloom]    |
+-----------------------------------------------------------------------------------------------+
```

### GUI Step-by-Step Operation:
1. Click **Upload Saree 1** and select any saree image from `dataset/` or your computer.
2. The detected border is automatically localized and marked with a bright green boundary box.
3. If desired, adjust the **Orientation** dropdown (`Bottom`, `Top`, `Left`, `Right`, `Auto`) or the **Width Slider** and click **Extract**.
4. If a saree has complex folds or an unusual drape angle, click **Manual Crop** and drag a rectangle over the border.
5. Click **Upload Saree 2** and repeat for the comparison target.
6. Click **COMPARE DESIGNS** to compute the multi-feature similarity.
7. Observe the **Overall Similarity %**, individual metric breakdowns, and qualitative interpretation.
8. Click **Save Comparison & Report** to export high-resolution side-by-side figures and audit reports into the `output/` folder.

---

## 🔬 Mathematical Formulation & Similarity Score

The total design similarity is computed via a weighted multi-descriptor model:

$$\text{Similarity}_{\text{total}} = w_c \cdot S_{\text{color}} + w_t \cdot S_{\text{texture}} + w_e \cdot S_{\text{edge}} + w_s \cdot S_{\text{struct}}$$

Where default weights are balanced as:
* **Color Palette ($w_c = 0.35$)**: Evaluated using normalized 32-bin HSV Histogram Intersection:
  $$S_{\text{color}} = \frac{1}{3} \sum_{i=1}^{32} \min(h_{1}(i), h_{2}(i))$$
* **Weave Texture ($w_t = 0.30$)**: Evaluated using Haralick GLCM features (Contrast, Correlation, Energy, Homogeneity) across 4 spatial directions ($0^\circ, 45^\circ, 90^\circ, 135^\circ$):
  $$S_{\text{texture}} = \exp\left(-2.2 \cdot \| v_{\text{glcm}, 1} - v_{\text{glcm}, 2} \|_2\right)$$
* **Edge & Motif Directionality ($w_e = 0.20$)**: Evaluated using Canny edge density match and 8-bin gradient orientation histogram intersection:
  $$S_{\text{edge}} = 0.5 \left(1 - \frac{|D_{e1} - D_{e2}|}{\max(D_{e1}, D_{e2})}\right) + 0.5 \sum_{j=1}^{8} \min(O_1(j), O_2(j))$$
* **Structural Complexity ($w_s = 0.15$)**: Evaluated using Cosine similarity of statistical intensity moments, Shannon entropy, and motif solidity.

### Qualitative Thresholds:
* **$\ge 90\%$**: Extremely High Similarity (Near-Identical Border Pattern & Palette)
* **$75\% - 89.9\%$**: High Similarity (Closely Related Motif, Weave Texture & Palette)
* **$55\% - 74.9\%$**: Moderate Similarity (Shared Texture or Palette Characteristics)
* **$35\% - 54.9\%$**: Low Similarity (Noticeable Differences in Motif and Color)
* **$< 35\%$**: Very Low / Dissimilar Border Designs

---

## 🧪 Automated Testing Suite (`testProject.m`)

Run the automated test suite in MATLAB:
```matlab
testProject
```
This executes **10 distinct automated test suites**:
1. Directory structure and dataset audit validation.
2. Image loading and format normalization (RGB, Grayscale, Float).
3. Preprocessing, Gaussian/median denoising, and contrast normalization.
4. Border extraction across orientations (Bottom, Top, Left, Right, Auto, Manual).
5. 49-D feature extraction (Color bins, finite GLCM metrics, unit vector norm).
6. Self-similarity verification ($\text{sim}(A, A) \ge 99\%$).
7. Cross-design comparison, bounds check $[0, 100]\%$, and mathematical symmetry ($\text{sim}(A, B) = \text{sim}(B, A)$).
8. Edge cases and zero-gradient robustness (blank images, uniform patches).
9. Graceful error handling for missing/corrupted files.
10. Synthetic pattern fixture benchmark tests (clearly marked as unit-test fixtures).

---

## 🛠️ Troubleshooting & Frequently Asked Questions

### 1. "matlab is not recognized as an internal or external command"
* **Cause**: MATLAB executable directory is not added to the Windows environment `PATH`.
* **Fix**: In Windows Search, open **Environment Variables**, select **Path**, click **Edit**, and add:
  `C:\Program Files\MATLAB\R202X\bin` (replace with your installed version). Restart VS Code.

### 2. "Image Processing Toolbox functions not found"
* **Diagnosis**: The core `.m` files in this project include **native resilience fallbacks** (such as Sobel filter convolutions and native histogram calculations).
* **Fix**: To use the full hardware-accelerated MathWorks toolbox, open MATLAB, go to **Add-Ons** ➔ **Get Add-Ons**, and install **Image Processing Toolbox**.

### 3. "Download fails or shows HTTP error"
* **Cause**: Corporate firewall, proxy, or offline environment.
* **Fix**: Run `prepareDataset.m`. If the dataset folder has no internet access, the script automatically generates high-resolution calibration benchmark samples across Silk, Cotton, Handloom, Printed, and Designer categories so that the entire project remains 100% operational offline.

### 4. "How do I extract a border that is diagonally folded?"
* **Fix**: Saree border drape folds can cause automatic rectangular margin detection to clip parts of the pattern. Simply click **Manual Crop** in the GUI, click and drag a tight rectangle directly over any clear section of the border pattern, and release. The system will extract features from the selected region.

---

## 📄 License & Attribution

* **Core Algorithms & Source Code**: Released under the MIT License.
* **Neural-Loom Dataset Attribution**: R. K. Bhattacharjee, M. Nandi, and A. Jha, *"Handloom Design Generation Using Deep Neural Networks"*, Assam Engineering College, Guwahati, India (ICIP 2020).
* **Wikimedia Commons Textile Images**: Licensed under Creative Commons (CC BY-SA 4.0 / CC BY 3.0). Complete source URLs and attribution records are preserved in `dataset/dataset_manifest.csv`.
