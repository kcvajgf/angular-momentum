from sqlalchemy import *
from sqlalchemy.orm import *
from database import Base, db_session, db_init
from flask.ext.login import UserMixin
from datetime import datetime

class Solved(Base):
    __tablename__ = "solved"
    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    problem_index = Column(Integer, ForeignKey('problems.index'), primary_key=True)
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

    def solve_count(self):
        return db_session.query(Solved).filter_by(user_id=self.id).count()

    def details(self):
        return {
            'username': self.username,
            'email': self.email,
            'is_admin': self.is_admin,
            'solve_count': self.solve_count(),
        }

class Problem(Base):
    __tablename__ = "problems"
    id = Column(Integer, primary_key=True)
    index = Column(Integer, unique=True)
    title = Column(String(255), index=True)
    html = Column(Text)
    answer = Column(String(255))
    release = Column(DateTime, index=True)
    is_live = Column(Boolean, index=True)

    def details(self, now=None):
        return {
            'id': self.id,
            'index': self.index,
            'title': self.title,
            'html': self.html,
            'answer': self.answer,
            'release': str(self.release),
            'is_live': self.is_live,
            'active': self.is_active(now),
            'solve_count': self.solve_count(),
        }

    def solve_count(self):
        return db_session.query(Solved).filter_by(problem_index=self.index).count()

    def is_active(self, now=None):
        if now is None:
            now = datetime.now()
        return self.is_live and self.release <= now

    @classmethod
    def active(cls, now=None):
        if now is None:
            now = datetime.now()
        return (cls.is_live == True) & (cls.release <= now)

    @classmethod
    def upcoming(cls, now=None):
        if now is None:
            now = datetime.now()
        return (cls.is_live == True) & (cls.release > now)

class Post(Base):
    __tablename__ = "posts"
    id = Column(Integer, primary_key=True)
    problem_index = Column(Integer, ForeignKey('problems.index'))
    content = Column(Text)
    author_id = Column(Integer, ForeignKey('users.id'))
    created_at = Column(DateTime, index=True)

    def details(self):
        return {
            'id': self.id,
            'problem_index': self.problem_index,
            'content': self.content,
            'author': User.query.get(self.author_id).details(),
            'created_at': str(self.created_at),
        }