# Feather Icons

A collection of beautifully crafted, open-source icons by Cole Bemis.

## Overview

| Property | Value |
|----------|-------|
| **Total Icons** | 287 |
| **Format** | PNG (48x48, white on transparent) |
| **Original Format** | SVG |
| **License** | MIT |
| **Author** | Cole Bemis |
| **GitHub** | [feathericons/feather](https://github.com/feathericons/feather) |
| **Website** | [feathericons.com](https://feathericons.com) |

## Features

- Simple and consistent 48x48 grid
- Stroke-based icons (outlines only)
- Clean, minimal design
- Perfect for interfaces and dashboards
- MIT licensed - free for commercial use

## How Astra ships this pack

- Data module: `icons/feather.luau` — 287 entries, `{ [name] =
  "assets/icons/feather-pack/<letter>/feather<Name>.png" }` (name → 48x48
  PNG path), lazy-loaded and cached by `icons/init.luau`.
- Look it up with `Astra.Icons.get("play", "feather")`,
  `Astra.Icons.getByPack("feather", "play")`, or pass `iconPack = "feather"`
  to `CreateWindow`/elements and use plain names via
  `window:ResolveIcon(name)`.
- At resolve time the repo-relative PNG path is mapped onto the repo's
  raw-GitHub base URL (or your executor's `getcustomasset` if provided), so
  no `rbxassetid` lookups are needed.

## Icon Categories

Feather icons cover these common categories:

| Category | Examples |
|----------|----------|
| **Arrows** | arrow-up, arrow-down, arrow-left, arrow-right, chevrons |
| **Actions** | check, x, plus, minus, edit, trash, search |
| **Media** | play, pause, skip, volume, music, camera |
| **Communication** | mail, message, phone, send, share |
| **Files** | file, folder, download, upload, clipboard |
| **UI** | menu, settings, home, user, eye, lock |
| **Social** | github, twitter, facebook, instagram |
| **Weather** | sun, moon, cloud, rain, wind, snowflake |

## License

MIT License - Copyright (c) 2013-2020 Cole Bemis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
