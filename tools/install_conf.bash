#!/bin/bash

set -e
set -x

git config --global user.email foo@acme.com
git config --global user.name "John Doe"

mkdir -p /etc/{hadoop,hive,tez}
#cp -r /hadoop/etc/hadoop /etc/
#cp -r /hive/conf/ /etc/hive/

conf init

for u in root vagrant dev hive;do
        conf set hadoop/core-site hadoop.proxyuser.${u}.groups '*'
        conf set hadoop/core-site hadoop.proxyuser.${u}.hosts '*'
done
conf set hadoop/core-site hadoop.tmp.dir '/data/hadoop-${user.name}'

conf set hadoop/yarn-site yarn.nodemanager.aux-services mapreduce_shuffle
conf set hadoop/yarn-site yarn.nodemanager.aux-services.mapreduce_shuffle.class org.apache.hadoop.mapred.ShuffleHandler
conf set hadoop/yarn-site yarn.nodemanager.resource.memory-mb 8192
conf set hadoop/yarn-site yarn.nodemanager.resource.cpu-vcores 2
conf set hadoop/yarn-site yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage 99

conf set hadoop/hdfs-site dfs.replication 1

conf set hadoop/capacity-scheduler yarn.scheduler.capacity.maximum-am-resource-percent 0.6
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.resource-calculator org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.root.queues default
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.root.default.capacity 100
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.root.default.user-limit-factor 1
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.root.default.maximum-capacity 100
conf set hadoop/capacity-scheduler yarn.scheduler.capacity.root.default.state RUNNING
#yarn.scheduler.capacity.root.default.acl_submit_applications '*'
#yarn.scheduler.capacity.root.default.acl_administer_queue '*'
#yarn.scheduler.capacity.root.default.acl_application_max_priority '*'
#yarn.scheduler.capacity.root.default.maximum-application-lifetime -1
#yarn.scheduler.capacity.root.default.default-application-lifetime -1
#yarn.scheduler.capacity.node-locality-delay 40
#yarn.scheduler.capacity.rack-locality-additional-delay -1
#yarn.scheduler.capacity.queue-mappings ''

conf set tez/tez-site tez.lib.uris '${fs.defaultFS}/apps/tez/tez.tar.gz'
#conf set tez/tez-site tez.am.resource.memory.mb 512

conf set hive/hive-site hive.metastore.warehouse.dir /data/hive/warehouse
# FIXME: probably defunct
conf set hive/hive-site hive.metastore.local true
conf set hive/hive-site hive.user.install.directory file:///tmp
conf set hive/hive-site hive.execution.engine tez
conf set hive/hive-site hive.log.explain.output true
conf set hive/hive-site hive.in.test true
conf set hive/hive-site hive.exec.scratchdir /data/hive
# FIXME: this might not needed...but for me it is :)
conf set hive/hive-site yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage 99

conf set hive/hive-site hive.tez.container.size 3356
conf set hive/hive-site hive.tez.java.opts -Xmx2g

# enable transactions support
conf set hive/hive-site hive.support.concurrency true
conf set hive/hive-site hive.txn.manager org.apache.hadoop.hive.ql.lockmgr.DbTxnManager
conf set hive/hive-site hive.mapred.mode nonstrict # not sure if this is also needed

# disable results cache as it usually an obstacle during debugging..
conf set hive/hive-site hive.query.results.cache.enabled false


mkdir -p /data/hive /data/log /apps/lib /apps/tez /work /active ~dev/.m2 ~dev/.config
chown dev /data{,/hive,/log} /apps/lib /apps/tez /work /active /apps ~dev/.m2 ~dev/.config
chmod 777 -R /data

# use ssd for docker

# FIXME: fix sdkman
cat > /etc/profile.d/confs.sh << EOF

export HADOOP_CONF_DIR=/etc/hadoop
export HADOOP_LOG_DIR=/data/log
export HADOOP_CLASSPATH=/etc/tez/:/active/tez/lib/*:/active/tez/*:/apps/lib/*
export HIVE_CONF_DIR=/etc/hive/

export JAVA_HOME=/usr/lib/jvm/zulu-8-amd64/

export PATH=$PATH:/active/hive/bin:/active/hadoop/bin:/active/eclipse/:/active/maven/bin/:/active/protobuf/bin:/active/jvisualvm/bin


EOF
