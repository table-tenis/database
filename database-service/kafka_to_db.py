"""simple consumer"""
import struct
import base64
from json import loads
from datetime import datetime
import time
import sqlalchemy
from sqlalchemy import create_engine, Integer, String, Column
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import select
engine = create_engine("mariadb+mariadbconnector://root:root@127.0.0.1:3308/xface_system", echo=True)
print(engine.connect())

Base = declarative_base(engine)
class Detection(Base):
    __tablename__ = 'detection'
    __table_args__ = {'autoload': True}
    
class Staff(Base):
    __tablename__ = 'staff'
    __table_args__ = {'autoload': True}
    
class Camera(Base):
    __tablename__ = 'camera'
    __table_args__ = {'autoload': True}

from confluent_kafka import Consumer

consumer = Consumer({
    'bootstrap.servers': 'localhost:29092',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': 'false',
    'auto.commit.interval.ms': 1000,
    'group.id': 'mygroup'
})
Session = sqlalchemy.orm.sessionmaker(bind=engine)
SESSION = Session()

consumer.subscribe(['C1_example_topic'])

index = 0
def datetime_to_str(date_obj):
    if(date_obj == None or (isinstance(date_obj, datetime) == False)):
      return None
    try:
      return datetime.strftime(date_obj, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError as err:
      print('ValueError: ', err)
    
list_data = []  
while True:
    start_time = time.time()
    msg = consumer.poll(1.0)

    if msg is None:
        continue
    if msg.error():
        print(f"Consumer error: {msg.error()}")
        continue
    data = loads(msg.value())
    staff = SESSION.execute(select(Staff).where(Staff.staff_code == data['staffCode'])).first()
    camera = SESSION.execute(select(Camera).where(Camera.ip == data['ip'])).first()
    insert_data = {'staff_id':staff[0].id, 'cam_id':camera[0].id, 'session_id':1,
                   'frame_id':1, 'detection_time':datetime_to_str(datetime.fromtimestamp(data['detectionTime']/1000.0)), 
                   'detection_score':data['confidence'],
                   'box_x':1, 'box_y':1, 'box_width':1, 'box_height':1}
    # print("detection time = ", insert_data['detection_time'])
    list_data.append(insert_data)
    return_commit = consumer.commit(msg, asynchronous=True)
    print('return_commit = ', return_commit)
    if(len(list_data) >= 100):
        SESSION.execute(Detection.__table__.insert(), list_data)
        SESSION.commit()
        insert_time = (time.time() - start_time)*1000.0
        print("==================== insert-time = ", insert_time, " milliseconds")
        list_data.clear()
    # else:
    #     load_time = (time.time() - start_time)*1000.0
    #     print("=================== load-time = ", load_time)
    # print(f'Received message: {index}:', staff[0].id, staff[0].staff_code, ', type = ', type(staff[0]))

consumer.close()