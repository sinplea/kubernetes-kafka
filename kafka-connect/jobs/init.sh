# Exec into kafka connect and run
curl -X POST -H "Content-Type: application/json" --data '{"name": "kafka-connect-jdbc", "config": {"connector.class":  "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306?user=postgres&password=root", "mode": "timestamp+incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "postgres-", "poll.interval.ms": 1000 }}' http://localhost:8082/connectors

# Check status of connector
curl -s -X GET http://localhost:8082/connectors/kafka-connect-jdbc/status