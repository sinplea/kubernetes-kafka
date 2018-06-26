#!/bin/bash 

kafka_manager_pod_name="$(kubectl get pods -n kafka | grep kafka-manager | cut -d ' ' -f 1)"
kafka_topics_ui_pod_name="$(kubectl get pods -n kafka | grep kafka-topics-ui | cut -d ' ' -f 1)"
zoonavigator_pod_name="$(kubectl get pods -n kafka | grep zoonavigator | cut -d ' ' -f 1)"

kubectl port-forward -n kafka $kafka_manager_pod_name 8080:8000 &
kubectl port-forward -n kafka $kafka_topics_ui_pod_name 8081:80 &
kubectl port-forward -n kafka $zoonavigator_pod_name 8082:8001 &
