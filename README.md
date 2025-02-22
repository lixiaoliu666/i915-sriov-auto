# i915-sriov-auto
对原仓库[strongtz/i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms) 在pve7、pve8系统上实现自动化部署，实现11代以上intel核显自动安装i915 dkms驱动，并配置sriov核显。

Automated Deployment of the original repository [strongtz/i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms) on Proxmox VE (PVE) 7 and 8 systems to achieve automatic installation of the i915 DKMS driver and SR-IOV virtual GPU configuration for Intel integrated graphics (11th generation and above).

一般需要重复运行本脚本两次（内核自动升级导致）。

It is generally necessary to run this script twice (caused by automatic kernel upgrades).

i915auto.sh是一键安装intel sriov vgpu脚本（直接全部复制贴pve终端运行就是）。

The i915auto.sh is a one-click installation script for Intel SR-IOV vGPU (simply copy and paste the entire script into the Proxmox VE terminal to run it).
