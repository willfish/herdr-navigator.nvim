<div align="center">

# herdr-navigator.nvim

**Seamless navigation between Neovim windows and Herdr panes.**

![Neovim](https://img.shields.io/badge/Neovim-plugin-57a143?style=for-the-badge&logo=neovim&logoColor=white)
![Herdr](https://img.shields.io/badge/herdr-navigation-2f81f7?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.1-000080?style=for-the-badge&logo=lua&logoColor=white)
![Nix](https://img.shields.io/badge/Nix-dev_shell-5277c3?style=for-the-badge&logo=nixos&logoColor=white)

`Alt+h/j/k/l` -> move inside Neovim -> fall back to the adjacent Herdr pane.

</div>

---

## Why This Exists

`vim-tmux-navigator` makes tmux and Vim splits feel like a single window graph.
Herdr needs the same loop: use the normal Vim window movement first, and only ask
Herdr to focus a neighbouring pane when Neovim is already at an edge.

`herdr-navigator.nvim` is the Neovim half of that integration. Pair it with the
Herdr-side `herdr-navigator` plugin so non-Neovim panes can forward navigation
keys into Neovim when needed.

## Features

| Capability | What it does |
| --- | --- |
| Window-first navigation | Runs `wincmd h/j/k/l` and stops when Neovim moved windows. |
| Herdr edge fallback | Calls `herdr pane focus --direction ...` at Neovim window edges. |
| Pane-aware focus | Uses `$HERDR_PANE_ID` when available, or Herdr's current pane fallback. |
| Terminal mode mappings | Leaves terminal mode before applying the same navigation behavior. |
| Lazy setup | Only installs default mappings when a Herdr environment marker is present. |

## Install

Use your preferred Neovim plugin manager:

```lua
{
  "willfish/herdr-navigator.nvim",
  config = function()
    require("herdr-navigator").setup()
  end,
}
```

The default mappings are:

```text
<M-h> -> left
<M-j> -> down
<M-k> -> up
<M-l> -> right
```

Outside Herdr, no mappings are installed by default. Keep using
`vim-tmux-navigator` for tmux sessions.

## Configuration

```lua
require("herdr-navigator").setup({
  mappings = {
    left = "<M-h>",
    down = "<M-j>",
    up = "<M-k>",
    right = "<M-l>",
  },
  herdr_executable = "herdr",
})
```

## Herdr Binding

In Herdr, bind the same keys to the Herdr-side navigator:

```toml
[[keys.command]]
key = "alt+h"
type = "plugin_action"
command = "willfish.herdr-navigator.left"
```

Repeat for `down alt+j`, `up alt+k`, and `right alt+l`.

## Development

This repository ships a Nix dev shell and a single check script:

```bash
direnv allow
scripts/check
```

`scripts/check` runs:

- headless Neovim tests
- `luacheck` when available
- `stylua --check` when available
- `shellcheck`
- `bash -n`

The test suite stubs Herdr calls and does not mutate a real Herdr session.
