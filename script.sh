#!/bin/bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install --namespace aiops --name node-exporter stable/prometheus-node-exporter

helm install --name database eskibana/ --values eskibana/values.yaml --namespace=aiops

Is_ready=$(kubectl get pod -n aiops | awk '/elasticsearch/{sub(/.*elasticsearch/, ""); print $2}')
echo $Is_ready

ready="1/1"

while true
do
	if [[ $Is_ready == *"$ready"* ]]
	then 
		echo "Enter user name : "
		read User_name

		helm install --name log logcollector/ --values logcollector/values.yaml --namespace=aiops --set env.eventLogIndexValue=$User_name --set env.podLogIndexValue=$User_name

		helm install --name metric metriccollector/ --values metriccollector/values.yaml --namespace=aiops --set env.metricLogIndexValue=$User_name --set env.prometheusLogIndexValue=$User_name
		break
	else	
		echo "NOT READY CONTAINER\n"
		sleep 5
		Is_ready=$(kubectl get pod -n aiops | awk '/elasticsearch/{sub(/.*elasticsearch/, ""); print $2}')	
	fi
done
