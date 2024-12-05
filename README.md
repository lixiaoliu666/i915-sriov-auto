# i915-sriov-auto
对原仓库[i915-sriov-dkms](https://github.com/strongtz/i915-sriov-dkms) 
在pve7、pve8系统上实现自动化部署
实现11代以上intel核显自动安装i915 dkms驱动，并配置sriov核显

一般需要重复运行本脚本两次（内核自动升级导致）
i915auto.sh是一键安装intel sriov vgpu脚本（直接全部复制贴pve终端运行就是）
