# ocm config-dir 功能设计文档

## 概述

`ocm config-dir` 功能允许用户通过环境变量或命令行方式管理 opencode 的配置目录，支持自定义配置路径和快速切换不同的配置环境。

通过设置 OPENCODE_CONFIG_DIR 环境变量来修改 opencode 读取的配置目录：
```bash
export OPENCODE_CONFIG_DIR=/path/to/my/config-directory
opencode run "Hello world"
```

## 目录结构

### 统一配置目录结构
```
~/.config/opencode/
├── settings/              # 原有配置存储
├── backups/              # 原有备份存储
└── setting-dirs/         # 配置目录集合
    ├── default/          # 默认配置目录
    ├── work/            # 工作配置目录
    ├── personal/        # 个人配置目录
    └── project-a/       # 项目A配置目录
```

## CLI 命令设计

### 主命令和别名
```bash
ocm config-dir <subcommand>    # 完整命令
ocm cdir <subcommand>          # 别名，更简洁
```

### 子命令

| 子命令 | 描述 | 示例 |
|--------|------|------|
| `set <path>` | 设置自定义配置目录路径 | `ocm cdir set ~/my-config` |
| `show` | 显示当前配置目录 | `ocm cdir show` |
| `list` | 列出所有预置配置目录 | `ocm cdir list` |
| `init <name>` | 初始化新的预置配置目录 | `ocm cdir init work` |
| `use <name>` | 快速切换到预置目录 | `ocm cdir use work` |
| `reset` | 重置为默认配置目录 | `ocm cdir reset` |

## 使用场景

### 1. 环境变量方式
```bash
# 临时指定配置目录
export OPENCODE_CONFIG_DIR=/path/to/config
opencode run "Hello world"

# 命令前临时设置
OPENCODE_CONFIG_DIR=/path/to/config opencode run "Hello world"
```

### 2. 命令行方式
```bash
# 设置自定义配置目录
ocm cdir set ~/project-a/opencode-config

# 创建预置配置目录
ocm cdir init work
ocm cdir init personal

# 快速切换
ocm cdir use work
ocm cdir use personal

# 查看和管理
ocm cdir show
ocm cdir list
ocm cdir reset
```

## 实现逻辑

### 环境变量优先级
1. `OPENCODE_CONFIG_DIR` 环境变量（最高优先级）
2. 命令设置的自定义目录
3. 默认目录 `~/.config/opencode`（最低优先级）

### 配置目录初始化
当执行 `ocm cdir init <name>` 时：
1. 在 `~/.config/opencode/setting-dirs/<name>/` 创建目录
2. 创建标准的子目录结构：`agent/`, `command/` 和 `plugin/`
3. 创建默认配置文件 `opencode.jsonc` 内容只需要 `{  "$schema": "https://opencode.ai/config.json" }` 即可

### 快速切换机制
当执行 `ocm cdir use <name>` 时：
1. 检查预置目录是否存在
2. 设置 `OPENCODE_CONFIG_DIR` 环境变量
3. 更新当前会话的配置路径

## 兼容性考虑

1. **向后兼容**：现有功能不受影响
2. **配置共享**：不同目录间的配置可以复制和迁移
3. **路径解析**：支持相对路径和绝对路径
4. **错误处理**：提供清晰的错误提示和回退机制

## 用户交互流程

```bash
# 场景1：为新项目创建独立配置
ocm cdir init myproject
ocm cdir use myproject
ocm create dev-config
ocm use dev-config

# 场景2：在不同环境间切换
ocm cdir use work      # 切换到工作配置
# ... 工作相关操作 ...
ocm cdir use personal  # 切换到个人配置
# ... 个人项目操作 ...

# 场景3：临时使用自定义目录
ocm cdir set /tmp/test-config
# ... 临时操作 ...
ocm cdir reset           # 恢复默认
```

## 扩展功能（未来考虑）

1. **配置目录模板**：支持快速创建带预设配置的新目录
2. **配置同步**：在不同机器间同步配置目录
3. **配置备份**：批量备份多个配置目录
4. **图形化界面**：提供简单的目录管理界面
