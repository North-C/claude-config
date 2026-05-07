# 常见问题排查

## VS Code 中文输入法不工作（GNOME Wayland + Ubuntu 22.04）

### 环境背景

Ubuntu 22.04 GNOME Wayland 下，VS Code 通过 Snap 安装时，中文输入法（fcitx5/ibus）无法正常工作。

### 根因分析

该问题由多个因素叠加导致：

1. **Snap 沙箱隔离** — Snap 版 VS Code 的沙箱机制限制了与系统输入法框架的通信，这是最主要的原因
2. **环境变量未正确传递** — GNOME Wayland 下桌面应用由 systemd 用户会话启动，不继承 shell 配置中的环境变量
3. **fcitx5 未启动** — fcitx5 没有自启动项，而 GNOME 默认启动 ibus 并覆盖输入法环境变量
4. **Electron Wayland IME** — VS Code（Electron）在 Wayland 下需要额外标志启用 IME 支持

### 解决方案

#### 第一步：将 VS Code 从 Snap 换成 .deb 安装

```bash
# 卸载 Snap 版
sudo snap remove code

# 下载并安装 .deb 版
wget -O /tmp/code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i /tmp/code.deb
sudo apt-get install -f
```

> VS Code 设置和插件保存在 `~/.config/Code/`，不受卸载影响。

#### 第二步：配置 fcitx5 环境变量

**`~/.zshrc`**（确保 shell 环境正确）:

```bash
# fcitx5 input method
export INPUT_METHOD=fcitx5
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
```

**`~/.config/environment.d/fcitx5.conf`**（让桌面应用也能识别）:

```ini
INPUT_METHOD=fcitx5
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
```

#### 第三步：配置 fcitx5 自启动并禁用 ibus

```bash
# fcitx5 自启动
cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/

# 禁用 GNOME 自带的 ibus 服务
systemctl --user mask org.freedesktop.IBus.session.GNOME.service

# 阻止 im-config 在 GNOME 下优先使用 ibus（需要 sudo）
sudo sed -i 's/^DESKTOP_SETUP_IBUS="GNOME"/#DESKTOP_SETUP_IBUS="GNOME"/' /etc/default/im-config
```

#### 第四步：VS Code 启用 Wayland IME

**`~/.config/code-flags.conf`**:

```
--enable-wayland-ime
--ozone-platform-hint=auto
```

#### 第五步：注销并重新登录

所有配置需要重新登录才能生效。

### 排查命令

```bash
# 检查 fcitx5 是否运行
ps aux | grep fcitx5 | grep -v grep

# 检查环境变量
env | grep -iE 'GTK_IM|QT_IM|XMODIFIERS|INPUT_METHOD'

# 检查 systemd 用户环境
systemctl --user show-environment | grep -iE 'GTK_IM|QT_IM|XMODIFIERS'

# fcitx5 诊断
fcitx5-diagnose

# 确认 VS Code 安装方式（不应显示 snap）
which code && ls -la $(which code)
```
