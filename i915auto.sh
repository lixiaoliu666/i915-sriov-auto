#!/bin/bash
#参考https://github.com/long1and-IceTea/i915-dkms-auto/blob/main/i915auto.sh 源码修改并加以改进，一般需要重复运行本脚本两次（内核自动升级导致）

#pve8换源
#修改基础系统（Debian）的源文件
sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
sed -i 's|^deb http://security.debian.org|deb https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
#修改 Proxmox 的源文件 换源
source /etc/os-release
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve $VERSION_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
#修改 ceph 源文件 换源
if [ -f /etc/apt/sources.list.d/ceph.list ]; then CEPH_CODENAME=`ceph -v | grep ceph | awk '{print $(NF-1)}'`; source /etc/os-release; echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-$CEPH_CODENAME $VERSION_CODENAME no-subscription" > /etc/apt/sources.list.d/ceph.list; fi

# 更新系统
apt update
apt dist-upgrade -y

# 安装 Proxmox VE 内核头文件 如果上面的更新更新了内核会导致uname -r显示旧内核，这里就需要重启机器后再执行下面的 pve-headers安装
apt install -y pve-headers-$(uname -r)

#安装必备的编译环境
apt install -y build-* dkms
apt install -y git

# 克隆 i915-sriov-dkms 存储库，分别直接克隆和使用代理克隆两次，总有一次能成功的
rm -Rf i915-sriov-dkms
git clone https://github.com/strongtz/i915-sriov-dkms.git
git clone https://mirror.ghproxy.com/https://github.com/strongtz/i915-sriov-dkms.git
cd i915-sriov-dkms

# 修改 dkms.conf 文件 写6.1或者6.5无所谓
sed -i '1s/.*/PACKAGE_NAME="i915-sriov-dkms"/; 2s/.*/PACKAGE_VERSION="6.1"/' dkms.conf

# 安装 i915-sriov-dkms 模块，自动卸载并重复安装两次
dkms add .
dkms remove -m i915-sriov-dkms -v 6.1
dkms install -m i915-sriov-dkms -v 6.1
dkms remove -m i915-sriov-dkms -v 6.1
dkms install -m i915-sriov-dkms -v 6.1

# 检查模块是否安装编译成功
modinfo i915|grep vf

# 修改 GRUB 配置
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_guc=3 i915.max_vfs=7"/' /etc/default/grub

# 更新 GRUB 配置
update-grub

# 更新 initramfs
update-initramfs -u -k all


# 配置 sriov_numvfs 数量并写入开机自启动，需要用户输入数量，先删除/etc/rc.local，再重新写入/etc/rc.local
read -p "请输入你需要几个vGPU 一般是整数2到7：输入后才能进入下一步骤 " numvfs
rm /etc/rc.local
echo '#!/bin/bash' >>/etc/rc.local
echo "echo $numvfs > /sys/devices/pci0000:00/0000:00:02.0/sriov_numvfs" >>/etc/rc.local
chmod +x /etc/rc.local

# 再次检查模块是否安装编译成功
modinfo i915|grep vf >/dev/null
if [ $? -eq 0 ]; then
	echo "i915-sriov-dkms安装成功"
else
	echo "i915-sriov-dkms没有安装成功，请重启后再运行一次本脚本（可能因为更新了内核导致没安装成功）"
fi
echo "请重启pve物理机，如果重启后失败（一般是因为自动更新了内核导致），请再次运行本脚本一次"
