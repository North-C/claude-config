# Ghostty 在 GNOME Wayland 下无法通过桌面图标启动

## 问题描述

**环境**: Fedora 41, GNOME Wayland, Ghostty 1.2.3-1.fc41

在 GNOME 应用网格中点击 Ghostty 图标，窗口无法显示。进程在后台启动，shell 子进程也运行正常，但 GUI 窗口不可见。

## 根因分析

### 原因 1: D-Bus 单实例激活与 Wayland 窗口映射冲突

系统安装的 Ghostty 包含以下 D-Bus 激活链：

```
desktop 文件 (DBusActivatable=true)
  -> D-Bus 服务文件 (SystemdService=app-com.mitchellh.ghostty.service)
    -> systemd 用户服务
      -> /usr/bin/ghostty --gtk-single-instance=true --initial-window=false
```

关键参数 `--initial-window=false` 表示服务启动时不创建初始窗口。当用户点击图标时，GNOME Shell 通过 D-Bus 向已有服务发送 `Activate` 信号。服务在内部创建了 surface 和 shell 子进程（日志显示一切正常），但窗口在 Wayland 合成器（Mutter）上无法正确映射显示。

这是一个 Ghostty + GTK4 + GNOME Wayland 的交互问题。

### 原因 2: 配置字段版本不兼容

`background-blur-radius` 在 Ghostty 1.2.3 中已改名为 `background-blur`。旧字段名会导致配置解析警告。

## 解决方案

通过本地文件覆盖系统的 desktop 和 D-Bus 服务配置，绕过 D-Bus 单实例激活机制。

### 修改对比

| 文件 | 系统默认 (有问题) | 本地覆盖 (修复后) |
|------|-------------------|-------------------|
| Desktop | `DBusActivatable=true`, `Exec=/usr/bin/ghostty --gtk-single-instance=true` | 无 `DBusActivatable`, `Exec=/usr/bin/ghostty` |
| D-Bus Service | `SystemdService=...`, `--initial-window=false` | 无 `SystemdService`, `Exec=/usr/bin/ghostty` |
| systemd | 自动启动 | `masked` (禁用) |
| config | `background-blur-radius = 20` | `background-blur = true` |

### 涉及文件

```
~/.config/ghostty/config                                          # Ghostty 配置
~/.local/share/applications/com.mitchellh.ghostty.desktop         # 覆盖 desktop 文件
~/.local/share/dbus-1/services/com.mitchellh.ghostty.service      # 覆盖 D-Bus 服务文件
systemctl --user mask app-com.mitchellh.ghostty.service           # 禁用 systemd 服务
```

### 一键安装

```bash
bash ghostty/install.sh
```

### 手动安装

```bash
# 1. 配置文件
cp ghostty/config ~/.config/ghostty/config

# 2. 覆盖 desktop 文件
mkdir -p ~/.local/share/applications
cp ghostty/overrides/com.mitchellh.ghostty.desktop ~/.local/share/applications/

# 3. 覆盖 D-Bus 服务文件
mkdir -p ~/.local/share/dbus-1/services
cp ghostty/overrides/com.mitchellh.ghostty.service ~/.local/share/dbus-1/services/

# 4. 禁用系统的 D-Bus 单实例服务
systemctl --user mask app-com.mitchellh.ghostty.service

# 5. 更新桌面数据库
update-desktop-database ~/.local/share/applications
```

### 回滚

```bash
# 恢复系统默认行为
rm ~/.local/share/applications/com.mitchellh.ghostty.desktop
rm ~/.local/share/dbus-1/services/com.mitchellh.ghostty.service
systemctl --user unmask app-com.mitchellh.ghostty.service
update-desktop-database ~/.local/share/applications
```

## 排查过程

1. `ghostty +validate-config` — 发现 `background-blur-radius` 字段废弃
2. `ghostty` 从命令行启动正常 — 排除配置本身导致崩溃
3. `gtk-launch com.mitchellh.ghostty` — 确认 D-Bus 激活路径有问题
4. `journalctl --user` — 确认进程启动、surface 创建、shell 运行均正常，但窗口不可见
5. `gdbus introspect/call` — 确认 D-Bus 服务运行正常，`new-window` action 可调用
6. 对比 `ps aux` 输出 — 发现 `--initial-window=false` 参数是关键差异
7. 创建本地覆盖文件绕过 D-Bus 激活 — 问题解决

## 代价

绕过 D-Bus 单实例模式意味着每次点击图标会启动独立的 Ghostty 进程，不再共享进程。对日常使用影响不大，但不再有"单实例多窗口"的行为。
