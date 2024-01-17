# MoYu脚本

## 网络相关摸鱼脚本

### 安装GOBGP（AMD64默认）

```
#wget
wget -O - https://bash.rbq.sh/bash/gobgp.sh | bash
#curl
curl https://bash.rbq.sh/bash/gobgp.sh | bash
```

### Linux路由器起始配置

开启MPLS，安装FRR（附加RPKI，启用常用的路由协议 ）及BGPQ4，在/root目录放一个开机启动文件

```
#wget
wget -O - https://bash.rbq.sh/bash/linux_router_kickstart.sh | bash
#curl
curl https://bash.rbq.sh/bash/linux_router_kickstart.sh | bash
```

## Proxmox配置摸鱼脚本


### 配置NAT网卡+DHCP

来自狗蛋的PVE网卡脚本，原本只有PVE5版本，咱在基础上改了一下也能支持PVE6了

#### PVE5

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/pve5_nat_dog.sh | bash
#curl
curl https://bash.rbq.sh/bash/pve5_nat_dog.sh | bash
~~~

#### PVE6


~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/pve6_nat_dog.sh | bash
#curl
curl https://bash.rbq.sh/bash/pve6_nat_dog.sh | bash
~~~

### 中科大PVE更新源

切换中科大免订阅源

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/pve6_non_ustc_cn_source.sh | bash
#curl
curl https://bash.rbq.sh/bash/pve6_non_ustc_cn_source.sh | bash
~~~


### 清华PVE更新源

清华免订阅源

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/pve6_non_tuna_cn_source.sh | bash
#curl
curl https://bash.rbq.sh/bash/pve6_non_tuna_cn_source.sh | bash
~~~

### 配置NAT网卡

没DHCP服务干干净净的配置NAT网卡脚本

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/vmbr_iptables_nat_init.sh | bash
#curl
curl https://bash.rbq.sh/bash/vmbr_iptables_nat_init.sh | bash
~~~

### PVE习惯性配置

YF平时习惯性给PVE的一些配置

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/pve_cn_init.sh | bash
#curl
curl https://bash.rbq.sh/bash/pve_cn_init.sh | bash
~~~


## 通用

### UFW放行OSPF

在UFW防火墙中放行OSPF协议
Ubuntu WDNMD（就因为ufw搞定咱排查了半天

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/ufw_ospf.sh | bash
#curl
curl https://bash.rbq.sh/bash/ufw_ospf.sh | bash
~~~

### 安装作曲家

没啥好说，使用需要先安装好php

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/get_composer_cn.sh | bash
#curl
curl https://bash.rbq.sh/bash/get_composer_cn.sh | bash
~~~


### 配置系统模板基础

让纯净的系统安装一些软件+支持各种云

~~~bash
#wget
wget -O - https://bash.rbq.sh/bash/cloudinit_install.sh | bash
#curl
curl https://bash.rbq.sh/bash/cloudinit_install.sh | bash
~~~

## 需配置脚本

### 自动拉代码

请下载后自己更改

~~~bash
#wget
wget https://bash.rbq.sh/bash/pull_code.sh
~~~

### 自动拉代码

请下载后自己更改

~~~bash
#wget
wget https://bash.rbq.sh/bash/pull_code.sh
~~~
