# Web build (GitHub Pages)

This folder is what GitHub Pages serves at:

**https://0tan.github.io/TadMucho/**

## One-time setup (do this once, in the browser)

1. Go to the repo on GitHub → **Settings** → **Pages**.
2. Under **Build and deployment → Source**, choose **Deploy from a branch**.
3. Set **Branch** to `main` and the folder to `/docs`, then **Save**.
4. Wait ~1 minute, then open https://0tan.github.io/TadMucho/ — you should see the placeholder page.

## Deploying a new build

1. In GameMaker, set the target platform to **HTML5**.
2. **Build → Create Executable** and export.
3. Copy the exported contents (the `index.html` and its asset folders) into this `docs/` folder,
   overwriting the placeholder `index.html`.
4. Keep the `.nojekyll` file here — it stops GitHub from stripping folders that start with `_`,
   which GameMaker's HTML5 output uses.
5. Commit and push:

   ```powershell
   git add -A
   git commit -m "Deploy HTML5 build"
   git push
   ```

6. The live URL updates within a minute or two.
