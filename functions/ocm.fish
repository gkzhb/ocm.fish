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

    # Default config directory
    set --local default_config_dir ~/.config/opencode
    set --local settings_dir $default_config_dir/settings

    # Ensure directories exist
    if ! test -d $default_config_dir
        command mkdir -p $default_config_dir
    end
    if ! test -d $settings_dir
        command mkdir -p $settings_dir
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

function _ocm_find_config_file --argument-names config_name settings_dir
    # Try .jsonc first, then .json
    if test -f $settings_dir/$config_name.jsonc
        echo $settings_dir/$config_name.jsonc
    else if test -f $settings_dir/$config_name.json
        echo $settings_dir/$config_name.json
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
    set --local default_config_dir ~/.config/opencode
    set --local settings_dir $default_config_dir/settings
    set --local current_config $OPENCODE_CONFIG

    # Show current config first
    if set --query current_config[1]
        echo "Current: $current_config"
    else if test -f $default_config_dir/opencode.jsonc
        echo "Current: $default_config_dir/opencode.jsonc (default)"
    else if test -f $default_config_dir/opencode.json
        echo "Current: $default_config_dir/opencode.json (default)"
    end
    echo ""

    # List all configs in settings directory
    echo "Available configurations:"
    if test -d $settings_dir
        # Find all .json and .jsonc files
        for config in $settings_dir/*.json $settings_dir/*.jsonc
            if test -f $config
                set --local basename (_ocm_get_config_basename $config)
                echo "  $basename"
            end
        end
    end

    # Also show default config if it exists
    if test -f $default_config_dir/opencode.jsonc
        echo "  default (opencode.jsonc)"
    else if test -f $default_config_dir/opencode.json
        echo "  default (opencode.json)"
    end
end

function _ocm_current_config
    if set --query OPENCODE_CONFIG[1]
        echo $OPENCODE_CONFIG
    else if test -f ~/.config/opencode/opencode.jsonc
        echo ~/.config/opencode/opencode.jsonc
    else
        echo "No configuration found"
        return 1
    end
end

function _ocm_use_config --argument-names config_name
    set --local default_config_dir ~/.config/opencode
    set --local settings_dir $default_config_dir/settings
    set --local config_file

    # Determine config file path
    if test $config_name = "default"
        if test -f $default_config_dir/opencode.jsonc
            set config_file $default_config_dir/opencode.jsonc
        else if test -f $default_config_dir/opencode.json
            set config_file $default_config_dir/opencode.json
        else
            echo "ocm: Default configuration not found" >&2
            return 1
        end
    else
        set config_file (_ocm_find_config_file $config_name $settings_dir)
        if test -z "$config_file"
            echo "ocm: Configuration \"$config_name\" not found" >&2
            return 1
        end
    end

    # Check if config file exists
    if ! test -f $config_file
        echo "ocm: Configuration file not found: $config_file" >&2
        return 1
    end

    # Validate JSONC format (basic check)
    # Skip validation for now as JSONC may contain comments that node doesn't handle
    # if ! command node -e "try { require('$config_file') } catch(e) { process.exit(1) }" 2>/dev/null
    #     echo "ocm: Invalid JSON format in configuration file" >&2
    #     return 1
    # end

    # Set environment variable
    set -gx OPENCODE_CONFIG $config_file
    echo "Now using configuration: $config_name ($config_file)"
end

function _ocm_create_config --argument-names config_name
    set --local settings_dir ~/.config/opencode/settings
    set --local config_file $settings_dir/$config_name.jsonc

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
    set --local default_config_dir ~/.config/opencode
    set --local settings_dir $default_config_dir/settings
    set --local config_file

    # Determine config file path
    if test $config_name = "default"
        if test -f $default_config_dir/opencode.jsonc
            set config_file $default_config_dir/opencode.jsonc
        else if test -f $default_config_dir/opencode.json
            set config_file $default_config_dir/opencode.json
        else
            echo "ocm: Default configuration not found" >&2
            return 1
        end
    else
        set config_file (_ocm_find_config_file $config_name $settings_dir)
        if test -z "$config_file"
            echo "ocm: Configuration \"$config_name\" not found" >&2
            return 1
        end
    end

    # Use editor from environment or fallback
    set -q EDITOR; or set -l EDITOR nano
    command $EDITOR $config_file
end

function _ocm_delete_config --argument-names config_name
    set --local settings_dir ~/.config/opencode/settings
    set --local config_file (_ocm_find_config_file $config_name $settings_dir)

    # Prevent deletion of default config
    if test $config_name = "default"
        echo "ocm: Cannot delete default configuration" >&2
        return 1
    end

    # Check if config exists
    if test -z "$config_file"
        echo "ocm: Configuration \"$config_name\" not found" >&2
        return 1
    end

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
    set --local settings_dir ~/.config/opencode/settings
    set --local source_file
    set --local dest_file $settings_dir/$dest_name.jsonc

    # Determine source file path
    if test $source_name = "default"
        if test -f ~/.config/opencode/opencode.jsonc
            set source_file ~/.config/opencode/opencode.jsonc
        else if test -f ~/.config/opencode/opencode.json
            set source_file ~/.config/opencode/opencode.json
        else
            echo "ocm: Default configuration not found" >&2
            return 1
        end
    else
        set source_file (_ocm_find_config_file $source_name $settings_dir)
        if test -z "$source_file"
            echo "ocm: Source configuration \"$source_name\" not found" >&2
            return 1
        end
    end

    # Check if destination already exists
    if test -f $dest_file
        echo "ocm: Destination configuration \"$dest_name\" already exists" >&2
        return 1
    end

    command cp $source_file $dest_file
    echo "Copied configuration: $source_name -> $dest_name"
end

function _ocm_backup_config
    set --local default_config_dir ~/.config/opencode
    set --local backup_dir $default_config_dir/backups
    set --local timestamp (date +%Y%m%d_%H%M%S)
    set --local backup_name "backup_$timestamp"
    set --local backup_file $backup_dir/$backup_name.jsonc

    # Ensure backup directory exists
    if ! test -d $backup_dir
        command mkdir -p $backup_dir
    end

    # Determine current config file
    set --local config_file
    if set --query OPENCODE_CONFIG[1]
        set config_file $OPENCODE_CONFIG
    else if test -f $default_config_dir/opencode.jsonc
        set config_file $default_config_dir/opencode.jsonc
    else if test -f $default_config_dir/opencode.json
        set config_file $default_config_dir/opencode.json
    else
        echo "ocm: No configuration found to backup" >&2
        return 1
    end

    command cp $config_file $backup_file
    echo "Backed up configuration to: $backup_name"
end

function _ocm_restore_config --argument-names backup_name
    set --local default_config_dir ~/.config/opencode
    set --local backup_dir $default_config_dir/backups
    set --local backup_file $backup_dir/$backup_name.jsonc

    # Check if backup exists
    if ! test -f $backup_file
        echo "ocm: Backup \"$backup_name\" not found" >&2
        echo "Available backups:"
        if test -d $backup_dir
            for backup in $backup_dir/*.json $backup_dir/*.jsonc
                if test -f $backup
                    _ocm_get_config_basename $backup
                end
            end
        end
        return 1
    end

    # Determine current config file
    set --local config_file
    if test -f $default_config_dir/opencode.jsonc
        set config_file $default_config_dir/opencode.jsonc
    else if test -f $default_config_dir/opencode.json
        set config_file $default_config_dir/opencode.json
    else
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