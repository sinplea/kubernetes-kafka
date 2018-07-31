# Add a task to be ran on the Kafka Connect cluster
curl -X POST -H "Content-Type: application/json" --data '{"name": "jdbc-test", "config": {"connector.class":  "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306/'$DATABASE_NAME'?user='$DATABASE_USER'&password='$DATABASE_PASSWORD'", "mode": "timestamp+incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "postgres-", "poll.interval.ms": 1000 }}' http://localhost:8083/connectors

curl -X POST -H "Content-Type: application/json" --data '{"name": "jdbc-test", "config": {"connector.class":  "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306/'$DATABASE_NAME'?user=postgres&password=root", "mode": "timestamp+incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "postgres-", "poll.interval.ms": 1000 }}' http://localhost:8083/connectors

# Checking the status of a task
curl -s -X GET http://localhost:8082/connectors/jdbc-test/status

# For a full list of API commands, see:
# https://docs.confluent.io/current/connect/references/restapi.html
