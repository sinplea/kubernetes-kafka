## Kafka Connect
---

### About the deployment

Kafka connect is horizontally scalable. If you increase the number of replicas for this deployment, you will effectively increase Kafka Connect's compute power.

```yaml{.line-numbers}
replicas: 1
```

Notice there is a podStart lifecycle hook on the kafka-connect container. This hook will run a curl command on container start to download the JDBC driver that is needed for the connector to connect to a JDBC compatible database. (MySQL, Postgres, SQLite).

```yaml{.line-numbers}
lifecycle:
    postStart:
    exec:
        command: ["/bin/sh", "-c",
        "curl -O https://jdbc.postgresql.org/download/postgresql-42.2.2.jre6.jar && mv postgresql-42.2.2.jre6.jar /usr/share/java/kafka-connect-jdbc"]
```

Note the connector will be installed at ```/usr/share/java/kafka-connect-jdbc```, so another connector must be installed at this location as well. (e.g. ```/usr/share/java/other-connector```).

The Kafka Connect cluster will obviously need permission to access your database. These will come from Kubernetes credentials as environment variables.

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

The list of environment variables used are documented by [Confluent](https://docs.confluent.io/current/connect/userguide.html) if you want more details.

This service is exposed on port ```8083```

### Using Kafka Connect.

This example will use the bash scripts found in ```kafka-connect/scripts/``` This example will go over how to use Kafka Connect with Postgres.

In the following examples, I will be using telepresence.io to access resources in my cluster. If you are not using telepresence, you can copy the curl commands from the bash scripts, change the dynamically configured parameters, exec into the Kafka Connect deploymenet via kubectl (```kubectl exec -it <kafka-connect-pod> -n kafka -- bash```) and run curl commands from there.

The following commands will assume your are located in ```kafka-connect/scripts```

> Curl commands to be copied will be marked in the code with a comment: # COPY_CURL

#### Start telepresence

```bash
telepresence --run-shell
...
$yourcluster~
```

#### Adding a JDBC Source connector.

```{.line-numbers}
Name a task for your connector: my-cool-task
Select an available connector class (JDBC): JDBC
Select a mode (timestamp, incrementing, timestamp+incrementing): timestamp
Enter a prefix for your Kafka topic: postgres- 

Adding connector...
```

You can then check the status of the connector via ```check_connector_status.sh```

```
$ bash check_connector_status.sh
...
Connector status: RUNNING
```

If the task is running, then Kafka Connect is working properly and is now pulling tables from your database into kafka topics prefixed by the prefix given. That's it. You now have a topic that is being filled dynamically by updates to Postgres

> Note: how the topic receives messages from Postgres is based on the selected mode. 

```timestamp``` will look for a column named ```modified``` in you database. Any time a record is updated and ```modified``` is changed. A message containing the record will be sent to the Kafka topic. Effectively you are watching for updates to your rows.

```incrementing``` will look for column named ```id``` in your database. If a new record is added with a new ```id``` a message will be sent to a Kafka topic. Effectively you are watching for the insertions of new rows.

```timestamp+incrementing``` is a combination of both updates and inserts.

> There is no way to check for delete events with the vanilla JDBC connector. If you are able to use the Debezium connector, you can then check for deletion events; howerver, debezium is only available for on-prem databases or databases on AWS.


