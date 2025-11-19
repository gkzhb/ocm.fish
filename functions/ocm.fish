# Common variables
set --global --export OCM_DEFAULT_CONFIG_DIR ~/.config/opencode
set --global --export OCM_SETTINGS_DIR $OCM_DEFAULT_CONFIG_DIR/settings
set --global --export OCM_BACKUP_DIR $OCM_DEFAULT_CONFIG_DIR/backups

function ocm --description "Opencode configuration manager"
    # Parse silent flag
    for silent in --silent -s
        if set --local index (contains --index -- $silent $argv)
            set --erase argv[$index] && break
        end
        set --erase silent
    end

    set --local cmd $argv[1]
    set --local config_name $argv[2]

    # Ensure directories exist
    if ! test -d $OCM_DEFAULT_CONFIG_DIR
        command mkdir -p $OCM_DEFAULT_CONFIG_DIR
    end
    if ! test -d $OCM_SETTINGS_DIR
        command mkdir -p $OCM_SETTINGS_DIR
    end

    switch "$cmd"
        case -v --version
            echo "ocm, version 1.0.0"
        case "" -h --help
            echo "Usage: ocm list                          List all available configurations"
            echo "       ocm use <config>                  Switch to specified configuration"
            echo "       ocm current                       Show current active configuration"
            echo "       ocm create <config>               Create a new configuration"
            echo "       ocm edit <config>                 Edit specified configuration"
            echo "       ocm delete <config>               Delete specified configuration"
            echo "       ocm copy <source> <dest>          Copy configuration"
            echo "       ocm backup                        Backup current configuration"
            echo "       ocm restore <backup>              Restore from backup"
            echo "       ocm --version                     Print version of ocm"
            echo "       ocm --help                        Print this help message"
            echo ""
            echo "Environment Variables:"
            echo "       OPENCODE_CONFIG                   Override default config file path"
            echo ""
            echo "Examples:"
            echo "       ocm list                          # Show all configs"
            echo "       ocm use dev-plugin                # Switch to dev-plugin config"
            echo "       ocm create myconfig               # Create new config"
            echo "       ocm edit default                  # Edit default config"
            echo "       OPENCODE_CONFIG=~/myconfig.jsonc opencode  # Use custom config"

        case ls list
            _ocm_list_configs
        case current
            _ocm_current_config
        case use
            if ! set --query config_name[1]
                echo "ocm: Configuration name required" >&2
                return 1
            end
            _ocm_use_config $config_name
        case create
            if ! set --query config_name[1]
                echo "ocm: Configuration name required" >&2
                return 1
            end
            _ocm_create_config $config_name
        case edit
            if ! set --query config_name[1]
                echo "ocm: Configuration name required" >&2
                return 1
            end
            _ocm_edit_config $config_name
        case delete rm remove
            if ! set --query config_name[1]
                echo "ocm: Configuration name required" >&2
                return 1
            end
            _ocm_delete_config $config_name
        case copy cp
            if ! set --query argv[3]
                echo "ocm: Source and destination configuration names required" >&2
                return 1
            end
            _ocm_copy_config $config_name $argv[3]
        case backup
            _ocm_backup_config
        case restore
            if ! set --query config_name[1]
                echo "ocm: Backup name required" >&2
                return 1
            end
            _ocm_restore_config $config_name
        case \*
            echo "ocm: Unknown command or option: \"$cmd\" (see ocm --help for usage)" >&2
            return 1
    end
end

function _ocm_resolve_config_path --argument-names config_name
    # Resolve configuration file path for both default and named configs
    if test $config_name = "default"
        # Use unified helper for default config
        _ocm_find_json_file $OCM_DEFAULT_CONFIG_DIR/opencode
    else
        # For named configs, use the find function
        _ocm_find_config_file $config_name $OCM_SETTINGS_DIR
    end
end

function _ocm_get_current_config_path
    # Get the current active configuration path
    if set --query OPENCODE_CONFIG[1]
        echo $OPENCODE_CONFIG
    else
        # Use unified helper for default config
        _ocm_find_json_file $OCM_DEFAULT_CONFIG_DIR/opencode
    end
end

function _ocm_validate_config_exists --argument-names config_name
    # Validate that a configuration exists
    set --local config_path (_ocm_resolve_config_path $config_name)
    if test -z "$config_path"
        echo "ocm: Configuration \"$config_name\" not found" >&2
        return 1
    end
    return 0
end

function _ocm_find_config_file --argument-names config_name settings_dir
    # Use unified helper for named configs
    _ocm_find_json_file $settings_dir/$config_name
end

function _ocm_find_json_file --argument-names base_path
    # Try .jsonc first, then .json - returns empty string if neither exists
    if test -f $base_path.jsonc
        echo $base_path.jsonc
    else if test -f $base_path.json
        echo $base_path.json
    else
        echo ""
    end
end

function _ocm_get_config_basename --argument-names config_file
    # Remove both .json and .jsonc extensions
    set --local basename (basename $config_file)
    string replace -r '\.jsonc?$' '' $basename
end

function _ocm_list_configs
    set --local current_config $OPENCODE_CONFIG

    # Show current config first
    if set --query current_config[1]
        echo "Current: $current_config"
    else
        set --local default_config (_ocm_find_json_file $OCM_DEFAULT_CONFIG_DIR/opencode)
        if test -n "$default_config"
            echo "Current: $default_config (default)"
        end
    end
    echo ""

    # List all configs in settings directory
    echo "Available configurations:"
    if test -d $OCM_SETTINGS_DIR
        # Find all .json and .jsonc files
        for config in $OCM_SETTINGS_DIR/*.json $OCM_SETTINGS_DIR/*.jsonc
            if test -f $config
                set --local basename (_ocm_get_config_basename $config)
                echo "  $basename"
            end
        end
    end

    # Also show default config if it exists
    set --local default_config (_ocm_find_json_file $OCM_DEFAULT_CONFIG_DIR/opencode)
    if test -n "$default_config"
        set --local extension (string replace -r '.*\.' '' $default_config)
        echo "  default (opencode.$extension)"
    end
end

function _ocm_current_config
    set --local config_path (_ocm_get_current_config_path)
    if test -z "$config_path"
        echo "No configuration found"
        return 1
    end
    echo $config_path
end

function _ocm_use_config --argument-names config_name
    # Validate config exists
    if ! _ocm_validate_config_exists $config_name
        return 1
    end

    # Get config file path
    set --local config_file (_ocm_resolve_config_path $config_name)

    # Set environment variable
    set -gx OPENCODE_CONFIG $config_file
    echo "Now using configuration: $config_name ($config_file)"
end

function _ocm_create_config --argument-names config_name
    set --local config_file $OCM_SETTINGS_DIR/$config_name.jsonc

    # Check if config already exists
    if test -f $config_file
        echo "ocm: Configuration \"$config_name\" already exists" >&2
        return 1
    end

    # Create default config content
    echo '{
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
}' > $config_file

    echo "Created new configuration: $config_name"
    echo "Edit it with: ocm edit $config_name"
end

function _ocm_edit_config --argument-names config_name
    # Validate config exists
    if ! _ocm_validate_config_exists $config_name
        return 1
    end

    # Get config file path
    set --local config_file (_ocm_resolve_config_path $config_name)

    # Use editor from environment or fallback
    set -q EDITOR; or set -l EDITOR nano
    command $EDITOR $config_file
end

function _ocm_delete_config --argument-names config_name
    # Prevent deletion of default config
    if test $config_name = "default"
        echo "ocm: Cannot delete default configuration" >&2
        return 1
    end

    # Validate config exists (named configs only)
    if ! _ocm_validate_config_exists $config_name
        return 1
    end

    # Get config file path
    set --local config_file (_ocm_resolve_config_path $config_name)

    # Confirm deletion
    echo -n "Delete configuration \"$config_name\"? (y/N): "
    read -l confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Deletion cancelled"
        return 0
    end

    command rm $config_file
    echo "Deleted configuration: $config_name"
end

function _ocm_copy_config --argument-names source_name dest_name
    set --local dest_file $OCM_SETTINGS_DIR/$dest_name.jsonc

    # Validate source config exists
    if ! _ocm_validate_config_exists $source_name
        return 1
    end

    # Check if destination already exists
    if test -f $dest_file
        echo "ocm: Destination configuration \"$dest_name\" already exists" >&2
        return 1
    end

    # Get source file path and copy
    set --local source_file (_ocm_resolve_config_path $source_name)
    command cp $source_file $dest_file
    echo "Copied configuration: $source_name -> $dest_name"
end

function _ocm_backup_config
    set --local timestamp (date +%Y%m%d_%H%M%S)
    set --local backup_name "backup_$timestamp"
    set --local backup_file $OCM_BACKUP_DIR/$backup_name.jsonc

    # Ensure backup directory exists
    if ! test -d $OCM_BACKUP_DIR
        command mkdir -p $OCM_BACKUP_DIR
    end

    # Get current config file
    set --local config_file (_ocm_get_current_config_path)
    if test -z "$config_file"
        echo "ocm: No configuration found to backup" >&2
        return 1
    end

    command cp $config_file $backup_file
    echo "Backed up configuration to: $backup_name"
end

function _ocm_restore_config --argument-names backup_name
    set --local backup_file $OCM_BACKUP_DIR/$backup_name.jsonc

    # Check if backup exists
    if ! test -f $backup_file
        echo "ocm: Backup \"$backup_name\" not found" >&2
        echo "Available backups:"
        if test -d $OCM_BACKUP_DIR
            for backup in $OCM_BACKUP_DIR/*.json $OCM_BACKUP_DIR/*.jsonc
                if test -f $backup
                    _ocm_get_config_basename $backup
                end
            end
        end
        return 1
    end

    # Get current config file path
    set --local config_file (_ocm_get_current_config_path)
    if test -z "$config_file"
        echo "ocm: No default configuration found" >&2
        return 1
    end

    # Confirm restore
    echo -n "Restore backup \"$backup_name\" to current configuration? (y/N): "
    read -l confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Restore cancelled"
        return 0
    end

    command cp $backup_file $config_file
    echo "Restored configuration from: $backup_name"
end