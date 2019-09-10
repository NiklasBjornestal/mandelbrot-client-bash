mkdir -p "jobs_tmp"
rm jobs_tmp/*

MINCRE=$1
MINCIM=$2
MAXCRE=$3
MAXCIM=$4
MAXN=$5
XSIZE=$6
YSIZE=$7
DIVISIONS=$8
JOB_XSIZE=$((XSIZE / DIVISIONS))
JOB_YSIZE=$((YSIZE / DIVISIONS))
REPIXSIZE=`bc -l <<< "(($MAXCRE)-($MINCRE))/$XSIZE"`;
IMPIXSIZE=`bc -l <<< "(($MAXCIM)-($MINCIM))/$YSIZE"`

NUMSERVERS=$(($#-9))
for (( ROW=0; ROW<$DIVISIONS; ROW++ )); do
  for (( COL=0; COL<$DIVISIONS; COL++)); do 
	JOB_MINCRE=`bc -l <<< "$MINCRE + $COL * $JOB_XSIZE * $REPIXSIZE"`
	JOB_MINCIM=`bc -l <<< "$MINCIM + $ROW * $JOB_YSIZE * $IMPIXSIZE"`
	JOB_MAXCRE=`bc -l <<< "$JOB_MINCRE + ($JOB_XSIZE - 1) * $REPIXSIZE"`
	JOB_MAXCIM=`bc -l <<< "$JOB_MINCIM + ($JOB_YSIZE - 1) * $IMPIXSIZE"`
	ROWZ=$(printf "%03d" $ROW)
	COLZ=$(printf "%03d" $COL)
	echo "mandelbrot/$JOB_MINCRE/$JOB_MINCIM/$JOB_MAXCRE/$JOB_MAXCIM/$JOB_XSIZE/$JOB_YSIZE/$MAXN | convert -size ${JOB_XSIZE}x${JOB_YSIZE} -depth 8 gray:- jobs_tmp/image_${ROWZ}_${COLZ}.pgm" >> jobs_tmp/jobs;
  done;
done;

for i in $(seq 9 $#); do
    ./worker.sh ${!i} &
    pids[${i}]=$!
done

for pid in ${pids[*]}; do
    wait $pid
done


montage -geometry ${size}x${size}+0+0 jobs_tmp/image*.pgm image.pgm
