import pandas as pd 
import numpy as np
from datetime import date, datetime
import sys, os
dir = os.path.dirname(__file__)
sys.path.insert(0, os.path.abspath(os.path.join(dir, '.')))
import mariadb

URL = 'http://172.21.100.254:8080'

import json
import asyncio

from datetime import datetime
import sqlalchemy
from sqlalchemy import create_engine, Integer, String, Column
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import select
engine = create_engine("mariadb+mariadbconnector://xface_client:admin@127.0.0.1:3309/xface_system?charset=utf8", echo=True)
print(engine.connect())

Base = declarative_base(engine)

class Enterprise(Base):
    __tablename__ = 'enterprise'
    __table_args__ = {'autoload': True}
    
class Staff(Base):
    __tablename__ = 'staff'
    __table_args__ = {'autoload': True}
    
class Site(Base):
    __tablename__ = 'site'
    __table_args__ = {'autoload': True}
    
class FaceID(Base):
    __tablename__ = 'faceid'
    __table_args__ = {'autoload': True}
    
class ShiftTime(Base):
    __tablename__ = 'shift_time'
    __table_args__ = {'autoload': True}
    
class ShiftRegister(Base):
    __tablename__ = 'shift_register'
    staff_id = Column(Integer, primary_key=True)
    shift_type = Column(String, primary_key=True)
    weekday = Column(Integer, primary_key=True)
    
class SiteIORegister(Base):
    __tablename__ = 'site_io_register'
    __table_args__ = {'autoload': True}
    
class SessionService(Base):
    __tablename__ = 'session_service'
    __table_args__ = {'autoload': True}
    
class Camera(Base):
    __tablename__ = 'camera'
    __table_args__ = {'autoload': True}

class RestrictedROI(Base):
    __tablename__ = 'restricted_roi'
    __table_args__ = {'autoload': True}

class Detection(Base):
    __tablename__ = 'detection'
    __table_args__ = {'autoload': True}
    
class MOT(Base):
    __tablename__ = 'mot'
    __table_args__ = {'autoload': True}
    
class MTAR(Base):
    __tablename__ = 'mtar'
    __table_args__ = {'autoload': True}

# Create session
Session = sqlalchemy.orm.sessionmaker(bind=engine)
SESSION = Session()

NUM_RECEIVED_PACKET = 0
NUM_INSERTED = 0

def dump_enterprise_data():
    dump = Enterprise(enterprise_code="vtx", name="Vien hang khong vu tru Viettel", email="vtx@vtx", note="Nothing")
    SESSION.add(dump)
    SESSION.commit()

def dump_staff_data():
    df = pd.read_csv('data/staff2.csv', dtype={"cellphone": str})
    df = df.where(pd.notnull(df), None)
    list_staff = []
    for idx in df.index:
        list_staff.append({'enterprise_id':1, 'staff_code':df['staff_code'][idx], 'fullname':df['full_name'][idx],
                           'email_code':df['mail_code'][idx], 'cellphone':df['cellphone'][idx], 'unit':df['unit'][idx],
                           'title':df['title'][idx], 'date_of_birth':df['date_of_birth'][idx],
                           'sex': df['sex'][idx], 'note':df['note'][idx],
                           'notify_enable':df['should_diemdanh'][idx], 'state':1})
    SESSION.execute(Staff.__table__.insert(), list_staff)
    SESSION.commit()
    
def update_staff_data():
    df = pd.read_csv('data/staff2.csv', dtype={"cellphone": str})
    df = df.where(pd.notnull(df), None)
    list_staff = []
    for idx in df.index:
        if df['activate'][idx] == False:
            print(df['staff_code'][idx], df['full_name'][idx], df['activate'][idx]) 
            staff = SESSION.execute(select(Staff).where(Staff.staff_code == df['staff_code'][idx])).first()
            staff[0].state = 0
            SESSION.add(staff[0])
            SESSION.commit()
    
def dump_site_data():
    dump = Site(enterprise_id=1, name="Xuong X1", description="Xuong X1 located in Hoa Lac")
    SESSION.add(dump)
    SESSION.commit()
 
def datetime_to_str(date_obj):
    if(date_obj == None or (isinstance(date_obj, datetime) == False)):
      return None
    try:
      return datetime.strftime(date_obj, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError as err:
      print('ValueError: ', err)   
def dump_session_service_data():
    dump = SessionService(site_id=1, type="Detection", is_registered=False, name="Detection Service", state=0, start_time=datetime_to_str(datetime.now()))
    SESSION.add(dump)
    SESSION.commit()
    
def dump_camera_data():
    df = pd.read_csv('data/camera.csv', dtype={"floor": int})
    list_camera = []
    for idx in df.index:
        list_camera.append({'site_id':1, 'session_service_id':1, 'ip':df['ip'][idx],
                           'description':"camera tang " + str(df['floor'][idx])})
    # print(list_staff)
    SESSION.execute(Camera.__table__.insert(), list_camera)
    SESSION.commit()
    
def get_staff():
    staffs = SESSION.execute(select(Staff).where(Staff.staff_code == '015234')).all()
    for staff in staffs:
        print(staff[0].id, staff[0].staff_code, staff[0].fullname)

if __name__ == "__main__":
    dump_enterprise_data()
    dump_staff_data()
    dump_site_data()
    dump_session_service_data()
    dump_camera_data()