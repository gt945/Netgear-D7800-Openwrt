#!/bin/sh
for i in $(seq 1200); do
	sleep 3
	echo $i > /tmp/dsl_time
done
	rm -rf /tmp/dsl_time
