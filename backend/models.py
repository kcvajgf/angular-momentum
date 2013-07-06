from sqlalchemy import *
from sqlalchemy.orm import *
from database import Base
from flask.ext.login import UserMixin
from datetime import datetime

class Solved(Base):
    __tablename__ = "solved"
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    problem_id = Column(Integer, ForeignKey('problems.id'), primary_key=True)
    created_at = Column(DateTime, index=True)
    problem = relationship("Problem")

class User(Base, UserMixin):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    username = Column(String(255), unique=True)
    email = Column(String(255), index=True)
    password = Column(String)
    problems_solved = relationship("Solved")
    is_admin = Column(Boolean, index=True)

    def details(self):
        return {
            'username': self.username,
            'email': self.email,
            'is_admin': self.is_admin,            
        }

class Problem(Base):
    __tablename__ = "problems"
    id = Column(Integer, primary_key=True)
    index = Column(Integer, unique=True)
    title = Column(String(255), index=True)
    html = Column(String)
    answer = Column(String(255))
    release = Column(DateTime, index=True)
    is_live = Column(Boolean, index=True)

    def details(self):
        return {
            'id': self.id,
            'index': self.index,
            'title': self.title,
            'html': self.html,
            'answer': self.answer,
            'release': str(self.release),
            'is_live': self.is_live,
            'active': self.is_active(),
        }

    def is_active(self, now=None):
        if now is None:
            now = datetime.now()
        return self.is_live and self.release <= now

    @classmethod
    def active(cls, now=None):
        if now is None:
            now = datetime.now()
        return (cls.is_live == True) & (cls.release <= now)

