# Setup: R, RStudio, Git and GitHub (about 30 minutes, done once)

## 1. Install the tools
1. **R:** https://cran.r-project.org (choose your OS).
2. **RStudio Desktop:** https://posit.co/download/rstudio-desktop/
3. **Git:**
   - Windows: https://git-scm.com/download/win (accept the defaults).
   - Mac: in Terminal, run `xcode-select --install`.
4. **GitHub account:** https://github.com. Pick a professional username, since it goes on your CV.

## 2. Tell Git who you are (once)
In RStudio's **Console**:
```r
install.packages(c("usethis", "gitcreds"))
usethis::use_git_config(user.name = "Your Name", user.email = "email-you-used-on-github@example.com")
```

## 3. Let RStudio talk to GitHub (a personal access token)
```r
usethis::create_github_token()   # opens GitHub; keep the default scopes, set an expiry, click Generate
gitcreds::gitcreds_set()          # paste the token when asked
```
Restart RStudio after this step.

## 4. Open the project and turn it into a Git repo
1. Unzip `airbnb-poster` somewhere sensible (for example `Documents/projects/`).
2. Double-click `airbnb-poster.Rproj` to open it in RStudio.
3. In the Console:
```r
usethis::use_git()      # say yes to commit, then yes to restart
usethis::use_github()   # creates the GitHub repo and pushes your first commit
```
A browser tab opens on your new repository. Done.

## 5. Day-to-day workflow
After a working session, open the **Git** tab (top right in RStudio):
1. Tick the files you changed (**Stage**).
2. Click **Commit**, write a short message such as "Fit full model and LRT", then click **Commit**.
3. Click **Push** (the green up arrow).

Commit small and often. A history of real commits also shows that the work is yours.

## 6. Before you put it on your portfolio
- Fill in the TODO sections of `README.md`, with 1-2 figures and the key finding.
- Add the poster as a PDF in `output/` and link it from the README.
- Pin the repo on your GitHub profile (Profile → Customize your pins).
- Optional: add `LICENSE` with `usethis::use_mit_license()` (this covers your code; the data stays CC BY 4.0, credited to Inside Airbnb).
