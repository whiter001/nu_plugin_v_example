# nu_plugin_v_example

<div align="center">

![V](https://img.shields.io/badge/V-0175C2?style=for-the-badge&logo=v&logoColor=white)
![Nushell](https://img.shields.io/badge/Nushell-4E9A06?style=for-the-badge&logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![V Version](https://img.shields.io/badge/V->=0.4.0-0175C2)

</div>

> 一个展示如何使用 **V 语言** 编写 [nushell](https://www.nushell.sh/) 插件的最小示例。

本项目与官方 [Node.js 插件示例](https://github.com/nushell/plugin-examples/blob/main/javascript/nu_plugin_node_example/nu_plugin_node_example.js)功能等价，只是语言栈换成了 V。

---

## ⚡ 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/your-repo/nu_plugin_v_example.git
cd nu_plugin_v_example

# 2. 编译插件
v -prod nu_plugin_v_example.v

# 3. 在 Nushell 中注册
plugin add ./nu_plugin_v_example
plugin use nu_plugin_v_example

# 4. 运行！
v_example 1 "test"
```

---

## 目录

1. [功能亮点](#功能亮点)
2. [先决条件](#先决条件)
3. [构建 & 安装](#构建--安装)
4. [基本用法](#基本用法)
5. [测试](#测试)
6. [开发与调试](#开发与调试)
7. [插件协议](#插件协议)
8. [与 Node.js 示例对比](#与-nodejs-示例对比)
9. [项目结构](#项目结构)
10. [许可证](#许可证)

---

## 功能亮点

- 实现 nushell 插件协议（Hello/Signature/Metadata/Run/Goodbye）
- 注册命令 `v_example`
  - **位置参数**：`a` (int), `b` (string)
  - **可选参数**：`opt` (int)
  - **可变参数**：`rest ...` (string)
  - **命名参数**：`--flag`/`-f`, `--named`/`-n`, `--help`/`-h`
- 返回一个含 10 行的表格，列名为 `one`、`two`、`three`

## 先决条件

- [V 语言](https://vlang.io/) 已安装并在 `$PATH` 中
- [Nushell](https://www.nushell.sh/) 版本 **0.89 或更高**，支持插件机制

## 构建 & 安装

### 1. 编译使用

```bash
v -prod nu_plugin_v_example.v
```

然后在 Nushell 内执行：

```nushell
plugin add ./nu_plugin_v_example   # 本地二进制
plugin use nu_plugin_v_example
```

### 2. 运行时编译（无需手动编译）

```nushell
plugin add -s 'v' 'run' nu_plugin_v_example.v
plugin use nu_plugin_v_example
```

这种方式适合快速迭代或在 CI 中测试。

## 基本用法

注册插件后即可调用：

```nushell
# 简单调用
v_example 42 "hello"

# 带可选参数
v_example 10 "test" 5

# 使用可变参数
v_example 7 "demo" 3 a b c

# 包含命名参数
v_example 100 "flags" --flag --named "custom_value"
```

示例输出：

```
╭───┬─────┬─────┬───────╮
│ # │ one │ two │ three │
├───┼─────┼─────┼───────┤
│ 0 │  0  │  0  │   0   │
│ 1 │  1  │  2  │   3   │
│ … │ …   │ …   │ …     │
│ 9 │  9  │ 18  │  27   │
╰───┴─────┴─────┴───────╯
```

## 测试

### 运行全部测试

```bash
# Bash 测试套件（推荐）
./test.sh

# 或在 Nushell 中运行
nu run_tests.nu
```

### 测试覆盖范围

| 测试用例  | 描述                            |
| --------- | ------------------------------- |
| 帮助信息  | 无 `--stdio` 参数时显示使用说明 |
| Hello     | 插件握手协议                    |
| Signature | 命令签名解析                    |
| 必需参数  | 位置参数验证                    |
| 可选参数  | 可选参数处理                    |
| 命名参数  | Flag 参数处理                   |
| Metadata  | 元数据查询                      |
| Run       | 命令执行                        |
| 数据行数  | 返回 10 行数据验证              |
| 列值计算  | 数学逻辑验证                    |
| Goodbye   | 正常关闭连接                    |

### 交互式测试

```nushell
# 交互式调试
nu run_tests_interactive.nu
```

## 开发与调试

直接运行源码进入调试模式：

```bash
v run nu_plugin_v_example.v --stdio
```

> 这样可以在不编译的情况下快速修改代码并观察输出。

## 插件协议

插件与 Nushell 通过 **stdin/stdout** 进行通信，所有消息使用 JSON 格式，以 `\x04json\n`（EOT 字符 + "json\n"）为前缀。

### 消息流程

```
Nushell                    插件
   │                         │
   │◄──── Hello ─────────────│  插件发送握手信息
   │──── Signature ─────────►│  查询命令签名
   │◄──── Metadata ──────────│  返回元数据
   │──── Run ───────────────►│  执行命令
   │◄──── Response ──────────│  返回结果
   │                         │
   │──── Goodbye ───────────►│  关闭连接
```

### 消息类型

| 方法        | 方向           | 说明                         |
| ----------- | -------------- | ---------------------------- |
| `hello`     | Nushell → 插件 | 插件启动时发送，包含协议版本 |
| `signature` | Nushell → 插件 | 查询插件提供的命令签名       |
| `metadata`  | Nushell → 插件 | 获取插件元信息               |
| `run`       | Nushell → 插件 | 执行具体命令，携带参数       |
| `response`  | 插件 → Nushell | 返回执行结果（表格、错误等） |
| `goodbye`   | Nushell → 插件 | 正常关闭连接                 |

### 示例：Hello 消息

请求：

```json
{ "method": "hello", "params": {} }
```

响应：

```json
{ "protocol": "nu-plugin", "version": "0.89.0" }
```

### 示例：Signature 响应

```json
{
  "name": "v_example",
  "description": "A V language plugin example",
  "parameters": [
    { "name": "a", "desc": "First required argument", "required": true, "shape": { "Int": null } },
    {
      "name": "b",
      "desc": "Second required argument",
      "required": true,
      "shape": { "String": null }
    },
    { "name": "opt", "desc": "Optional argument", "required": false, "shape": { "Int": null } },
    {
      "name": "rest",
      "desc": "Remaining positional arguments",
      "required": false,
      "shape": { "List": ["String"] }
    }
  ],
  "flags": [
    { "name": "flag", "short": "f", "desc": "A flag", "arg": false },
    {
      "name": "named",
      "short": "n",
      "desc": "A named argument",
      "arg": true,
      "shape": { "String": null }
    }
  ]
}
```

## 与 Node.js 示例对比

| 特性     | Node.js          | V                              |
| -------- | ---------------- | ------------------------------ |
| 命令名   | `node_example`   | `v_example`                    |
| 运行方式 | `node script.js` | `v run script.v` 或 编译后执行 |
| 输入读取 | stdin + readline | C.read() 系统调用              |
| 输出写入 | `stdout.write`   | `os.stdout().write_string()`   |
| 行数     | 10               | 10                             |
| 计算逻辑 | i*1, i*2, i\*3   | i*1, i*2, i\*3                 |

## 项目结构

```
nu_plugin_v_example/
├── nu_plugin_v_example.v          # 插件源代码（核心）
├── nu_plugin_v_example.exe        # Windows 编译产物
├── nu_plugin_v_example            # Linux/macOS 编译产物
│
├── test_nu_plugin_v_example.nu   # Nushell 测试脚本
├── test_protocol.nu               # 协议层测试
├── test_v_plugin.nu                # 插件功能测试
├── run_tests.nu                   # 自动化测试入口
├── run_tests_interactive.nu       # 交互式测试
│
├── test.sh                        # Bash 测试套件
│
├── README.md                      # 本文件
└── .gitignore                     # Git 忽略配置
```

## 常见问题

### Q: 插件加载失败怎么办？

```nushell
# 检查插件状态
plugin list

# 强制重新添加
plugin drop nu_plugin_v_example
plugin add ./nu_plugin_v_example
plugin use nu_plugin_v_example
```

### Q: 运行时编译方式如何使用？

如果你不想手动编译，可以直接告诉 Nushell 使用 V 运行时：

```nushell
# 添加时指定解释器
plugin add -s 'v' 'run' nu_plugin_v_example.v

# 或使用绝对路径
plugin add -s 'v' '/full/path/to/nu_plugin_v_example.v'
```

### Q: 如何查看插件返回的原始数据？

使用 `--stdio` 参数手动启动插件，观察 JSON 输出：

```bash
v run nu_plugin_v_example.v --stdio
```

然后手动输入测试 JSON：

```json
{ "method": "hello", "params": {} }
```

### Q: 编译时出现链接错误？

确保 V 编译器已正确安装：

```bash
v version
# 应该是 >= 0.4.0
```

---

## 许可证

本项目采用 **MIT 许可证**。详情见 [LICENSE](LICENSE) 文件。

---

<div align="center">

Made with ❤️ using [V](https://vlang.io/)

</div>
