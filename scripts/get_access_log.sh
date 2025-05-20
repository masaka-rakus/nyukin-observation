# sh ssh.sh 2025 04 23

year=$1
m=$2
pass=$3

month=$(printf "%02d" $m)

# 対象月の1号機ログリスト取得
list=$(sshpass -p $pass ssh masahiro.kawakami@clmsbt.rakus-cloud.jp "ls /var/log/server/NYUKIN244/rniwbt054001.wb.t4.domain/LOG/${year}-${month}/access_log.gz_* | grep -oP \"${year}-${month}/[^/]+$\"")

for file in $list; do
    # 出力ファイル名 yyyymmdd_acccess_log.log
    day=$(echo $file | ggrep -oP "\d{2}$")
    output_path="logs/${year}${month}${day}_access_log.log"
    echo "${year}-${month}-${day}: $file -> $output_path" 

    sshpass -p $pass ssh masahiro.kawakami@clmsbt.rakus-cloud.jp "zgrep \"\" /var/log/server/NYUKIN244/rniwbt05400[12].wb.t4.domain/LOG/${file}| sort -k 4 -t\" \"" > $output_path
    
    # wait
    sleep 30
done
