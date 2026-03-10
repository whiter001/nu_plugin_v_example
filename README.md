# nu_plugin_v_example

一个使用 [V 语言](https://vlang.io/) 编写的 [nushell](https://www.nushell.sh/) 插件示例。

此插件等同于 [Node.js 示例](https://github.com/nushell/plugin-examples/blob/main/javascript/nu_plugin_node_example/nu_plugin_node_example.js)，但使用 V 语言实现。

## 功能

- 演示 V 语言实现 nushell 插件协议
- 注册 `v_example` 命令，包含：
  - 两个必需位置参数：`a` (int), `b` (string)
  - 一个可选位置参数：`opt` (int)
  - 可变参数：`rest` (string)
  - 命名参数：`--help`/`-h`, `--flag`/`-f`, `--named`/`-n`
- 返回一个 10 行表格，包含列 `one`, `two`, `three`

## 要求

- [V](https://vlang.io/) 已安装并在 PATH 中
- [Nushell](https://www.nushell.sh/) 0.89+ 支持插件的版本

## 构建与安装

### 方法 1：编译后使用

1. **编译插件**：
   ```bash
   v -prod nu_plugin_v_example.v
   ```

2. **在 nushell 中注册和使用插件**：
   ```nushell
   plugin add ./nu_plugin_v_example
   plugin use nu_plugin_v_example
   ```

### 方法 2：直接使用 v run（无需编译）

```nushell
plugin add -s 'v' 'run' nu_plugin_v_example.v
plugin use nu_plugin_v_example
```

## 使用方法

注册后，可以调用命令：

```nushell
# 基本用法
v_example 42 "hello"

# 带可选参数
v_example 10 "test" 5

# 带可变参数
v_example 7 "demo" 3 a b c

# 带命名参数
v_example 100 "flags" --flag --named "custom_value"
```

示例输出：

```
╭───┬─────┬─────┬───────╮
│ # │ one │ two │ three │
├───┼─────┼─────┼───────┤
│ 0 │  0  │  0  │   0   │
│ 1 │  1  │  2  │   3   │
│ 2 │  2  │  4  │   6   │
│ 3 │  3  │  6  │   9   │
│ 4 │  4  │  8  │  12   │
│ 5 │  5  │ 10  │  15   │
│ 6 │  6  │ 12  │  18   │
│ 7 │  7  │ 14  │  21   │
│ 8 │  8  │ 16  │  24   │
│ 9 │  9  │ 18  │  27   │
╰───┴─────┴─────┴───────╯
```

## 测试

### 运行 Bash 测试套件（推荐）

```bash
# 运行综合测试（11 个测试用例）
./test.sh
```

测试内容包括：
- 无 `--stdio` 参数时的使用说明
- Hello 握手消息
- Signature 命令签名
- 必需参数、可选参数、命名参数
- Metadata 元数据
- Run 命令执行
- 返回 10 行数据
- 列值计算验证
- Goodbye 处理

## 开发

### 直接运行（调试模式）

```bash
v run nu_plugin_v_example.v --stdio
```

### 项目结构

```
nu_plugin_v_example/
├── nu_plugin_v_example.v    # 主插件代码
├── test_nu_plugin_v_example.nu  # Nushell 测试脚本
├── test_plugin.nu           # 旧测试脚本（保留）
├── README.md                # 说明文档
└── nu_plugin_v_example      # 编译后的二进制文件
```

### 插件协议实现

插件使用以下协议与 nushell 通信：

1. **Hello** - 插件启动时发送握手消息
2. **Signature** - 返回命令签名（参数定义）
3. **Metadata** - 返回元数据
4. **Run** - 执行命令并返回结果
5. **Goodbye** - 结束通信

所有消息使用 JSON 格式，以 `\x04json\n` 为前缀。

## 与 Node.js 示例的对比

| 特性 | Node.js | V |
|------|---------|---|
| 命令名 | `node_example` | `v_example` |
| 运行方式 | `node script.js` | `v run script.v` 或编译后运行 |
| 输入读取 | stdin readline | C.read() 系统调用 |
| 输出方式 | stdout.write | os.stdout().write_string() |
| 行数 | 10 | 10 |
| 列计算 | i*1, i*2, i*3 | i*1, i*2, i*3 |

## 许可证

MIT
