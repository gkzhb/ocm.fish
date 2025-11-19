# Agent Guidelines for ocm.fish

## Project Overview
Fish shell plugin for managing opencode configurations (similar to nvm for Node.js versions).

## Commands
- **Install**: `fisher install gkzhb/ocm.fish`
- **Test**: Manual testing - no automated test framework detected
- **Lint**: No linting tools configured - follow Fish shell best practices

## Code Style Guidelines

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