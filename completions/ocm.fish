# Disable file completions for most commands
complete -c ocm -f

# Main commands
complete -c ocm -n "__fish_use_subcommand" -a "list" -d "List all available configurations"
complete -c ocm -n "__fish_use_subcommand" -a "ls" -d "List all available configurations"
complete -c ocm -n "__fish_use_subcommand" -a "current" -d "Show current active configuration"
complete -c ocm -n "__fish_use_subcommand" -a "use" -d "Switch to specified configuration"
complete -c ocm -n "__fish_use_subcommand" -a "create" -d "Create a new configuration"
complete -c ocm -n "__fish_use_subcommand" -a "edit" -d "Edit specified configuration"
complete -c ocm -n "__fish_use_subcommand" -a "delete" -d "Delete specified configuration"
complete -c ocm -n "__fish_use_subcommand" -a "copy" -d "Copy configuration"
complete -c ocm -n "__fish_use_subcommand" -a "backup" -d "Backup current configuration"
complete -c ocm -n "__fish_use_subcommand" -a "restore" -d "Restore from backup"

# Configuration name completion for use command
complete -c ocm -n "__fish_seen_subcommand_from use" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1'; echo default)"

# Configuration name completion for edit command
complete -c ocm -n "__fish_seen_subcommand_from edit" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1'; echo default)"

# Configuration name completion for delete command
complete -c ocm -n "__fish_seen_subcommand_from delete" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1')"
complete -c ocm -n "__fish_seen_subcommand_from remove" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1')"
complete -c ocm -n "__fish_seen_subcommand_from rm" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1')"

# Source config completion for copy command
complete -c ocm -n "__fish_seen_subcommand_from copy" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1'; echo default)"
complete -c ocm -n "__fish_seen_subcommand_from cp" -a "(ls ~/.config/opencode/settings/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1'; echo default)"

# Backup completion for restore command
complete -c ocm -n "__fish_seen_subcommand_from restore" -a "(ls ~/.config/opencode/backups/*.jsonc 2>/dev/null | string replace -r '.*/([^/]+)\.jsonc$' '$1')"

# Global options
complete -c ocm -s s -l silent -d "Suppress standard output"
complete -c ocm -s v -l version -d "Print the version of ocm"
complete -c ocm -s h -l help -d "Print help message"