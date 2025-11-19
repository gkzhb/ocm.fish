# Opencode Configuration Manager (ocm)

- [中文文档](./README.zh.md)

`ocm` is a command-line tool for managing opencode configuration files, similar to how nvm manages Node.js versions.

## Features

- List all available configurations
- Switch between configurations
- Create new configurations
- Edit existing configurations
- Delete configurations
- Copy configurations
- Backup and restore configurations

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```bash
fisher install gkzhb/ocm.fish
```

## Usage

### Basic Commands

```bash
# List all available configurations
ocm list

# Show current configuration
ocm current

# Switch to specified configuration
ocm use dev-plugin

# Create new configuration
ocm create myconfig

# Edit configuration
ocm edit myconfig

# Delete configuration
ocm delete myconfig

# Copy configuration
ocm copy source-config dest-config

# Backup current configuration
ocm backup

# Restore from backup
ocm restore backup_20251120_005705
```

### Environment Variables

- `OPENCODE_CONFIG`: Specify the configuration file path to use (supports both `.json` and `.jsonc` formats)

```bash
# Use custom configuration file
OPENCODE_CONFIG=~/myconfig.jsonc opencode
OPENCODE_CONFIG=~/myconfig.json opencode

# Or set environment variable first
export OPENCODE_CONFIG=~/myconfig.jsonc
opencode
```

## Configuration Structure

Configuration files are stored in the following locations:

- Default configuration: `~/.config/opencode/opencode.jsonc` or `~/.config/opencode/opencode.json`
- Other configurations: `~/.config/opencode/settings/<name>.jsonc` or `~/.config/opencode/settings/<name>.json`
- Backup files: `~/.config/opencode/backups/backup_<timestamp>.jsonc` or `~/.config/opencode/backups/backup_<timestamp>.json`

**Note:** Both `.json` and `.jsonc` (JSON with comments) formats are supported.

## Configuration Example

Basic configuration file structure:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [],
  "provider": {},
  "permission": {
    "edit": "ask",
    "bash": "ask"
  },
  "instructions": [],
  "mcp": {},
  "share": "disabled",
  "autoupdate": false
}
```

## Notes

1. Confirmation prompt when deleting configurations
2. Default configuration (`default`) cannot be deleted
3. Configuration switching is achieved by setting the `OPENCODE_CONFIG` environment variable
4. Backup files are automatically created in the `~/.config/opencode/backups/` directory
5. Both `.json` and `.jsonc` (JSON with comments) formats are supported for all configuration files

## Comparison with nvm

| nvm | ocm |
|-----|-----|
| `nvm list` | `ocm list` |
| `nvm use <version>` | `ocm use <config>` |
| `nvm current` | `ocm current` |
| `nvm install <version>` | `ocm create <config>` |
| Manages Node.js versions | Manages opencode configurations |
