# nvim-push

A Neovim plugin that automatically syncs files to a remote server via `rsync` on save.

## Requirements

- Neovim 0.8+
- [rsync](https://rsync.samba.org/) installed locally
- SSH access to the remote server

## Installation

### lazy.nvim

```lua
{
  "warmpool/nvim-push",
  ft = "*", -- or load on specific filetypes
  config = function()
    require("nvim-push").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "warmpool/nvim-push",
  config = function()
    require("nvim-push").setup()
  end,
}
```

## Usage

On first run, the plugin will prompt you to configure remote server details. The configuration can be saved to a `.nvim-push.json` file in your project root.

### Commands

| Command | Description |
|---------|-------------|
| `:Nvimpush` | Setup and sync the current file |
| `:Nvimpush setup` | Initialize/reconfigure the plugin |
| `:Nvimpush sync` | Manually sync the current file |
| `:Nvimpush showconfig` | Display current configuration |

### Auto-sync

Files are automatically synced via rsync whenever you save (`BufWritePost`).

### Lualine Integration

Add the push status to your lualine:

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      require("nvim-push").lualine_component(),
    },
  },
})
```

## Configuration

The plugin stores its config in `.nvim-push.json` at the project root:

```json
{
  "remote_host": "user@hostname",
  "remote_dir": "/path/to/remote/dir",
  "ssh_port": 22,
  "ssh_key": "",
  "rsync_flags": "-avp"
}
```

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `remote_host` | Yes | - | Remote host in `user@hostname` format |
| `remote_dir` | Yes | - | Remote directory path |
| `ssh_port` | No | `22` | SSH port |
| `ssh_key` | No | `""` | Path to SSH key file |
| `rsync_flags` | No | `-avp` | Additional rsync flags |

## Project Root Detection

The plugin finds the project root by looking for a git repository root, falling back to the current working directory.

## Log Files

Logs are written to `vim.fn.stdpath("data")/nvim-push.log`.
