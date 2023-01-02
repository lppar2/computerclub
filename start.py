from flask import Flask, render_template, url_for, request, flash, session, redirect, abort, g
from DB import *
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from login import LoginUser
from dotenv import load_dotenv
import psycopg2
from config import host, user, password, db_name, port
import re
import os


# подулючение виртуального окружения для получения секретных данных
load_dotenv()
SECRET_KEY = os.getenv('SECRET_KEY')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')

app = Flask(__name__)
app.secret_key = os.urandom(24)
# Настройка лоигрования юзера и ограничения доступа к страницам
login = LoginManager(app)
login.session_protection = "strong"
login.login_view = 'login'
login.login_message = "Пожалуйста, авторизуйтесь  для доступа к закрытым страницам"
login.login_message_category = "success"
user_is_client = False  # отображение вкладки с добавл. задания только для клиента
user_is_admin = False  # отображение вкладки с добавл. задания только для админа

# подключение без пароля
def connect():
    try:
        connection = psycopg2.connect(
            host=host,
            user=user,
            password=password,
            database=db_name,
            port=port
        )
        return connection
    except Exception as e:
        print(e)
# Подключение к бд с паролем
def connection_db(user_log, user_pass):
    try:
        # подключаемся к бд
        connection = psycopg2.connect(
            host=host,
            user=user,
            password=password,
            database=db_name,
            port=port
        )
        # чтобы все изменения в бд автоматически применялись
        connection.autocommit = True
        print("Connected")
        return connection

    except Exception as _ex:
        print("ERROR while working with PostgreSQL", _ex)
        return False

@app.route('/')
def start_page():
    return render_template('start_page.html')


# Подключение к бд через логин и пароль юзера
# Создание юзера в сессии
@login.user_loader
def loadUser(user_id):
    db = connection_db(session.get('current_user', SECRET_KEY), session.get('user_password', SECRET_KEY))
    return LoginUser().from_DB(user_id, db)


# авторизация
@app.route('/login', methods=["POST", "GET"])
def login():
    if current_user.is_authenticated:  # если юзер уже авторизован, то при переходе на авторизацию
        return redirect(url_for('profile'))  # его будет перенаправлять в его профиль
    user = None
    if request.method == "POST":
        user_login = request.form.get('username')
        enter_pass = request.form.get('psw')
        if user_login and enter_pass:
            db = connection_db(user_log=DB_USER, user_pass=DB_PASSWORD)
            with db:

                # сравниваем введенный пароль с паролем в бд
                user_password_correct = getPassUserByLogin(user_login, enter_pass, db)

                # если пароль верный, то создаем сессию этого пользователя
                if user_password_correct:
                    user = getUserByLogin(user_login, db)
                    userlogin = LoginUser().create(user)

                    # для запоминания пользователя в сессии
                    rm = True if request.form.get('remainme') else False
                    login_user(userlogin, remember=rm)
                    session['current_user'] = user
                    session['user_password'] = enter_pass
                    return redirect(url_for("profile"))
                else:
                    flash("Введен неверный пароль.", "error")

        else:
            flash('Неверный ввод логина/пароля', 'error')

    return render_template("login.html", title="Авторизация")


@app.route('/profile')
@login_required
def profile():
    db = connection_db(session.get('current_user', SECRET_KEY), session.get('user_password', SECRET_KEY))
    user_id = LoginUser.get_id(current_user)
    position_user = getPositionUser(user_id, db)
    user_is_admin = True if position_user == [1] else False
    user_is_client = True if position_user == [2] else False
    return render_template("profile.html", title="Профиль", client=user_is_client, admin=user_is_admin)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('start_page'))

# регистрация пользователя
@app.route('/register', methods=["POST", "GET"])
def register():
    user_is_admin = None
    user_is_client = None
    db = connection_db(DB_USER, DB_PASSWORD)
    try:
        user_id = LoginUser.get_id(current_user)
        position_user = getPositionUser(user_id, db)
        user_is_admin = True if position_user == [1] else False
        user_is_client = True if position_user == [2] else False
    except:
        user_is_admin = False
    if user_is_admin:
        if request.method == "POST":
            with db:
                if len(request.form['username']) > 0 and len(request.form['psw']) > 0 and \
                        request.form['psw'] == request.form['psw2']:
                    res = addUser(request.form['role'], request.form['firstname'], request.form['lastname'],
                                request.form['passport'], request.form['phone'], request.form['username'],
                                request.form['psw'], db)
                    if res:
                        flash('Успешно зарегистрирован.', 'success')
                        return redirect(url_for('start_page'))
                    else:
                        flash('Ошибка при добавлении в бд.', 'error')
                else:
                    flash('Неверно заполнены поля', 'error')


    else:
        if request.method == "POST":
            with db:
                if len(request.form['username']) > 0 and len(request.form['psw']) > 0 and \
                        request.form['psw'] == request.form['psw2']:
                    res = addUser('client', request.form['firstname'], request.form['lastname'],
                                request.form['passport'], request.form['phone'], request.form['username'],
                                request.form['psw'], db)
                    if res:
                        flash('Успешно зарегестрирован.', 'success')
                        return redirect(url_for('start_page'))
                    else:
                        flash('Ошибка при добавлении в бд.', 'error')
                else:
                    flash('Неверно заполнены поля', 'error')
    return render_template('register.html', title="Регистрация работника.", admin=user_is_admin, client=user_is_client)

@app.route('/showRooms')
def showRooms():
    db = connect()
    room = getRooms(db)
    return render_template('rooms.html', rooms=room, title="Список залов")

@app.route('/client_card')
@login_required
def client_card():
    if 'current_user' in session:
        db = connection_db(session.get('current_user', SECRET_KEY), session.get('user_password', SECRET_KEY))
        user_id = LoginUser.get_id(current_user)
        card = getClientCardTable(user_id, db)
        position_user = getPositionUser(user_id, db)
        user_is_client = True if position_user == [2] else False
    return render_template('my_client_card.html', title="Мои карточки клиента", client=user_is_client, cards=card)


@app.route('/add_client_card', methods=["POST", "GET"])
@login_required
def addClientCard():
    if 'current_user' in session:
        db = connection_db(session.get('current_user', SECRET_KEY), session.get('user_password', SECRET_KEY))
        user_id = LoginUser.get_id(current_user)
        position_user = getPositionUser(user_id, db)
        user_is_admin = True if position_user == [1] else False
        user_is_client = True if position_user == [2] else False
    if request.method == "POST":
        with db:
            # получаем данные из пользовательского ввода, проверяем, все ли получили
            # и создаем группу.
            id_clientt = request.form.get('id_cli')
            id_compp = request.form.get('id_com')
            minutt = request.form.get('min')
            if not (id_clientt or id_compp or minutt):
                flash("Заполните все поля", "error")
            else:
                res = addClientCard(id_clientt, id_compp,minutt, db)
                if not res:
                    flash('Ошибка добавления группы', category='error')
                else:
                    flash('Группа успешно добавлена', category='succes')
            return redirect(url_for('profile'))
    return render_template('add_client_card.html', title='Добавление карточки группы', admin=user_is_admin,
                           client=user_is_client)

id_games = ['1', '2', '3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20']
# Отображаем список спорт. групп
@app.route('/show_pc_by_game_id',  methods=["POST", "GET"])
@login_required
def showGamePc():
    games_pc = ['', '']
    if 'current_user' in session:
        db = connection_db(session.get('current_user', SECRET_KEY), session.get('user_password', SECRET_KEY))
        user_id = LoginUser.get_id(current_user)
        position_user = getPositionUser(user_id, db)
        user_is_admin = True if position_user == [1] else False
        user_is_client = True if position_user == [2] else False
        if request.method == "POST":
            with db:
                game_id = request.form.get('id_gam')
                check_correct_id = re.findall(r"[^0-9]", game_id)
                if check_correct_id:
                    flash("Введите корректный id", "error")
                else:
                    if not game_id:
                        flash("Введите id игры для поиска", "error")
                    if game_id not in id_games:
                        flash("Неверный ID", "error")
                    else:
                        games_pc = showPCgameid(game_id, db)
    return render_template('show_pc_by_game_id.html', client=user_is_client, admin=user_is_admin, games=games_pc)

@app.route('/showGames')
def showGames():
    db = connect()
    game = getGames(db)
    return render_template('games.html', games=game)

if __name__ == '__main__':
    app.run()
