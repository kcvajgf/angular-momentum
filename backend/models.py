from sqlalchemy import *
from sqlalchemy.orm import *
from database import Base
from flask.ext.login import UserMixin
from datetime import datetime

class Solved(Base):
    __tablename__ = "solved"
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    problem_id = Column(Integer, ForeignKey('problems.id'), primary_key=True)
    created_at = Column(DateTime)
    problem = relationship("Problem")

class User(Base, UserMixin):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    username = Column(String(255), unique=True)
    email = Column(String(255))
    password = Column(String)
    problems_solved = relationship("Solved")
    is_admin = Column(Boolean)

class Problem(Base):
    __tablename__ = "problems"
    id = Column(Integer, primary_key=True)
    index = Column(Integer, unique=True)
    title = Column(String(255))
    html = Column(String)
    answer = Column(String(255))
    release = Column(DateTime)

    def is_active(self):
        return self.release <= datetime.now()


