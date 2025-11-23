#!/bin/sh
set -e

# 如果存在旧的目录和文件，就清理掉
# 仅清理工作目录，不清理系统目录，因为默认用户每次使用新的容器进行构建（仓库中的构建指南是这么指导的）
rm -rf *.tar.gz \
    perl5-5.42.0 \
    perl-5.42.0-ohos-arm64

# 准备一些杂项的命令行工具
curl -L -O https://github.com/Harmonybrew/ohos-busybox/releases/download/1.37.0/busybox-1.37.0-ohos-arm64.tar.gz
tar -zxf busybox-1.37.0-ohos-arm64.tar.gz -C /opt
cp /opt/busybox-1.37.0-ohos-arm64/bin/busybox /bin/
ln -s busybox /bin/tr
ln -s busybox /bin/expr
ln -s busybox /bin/awk

# 准备鸿蒙版 llvm、make
curl -L -O https://github.com/Harmonybrew/ohos-llvm/releases/download/20251121/llvm-21.1.5-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-make/releases/download/4.4.1/make-4.4.1-ohos-arm64.tar.gz
tar -zxf llvm-21.1.5-ohos-arm64.tar.gz -C /opt
tar -zxf make-4.4.1-ohos-arm64.tar.gz -C /opt

# 准备环境变量
export PATH=$PATH:/opt/llvm-21.1.5-ohos-arm64/bin
export PATH=$PATH:/opt/make-4.4.1-ohos-arm64/bin

# 编译 perl
curl -L https://github.com/Perl/perl5/archive/refs/tags/v5.42.0.tar.gz -o perl5-5.42.0.tar.gz
tar -zxf perl5-5.42.0.tar.gz
cd perl5-5.42.0
sed -i 's/defined(__ANDROID__)/defined(__ANDROID__) || defined(__OHOS__)/g' perl_langinfo.h
./Configure \
    -des \
    -Dprefix=/opt/perl-5.42.0-ohos-arm64 \
    -Duserelocatableinc \
    -Dcc=clang \
    -Dcpp=clang++ \
    -Dar=llvm-ar \
    -Dnm=llvm-nm \
    -Accflags=-D_GNU_SOURCE
make -j$(nproc)
make install
cd ..

# 履行开源义务，将 license 随制品一起发布
cp perl5-5.42.0/Copying /opt/perl-5.42.0-ohos-arm64
cp perl5-5.42.0/AUTHORS /opt/perl-5.42.0-ohos-arm64

# 打包最终产物
cp -r /opt/perl-5.42.0-ohos-arm64 ./
tar -zcf perl-5.42.0-ohos-arm64.tar.gz perl-5.42.0-ohos-arm64
