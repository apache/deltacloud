#! /bin/bash
# Restart the prod server (https://api.deltacloud.org)
# FIXME: This is a crazy hack. There's no clean separation of code and runtime
# files (like pid_file)

gem_dir=${HOME}/gems
port=3001
pid_file=${HOME}/pids/thin-prod.pid
logdir=${HOME}/log
deltacloudd=$gem_dir/bin/deltacloudd
servername=api.deltacloud.org

exec >> $logdir/prod-update.log
echo "Restarting $servername at $(date)"

[ -f $pid_file ] && thin -P $pid_file stop

export GEM_PATH=$gem_dir:$GEM_HOME:/usr/lib/ruby/gems/1.8
$deltacloudd -i ec2 -p $port -e production -f deltacloud,cimi,ec2 -d --pid $pid_file --logdir $logdir/prod

echo "Done at $(date)"
echo
