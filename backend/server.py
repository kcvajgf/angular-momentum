# Welcome to our simple demo server!
import json # This is a library for encoding objects into JSON
from flask import Flask, request # This the microframework library we'll use to build our backend.
from flask.ext.login import LoginManager, login_user, logout_user, current_user, login_required
import sqlalchemy
from models import User, Problem, Solved
from database import db_session, db_init
from md5 import md5
from datetime import datetime
from functools import wraps

app = Flask(__name__)
db_init()
app.config['SECRET_KEY'] = 'My secret key'

login_manager = LoginManager()
login_manager.init_app(app)

def admin_required(func):
    @wraps(func)
    @login_required
    def new_func(*args, **kwargs):
        if current_user.is_admin:
            return func(*args, **kwargs)
        else:
            return "Forbidden", 403
    return new_func


def authenticate(username, password):
    try:
        user = User.query.filter_by(username=username).one()
        password = md5(password).hexdigest()
        if user.password == password:
            return user
    except sqlalchemy.orm.exc.NoResultFound:
        return None

@login_manager.user_loader
def load_user(id):
    try:
        return User.query.get(id)
    except sqlalchemy.orm.exc.NoResultFound:
        return None

@app.route('/users/', methods=['POST'], strict_slashes=False)
def create_user():
    username = request.json['username']
    email = request.json['email']
    password = md5(request.json['password']).hexdigest()
    user = User(username=username, email=email, password=password)
    db_session.add(user)
    db_session.commit()
    login_user(user)
    return str(user.id)

@app.route('/login/', methods=['POST'], strict_slashes=False)
def login():
    username = request.json['username']
    password = request.json['password']
    user = authenticate(username, password)
    if user:
        login_user(user)
        return json.dumps({'ok': True, 'user': user.details()})
    else:
        return json.dumps({'ok': False})

@app.route('/logout/', methods=['POST'], strict_slashes=False)
def logout():
    logout_user()
    return json.dumps({'ok': True})

@app.route('/problems/', methods=['GET'], strict_slashes=False)
def get_problems():
    query = Problem.query
    if 'from' in request.args:
        query = query.filter(Problem.index >= request.args['from'])
    if 'to' in request.args:
        query = query.filter(Problem.index <= request.args['to'])
    if not (current_user.is_authenticated() and current_user.is_admin):
        query = query.filter(Problem.active())

    problems = [problem.details() for problem in query.all()]

    if current_user.is_authenticated():
        solveds = Solved.query.filter_by(user_id=current_user.id)
        if 'from' in request.args:
            solveds = solveds.filter(Solved.problem.index >= request.args['from'])
        if 'to' in request.args:
            solveds = solveds.filter(Solved.problem.index <= request.args['to'])

        solveds = set(s.problem_id for s in solveds.all())
        for problem in problems:
            if problem['id'] in solveds:
                problem['has_answered'] = True
            else:
                del problem['answer']
            problem['can_answer'] = True
            problem['can_edit'] = current_user.is_admin
    else:
        for problem in problems:
            del problem['answer']

    return json.dumps(problems)

@app.route('/problems/<int:index>', methods=['GET'], strict_slashes=False)
def get_problem(index):
    try:
        problem = Problem.query.filter_by(index=index).first()
        if not problem or not (current_user.is_authenticated() and current_user.is_admin or problem.is_active()):
            return 'Not found', 404
        problem = problem.details()
        problem['release'] = str(problem['release'])
        if current_user.is_authenticated():
            if Solved.query.filter_by(user_id=current_user.id, problem_id=problem['id']).count() > 0:
                problem['has_answered'] = True
            elif not current_user.is_admin:
                del problem['answer']
            problem['can_answer'] = True
            problem['can_edit'] = current_user.is_admin
        else:
            del problem['answer']

        return json.dumps(problem)
    except sqlalchemy.orm.exc.NoResultFound:
        return 'Not found', 404

@app.route('/problems/<int:index>/answer', methods=['POST'], strict_slashes=False)
@login_required
def answer_problem(index):
    answer = request.json['answer']
    problem = Problem.query.filter_by(index=index).first()
    if problem.is_active():
        if answer == problem.answer:
            if Solved.query.filter_by(user_id=current_user.id, problem_id=problem.id).count() == 0:
                solved = Solved(user_id=current_user.id, problem_id=problem.id)
                db_session.add(solved)
                db_session.commit()
            return json.dumps({'ok': True, 'correct': True, 'answer': problem.answer})
        return json.dumps({'ok': True, 'correct': False})
    return json.dumps({'ok': False})

@app.route('/problems/', methods=['POST'], strict_slashes=False)
@admin_required
def make_problem():
    return "TODO"

@app.route('/problems/<int:index>', methods=['PUT'], strict_slashes=False)
@admin_required
def update_problem(index):
    problem = Problem.query.filter_by(index=index).first()
    print request.json
    print problem
    problem = problem.details()
    problem['can_answer'] = True
    problem['can_edit'] = True
    return json.dumps(problem)

@app.route('/current_user', methods=['GET'], strict_slashes=False)
def get_current_user():
    if current_user.is_authenticated():
        return json.dumps({'ok': True, 'user': current_user.details()})
    else:
        return json.dumps({'ok': False})
if __name__ == '__main__':
    print 'Listening on port 8080...'
    app.run(host='0.0.0.0', port=8080, debug=True)
