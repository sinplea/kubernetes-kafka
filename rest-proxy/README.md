## [Confluent's REST Proxy](https://docs.confluent.io/current/kafka-rest/docs/intro.html)

### Why a rest proxy?

Confluent's REST Proxy provides applications with a ubiquitous language for interacting with a Kafka cluster: REST. The REST Proxy is particularly useful for producers who would like to send Avro data to Kafka but are lacking a well supported version of the Kafka Producer API. When posting an Avro message to the REST Proxy, the REST Proxy will communicate with Confluent's Schema Registry to validate or register a schema. If valid, the message will be saved to a Kafka topic and the producer will recieve a ```200``` status code.

### Usage

> The following examples are found in the link above.

#### Producing an Avro message.

```
curl -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" \
      -H "Accept: application/vnd.kafka.v2+json" \
      --data '{"value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}]}", "records": [{"value": {"name": "testUser"}}]}' \
      "http://localhost:8082/topics/avrotest"
```

(The body of the post request with better formatting)

```json{.line-numbers}
{
    "value_schema": {
        "type": "record", 
        "name": "User",
        "fields": [
            { "name": "name", "type": "string" }
        ]
    },
    "records": [
        { "value": { "name": "testUser"} }
    ]
}
```

#### Producing a keyed Avro message

Supply a key schema.

```
curl -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" \
      -H "Accept: application/vnd.kafka.v2+json" \
      --data '{"key_schema": "{\"name\":\"user_id\"  ,\"type\": \"int\"   }", "value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}]}", "records": [{"key" : 1 , "value": {"name": "testUser"}}]}' \
      "http://localhost:8082/topics/avrokeytest2"
```

```json{.line-numbers}
{
    "key_schema": {
        "name": "user_id",
        "type": "int"
    },
    "value_schema": {
        "type": "record", 
        "name": "User",
        "fields": [
            { "name": "name", "type": "string" }
        ]
    },
    "records": [
        { "value": { "name": "testUser"} }
    ]
}
```