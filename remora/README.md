## [Remora](https://github.com/zalando-incubator/remora)

### What's it for?

As more and more service begin depending on Kafka, it will become increasingly apparant that Kafka must be monitored for various performance metrics like network bandwidth, disk usage, consumer lag, etc... Consumer lag is when a consumer struggles to keep up with events as they come into a topic. For example, if the latest offset of a topic is O(1000) and consumer C1 is at O(900), the consumer is 100 messages behind the latest message. Maybe this isn't so bad, but if you leave for lunch, come back, and see that C1 is at O(1000) and the latest offset is at O(5000), there is clear problem as the consumer, rather than catching up to the latest offset is getting further and further behind.

### Checking consumer lag

Start by either port-forwarding with kubectl or entering the remora container.

To port-forward:

```
kubectl port-forward -n kafka <remora-pod> 9000
```

To enter the container

```
kubectl exec -it -n kafka <remora-pod> -- bash
```

```
$ curl http://localhost:9000/consumers/<ConsumerGroupId>
{  
   "state":"Empty",
   "partition_assignment":[  
      {  
         "group":"console-consumer-20891",
         "coordinator":{  
            "id":0,
            "id_string":"0",
            "host":"foo.company.com",
            "port":9092
         },
         "topic":"products-in",
         "partition":1,
         "offset":3,
         "lag":0,
         "consumer_id":"-",
         "host":"-",
         "client_id":"-",
         "log_end_offset":3
      },
      {  
         "group":"console-consumer-20891",
         "coordinator":{  
            "id":0,
            "id_string":"0",
            "host":"foo.company.com",
            "port":9092
         },
         "topic":"products-in",
         "partition":0,
         "offset":3,
         "lag":0,
         "consumer_id":"consumer-1-7baba9b9-0ec3-4241-9433-f36255dd4708",
         "host":"/xx.xxx.xxx.xxx",
         "client_id":"consumer-1",
         "log_end_offset":3
      }
   ],
   "lag_per_topic":{
        "products-in" : 0
   }
}
```

> There are also global metrics provided by Remora that may prove to be useful. See the Remora docs for more info.