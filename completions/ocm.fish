# Disable file completions for most commands
complete -c ocm -f

# Helper function to extract config names from files
function __ocm_get_config_names --description "Extract configuration names from config files"
    set -l settings_dir $OCM_SETTINGS_DIR
    set -l include_default $argv[1]
    
    # Return empty if settings directory doesn't exist
    if not test -d $settings_dir
        return
    end
    
    # Extract config names from all JSON files using unified approach
    for config_file in $settings_dir/*.json{,c}
        if test -f $config_file
            basename $config_file | string replace -r '\.jsonc?$' ''
        end
    end
    
    # Include default if requested
    if test "$include_default" = "include_default"
        echo default
    end
end

# Helper function to get backup names
function __ocm_get_backup_names --description "Extract backup names from backup files"
    set -l backup_dir $OCM_BACKUP_DIR
    
    # Return empty if backup directory doesn't exist
    if not test -d $backup_dir
        return
    end
    
    # Extract backup names from all JSON files using unified approach
    for backup_file in $backup_dir/*.json{,c}
        if test -f $backup_file
            basename $backup_file | string replace -r '\.jsonc?$' ''
        end
    end
end

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
complete -c ocm -n "__fish_seen_subcommand_from use" -a "(__ocm_get_config_names include_default)"

# Configuration name completion for edit command
complete -c ocm -n "__fish_seen_subcommand_from edit" -a "(__ocm_get_config_names include_default)"

# Configuration name completion for delete command (exclude default)
complete -c ocm -n "__fish_seen_subcommand_from delete" -a "(__ocm_get_config_names)"
complete -c ocm -n "__fish_seen_subcommand_from remove" -a "(__ocm_get_config_names)"
complete -c ocm -n "__fish_seen_subcommand_from rm" -a "(__ocm_get_config_names)"

# Source config completion for copy command (include default)
complete -c ocm -n "__fish_seen_subcommand_from copy" -a "(__ocm_get_config_names include_default)"
complete -c ocm -n "__fish_seen_subcommand_from cp" -a "(__ocm_get_config_names include_default)"

# Backup completion for restore command
complete -c ocm -n "__fish_seen_subcommand_from restore" -a "(__ocm_get_backup_names)"

# Global options
complete -c ocm -s s -l silent -d "Suppress standard output"
complete -c ocm -s v -l version -d "Print the version of ocm"
complete -c ocm -s h -l help -d "Print help message"