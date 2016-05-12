PID=$1
DIR=`pwd`
git submodule init
git submodule update
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
perf record -F 99 -p $PID -g -- sleep 30; ./Misc/java/jmaps
perf script > out.stacks01
cat out.stacks01 | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl --color=java --hash > flame01.svg
