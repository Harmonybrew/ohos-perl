#!/bin/sh
set -e

# 如果存在旧的目录和文件，就清理掉
# 仅清理工作目录，不清理系统目录，因为默认用户每次使用新的容器进行构建（仓库中的构建指南是这么指导的）
rm -rf *.tar.gz \
    perl5-5.42.0 \
    perl-5.42.0-ohos-arm64

# 准备一些杂项的命令行工具
curl -L -O https://github.com/Harmonybrew/ohos-coreutils/releases/download/9.9/coreutils-9.9-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-gawk/releases/download/5.3.2/gawk-5.3.2-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-busybox/releases/download/1.37.0/busybox-1.37.0-ohos-arm64.tar.gz
tar -zxf coreutils-9.9-ohos-arm64.tar.gz -C /opt
tar -zxf gawk-5.3.2-ohos-arm64.tar.gz -C /opt
tar -zxf busybox-1.37.0-ohos-arm64.tar.gz -C /opt

# 准备鸿蒙版 make
curl -L -O https://github.com/Harmonybrew/ohos-make/releases/download/4.4.1/make-4.4.1-ohos-arm64.tar.gz
tar -zxf make-4.4.1-ohos-arm64.tar.gz -C /opt

# 准备鸿蒙版 ohos-sdk
sdk_download_url="https://cidownload.openharmony.cn/version/Master_Version/ohos-sdk-public_ohos/20251209_020142/version-Master_Version-ohos-sdk-public_ohos-20251209_020142-ohos-sdk-public_ohos.tar.gz"
curl $sdk_download_url -o ohos-sdk.tar.gz
mkdir /opt/ohos-sdk
tar -zxf ohos-sdk.tar.gz -C /opt/ohos-sdk
rm -f ohos-sdk.tar.gz
cd /opt/ohos-sdk/ohos
/opt/busybox-1.37.0-ohos-arm64/bin/busybox unzip -q native-ohos-x64-6.1.0.21-Canary1.zip
rm -rf *.zip
cd - >/dev/null

# 准备环境变量
export PATH=/opt/coreutils-9.9-ohos-arm64/bin:$PATH
export PATH=/opt/gawk-5.3.2-ohos-arm64/bin:$PATH
export PATH=/opt/make-4.4.1-ohos-arm64/bin:$PATH
export PATH=/opt/ohos-sdk/ohos/native/llvm/bin:$PATH

# 编译 perl
curl -L https://github.com/Perl/perl5/archive/refs/tags/v5.42.0.tar.gz -o perl5-5.42.0.tar.gz
tar -zxf perl5-5.42.0.tar.gz
cd perl5-5.42.0
sed -i 's/defined(__ANDROID__)/defined(__ANDROID__) || defined(__OHOS__)/g' perl_langinfo.h
./Configure \
    -des \
    -Dprefix=/opt/perl-5.42.0-ohos-arm64 \
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

# 这一步是针对手动构建场景做优化。
# 在 docker run --rm -it 的用法下，有可能文件还没落盘，容器就已经退出并被删除，从而导致压缩文件损坏。
# 使用 sync 命令强制让文件落盘，可以避免那种情况的发生。
sync
