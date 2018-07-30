#!/bin/bash

# TODO: Get a list of available connectors via curl

# Getting user input (this is super basic for now)

read -p "Name a task for your connector: " task_name
read -p "Select an available connector class (JDBC): " connector_class_name
read -p "Select a mode (timestamp, incrementing, timestamp+incrementing): " mode
read -p "Enter a prefix for your Kafka topic: " topic_prefix

# Validating inputs
if [connector_class_name == "JDBC"] 
then
    connector_class = "io.confluent.connect.jdbc.JdbcSourceConnector"
fi

# COPY_CURL
curl -X POST -H "Content-Type: application/json" --data '{"name": "'$task_name'''", "config": {"connector.class":  "'$connector_type'", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306/'$DATABASE_NAME'?user='$DATABASE_USER'&password='$DATABASE_PASSWORD'", "mode": "'$mode'", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "'$prefix'", "poll.interval.ms": 1000 }}' http://localhost:8083/connectors