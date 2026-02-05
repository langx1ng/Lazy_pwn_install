# Lazy_pwn_install 🚀

**Lazy_pwn_install** 是一款专为 Ubuntu 设计的“懒人”一键式 Pwn 环境配置脚本。它能够自动化完成从系统换源到高级调试工具安装的全过程，并根据系统版本智能匹配最佳工具链。

## 🌟 核心特性

- 
- **智能环境扫描**：启动时自动检测已安装工具，跳过重复项，仅补全缺失环境。
- **Ubuntu 版本感知**：根据 18.04 / 20.04 / 22.04 / 24.04 不同版本，自动 checkout 最兼容的 **pwndbg** 标签（Tag），解决 GDB 与 Python 版本冲突。
- **模块化可选安装**：通过交互式菜单，自由选择是否安装 **Docker**、**内核 Pwn (QEMU)** 或 **PHP 源码调试环境**。

## 🛠️ 包含工具链

### 1. 基础工具 (Base)

- vim, git, gcc, gdb-multiarch, python3-pip, build-essential, wget, curl 等。

### 2. 核心 Pwn 插件 (Core)

- **Pwntools**: 强大的 Pwn 利用框架。
- **Pwndbg**: 智能适配系统版本的 GDB 增强插件。
- **ROPgadget**: 经典的 ROP 链搜索工具。
- **patchelf**: ELF 文件动态链接器修改工具。
- **glibc-all-in-one**: 离线多版本 glibc 下载器。

### 3. 环境增强 (Enhancement)

- **clibc (by CAO-PNG)**: 一键 Patch 程序 libc，快速切换运行环境。
- **pwninit (by CAO-PNG)**: 自动化赋权、检查保护、并生成包含 sa/sla/ru 等高级宏定义的 exp 模板。

### 4. 高级环境 (Advanced - 可选)

- **Docker**: 最新版 Docker 容器环境及 Compose。
- **Kernel Pwn**: QEMU 仿真环境及内核提取脚本 extract-vmlinux。
- **PHP Pwn**: 自动编译安装支持 Debug 的 **PHP-8.3.15** 源码环境。

## 🚀 快速开始

在 Ubuntu 终端中执行以下命令：

```bash
# 克隆仓库
git clone https://github.com/langx1ng/Lazy_pwn_install.git

# 进入目录
cd Lazy_pwn_install

# 赋予执行权限
chmod +x Lazy_pwn_install.sh

# 运行脚本
./Lazy_pwn_install.sh
```

## 📖 使用指南

1. **初始菜单**：运行后会出现经典的欢迎界面，询问是否开始。
2. **状态扫描**：脚本会自动列出当前系统已安装和未安装的工具。
3. **推荐项询问**：
   - 会询问是否安装 clibc 和 pwninit。
4. **可选大项询问**：
   - 询问是否安装 Docker、内核 Pwn 或编译 PHP 源码。
5. **等待完成**：根据网速，通常在 5-15 分钟内即可拥有一个完美的 Pwn 实验环境。

## ⚠️ 注意事项

- **PHP 编译**：编译 PHP 源码时，脚本会自动处理依赖。由于网络环境差异，make test 阶段可能会报错，请直接忽略，二进制文件已正常生成。
- **权限需求**：脚本运行过程中需要多次调用 sudo，请确保当前用户具有 sudo 权限。

## 🤝 致谢

- 核心调试工具源自：[pwndbg](https://www.google.com/url?sa=E&q=https%3A%2F%2Fgithub.com%2Fpwndbg%2Fpwndbg), [pwntools](https://www.google.com/url?sa=E&q=https%3A%2F%2Fgithub.com%2FGallopsled%2Fpwntools), [glibc-all-in-one](https://www.google.com/url?sa=E&q=https%3A%2F%2Fgithub.com%2Fmatrix1001%2Fglibc-all-in-one)。
- 感谢 **CAO-PNG** 提供的 clibc 与 pwninit 快捷安装脚本。

------



**Author: [langx1ng](https://www.google.com/url?sa=E&q=https%3A%2F%2Fgithub.com%2Flangx1ng)**
*祝你在 Pwn 的路上越走越远！*
