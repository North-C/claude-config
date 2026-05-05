# MT7921 蓝牙音频卡顿/断续

## 问题

使用 MT7921 (MediaTek Filogic 330) 蓝牙连接耳机/音箱播放音频时，声音卡顿、断断续续。

## 环境

- **系统**: Fedora 44, Kernel 6.19.x
- **蓝牙芯片**: MediaTek MT7921 (USB 接口, `13d3:3563`)
- **音频服务**: PipeWire
- **编码**: A2DP/SBC

## 原因

1. **USB 自动挂起**: btusb 设备默认 autosuspend=2（2 秒后挂起），蓝牙传输频繁中断
2. **ERTM 模式**: 增强重传模式在某些设备上导致 A2DP 不稳定

## 解决方法

### 1. 禁用 btusb 自动挂起 + 禁用 ERTM

创建 `/etc/modprobe.d/btusb-fix.conf`：

```bash
sudo tee /etc/modprobe.d/btusb-fix.conf > /dev/null << 'EOF'
# Fix MT7921 Bluetooth audio stuttering
# Disable USB autosuspend for btusb device (13d3:3563)
options btusb enable_autosuspend=0
# Disable ERTM for more stable BLE/A2DP connections
options bluetooth disable_ertm=1
EOF
```

### 2. 临时生效（无需重启）

```bash
# 禁用自动挂起
echo -1 | sudo tee /sys/bus/usb/devices/1-5/power/autosuspend
echo on | sudo tee /sys/bus/usb/devices/1-5/power/control
```

> 注意: `1-5` 是 MT7921 的 USB 路径，可通过 `lsusb -t` 确认 btusb 所在端口。

### 3. 重启生效验证

```bash
# 重启后检查
cat /sys/module/bluetooth/parameters/disable_ertm
# 应输出: Y

cat /sys/bus/usb/devices/1-5/power/control
# 应输出: on
```

## 验证

```bash
# 确认蓝牙设备未挂起
cat /sys/bus/usb/devices/1-5/power/autosuspend
# 应输出: -1

# 确认编码和采样率
pactl list sinks | grep -A5 bluez_output
```

## 参考

- MT7921 蓝牙通过 USB 挂载（`lsusb -t` 可见 `Driver=btusb`）
- USB autosuspend 默认值 2 秒对持续数据流（音频）不友好
- ERTM (Enhanced Retransmission Mode) 在部分 MediaTek 芯片上与 A2DP 冲突
