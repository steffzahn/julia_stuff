# AGENTS.md — julia_stuff

## Structure
Flat collection of Julia scripts (not a Julia package). No `Project.toml` or `Manifest.toml`. Just `julia <file>.jl` to run anything.

## Key files
- `exper.jl` — main fractal renderer: Quaternion type, palette system, `myimage()`/`mydraw()` functions, video sequence generation, and a CLI preview mode
- `startJupyter.jl` / `startPluto.jl` — launch those notebook environments
- `notes` — log of parameter combos + iteration formulas that produced specific fractal images; also contains ffmpeg commands for encoding frame sequences to video

## CLI entrypoint (exper.jl)
```
julia exper.jl preview [size] [additionalParameter] [additionalParameter2]
```
Defaults: size=1000, addParam=0.0, addParam2=0.0. Writes `fractal_preview.png`.

## Pluto notebooks
Files starting with `### A Pluto.jl notebook ###` are Pluto notebooks, not plain scripts. Open in Pluto, not `julia file.jl`. Examples: `h0.jl`, `lecture1.jl`, `transforming_images.jl`, `dataframes.jl`, `fun.jl`, `empty.jl`, `slow.jl`.

## Video rendering
Frame sequences use `myvideosequence()` in `exper.jl`. Encode with:
```
ffmpeg -i xx_%d.png -c:v libx264 -b:v 6000k -pass 1 -vf scale=600:600 -b:a 128k output.mp4
ffmpeg -i xx_%d.png -c:v libx264 -b:v 6000k -pass 2 -vf scale=600:600 -b:a 128k output.mp4
```
WebM variant: use `libvpx-vp9` / `libopus`.

## Git
Tags used to mark parameter states that produced specific fractal images (e.g., `swirl`, `bird`, `butterfly`). Check `git tag` for named renders.

## No tests, no CI, no build tools
Plain Julia scripts — no test suite, no linting, no CI.
