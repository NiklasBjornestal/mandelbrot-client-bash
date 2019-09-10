exec 8>jobs_tmp/lock
while [ -s jobs_tmp/jobs ]; do
    flock -x 8
    JOB=`head -1 jobs_tmp/jobs`
    sed -i '1d' jobs_tmp/jobs
    flock -u 8
	eval "curl http://$1/$JOB"
done

