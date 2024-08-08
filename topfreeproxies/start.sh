#!/usr/bin/env bash
clear

# 下载 nekowarp 订阅文件
wget -t 3 -T 10 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "https://neko-warp.nloli.xyz/neko_warp.yaml" -O"nekowarp.yaml"

chmod -v +x utils/subconverter/subconverter utils/litespeedtest/lite utils/scripts/mihomos

# 自定义替换文件多行内容
replace_string_in_file() {
    # 定义要搜索的字符串
    search_string="$1"

    # 定义要替换的字符串
    replace_string="$2"

    # 定义文件路径
    file_path="$3"

    # 定义执行替换操作的标志默认1
    num="${4:-1}"
    # num 为1则只保留第一个其他部分全部替换
    if [ "$num" -eq 1 ]; then
        # 计算字符串在文件中出现的次数
        count=$(grep -Fo "$search_string" "$file_path" | wc -l)

        # 如果字符串出现两次以上，则只保留第一个其他部分全部替换
        if [ "$count" -gt 1 ]; then
            # 使用perl命令，当第一次匹配到字符串时，将其替换为一个临时字符串
            # 然后将文件中的其他匹配项替换为目标字符串
            # 最后，将临时字符串替换回原始字符串
            perl -0777 -i -pe "s/\Q$search_string\E/++\$n == 1 ? \$& : '$replace_string'/ge" "$file_path"
        fi
    # num 为0则全部替换一个不留
    elif [ "$num" -eq 0 ]; then
          # 使用perl命令进行替换
          perl -0777 -i -pe "s/\Q$search_string\E/$replace_string/g" "$file_path"
    fi
}

# 函数使用示例：replace_config "config.yaml"
replace_config() {
    local config_file=$1

    echo "正在编辑 ${config_file}，请稍候..."

    declare -a delete_params=(
    "port: 7890"
    "mixed-port: 7890"
    "socks-port: 7891"
    "allow-lan: "
    "external-controller: "
    "mode: "
    "log-level: "
    "port: 7891"
    "socks-port: 7892"
    "mixed-port: 7893"
    "external-controller: :7894"
    "redir-port: 7895"
    "tproxy-port: 7896"
    )

    declare -a add_params=(
    "port: 7891"
    "socks-port: 7892"
    "mixed-port: 7893"
    "external-controller: :7894"
    "redir-port: 7895"
    "tproxy-port: 7896"
    "allow-lan: true"
    "mode: rule"
    "log-level: debug"
    )

    for param in "${delete_params[@]}"; do
    echo "删除 ${config_file} 中开头为 \"${param}\" 的行："
    sed -i "/^${param}/d" "${config_file}"
    echo sed -i "/^${param}/d" "${config_file}"
    done

    for ((i=0; i<${#add_params[@]}; i++)); do
    echo "在第$((i+1))行开头添加 ${add_params[i]}"
    sed -i "$((i+1))i${add_params[i]}" "${config_file}"
    echo sed -i "$((i+1))i${add_params[i]}" "${config_file}"
    done
}

cd utils/scripts/
bash set_proxy.sh

cd ..
python main.py

cd ..

replace_config "Eternity.yaml"

# 调用替换多行参数1
search_string='proxy-groups:
'
replace_string='proxy-groups:
  - name: GLOBAL
    proxies:
      - ♻️ 自动选择
      - 🤘 手动选择
    type: select
'
file_path="Eternity.yaml"
num=0
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 替换协议
sed -i 's;cipher: chacha20-poly1305;cipher: chacha20-ietf-poly1305;g' Eternity.yaml
sed -i 's;cipher: xchacha20-poly1305;cipher: chacha20-ietf-poly1305;g' Eternity.yaml

# 关闭开启本地 http 协议访问
kill -9 $(ps -ef | grep -v grep | grep "http.server" | awk '{print $2}')
nohup python -m http.server > /dev/null 2>&1 & disown

# clone sing-box-subscribe.git 订阅 clash/v2ray 转换 singbox
rm -rfv sing-box-subscribe.bak/* sing-box-subscribe.bak/.*
git clone https://github.com/Toperlock/sing-box-subscribe sing-box-subscribe.bak
git config --global --add safe.directory sing-box-subscribe.bak
git config --global --add safe.directory /topfreeproxies/sing-box-subscribe.bak
cd sing-box-subscribe.bak
git fetch --all
git reset --hard origin/main
git pull

# 替换解析模板配置文件
# 添加 str() 函数
sed -i "s;share_link\['name'\];str(share_link\['name'\]);g" parsers/clash2base64.py
grep -i "str(share_link\['name'\])" parsers/clash2base64.py

# 使用命令替换 sing-box 模板配置文件端口 http: 7897 socks: 7898 mixed: 7899 controller: 7900
#perl -i -pe 'BEGIN{undef $/;} s/,\n    {\n      "type": "mixed",\n      "listen": "127.0.0.1",\n      "listen_port": 2080,\n      "sniff": true,\n      "users": \[\]\n    }/,\n    {\n      "type": "http",\n      "listen": "0.0.0.0",\n      "listen_port": 7897,\n      "sniff": true,\n      "users": \[\]\n    },\n    {\n      "type": "socks",\n      "listen": "0.0.0.0",\n      "listen_port": 7898,\n      "sniff": true,\n      "users": \[\]\n    },\n    {\n      "type": "mixed",\n      "listen": "0.0.0.0",\n      "listen_port": 7899,\n      "sniff": true,\n      "users": \[\]\n    }/smg' config_template/config_template_groups_rule_set_tun.json
#sed -i 's;127.0.0.1;0.0.0.0;g;s;0.0.0.0:9090;:7900;g;s;"strict_route": true;"strict_route": false;g;s;_port": 2080;_port": 7897;g' config_template/config_template_groups_rule_set_tun.json
cp -fv ../config_template_groups_rule_set_tun.json config_template/config_template_groups_rule_set_tun.json

# 写入订阅解析配置
cp -fv ../providers.json providers.json

# 新增 singbox 转换生成
# 执行转换项目程序
echo -e '1\n' | python main.py

cd ..

# sed 替换全部 "max_early_data": xxxxxxx 为 "max_early_data": 3999999999
sed -i 's/"max_early_data":.[^,}]*/"max_early_data": 3999999999/g' "singbox-config.json"

# 备份测试修改对比
#cp -fv "singbox-config.json" "singbox-config.json.bak"

# 调用替换多行参数1
search_string='"
      ]
    },
    {
      "tag": "topfreeproxies",
      "type": "selector",
      "outbounds": ['
replace_string='",'
file_path="singbox-config.json"
num=1
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 调用替换多行参数2
search_string=',
      "endpoint_independent_nat": false,
      "stack": "system",
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "0.0.0.0",
          "server_port": 7891
        }
      }'
replace_string=''
file_path="singbox-config.json"
num=0
replace_string_in_file "$search_string" "$replace_string" "$file_path" "$num"

# 替换协议
sed -i 's;"chacha20-poly1305";"chacha20-ietf-poly1305";g' singbox-config.json
sed -i 's;"method": "ss";"method": "aes-128-gcm";g' singbox-config.json

# 删除订阅文件
rm -fv nekowarp.yaml

# 删除python cache
IFS_BAK=$IFS
IFS=$'\n'
for i in $(find ${SOURCE_PATH} -type d -iname "__pycache__")
do
    echo $i ; rm -rfv $i
done
IFS=$IFS_BAK

# 校验 Eternity.yaml 
chmod -v +x ./mihomo-linux-amd64 
./mihomo-linux-amd64 -t Eternity.yaml > mihomo-check.log

# 校验 sing-box-config.json
chmod -v +x ./sing-box-linux-amd64
./sing-box-linux-amd64 format -c singbox-config.json > singbox-config-format.json
./sing-box-linux-amd64 check -c singbox-config-format.json > singbox-config-check.log

# 移动 Eternity.yaml singbox-config.json singbox-config-format.json 到 /root/topfreeproxies 目录让 docker 挂在目录不至于为空
if [ ! -d /root/topfreeproxies ] ; then
    mkdir -pv /root/topfreeproxies/
    cp -fv Eternity.yaml singbox-config.json singbox-config-format.json /root/topfreeproxies/
fi
