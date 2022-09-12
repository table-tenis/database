# **Database Services**

## **Requirements**
- confluent_kafka
- sqlalchemy
- pandas
## **Installation**
```
python3 -m pip install -r requirements.txt
```
## **What The Services Do**
- kafka_to_db is service to consume data from kafka server and insert it into database.
- dump_facedata_db is service to dump existed enterprise data from data folder into database.
## **How To Run**
- Run kafka database service.
```
python3 kafka_to_db.py
```
- Run dump_facedata_db service.
```
python3 dump_facedata_db.py
```


