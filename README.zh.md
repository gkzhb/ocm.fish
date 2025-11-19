# Opencode Configuration Manager (ocm)

`ocm` 是一个用于管理 opencode 配置文件的命令行工具，类似于 nvm 管理 Node.js 版本的方式。

## 功能

- 列出所有可用配置
- 切换当前使用的配置
- 创建新配置
- 编辑现有配置
- 删除配置
- 复制配置
- 备份和恢复配置

## 安装

使用 [Fisher](https://github.com/jorgebucaran/fisher) 安装：

```bash
fisher install gkzhb/ocm.fish
```

## 使用方法

### 基本命令

```bash
# 列出所有可用配置
ocm list

# 显示当前配置
ocm current

# 切换到指定配置
ocm use dev-plugin

# 创建新配置
ocm create myconfig

# 编辑配置
ocm edit myconfig

# 删除配置
ocm delete myconfig

# 复制配置
ocm copy source-config dest-config

# 备份当前配置
ocm backup

# 从备份恢复
ocm restore backup_20251120_005705
```

### 环境变量

- `OPENCODE_CONFIG`: 指定要使用的配置文件路径 (支持 `.json` 和 `.jsonc` 两种格式)

```bash
# 使用自定义配置文件
OPENCODE_CONFIG=~/myconfig.jsonc opencode
OPENCODE_CONFIG=~/myconfig.json opencode

# 或者先设置环境变量
export OPENCODE_CONFIG=~/myconfig.jsonc
opencode
```

## 配置结构

配置文件存储在以下位置：

- 默认配置：`~/.config/opencode/opencode.jsonc` 或 `~/.config/opencode/opencode.json`
- 其他配置：`~/.config/opencode/settings/<name>.jsonc` 或 `~/.config/opencode/settings/<name>.json`
- 备份文件：`~/.config/opencode/backups/backup_<timestamp>.jsonc` 或 `~/.config/opencode/backups/backup_<timestamp>.json`

**注意：** 同时支持 `.json` 和 `.jsonc` (支持注释的JSON) 两种格式。

## 配置示例

基本的配置文件结构：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [],
  "provider": {},
  "permission": {
    "edit": "ask",
    "bash": "ask",
  },
  "instructions": [],
  "mcp": {},
  "share": "disabled",
  "autoupdate": false,
}
```

## 注意事项

1. 删除配置时会有确认提示
2. 默认配置 (`default`) 不能被删除
3. 配置切换通过设置 `OPENCODE_CONFIG` 环境变量实现
4. 备份文件会自动创建在 `~/.config/opencode/backups/` 目录
5. 所有配置文件都支持 `.json` 和 `.jsonc` (支持注释的JSON) 两种格式

## 与 nvm 的对比

| nvm                     | ocm                   |
| ----------------------- | --------------------- |
| `nvm list`              | `ocm list`            |
| `nvm use <version>`     | `ocm use <config>`    |
| `nvm current`           | `ocm current`         |
| `nvm install <version>` | `ocm create <config>` |
| 管理 Node.js 版本       | 管理 opencode 配置    |

