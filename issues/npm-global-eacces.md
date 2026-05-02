# npm 全局安装权限不足 (EACCES)

## 问题

以普通用户执行 `npm install -g` 时报权限错误：

```
npm error code EACCES
npm error syscall rename
npm error path /usr/lib/node_modules/@openai/codex
npm error errno -13
npm error Error: EACCES: permission denied
```

## 原因

npm 默认全局安装目录为 `/usr/lib/node_modules/`，该目录属于 root 用户，普通用户无写入权限。

## 解决方法

将 npm 全局目录改到用户主目录下。

### 1. 创建用户级全局目录

```bash
mkdir -p ~/.npm-global
```

### 2. 修改 npm 全局前缀

```bash
npm config set prefix ~/.npm-global
```

验证：

```bash
npm config get prefix
# 应输出: /home/<用户名>/.npm-global
```

### 3. 添加到 PATH

在 `~/.zshrc` 中添加：

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
```

然后重新加载：

```bash
source ~/.zshrc
```

### 4. 重新安装

```bash
npm install -g <package>
```

## 验证

```bash
which <package>
# 应输出: /home/<用户名>/.npm-global/bin/<package>
```

## 不推荐的方案

- `sudo npm install -g` — 用 root 权限安装可能破坏文件权限
