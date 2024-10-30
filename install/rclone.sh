#!/usr/bin/env bash

## Rclone模组 Rclone moudle

set +e

install_rclone(){
	set +e
	curl https://rclone.org/install.sh | bash
	apt-get install fuse -y
}
