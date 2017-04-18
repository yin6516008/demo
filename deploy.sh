#!/bin/bash
#

#time
CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%Y-%m-%d-%H-%M")

#shell
CODE_DIR="/deploy/code/demo"
CONFIG_DIR="/deploy/config"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"

#git函数，拉取新版本到本地，并且取得commit id 和commit id前五位，后面用来当作版本名，然后拷贝到/deploy/tmp下，后续好在/deploy/tmp下操作
git_pro(){
    echo "begin git pull"   
    cd "$CODE_DIR" && git pull
    COMMIT_ID=$(git show |grep commit |awk '{print $2}')
    COMMIT_ID5=$(echo ${COMMIT_ID:0:6})
    cp -r "$CODE_DIR" "$TMP_DIR"
}

#配置文件的函数，拷贝配置文件到/deploy/tmp/demo下，和代码放一起，方便打包和后续推送。
#并且把代码目录以commit id前五位和当前时间命名
config_pro(){
    echo "add config file"
    /bin/cp "$CONFIG_DIR"/*  $TMP_DIR/demo/
    TAR_VER="$COMMIT_ID5"_"$CTIME"
    cd $TMP_DIR && mv demo pro_demo_"$TAR_VER"
}

#打包代码
tar_pro(){
    echo "tar pro"
    cd $TMP_DIR && tar czf pro_demo_"$TAR_VER".tar.gz pro_demo_"$TAR_VER"
    echo "tar end pro_demo_"$TAR_VER".tar.gz"
}

#发送到需要更新的节点上，实际情况中，可能需要使用scp到节点上
copy_pro(){
    echo "begin copy"
    /bin/cp $TMP_DIR/pro_demo_"$TAR_VER".tar.gz /tmp
}

#发送到节点上后，可能需要先从集群上移除节点，然后更新代码。
#remove_node(){
#
#}

#部署。在/tmp下解压新代码，删除之前软连接，创建新软连接
deploy_pro(){
    echo "begin deploy"
    cd /tmp && tar zxf pro_demo_"$TAR_VER".tar.gz
    rm -f /var/www/html/demo
    ln -sv /tmp/pro_demo_"$TAR_VER"  /var/www/html/demo
}



#部署好新代码后，可能需要重新载入配置文件。或重启
#reload_pro(){
#}

#测试新代码。此处按实际业务情况进行测试
test_pro(){
    echo "test begin"
    echo "test ok"

}


#测试完毕后，从集群上添加到节点
#add_node(){
#
#
#
#}

#列出所有老版本
rollback_list(){
    ls -l /tmp/*.tar.gz
}

#回滚到老版本，$1为老版本文件夹
rollback_pro(){
    rm -f /var/www/html/demo
    ln -sv "/tmp/$1" /var/www/html/demo
}

#用法
usege(){
    echo "$0 usege [ deploy | rollback-list | rollback version]"
}

#main方法
main(){
    case $1 in
	deploy)
	    git_pro;
	    config_pro;
	    tar_pro;
   	    copy_pro;
	    deploy_pro;
	    test_pro;
	    ;;
	rollback-list)
	    rollback_list ;
	    ;;
	rollback)
	    rollback_pro $2;
	    ;;
      	*)
	    usege;
	esac
}

main $1 $2
