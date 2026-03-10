# 使用临时的 registry 文件进行插件测试，不污染全局配置
$env.NU_PLUGIN_REGISTRY_PATH = ($env.PWD | path join "test_registry.msgpack")

# 清理旧的 registry 文件
if ("test_registry.msgpack" | path exists) {
    rm test_registry.msgpack
}

print "--- Registering V plugin ---"
# 注意：v 实现需要指定二进制路径
plugin add ./nu_plugin_v_example

print "--- Testing V plugin output ---"
# 运行插件命令 1 + 2
let result = (v_example 1 2)
print $result

if $result == 3 {
    print "✓ SUCCESS: V plugin returned correct result (3)"
} else {
    print "✗ FAILURE: V plugin returned ($result), expected 3"
}
