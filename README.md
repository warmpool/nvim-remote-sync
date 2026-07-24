# nvim-remote-sync

A Neovim plugin that automatically syncs files to a remote server via `rsync` on save.
The project is largely inspired by Atom's remote-sync plugin.

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
    require("remote-sync").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "warmpool/nvim-remote-sync",
  config = function()
    require("remote-sync").setup()
  end,
}
```

## Usage

Call `:RemoteSync` to start the plugin. On first run, you will be prompted to configure remote server details. The configuration can be saved to a `.remote-sync.json` file in your project root. The syncing status can be presented in lualine.

### Commands

| Command | Description |
|---------|-------------|
| `:RemoteSync` | Setup and sync the current file |
| `:RemoteSync setup` | Initialize/reconfigure the plugin |
| `:RemoteSync sync` | Manually sync the current file |
| `:RemoteSync showconfig` | Display current configuration |

### Auto-sync

Files are automatically synced via rsync whenever you save (`BufWritePost`).

### Status

The plugin tracks sync status which can be one of: `off`, `ready`, `syncing..`, `synced`, or `error`.

### Lualine Integration

Add the push status to your lualine:

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      require("remote-sync").lualine_component(),
    },
  },
})
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
- [coffebar/transfer.nvim](https://github.com/coffebar/transfer.nvim)
- [chipsenkbeil/distant.nvim](https://github.com/chipsenkbeil/distant.nvim)
- [inhesrom/remote-ssh.nvim](https://github.com/inhesrom/remote-ssh.nvim)
- [KenN7/vim-arsync](https://github.com/KenN7/vim-arsync)
- [OscarCreator/rsync.nvim](https://github.com/OscarCreator/rsync.nvim)
