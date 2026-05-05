# 蓝牙挂起恢复后无法启用 (MediaTek MT7921)

## 问题

系统从挂起 (S3) 恢复后，GUI 蓝牙开关无法打开。`bluetooth.service` 状态为 `active (running)`，但 `hci0` 处于 DOWN 状态，MAC 地址归零：

```
hci0:  Type: Primary  Bus: USB
       BD Address: 00:00:00:00:00:00  ACL MTU: 0:0  SCO MTU: 0:0
       DOWN
```

## 原因

蓝牙芯片为 MediaTek MT7921 (USB ID: `13d3:3563`，驱动 `btusb` + `btmtk`)。

挂起恢复时 xHCI 控制器报错，导致蓝牙芯片 HCI 接口无响应：

```
xhci_hcd: xHC error in resume, USBSTS 0x401, Reinit
Bluetooth: hci0: Opcode 0x0c03 failed: -110
Bluetooth: hci0: Failed to read MSFT supported features (-110)
Bluetooth: hci0: AOSP get vendor capabilities (-110)
```

`-110` 即 `ETIMEDOUT`，HCI Reset 命令超时，控制器未正确重新初始化。

简单的驱动 rebind (`unbind`/`bind`) 无法恢复，需要硬件级 USB 重置。

## 解决方法

### 立即修复

```bash
# USB authorized 标志做硬件级重置
echo 0 | sudo tee /sys/bus/usb/devices/1-5/authorized
sleep 2
echo 1 | sudo tee /sys/bus/usb/devices/1-5/authorized
sleep 3
sudo systemctl restart bluetooth.service
```

### 自动修复（推荐）

创建 systemd sleep hook 脚本，每次挂起恢复后自动执行重置：

```bash
sudo tee /usr/lib/systemd/system-sleep/bt-rebind.sh << 'SCRIPT'
#!/bin/bash
BT_DEV="/sys/bus/usb/devices/1-5/authorized"

if [ "$1" = "post" ]; then
    if [ -f "$BT_DEV" ]; then
        logger "bt-rebind: resetting bluetooth USB device after resume"
        echo 0 > "$BT_DEV" 2>/dev/null
        sleep 2
        echo 1 > "$BT_DEV" 2>/dev/null
        sleep 3
        systemctl restart bluetooth.service 2>/dev/null
        logger "bt-rebind: bluetooth device reset complete"
    fi
fi
SCRIPT

sudo chmod +x /usr/lib/systemd/system-sleep/bt-rebind.sh
```

> 注意：设备路径 `1-5` 对应本机蓝牙适配器的 USB 端口，不同机器可能不同。
> 可通过 `ls /sys/bus/usb/drivers/btusb/` 查询。

## 验证

```bash
hciconfig -a
# 正常状态应显示：
#   BD Address: <非零MAC>  ACL MTU: 1021:6  SCO MTU: 240:8
#   UP RUNNING
```
