from sqlalchemy import *
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    username = Column(String(255)) # make this unique!
    email = Column(String(255))

class Session(Base):
    __tablename__ = "sessions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer) # foreign key
    #expiry = date
    