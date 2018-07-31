## Kafka Connect
---

### About the deployment

Kafka connect is horizontally scalable. If you increase the number of replicas for this deployment, you will effectively increase Kafka Connect's compute power.

```yaml{.line-numbers}
replicas: 1
```

Notice there is a podStart lifecycle hook on the kafka-connect container. This hook will curl to download the JDBC driver that is needed for the connector to connect to a JDBC compatible database. (MySQL, Postgres, SQLite).

```yaml{.line-numbers}
lifecycle:
    postStart:
    exec:
        command: ["/bin/sh", "-c",
        "curl -O https://jdbc.postgresql.org/download/postgresql-42.2.2.jre6.jar && mv postgresql-42.2.2.jre6.jar /usr/share/java/kafka-connect-jdbc"]
```

Note the connector will be installed at ```/usr/share/java/kafka-connect-jdbc```, so other drivers must also be installed at this location. (e.g. ```/usr/share/java/other-connector```).

The Kafka Connect cluster will need permission to access your database. These are assumed to come from Kubernetes credentials as environment variables.

```yaml{.line-numbers}
env:
    - name: DATABASE_NAME
        value: postgres
    - name: DATABASE_USER
        valueFrom:
        secretKeyRef:
            name: cloudsql-db-credentials
            key: username
    - name: DATABASE_PASSWORD
        valueFrom:
        secretKeyRef:
            name: cloudsql-db-credentials
            key: password
```

The full list of environment variables used are documented by [Confluent](https://docs.confluent.io/current/connect/userguide.html) if you want more details.

This service is exposed on port ```8083```

### Using Kafka Connect.

Unfortunately, because Kafka Connect uses some container specific environment variables we are unable to run a script outside or inside (via telepresence.io) our cluster to make configuring and managing our connectors a little less annoying.

> I'm considering adding shell scripts for installing connectors. Scripts could be added to a configmap, but I haven't worked out the limitations / benefits to this approach. Shell scripts could be attached to a lifecycle hook, reducing the manual nature of this process, but it is not very often one will need to mess with Kafka Connect and its connectors.

The following curl requests will need to be ran inside of a kafka-connect container:

```
$ kubectl exec -it -n kafka <kafka-connect-pod> -- bash
```

#### Adding a JDBC Source connector.

To add a JDBC source connector

```
curl -X POST -H "Content-Type: application/json" --data '{"name": "jdbc-test", "config": {"connector.class":  "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:postgresql://127.0.0.1:3306/'$DATABASE_NAME'?user='$DATABASE_USER'&password='$DATABASE_PASSWORD'", "mode": "timestamp+incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "postgres-", "poll.interval.ms": 1000 }}' http://localhost:8083/connectors
```

Some parameters to note:

```name``` is the name of the connector instance. This name will be how you query other API endpoints to interact with this running process (e.g ``` curl -X DELETE http://localhost:8083/connectors/<name>``` to delete a connector)

```mode``` defines when messages will be written to the Kafka topic from the database. (more info below)

```incrementing.column.name``` represents a column in the database that is a unique number to each entry.

```timestamp.column.name``` represents a column in the database that is a timestamp that is modified when a row is changed.

```topic.prefix``` is the prefix to the Kafka topic where database data will be saved with the Kafka Cluster. From the above example the topic name will be prefixed with ```postgres-```

#### Checking connector status

You can then check the status of the connector via 

> curl -X GET http://localhost:8082/connectors/jdbc-test/status

If the task is running, then Kafka Connect is working properly and is now pulling tables from your database into kafka topics with names matching the database table name, prefixed by the given prefix. That's it. You now have a topic that is being filled dynamically from Postgres

> Notice how the topic receives messages from Postgres based on the selected mode. 

Based con the configuration of our connector, ```timestamp``` will look for a column named ```modified``` in you database. Any time a record is updated and ```modified``` is changed, a message containing the record will be sent to the Kafka topic. Effectively you are watching for updates to your rows.

```incrementing``` will look for column named ```id``` in your database. If a new record is added with a new ```id``` a message will be sent to a Kafka topic. Effectively you are watching for the insertions of new rows.

```timestamp+incrementing``` is a combination of both updates and inserts.

> There is no way to check for delete events with the vanilla JDBC connector. If you are able to use the Debezium connector, you can then check for deletion events; however, Debezium is not available for cloud-based databases except for those running on AWS.
