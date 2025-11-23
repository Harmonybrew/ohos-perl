# ohos-perl
本项目为 OpenHarmony 平台编译了 perl，并发布预构建包。

## 获取软件包
前往 [release 页面](https://github.com/Harmonybrew/ohos-perl/releases) 获取。

## 用法
**1\. 在鸿蒙 PC 中使用**

因系统安全规格限制等原因，暂不支持通过“解压 + 配 PATH” 的方式使用这个软件包。

你可以尝试将 tar 包打成 hnp 包再使用，详情请参考 [DevBox](https://gitcode.com/OpenHarmonyPCDeveloper/devbox) 的方案。

**2\. 在鸿蒙开发板中使用**

用 hdc 把它推到设备上，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
hdc file send perl-5.42.0-ohos-arm64.tar.gz /data
hdc shell

cd /data
tar -zxf perl-5.42.0-ohos-arm64.tar.gz
export PATH=$PATH:/data/perl-5.42.0-ohos-arm64/bin

# 现在你可以使用 perl 命令了
```

**3\. 在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中使用**

在容器中用 curl 下载这个软件包，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker exec -it ohos sh

cd /root
curl -L -O https://github.com/Harmonybrew/ohos-perl/releases/download/5.42.0/perl-5.42.0-ohos-arm64.tar.gz
tar -zxf perl-5.42.0-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/perl-5.42.0-ohos-arm64/bin

# 现在你可以使用 perl 命令了
```

## 从源码构建

**1\. 手动构建**

这个项目使用本地编译（native compilation，也可以叫本机编译或原生编译）的做法来编译鸿蒙版 perl，而不是交叉编译。

需要在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中运行项目里的 build.sh，以实现 perl 的本地编译。

示例：
```sh
git clone https://github.com/Harmonybrew/ohos-perl.git
cd ohos-perl

docker run \
  --rm \
  -it \
  -v "$PWD":/workdir \
  -w /workdir \
  ghcr.io/hqzing/docker-mini-openharmony:latest \
  ./build.sh
```

**2\. 使用流水线构建**

如果你熟悉 GitHub Actions，你可以直接复用项目内的工作流配置，使用 GitHub 的流水线来完成构建。

这种情况下，你使用的是 GitHub 提供的构建机，不需要自己准备构建环境。

只需要这么做，你就可以进行你的个人构建：
1. Fork 本项目，生成个人仓
2. 在个人仓的“Actions”菜单里面启用工作流
3. 在个人仓提交代码或发版本，触发流水线运行

## 常见问题

**1\. 出现类似 "Can't locate xxx.pm" 的报错**

为了能在任意安装目录使用，这版 perl 专门做成了 relocatable 版本（有些地方也称为 portable，大概就是便携版、绿色版的意思），编译的时候是加了 `-Duserelocatableinc` 参数的。

然而，relocatableinc 是一个新特性，它不一定完美。

在一些使用场景中，有可能会遇到类似这样的报错
```txt
Can't locate strict.pm in @INC (you may need to install the strict module) (@INC entries checked: ../lib/perl5/site_perl/5.42.0/aarch64-linux ../lib/perl5/site_perl/5.42.0 ../lib/perl5/5.42.0/aarch64-linux ../lib/perl5/5.42.0)
```

如果遇到了这种情况，建议你重编一版自己的 perl。编的时候把 `-Duserelocatableinc` 参数去掉，并把 `-Dprefix` 设置为你实际要安装的位置，做成一个“不便携”的版本。这样子就可以避免此类问题的发生。

