# Bachelor Thesis 

This repo is used to write and manage the materials for the bachelor thesis.


## Setup

To set up this LaTeX thesis project from scratch on a Mac, thw following steps are recommended:

1. **Install TeX Live**
   - **Why:** TeX Live is a comprehensive LaTeX distribution that includes all the tools needed to compile and manage `.tex` documents.
   - **How to install:**  
     ```
     brew install texlive
     ```

2. **Install the LaTeX Workshop extension for VS Code**
   - **Why:** This extension provides LaTeX syntax highlighting, build tools, PDF preview, autocompletion, and other productivity features.
   - **How to install:**  
     Open VS Code, go to the Extensions tab, and search for **LaTeX Workshop** by James Yu. Click "Install".

3. **Install `tex-fmt` for LaTeX formatting**
   - **Why:** `tex-fmt` is used by the project and by the VS Code extension to auto-format `.tex` code in a consistent style.
   - **How to install:**  
     ```
     brew install tex-fmt
     ```
   - In the `.vscode/setting.json`-file the formater get configured