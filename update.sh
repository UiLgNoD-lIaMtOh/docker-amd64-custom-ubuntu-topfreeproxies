echo $(pwd)
sudo apt update
sudo apt -y install unar
# unar 解压函数
extract_single_file() {
  # 第一个参数压缩包名
  local ARCHIVE=$1
  # 处理第二个参数提取路径
  local DIRNAME=${2%/*} ; echo ${DIRNAME}
  # 处理第二个参数提取文件名
  local FILE=${2##*/} ; echo ${FILE}
  # 第3个参数文件重命名
  local NEW_FILENAME=$3
  # 第4个参数创建临时目录
  local OUTPUT_DIR=$(mktemp -d)
  # 解压压缩包文件至临时目录
  unar -o "${OUTPUT_DIR}" "${ARCHIVE}" || return $?
  # 移动文件并重命名
  mv -fv "${OUTPUT_DIR}/${DIRNAME}/${FILE}" ./${NEW_FILENAME} ; chmod -v u+x ./${NEW_FILENAME} 
  # 删除临时目录和压缩包
  rm -rfv "${OUTPUT_DIR}" "${ARCHIVE}"
}

# github 项目 SagerNet/sing-box
URI="SagerNet/sing-box"
# 从 SagerNet/sing-box 官网中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 1)
echo $VERSION

# 拼接下载链接 URI_DOWNLOAD 后打印 
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/"
echo $URI_DOWNLOAD

# 下载程序 linux amd64 sing-box
# 打印下载链接
echo "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-amd64.tar.gz"

# 下载
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}sing-box-${VERSION#v}-linux-amd64.tar.gz" -O"sing-box-${VERSION#v}-linux-amd64.tar.gz"

# 覆盖解压
ARCHIVE="sing-box-${VERSION#v}-linux-amd64.tar.gz"
FILE="sing-box-${VERSION#v}-linux-amd64/sing-box"
NEW_FILENAME="sing-box-linux-amd64"
extract_single_file "${ARCHIVE}" "${FILE}" "${NEW_FILENAME}"
mv -fv "${NEW_FILENAME}" "topfreeproxies/"

# 获取 mihomo 下载路径
DOWNLOAD=`curl -SL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 -H "Connection: keep-alive" -k 'https://github.com/MetaCubeX/mihomo/releases' | sed 's;";\n;g;s;tag;download;g' | grep '/download/' | head -n 2 | tail -1`

# 打印环境变量
echo "https://github.com${DOWNLOAD}/mihomo-linux-amd64-`basename ${DOWNLOAD}`.gz"

# 下载
curl -SL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 -H "Connection: keep-alive" -k "https://github.com${DOWNLOAD}/mihomo-linux-amd64-`basename ${DOWNLOAD}`.gz" -o mihomo-linux-amd64-`basename ${DOWNLOAD}`.gz -O

# 覆盖解压
unar -f mihomo-linux-amd64-`basename ${DOWNLOAD}`.gz 

# 修改文件名
cp -fv mihomo-linux-amd64-`basename ${DOWNLOAD}` "topfreeproxies/mihomo-linux-amd64"

# 删除压缩包文件
rm -rfv mihomo-linux-amd64-`basename ${DOWNLOAD}`.gz mihomo-linux-amd64-`basename ${DOWNLOAD}`


# 下载 Country.mmdb
rm -fv topfreeproxies/utils/Country.mmdb
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb" -O"topfreeproxies/utils/Country.mmdb"

# 下载 subconverter
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://github.com/tindy2013/subconverter/releases/latest/download/subconverter_linux64.tar.gz" -O"topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz"
TEMP=$(mktemp -d)
# 解压文件到临时目录
tar vxzf "topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz" -C $TEMP/
#  将 subconverter/subconverter 文件移动到当前目录
mv -fv $TEMP/subconverter/subconverter "topfreeproxies/utils/subconverter/"
# 删除
rm -rfv "topfreeproxies/utils/subconverter/subconverter_linux64.tar.gz" $TEMP

# 下载 lite
OS_TYPE=$(echo $(uname -s) | tr A-Z a-z)
ARCH_TYPE_MINIFORGE=$(uname -m)
# 获取架构 lite x86_64 -> amd64
ARCH_TYPE_LITE=$(if [ "$ARCH_TYPE_MINIFORGE" = "x86_64" ];then echo "amd64";else echo $ARCH_TYPE_MINIFORGE;fi)
# github 项目 xxf098/LiteSpeedTest
URI="xxf098/LiteSpeedTest"
# 从 xxf098/LiteSpeedTest github中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | head -n 2 | tail -n 1)
echo $VERSION
# 拼接下载链接 URI_DOWNLOAD 后打印
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/lite-$OS_TYPE-$ARCH_TYPE_LITE-$VERSION.gz"
echo $URI_DOWNLOAD
# 获取文件名 FILE_NAME 后打印
FILE_NAME=$(basename $URI_DOWNLOAD)
echo $FILE_NAME
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}" -O"topfreeproxies/utils/litespeedtest/${FILE_NAME}"
gunzip -v -f "topfreeproxies/utils/litespeedtest/${FILE_NAME}" -c > "topfreeproxies/utils/litespeedtest/lite"
rm -fv "topfreeproxies/utils/litespeedtest/${FILE_NAME}"

# github 项目 MetaCubeX/mihomo
URI="MetaCubeX/mihomo"
# 从 MetaCubeX/mihomo github中提取全部 tag 版本，获取最新版本赋值给 VERSION 后打印
VERSION=$(curl -sL "https://github.com/$URI/releases" | grep -oP '(?<=\/releases\/tag\/)[^"]+' | grep -v Prerelease | head -n 1)
echo $VERSION
# 拼接下载链接 URI_DOWNLOAD 后打印 
URI_DOWNLOAD="https://github.com/$URI/releases/download/$VERSION/mihomo-$OS_TYPE-$ARCH_TYPE_LITE-$VERSION.gz"
echo $URI_DOWNLOAD
# 获取文件名 FILE_NAME 后打印
FILE_NAME=$(basename $URI_DOWNLOAD)
echo $FILE_NAME
wget -t 3 -T 5 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${URI_DOWNLOAD}" -O"topfreeproxies/utils/scripts/${FILE_NAME}"
gunzip -v -f "topfreeproxies/utils/scripts/${FILE_NAME}" -c > "topfreeproxies/utils/scripts/mihomos"
rm -fv "topfreeproxies/utils/scripts/${FILE_NAME}"
