# System & Software Requirements

## Project: Saree Border Pattern Extraction and Design Similarity Comparison Using MATLAB

---

## 1. Primary Runtime Environment

| Component | Specification | Notes |
| :--- | :--- | :--- |
| **Primary Platform** | **MathWorks MATLAB** | Required runtime engine for executing `.m` code |
| **Supported MATLAB Versions** | MATLAB R2018a through R2024b+ | Built using modern `uifigure`, `uiaxes`, `inputParser` |
| **Tested Target Platform** | Microsoft Windows 10 / Windows 11 (64-bit) | Fully compatible with Windows file paths and shell |
| **Editor / IDE** | **Visual Studio Code (VS Code)** | Workspace code editing, terminal management |
| **MATLAB VS Code Extension** | *MATLAB* by MathWorks (Extension ID: `mathworks.matlab`) | Provides syntax highlighting, code navigation, and execution |

---

## 2. MATLAB Toolbox Requirements & Disclosures

### Required Toolbox:
* **Image Processing Toolbox**
  * **Functions Used**:
    * Color Space Conversion: `rgb2gray`, `rgb2hsv`
    * Spatial Filtering & Denoising: `imgaussfilt`, `medfilt2`, `imfilter`, `fspecial`
    * Contrast Normalization: `adapthisteq`, `imadjust`
    * Edge & Gradient Detection: `edge` (Canny operator), `imgradient` (Sobel operator)
    * Texture Characterization: `graycomatrix`, `graycoprops` (Haralick Contrast, Correlation, Energy, Homogeneity)
    * Morphological Operations: `imclose`, `strel`, `regionprops`
    * Sizing & Display: `imresize`, `imshow`

### Native Toolbox Fallbacks (Built-in Resilience):
To ensure maximum portability and prevent project crashes on minimal MATLAB student licenses:
* If `graycomatrix` / `graycoprops` are unavailable, `extractPatternFeatures.m` automatically activates a native spatial variation fallback.
* If `imgaussfilt` or `adapthisteq` are unavailable, convolution with Sobel/Gaussian kernels and `imadjust` are executed natively.
* If `edge` is unavailable, thresholded gradient magnitude calculation is performed natively.

---

## 3. Hardware Requirements

* **Processor**: Intel Core i3 / AMD Ryzen 3 or higher (Dual-Core 2.0 GHz+).
* **RAM**: 4 GB minimum (8 GB recommended for batch processing large 4K image datasets).
* **Storage Space**:
  * Core Code & Documentation: ~15 MB.
  * Verified Saree Dataset: ~150 MB to 500 MB (depending on downloaded image count).
* **Display Resolution**: 1280 × 800 minimum screen resolution (1920 × 1080 recommended for optimal dual-panel GUI presentation).

---

## 4. Supported Image Formats

The dataset loader and GUI support all standard lossless and lossy raster textile formats:
* JPEG / JPG (`.jpg`, `.jpeg`) — Standard camera capture and e-commerce catalogs.
* PNG (`.png`) — Lossless photographic captures and benchmark patterns.
* BMP (`.bmp`) — Uncompressed bitmap raster images.
* TIFF / TIF (`.tif`, `.tiff`) — High-fidelity textile scans.

---

## 5. Non-Dependencies (Mandatory Compliance)

* ❌ **No Python required or used**: No `python.exe`, `pip`, `venv`, or `.py` files.
* ❌ **No OpenCV / cv2 required or used**: All image processing is 100% native MATLAB `.m` code.
* ❌ **No C/C++ MEX compilation required**: All algorithms run directly on interpreted MATLAB arrays.
* ❌ **No paid third-party add-ons required**: Uses standard MATLAB and built-in Windows PowerShell for fallback data downloading.
