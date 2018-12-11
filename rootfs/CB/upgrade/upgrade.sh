PRG="$0"
while [ -h "$PRG" ] ; do
	ls=`ls -ld "$PRG"`
	link=`expr "$ls" : '.*-> \(.*\)$'`
	if expr "$link" : '.*/.*' > /dev/null; then
		PRG="$link"
	else
		PRG=`dirname "$PRG"`/"$link"
	fi
done

PRGDIR=`dirname "$PRG"`
cd $PRGDIR/..
UPGRADEPATH=`pwd`
$UPGRADEPATH/upgrade/apache-ant/bin/ant -f $UPGRADEPATH/upgrade/upgrade.xml
