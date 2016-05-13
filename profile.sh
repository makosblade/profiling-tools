DIR=`pwd`
git submodule init
git submodule update
export AGENT_HOME=`pwd`\/perf-map-agent
cd perf-map-agent
cmake .
make
if [ ! -f ../perf-java-top ] 
then
  ./bin/create-links-in ../
fi

cd $DIR
if [ $# -ge 1 ] 
then
  perf record -F 99 -a -g -- sleep 30; ./Misc/java/jmaps
  perf script > out.stacks01
  cat out.stacks01 | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl --color=java --hash > flame-all.svg
else
  perf record -F 99 -p $PID -g -- sleep 30; ./drewmaps $PID
  perf script > out.stacks01
  cat out.stacks01 | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl --color=java --hash > flame-$PID.svg
fi

#.for pid in $*; do
#  java -cp attach-main.jar:$JAVA_HOME/lib/tools.jar net.virtualvoid.perf.AttachOnce $pid
#done
