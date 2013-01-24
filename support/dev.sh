#! /bin/bash
# Restart the dev server (https://dev.deltacloud.org)

dev_dir=${HOME}/code/deltacloud/server
port=3002
pid_file=${HOME}/pids/thin-dev.pid
logdir=${HOME}/log
deltacloudd=$dev_dir/bin/deltacloudd
servername=dev.deltacloud.org

cd $dev_dir

exec >> $logdir/dev-update.log
echo "Restarting $servername at $(date)"

[ -f $pid_file ] && thin -P $pid_file stop

# update the git checkout
git pull
bundle update
rake mock:fixtures:reset 2>&1

$deltacloudd -c -i mock -p $port -e production -f deltacloud,cimi,ec2 -d --pid $pid_file --logdir $logdir/dev

echo "Done at $(date)"
echo
