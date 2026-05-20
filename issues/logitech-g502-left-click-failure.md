# Logitech G502 左键点击间歇失效

## 问题

Logitech G502 鼠标移动正常，但左键点击会间歇性失效。问题发生在 GNOME Wayland 会话中，表现为应用层无法响应左键点击。

## 环境

- **系统**: Fedora 44, Kernel 6.19.x
- **桌面环境**: GNOME Wayland
- **鼠标**: Logitech G502 HERO / G502 SE HERO
- **USB ID**: `046d:c08b`
- **输入事件设备**: `/dev/input/event7`

## 线索

### 1. 会话类型为 Wayland

```bash
printf 'XDG_SESSION_TYPE=%s\nXDG_CURRENT_DESKTOP=%s\nDISPLAY=%s\nWAYLAND_DISPLAY=%s\n' \
  "$XDG_SESSION_TYPE" "$XDG_CURRENT_DESKTOP" "$DISPLAY" "$WAYLAND_DISPLAY"
```

输出显示：

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=GNOME
DISPLAY=:0
WAYLAND_DISPLAY=wayland-0
```

因此 `xinput` 在这个场景下没有有效输出，排查重点应放在 `libinput`、GNOME 设置、udev 和内核日志。

### 2. 鼠标被系统正确识别

```bash
lsusb
```

相关输出：

```text
Bus 005 Device 003: ID 046d:c08b Logitech, Inc. G502 SE HERO Gaming Mouse
```

`/proc/bus/input/devices` 中也能看到鼠标事件设备：

```text
Name="Logitech G502 HERO Gaming Mouse"
Handlers=mouse1 event7
```

### 3. GNOME 左右手设置正常

```bash
gsettings get org.gnome.desktop.peripherals.mouse left-handed
```

输出：

```text
false
```

说明左键没有被 GNOME 配置成右手/左手反转问题。

### 4. Mouse Keys 辅助功能异常开启

```bash
gsettings list-recursively org.gnome.desktop.a11y.keyboard | grep mousekeys
```

相关输出：

```text
org.gnome.desktop.a11y.keyboard mousekeys-enable true
```

Mouse Keys 会允许键盘数字区模拟鼠标操作，虽然不是唯一原因，但在点击异常时属于高可疑干扰项。

### 5. 内核日志出现过 USB/xHCI 异常

```bash
journalctl -b -k --no-pager | grep -Ei 'logitech|g502|usb|hid|input|mouse|disconnect|reset|xhci'
```

相关线索包括：

```text
xhci_hcd 0000:02:00.0: xHC error in resume, USBSTS 0x401, Reinit
usb usb1: root hub lost power or was reset
usb 1-4: USB disconnect
usb 1-4: reset full-speed USB device
input: Logitech G502 HERO Gaming Mouse
```

这说明系统曾发生 USB 控制器恢复异常、USB root hub reset、鼠标断开重连等事件。此类问题可能造成鼠标输入在桌面层间歇失效。

## 中间证据

### 1. libinput 能识别鼠标配置

```bash
sudo libinput list-devices | sed -n '/Logitech G502 HERO Gaming Mouse/,/^$/p'
```

关键输出：

```text
Device:                  Logitech G502 HERO Gaming Mouse
Kernel:                  /dev/input/event7
Id:                      usb:046d:c08b
Capabilities:            pointer
Left-handed:             disabled
Middle emulation:        disabled
```

说明 libinput 层没有启用左手模式，也没有启用中键模拟。

### 2. 原始输入事件可以收到左键

```bash
sudo timeout 15s sh -c \
  'libinput debug-events --device /dev/input/event7 2>&1 | stdbuf -oL grep -E "DEVICE_ADDED|POINTER_BUTTON"'
```

测试时依次点击左键、中键、右键，输出包括：

```text
POINTER_BUTTON BTN_LEFT (272) pressed
POINTER_BUTTON BTN_LEFT (272) released
POINTER_BUTTON BTN_MIDDLE (274) pressed
POINTER_BUTTON BTN_MIDDLE (274) released
POINTER_BUTTON BTN_RIGHT (273) pressed
POINTER_BUTTON BTN_RIGHT (273) released
```

这说明左键在内核/libinput 层可以上报，问题不是简单的“左键被系统禁用”或“按钮映射错误”。

### 3. USB 电源状态

```bash
for d in /sys/bus/usb/devices/*; do
  [ -f "$d/idVendor" ] && [ -f "$d/idProduct" ] || continue
  v=$(cat "$d/idVendor")
  p=$(cat "$d/idProduct")
  if [ "$v:$p" = "046d:c08b" ]; then
    printf 'device=%s\n' "$d"
    for f in power/control power/autosuspend power/runtime_status power/wakeup; do
      [ -e "$d/$f" ] && printf '%s=' "$f" && cat "$d/$f"
    done
  fi
done
```

修复前后重点关注：

```text
power/control=on
power/autosuspend=2
power/runtime_status=active
```

虽然当时 `power/control` 已经是 `on`，但系统存在通用 autosuspend 规则，重插、重启或设备重新枚举后仍可能被其他规则改回自动省电。因此需要写入本机持久规则，保证这只鼠标始终保持供电。

## 解决方法

### 1. 关闭 GNOME Mouse Keys

```bash
gsettings set org.gnome.desktop.a11y.keyboard mousekeys-enable false
```

验证：

```bash
gsettings get org.gnome.desktop.a11y.keyboard mousekeys-enable
# 应输出: false
```

### 2. 禁用 G502 的 USB 自动省电

创建 `/etc/udev/rules.d/99-logitech-g502-no-autosuspend.rules`：

```udev
# Keep Logitech G502 HERO fully powered to avoid intermittent click loss after USB autosuspend/reset.
ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c08b", TEST=="power/control", ATTR{power/control}="on"
```

重新加载并触发规则：

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb --attr-match=idVendor=046d --attr-match=idProduct=c08b
```

## 验证

### 1. 检查 GNOME 设置

```bash
gsettings get org.gnome.desktop.a11y.keyboard mousekeys-enable
gsettings get org.gnome.desktop.peripherals.mouse left-handed
```

期望输出：

```text
false
false
```

### 2. 检查 udev 规则命中

```bash
sudo udevadm test /sys/bus/usb/devices/5-2 2>&1 | grep -E '99-logitech|power/control|c08b|046d'
```

相关输出：

```text
Reading rules file: /etc/udev/rules.d/99-logitech-g502-no-autosuspend.rules
ATTR{power/control}="on"
power/control : on
ID_MODEL_ID=c08b
ID_VENDOR_ID=046d
```

> 注意：`5-2` 是本机当时的 USB 设备路径，重插后可能变化。可通过 `udevadm info -q path -n /dev/input/event7` 或遍历 `/sys/bus/usb/devices/*/idVendor` 找到当前路径。

### 3. 检查当前电源状态

```bash
cat /sys/bus/usb/devices/5-2/power/control
# 应输出: on
```

### 4. 实际结果

关闭 Mouse Keys 并添加 G502 udev 规则后，左键点击失效问题消失。

## 结论

本次问题不是单纯的按钮映射错误：原始 `BTN_LEFT` 事件能被 libinput 捕获。更合理的判断是：

- GNOME Mouse Keys 开启造成输入行为存在干扰风险；
- 系统日志中存在 USB/xHCI reset、鼠标断开重连等异常；
- 对 G502 禁用 USB 自动省电后，配合关闭 Mouse Keys，问题得到修复。

后续如果同类问题复发，应优先重新抓取 `libinput debug-events` 和 `journalctl -b -k`，判断是鼠标硬件微动问题、USB 控制器恢复问题，还是桌面会话层输入处理卡住。
