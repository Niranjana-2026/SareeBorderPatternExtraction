# System Architecture & Algorithm Flowcharts

## Project: Saree Border Pattern Extraction & Design Similarity Comparison Using MATLAB

---

## 1. High-Level System Architecture

```mermaid
flowchart TD
    subgraph Data Layer ["Data Ingestion & Dataset Preparation"]
        A1["Public Sources Catalog<br/>(Neural Loom + Wikimedia)"] --> A2["downloadDataset.m / .ps1"]
        A2 --> A3["dataset/raw/"]
        A3 --> A4["organizeDataset.m<br/>(Validation & De-duplication)"]
        A4 --> A5["dataset/silk, cotton, handloom..."]
        A5 --> A6["dataset/processed/"]
    end

    subgraph Preprocessing Layer ["Image Normalization & Enhancement"]
        B1["Input Saree Image (RGB)"] --> B2["preprocessSareeImage.m"]
        B2 --> B3["Scale Normalization (MaxDim: 800px)"]
        B3 --> B4["Grayscale Conversion & Denoising<br/>(Gaussian/Median Filtering)"]
        B4 --> B5["Contrast Normalization<br/>(Adaptive Histogram Equalization)"]
        B5 --> B6["Sobel Gradient Magnitude & Direction"]
    end

    subgraph Border Extraction Layer ["Border Detection & Localization"]
        C1["Preprocessed Image"] --> C2["extractSareeBorder.m"]
        C2 --> C3{"User Mode?"}
        C3 -- Auto-Detect --> C4["Margin Energy Scoring<br/>(Bottom, Top, Left, Right)"]
        C4 --> C5["Edge Projection Profile Localization"]
        C3 -- Manual Override --> C6["Interactive BBox Selection"]
        C5 --> C7["Cropped Border Color & Gray Patches"]
        C6 --> C7
        C7 --> C8["Annotated Visual Overlay (Green BBox)"]
    end

    subgraph Feature Extraction Layer ["Multi-Descriptor Feature Engine"]
        D1["Cropped Border Image"] --> D2["extractPatternFeatures.m"]
        D2 --> D3["Color Histogram (32-D HSV)"]
        D2 --> D4["GLCM Haralick Texture (4-D)<br/>Contrast, Correlation, Energy, Homogeneity"]
        D2 --> D5["Canny Edge Density & 8-D Orientation Hist"]
        D2 --> D6["Structural Moments & Shannon Entropy (4-D)"]
        D3 & D4 & D5 & D6 --> D7["49-Dimensional Unified Feature Vector<br/>(L2 Normalized)"]
    end

    subgraph Similarity Layer ["Quantitative Comparison Engine"]
        E1["Border 1 Feature Vector"] & E2["Border 2 Feature Vector"] --> E3["compareSareeBorders.m"]
        E3 --> E4["Color Intersection S_color (Weight: 0.35)"]
        E3 --> E5["GLCM Distance Decay S_texture (Weight: 0.30)"]
        E3 --> E6["Edge Match S_edge (Weight: 0.20)"]
        E3 --> E7["Cosine Structural S_struct (Weight: 0.15)"]
        E4 & E5 & E6 & E7 --> E8["Composite Similarity Percentage [0% - 100%]"]
        E8 --> E9["Qualitative Assessment & Text Audit Report"]
    end

    subgraph Presentation Layer ["UI & Export Operations"]
        F1["sareeBorderGUI.m"] --> F2["Dual-Panel Interactive Visualization"]
        F2 --> F3["Save Comparison Plot & Text Report"]
    end

    A6 --> B1
    B6 --> C1
    C7 --> D1
    D7 --> E1
    E8 --> F1
```

---

## 2. Detailed Algorithm Pipeline Flowchart

```mermaid
flowchart TD
    Start(["Start Application (main.m)"]) --> CheckEnv{"MATLAB & Toolboxes<br/>Available?"}
    CheckEnv -- Yes --> InitPaths["Add Scripts to MATLAB Path & Create Output Folders"]
    CheckEnv -- Missing IPT --> SetFallbacks["Enable Native Fallback Convolutions & Filters"]
    SetFallbacks --> InitPaths
    InitPaths --> AuditDS["prepareDataset.m: Audit Image Folders"]
    
    AuditDS --> HaveImages{"Dataset<br/>Ready?"}
    HaveImages -- No --> DownloadPrompt["Run downloadDataset.m or Generate Calibration Samples"]
    DownloadPrompt --> GUIReady["Launch sareeBorderGUI"]
    HaveImages -- Yes --> GUIReady

    GUIReady --> LoadImages["User Uploads Saree 1 & Saree 2"]
    LoadImages --> Preprocess["preprocessSareeImage.m:<br/>1. Resize max dimension to 800px<br/>2. Convert RGB to Grayscale<br/>3. Gaussian/Median Denoising<br/>4. Contrast Normalization (adapthisteq)<br/>5. Sobel Gradient Magnitude Gmag"]

    Preprocess --> ExtractBorders["extractSareeBorder.m:<br/>1. Compute Canny Edge Map<br/>2. Evaluate Energy on 4 Candidate Margins<br/>3. Refine Bounding Box using 1D Projection Profile<br/>4. Crop Border Region [borderRGB, borderGray]"]

    ExtractBorders --> ExtractFeatures["extractPatternFeatures.m:<br/>1. HSV Color Histogram (16+8+8 = 32 bins)<br/>2. GLCM Haralick Features (0°, 45°, 90°, 135°)<br/>3. Edge Density De + 8-Bin Orientation Hist<br/>4. Shannon Entropy & Structural Solidity<br/>5. Form L2-Normalized Feature Vector"]

    ExtractFeatures --> Compare["compareSareeBorders.m:<br/>1. S_color = HSV Histogram Intersection<br/>2. S_texture = exp(-2.2 * ||v_glcm1 - v_glcm2||)<br/>3. S_edge = 0.5*DensityMatch + 0.5*OrientMatch<br/>4. S_struct = Cosine(s1, s2)<br/>5. Overall = 0.35*S_c + 0.30*S_t + 0.20*S_e + 0.15*S_s"]

    Compare --> DisplayResults["GUI Displays:<br/>- Overall Similarity Percentage<br/>- Sub-metric breakdown badges<br/>- Qualitative assessment"]

    DisplayResults --> UserChoice{"User Action?"}
    UserChoice -- Save --> ExportArtifacts["Save output/comparisons/comp_plot.png<br/>Save output/reports/similarity_report.txt"]
    UserChoice -- Manual Crop --> RefineCrop["User Drags Bounding Box<br/>Recompute Features & Similarity"]
    UserChoice -- Reset --> ResetGUI["Clear Axes & Reset State"]
    UserChoice -- Done --> Finish(["End Session"])
```

---

## 3. Data Processing Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User as College Student / Evaluator
    participant GUI as sareeBorderGUI.m
    participant Pre as preprocessSareeImage.m
    participant Border as extractSareeBorder.m
    participant Feat as extractPatternFeatures.m
    participant Comp as compareSareeBorders.m
    participant FS as File System (output/)

    User->>GUI: Launch application (main.m)
    GUI->>User: Display Dual-Panel Interface
    User->>GUI: Click "Upload Saree 1" & "Upload Saree 2"
    GUI->>Pre: preprocessSareeImage(img)
    Pre-->>GUI: Return [original, resized, gray, enhanced, gradientMag]
    GUI->>Border: extractSareeBorder(prep, 'Orientation', 'auto')
    Border-->>GUI: Return [borderRGB, borderGray, borderBBox, annotatedImage]
    GUI->>Feat: extractPatternFeatures(borderRGB)
    Feat-->>GUI: Return 49-D Feature Vector [colorHist, glcm, edge, structural]
    GUI->>User: Display annotated saree & extracted border crops
    User->>GUI: Click "COMPARE DESIGNS"
    GUI->>Comp: compareSareeBorders(feat1, feat2)
    Comp-->>GUI: Return similarityResult (Score %, Breakdowns, Qualitative Text)
    GUI->>User: Display Overall Similarity % & Metric Badges
    User->>GUI: Click "Save Results"
    GUI->>FS: Write comparison plot (.png) & audit report (.txt)
    FS-->>GUI: File paths confirmed
    GUI->>User: Alert "Results Saved Successfully"
```
