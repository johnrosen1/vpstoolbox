#!/usr/bin/env bash

## Aria2全自动上传Onedrive(可以为GD等)模组 Aria2 Auto upload to Onedrive/Google Drive moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

## Aria2使用方法: aria2c --on-download-complete /etc/aria2/autoupload.sh http://example.org/file.iso 或者 on-download-complete=/etc/aria2/autoupload.sh
## Qbittorrent-nox使用方法: bash /etc/aria2/autoupload.sh %N %C %F
## 通用使用方法: bash /etc/aria2/autoupload.sh \$gid \$file_num \$file_path

## 注：bt下载做种完成后(可以手动停止做种)才会执行上传命令。

## Rclone请自行配置

## 获取环境变量

## aria2 passes 3 arguments to specified command when it is executed. These arguments are: GID, the number of files and file path. For HTTP, FTP, and SFTP downloads, usually the number of files is 1. BitTorrent download can contain multiple files. If number of files is more than one, file path is first one.
## 多文件(指新建了文件夹)的话默认路径是第一个文件的路径。

rclone_name="onedrive" ## rclone config时设置的名称,```rclone listremotes --long```查看
file_path=$3 ## 文件路径
#echo ${file_path}
file_folder=${file_path%/*} ## 文件夹路径
#echo ${file_folder}
file_folder_size=$(du -hs ${file_folder} | sed "s/\..*//g") ## 文件夹大小
file_num=$2 ## 文件数量
gid=$1 ##gid

## 设置默认策略,可用策略为保留下载档案(```keep```),删除下载档案(```delete```)

policy_default="keep"

## 设置保留的磁盘空间大小,低于此下限默认上传并删除档案(默认10GB)。

policy_preserved_disk_size="10"

## 设置默认上传并删除的已下载档案大小,高于此上限默认上传并删除档案(默认50GB)。

policy_default_delete_file_size="50"

## 设置默认的远程储存目录(默认为```/aria2_downloaded/```)

policy_default_path="/aria2_downloaded/"

## 检测rclone命令是否可用

which rclone

if [[ $? != 0 ]]; then
	curl https://rclone.org/install.sh | bash
	apt-get install fuse -y
	echo -e "请自行配置rclone并继续"
	exit 1;
fi

which aria2c

if [[ $? != 0 ]]; then
	echo -e "未找到aria2,可能未安装,请自行安装aria2并继续"
	exit 1;
fi

## 检测日志路径是否存在

if [[ ! -d /var/log/rclone ]]; then
	mkdir /var/log/rclone
	touch /var/log/rcloneupload.log
fi

## 获取剩余磁盘空间

disk_remain_size_kb=$(df $PWD | awk '/[0-9]%/{print $(NF-2)}' 2> /dev/null)
disk_remain_size_gb=$((${disk_remain_size_kb}/1024/1024))

echo -e "剩余空间${disk_remain_size_gb}GB"

## 如可用空间小于保留磁盘空间,则将默认策略改为删除

if [[ ${disk_remain_size_gb} -le ${policy_preserved_disk_size} ]]; then
	policy_default="delete"
fi

## 上传至onedrive或者任何rclone已连接的云端储存

upload_onedrive(){
	if [[ ${file_num} -lt 1 ]]; then
		echo "[${gid}] 文件数量小于1,可能下载失败" &>> /var/log/rclone/upload.log
		exit 1;
	fi
	if [[ ${file_num} -gt 1 ]]; then
		## 如默认策略为删除,则强制删除已下载档案。
		if [[ ${policy_default} == "delete" ]] || [[ ${file_folder_size} -gt ${policy_default_delete_file_size} ]]; then
			echo "[${gid}] 文件数量大于1,可能为bt下载,检测到默认策略为删除,上传档案并删除" &>> /var/log/rclone/upload.log
			rclone copy -v "${file_folder}" ${rclone_name}:${policy_default_path} -v &>> /var/log/rclone/upload.log && rm -rf ${file_folder}
			exit 0;
		fi
		## 新建screen上传文件
		echo "[${gid}] 文件数量大于1,可能为bt下载,默认保留文件并上传" &>> /var/log/rclone/upload.log
		rclone copy -v "${file_folder}" ${rclone_name}:${policy_default_path} -v &>> /var/log/rclone/upload.log
		exit 0;
	fi
	## 如默认策略为删除,则强制删除已下载档案。
	if [[ ${policy_default} == "delete" ]] || [[ ${file_folder_size} -gt ${policy_default_delete_file_size} ]]; then
		echo "[${gid}] 文件数量等于1,可能为http(s)/ftp(s)下载,检测到默认策略为删除,上传档案并删除" &>> /var/log/rclone/upload.log
		rclone copy -v "${file_path}" ${rclone_name}:${policy_default_path} -v &>> /var/log/rclone/upload.log && rm -rf ${file_path}
		exit 0;
	fi
	## 新建screen上传文件
		echo "[${gid}] 文件数量等于1,可能为http(s)/ftp(s)下载,默认保留文件并上传" &>> /var/log/rclone/upload.log
		rclone copy -v "${file_path}" ${rclone_name}:${policy_default_path} -v &>> /var/log/rclone/upload.log
		exit 0;
}

echo "开始上传"
upload_onedrive
