# Set global variables (similar to nvm_mirror)
set --query OCM_DEFAULT_CONFIG_DIR || set --global --export OCM_DEFAULT_CONFIG_DIR ~/.config/opencode
set --query OCM_SETTINGS_DIR || set --global --export OCM_SETTINGS_DIR $OCM_DEFAULT_CONFIG_DIR/settings
set --query OCM_BACKUP_DIR || set --global --export OCM_BACKUP_DIR $OCM_DEFAULT_CONFIG_DIR/backups

# Ensure directories exist on plugin install
function _ocm_install --on-event ocm_install
    test ! -d $OCM_DEFAULT_CONFIG_DIR && command mkdir -p $OCM_DEFAULT_CONFIG_DIR
    test ! -d $OCM_SETTINGS_DIR && command mkdir -p $OCM_SETTINGS_DIR
    test ! -d $OCM_BACKUP_DIR && command mkdir -p $OCM_BACKUP_DIR
end

# Cleanup on plugin update
function _ocm_update --on-event ocm_update
    set --query --universal OCM_DEFAULT_CONFIG_DIR && set --erase --universal OCM_DEFAULT_CONFIG_DIR
    set --query --universal OCM_SETTINGS_DIR && set --erase --universal OCM_SETTINGS_DIR
    set --query --universal OCM_BACKUP_DIR && set --erase --universal OCM_BACKUP_DIR
    
    # Reset global variables
    set --query OCM_DEFAULT_CONFIG_DIR || set --global --export OCM_DEFAULT_CONFIG_DIR ~/.config/opencode
    set --query OCM_SETTINGS_DIR || set --global --export OCM_SETTINGS_DIR $OCM_DEFAULT_CONFIG_DIR/settings
    set --query OCM_BACKUP_DIR || set --global --export OCM_BACKUP_DIR $OCM_DEFAULT_CONFIG_DIR/backups
end

# Cleanup on plugin uninstall
function _ocm_uninstall --on-event ocm_uninstall
    # Clean up variables
    set --names | string replace --filter --regex -- "^OCM_" "set --erase" | source
    set --names | string replace --filter --regex -- "^ocm_" "set --erase" | source
    
    # Clean up functions
    functions --erase (functions --all | string match --entire --regex -- "^_ocm_")
    functions --erase ocm
end


# Auto-use config if set and no OPENCODE_CONFIG active (executed during conf.d loading)
if status is-interactive && ! set --query OPENCODE_CONFIG
    if set --query ocm_current_config
        ocm use --silent $ocm_current_config
    else if set --query ocm_default_config
        ocm use --silent $ocm_default_config
    end
end
