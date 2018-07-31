## Confluent Platform Schema Registry

### About the schema registry

The schema registry will manage the registration and lookup of Avro schemas. I recommend interacting with the schema registry through a secondary layer of abstraction. For example, if you want to send a Avro formatted message to a Kafka topic, then you should do so through an Avro supported version of the Producers API, or possibly through [Confluent's Rest Proxy](). 

However, the schema registry does have a [REST API](https://docs.confluent.io/current/schema-registry/docs/api.html).

### About the deployment

There is little to mention about this deployment. We create 2 replicas, simply for the sake of maintaining some semblance of fault tolerance.

```yaml
replicas: 1
```

### Notable environment variables

```SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL``` should point to your zookeeper quorum.