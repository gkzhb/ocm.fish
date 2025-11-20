# Agent Guidelines for ocm.fish

## Project Overview
Fish shell plugin for managing opencode configurations (similar to nvm for Node.js versions).

## Commands
- **Install**: `fisher install gkzhb/ocm.fish`
- **Test**: Manual testing - no automated test framework detected
- **Lint**: No linting tools configured - follow Fish shell best practices

## Code Style Guidelines

### Directory Structure

- **conf.d/**: Configuration files loaded at shell startup - 包含副作用操作（目录创建、变量初始化）和变量复制（通用变量→全局变量）
- **functions/**: Fish shell functions for ocm commands - 仅包含函数定义，避免副作用操作
- **completions/**: Auto-completion scripts for ocm commands

### Fish Shell Conventions
- Use `set --local` for local variables
- Use `test` for conditionals instead of `[ ]`
- Use `command` prefix for external commands (e.g., `command mkdir`)
- Functions prefixed with `_ocm_` are internal helpers
- Error messages to stderr: `echo "error" >&2`
- Return 1 for errors, 0 for success

### Naming Conventions
- Function names: lowercase with underscores (`_ocm_list_configs`)
- Variables: lowercase with underscores (`config_file`)
- Constants: uppercase (`OPENCODE_CONFIG`)

### Error Handling
- Always validate required arguments
- Provide descriptive error messages
- Use confirmation prompts for destructive operations
- Check file existence before operations

### Configuration Management
- Configs stored in `~/.config/opencode/settings/`
- Default config: `~/.config/opencode/opencode.jsonc`
- Backups in `~/.config/opencode/backups/`
- Use `.jsonc` extension for JSON with comments
