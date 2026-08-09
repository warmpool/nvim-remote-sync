# nvim-remote-sync

A Neovim plugin that syncs local files to a remote server via `rsync`. Edit locally for a smooth, lag-free experience while keeping your remote project up to date.
Inspired by Atom's plugin.

## Why?

When working on remote machines, you may experience:
- **Network latency** — overseas hosts or unstable connections (e.g., on a train)
- **Slow UI rendering** — some HPC clusters throttle Neovim's terminal rendering

This plugin lets you edit code locally and push changes on save via `rsync`, giving you the best of both worlds: a fast local editor and a always-in-sync remote copy.

## Key Features

- **Auto-sync on save** — files are synced automatically via `BufWritePost` (toggleable, off by default)
- **Async transfers** — non-blocking rsync via `vim.uv.spawn()`, editor stays responsive
- **Interactive setup** — first-run wizard prompts for remote host, directory, SSH port, and key
- **Persistent config** — settings saved to `.remote-sync.json` at project root
- **Toggleable autocmd** — enable/disable auto-sync at any time with `:RemoteSync toggle`
- **Lualine integration** — display sync status (`off`, `ready`, `syncing..`, `synced`, `error`)
- **Logging** — dual output to `vim.notify` and a persistent log file

### Limitations
1. Similar environments are required on local and remote for LSP to work properly.
2. You get 2 copies of the same code here and there. Bad for version control but good for backup.

## Requirements

- Neovim 0.8+
- [rsync](https://rsync.samba.org/) installed locally
- SSH access to the remote server

## Installation

### lazy.nvim

```lua
{
  "warmpool/nvim-remote-sync",
  config = function()
    require("remote-sync")
  end,
}
```

### packer.nvim

```lua
use {
  "warmpool/nvim-remote-sync",
  config = function()
    require("remote-sync")
  end,
}
```

## Usage

The plugin provides the `:RemoteSync` command with several subcommands. On first run you will be prompted to configure remote server details. Configuration can be saved to a `.remote-sync.json` file in your project root.

### Commands

| Command | Description |
|---------|-------------|
| `:RemoteSync` | Full setup: configure, show config, enable auto-sync, and sync current file |
| `:RemoteSync setup` | Initialize or reconfigure the plugin |
| `:RemoteSync sync` | Manually sync the current file |
| `:RemoteSync showconfig` | Display current configuration |
| `:RemoteSync toggle` | Toggle auto-sync on save on/off |

### Auto-sync

Auto-sync on save is **off by default**. Enable it by running `:RemoteSync` (full setup) or `:RemoteSync toggle`. Run `:RemoteSync toggle` again to disable it.

While enabled, files are automatically synced via rsync whenever you save (`BufWritePost`).

### Status

The plugin tracks sync status which can be one of: `off`, `ready`, `syncing..`, `synced`, or `error`.

### Lualine Integration

Add the sync status to your lualine:

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      require("remote-sync").lualine_component(),
    },
  },
})
```

The status is displayed with an `rs:` prefix (e.g. `rs:ready`, `rs:synced`). You can customize the prefix by passing a string argument:

```lua
require("remote-sync").lualine_component("sync:")
```

## Configuration

The plugin stores its config in `.remote-sync.json` at the project root:

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

Logs are written to `vim.fn.stdpath("data")/remote-sync.log`.

## Related projects

- [amitds1997/remote-nvim.nvim](https://github.com/amitds1997/remote-nvim.nvim)
- [ayush-garg341/code_sync](https://github.com/ayush-garg341/code_sync)
- [chipsenkbeil/distant.nvim](https://github.com/chipsenkbeil/distant.nvim)
- [coffebar/transfer.nvim](https://github.com/coffebar/transfer.nvim)
- [inhesrom/remote-ssh.nvim](https://github.com/inhesrom/remote-ssh.nvim)
- [KenN7/vim-arsync](https://github.com/KenN7/vim-arsync)
- [OscarCreator/rsync.nvim](https://github.com/OscarCreator/rsync.nvim)
