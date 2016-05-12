TYPE=$1
PID=$2
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

cd out
java -cp attach-main.jar:$JAVA_HOME/lib/tools.jar net.virtualvoid.perf.AttachOnce $PID
cd $DIR
if [[ "$TYPE" -eq "multi" ]]
then
  perf record -F 99 -a -g -- sleep 30; ./Misc/java/jmaps
else
  perf record -F 99 -p $PID -g -- sleep 30; ./drewmaps $PID
fi
perf script > out.stacks01
cat out.stacks01 | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl --color=java --hash > flame01.svg
