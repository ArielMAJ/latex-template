# LaTeX Article Template

A ready-to-use template for academic articles with local compilation via `latexmk` or Docker, automatic PDF generation on every push via GitHub Actions, and PR-based review workflow.

## Using this template

Click **"Use this template"** on GitHub to create a new repository from this template. Then:

1. Clone your new repo and rename things as needed
2. Edit `main.tex`. The PDF will be named after the **repository folder name** automatically
3. Add your bibliography entries to `references.bib`
4. Drop figures into the `figures/` folder and reference them with `\includegraphics{filename}`

## Project structure

```
.
├── main.tex              # Article entry point
├── references.bib        # BibTeX bibliography
├── figures/              # Images and plots
├── build/                # Generated auxiliary files (gitignored)
├── <repo-name>.pdf       # Compiled output (root, gitignored by default)
├── Makefile              # Local compilation commands
└── .github/
    └── workflows/
        └── compile.yml   # CI: compile & commit PDF on push
```

## Local compilation

You need either **latexmk** (from a local TeX distribution) or **Docker / Podman**. The Makefile auto-detects which is available.

### Option A: Local TeX (macOS)

```bash
brew install --cask basictex
# open a new terminal, then:
sudo tlmgr update --self
sudo tlmgr install latexmk collection-fontsrecommended
```

### Option B: Docker (no TeX installation needed)

```bash
make pull   # one-time: pulls texlive/texlive (~4 GB)
```

### Commands

```
make              # show this help
make build        # compile the PDF once
make watch        # recompile on every file save
make watch-logs   # follow watch output (Docker only)
make watch-stop   # stop the background watcher (Docker only)
make open         # open the compiled PDF
make clean        # remove auxiliary files (keeps PDF)
make pull         # pull/update the Docker image
```

## GitHub Actions workflow

On every push to any branch **except `main`**, the workflow:

1. Compiles `main.tex` using the full `texlive/texlive` Docker image
2. Commits the resulting PDF back to the same branch

This means every branch always has an up-to-date PDF that reviewers can download directly from GitHub without needing a local TeX installation.

### Branch strategy

| Branch      | Purpose                                                     |
| ----------- | ----------------------------------------------------------- |
| `main`      | Stable, only receives merges                                |
| `<feature>` | Writing, revisions, experiments (PDF auto-compiled on push) |

> **Important:** CI does not run on `main`, so the PDF is never recompiled there. This means the PDF committed to a branch always reflects exactly what will land on `main` after the merge, but only if the branch is **up-to-date with `main`** before merging. Always rebase or merge `main` into your branch and let CI recompile before requesting a review.

### Reviewing a draft

1. Rebase/merge `main` into your branch to ensure it is up-to-date
2. Push so CI recompiles the PDF with all latest changes included
3. Open a PR from your branch to `main`
4. Reviewer downloads the PDF directly from the branch
5. Feedback is left as PR comments
