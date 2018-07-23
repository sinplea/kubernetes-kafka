curl -X POST -H "Content-Type: application/json" --data '{ "name": "jdbc-source", "config": { "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306/$DATABASE_NAME?user=$DATABASE_USER&password=$DATABASE_PASSWORD", "mode": "timestamp+incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "p-jdbc-", "poll.interval.ms": 1000 }}'