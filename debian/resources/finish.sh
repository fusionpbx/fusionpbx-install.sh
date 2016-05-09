#!/bin/bash
echo "Waiting for config.php to exist."
seconds=0
while [ ! -f /tmp/test.txt ] && [ ! -f /tmp/test2.txt ]
do
  echo -ne "$seconds\033[o\r"
  sleep 1
  seconds=$((seconds+1))
done

if [ -f /tmp/test.txt ] || [ -f /tmp/test2.txt ]
then
 echo "The config.php has been found."
fi

echo "Waiting 30 more seconds before continuing."
seconds=0
while [ $seconds -lt 30 ]
do
  echo -ne "$seconds\033[o\r"
  sleep 1
  seconds=$((seconds+1))
done

#restart freeswitch
/bin/systemctl daemon-reload
/bin/systemctl restart freeswitch
