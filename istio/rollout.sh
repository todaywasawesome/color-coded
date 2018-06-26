#!/bin/bash

#Our istio update loop

healthcheck(){
	echo "Starting Heathcheck"
	h=true
	#Start custom healthcheck
	output=$(kubectl get pods -l app="$CANARY_HOST_NAME" -n canary --no-headers)
	s=($(echo "$output" | awk '{s+=$4}END{print s}'))
	c=($(echo "$output" | wc -l))

	if [ "$s" -gt "2" ]; then
		h=false
	fi
	#End custom healthcheck
	if [ ! $h == true ]; then
		cancel
		echo "Exit failed"
	else
		echo "Service healthy."
	fi
}

cancel(){
	echo "Cancelling rollout"
	m="cancel"
	cp istio/canary.yml $WORKING_VOLUME/canary_$m.yml
    echo "    - destination:" >> $WORKING_VOLUME/canary_$m.yml
    echo "        host:" "$CURRENT_HOST_NAME" >> $WORKING_VOLUME/canary_$m.yml
    echo "        port:" >> $WORKING_VOLUME/canary_$m.yml
    echo "          number:" 80 >> $WORKING_VOLUME/canary_$m.yml
    echo "      weight:" "100" >> $WORKING_VOLUME/canary_$m.yml
    echo "Done building config..."
    cat $WORKING_VOLUME/canary_$m.yml
    istioctl replace -f $WORKING_VOLUME/canary_$m.yml -n $NAMESPACE -c $KUBE 
    echo "Canary removed from network."
    exit 1
}

incrementservice(){
	#Pass $1 = canary traffic increment
	m=$1
	echo "Creating $WORKING_VOLUME/canary_$m.yml ..."
	cp istio/canary.yml $WORKING_VOLUME/canary_$m.yml
	if [ "$m" -lt "100" ]; then #Route die traffic to canary version only for the demo.
		echo "  - match:" >> $WORKING_VOLUME/canary_$m.yml
		echo "    - uri:" >> $WORKING_VOLUME/canary_$m.yml
		echo "        prefix: \"/die\"" >> $WORKING_VOLUME/canary_$m.yml
		echo "    route:" >> $WORKING_VOLUME/canary_$m.yml
		echo "    - destination:" >> $WORKING_VOLUME/canary_$m.yml
		echo "        host:" "$CANARY_HOST_NAME" >> $WORKING_VOLUME/canary_$m.yml
		echo "        port:" >> $WORKING_VOLUME/canary_$m.yml
		echo "          number: 80" >> $WORKING_VOLUME/canary_$m.yml
	fi
	echo "  - route:" >> $WORKING_VOLUME/canary_$m.yml #Always prefix the route
	if [ "$m" -lt "100" ]; then #Add old version
		echo "    - destination:" >> $WORKING_VOLUME/canary_$m.yml
	    echo "        host:" "$CURRENT_HOST_NAME" >> $WORKING_VOLUME/canary_$m.yml
	    echo "        port:" >> $WORKING_VOLUME/canary_$m.yml
	    echo "          number:" 80 >> $WORKING_VOLUME/canary_$m.yml
	    echo "      weight:" $((100-$m)) >> $WORKING_VOLUME/canary_$m.yml
	fi
    echo "Add Canary" #Add new version
    echo "    - destination:" >> $WORKING_VOLUME/canary_$m.yml
    echo "        host:" "$CANARY_HOST_NAME" >> $WORKING_VOLUME/canary_$m.yml
    echo "        port:" >> $WORKING_VOLUME/canary_$m.yml
    echo "          number:" 80 >> $WORKING_VOLUME/canary_$m.yml
    echo "      weight:" $m >> $WORKING_VOLUME/canary_$m.yml
    echo "Done building config..."
    cat $WORKING_VOLUME/canary_$m.yml
    echo "Applying $WORKING_VOLUME/canary_$m.yml"
    echo "Running istioctl replace -f $WORKING_VOLUME/canary_$m.yml -n $NAMESPACE"
    istioctl replace -f $WORKING_VOLUME/canary_$m.yml -n $NAMESPACE -c $KUBE --log_output_level=debug
    sleep 10s
    echo "Traffic mix updated to $m% for canary."
}

mainloop(){
	while [ $TRAFFIC_INCREMENT -lt 100 ]
	do
		p=$((p + $TRAFFIC_INCREMENT))
		if [ "$p" -gt "100" ]; then
			p=100
		fi
		incrementservice $p

		if [ "$p" == "100" ]; then
			echo "Done"
			exit 0
		fi
		sleep 50s
		healthcheck
	done
}

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ] && [ "$5" != "" ]; then
	echo "Volume Set"
	WORKING_VOLUME=${1%/}
	CURRENT_HOST_NAME=$2
	CANARY_HOST_NAME=$3
	TRAFFIC_INCREMENT=$4
	KUBE=$5
	NAMESPACE=$6
else
	#echo instructions
	echo "USAGE\n rollout.sh [WORKING_VOLUME] [CURRENT_HOST_NAME] [CANARY_HOST_NAME] [TRAFFIC_INCREMENT]"
	echo "\t [WORKING_VOLUME] - This should be set with \${{CF_VOLUME_PATH}}"
	echo "\t [CURRENT_HOST_NAME] - The name of the service currently receiving traffic from the Istio gateway"
	echo "\t [CANARY_HOST_NAME] - The name of the new service we're rolling out."
	echo "\t [TRAFFIC_INCREMENT] - Integer between 1-100 that will step increase traffic"
	echo "\t [NAMESPACE] - Namespace of the application"
	exit 1;
fi

echo $BASH_VERSION
p=0
mainloop
