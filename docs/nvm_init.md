# nvm.fish 默认 Node 版本初始化机制

## 概述
nvm.fish 在 fish shell 初始化时通过配置文件自动设置和读取默认 Node 版本，确保新 shell 会话中使用一致的 Node.js 环境。

## 初始化流程

### 1. 配置文件位置
- 主配置：`~/.config/fish/conf.d/nvm.fish`
- 变量设置：`~/.config/fish/conf.d/common.fish` 或其他配置文件

### 2. 关键代码段 (`conf.d/nvm.fish:26-28`)
```fish
if status is-interactive && set --query nvm_default_version && ! set --query nvm_current_version
    nvm use --silent $nvm_default_version
end
```

### 3. 执行条件
- `status is-interactive`: 仅在交互式 shell 中执行
- `set --query nvm_default_version`: 已设置默认版本变量
- `! set --query nvm_current_version`: 当前没有激活的版本

## 核心变量

| 变量名 | 作用 | 设置方式 |
|--------|------|----------|
| `nvm_default_version` | 默认 Node 版本 | `set -uU nvm_default_version 'v18'` |
| `nvm_current_version` | 当前激活版本 | 自动设置，全局变量 |
| `nvm_data` | Node 版本存储路径 | `$XDG_DATA_HOME/nvm` |
| `nvm_mirror` | 下载镜像地址 | 可自定义镜像源 |

## 版本激活机制

### 1. 版本激活函数 (`_nvm_version_activate.fish`)
```fish
function _nvm_version_activate --argument-names ver
    set --global --export nvm_current_version $ver
    set --prepend PATH $nvm_data/$ver/bin
end
```

### 2. 激活过程
1. 设置全局变量 `nvm_current_version`
2. 将对应版本的 bin 目录添加到 PATH 开头
3. 后续命令将使用新版本的 Node.js

### 3. 版本切换
- 安装新版本：`nvm install <version>`
- 切换版本：`nvm use <version>`
- 使用默认：`nvm use default`
- 使用系统：`nvm use system`

## 版本读取优先级

1. **显式指定版本**：`nvm use 18.17.0`
2. **项目配置文件**：`.nvmrc` 或 `.node-version`
3. **默认版本变量**：`nvm_default_version`
4. **系统版本**：`nvm use system`

## 配置示例

### 设置默认版本
```fish
# 在 ~/.config/fish/conf.d/common.fish 中
set -uU nvm_default_version 'v18'
```

### 使用国内镜像
```fish
set -uU nvm_mirror https://npmmirror.com/mirrors/node/
```

## 注意事项

1. **首次使用**：需要先安装对应版本 `nvm install <version>`
2. **版本缓存**：已安装版本存储在 `$nvm_data` 目录
3. **PATH 管理**：自动添加/移除版本路径，无需手动操作
4. **交互式限制**：仅在交互式 shell 中自动激活，避免影响脚本执行

通过这种机制，nvm.fish 实现了无缝的 Node.js 版本管理，确保开发环境的一致性。