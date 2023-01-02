import psycopg2
from psycopg2.extras import DictCursor
from psycopg2 import sql



def getRooms(db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute("SELECT * FROM show_all_rooms")
            res = cursor.fetchall()
            if not res:
                print("Доступные залы не найдены.")
                return False
            return res
    except Exception as e:
        print(e)
        print("Ошибка при просмотре доступных залов")
    return False

# получение пользователя из бд по его Id
def getUser(user_id, db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute("SELECT * FROM users WHERE id = %(id)s",
                           {'id': user_id})
            res = cursor.fetchone()
            if not res:
                print("Пользовтель не найден.")
                return False
            return res
    except Exception as e:
        print(e)
        print("Ошибка получения данных из бд.")
    return False

# получение пользователя из бд по его логину
def getUserByLogin(login, db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            try:
                cursor.execute("SELECT * FROM users WHERE login = %(login)s",
                               {'login': login})
                res = cursor.fetchone()
            except psycopg2.OperationalError as e:
                print(e)
                res = False
            # if not res:
            # print("Пользователь не найден.")
            return res

    except Exception as e:
        print(e)
        print("Ошибка получения пользователя из бд.")

    return False


# получение пароля пользователя по его логину
def getPassUserByLogin(login, pasw, db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            query = sql.SQL("SELECT password "
                            "FROM users WHERE login = {logi}") \
                .format(passws=sql.Literal(pasw),
                        logi=sql.Literal(login))

            cursor.execute(query)
            res = cursor.fetchone()[0]
            return res

    except Exception as e:
        print(e)
        print("Ошибка получения пользователя из бд.")

    return False


def getGames(db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute("SELECT * FROM games")
            res = cursor.fetchall()
            if not res:
                print("Игры не найдены.")
                return False
            return res
    except Exception as e:
        print(e)
        print("Ошибка при просмотре игр")
    return False


def getPositionUser(user_id, db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute("SELECT position_id FROM users WHERE id = %(user_id)s",
                           {'user_id': user_id})
            res = cursor.fetchone()
            if not res:
                print("Пользователя с таким id нет.")
                return False
            return res

    except Exception as e:
        print(e)
        print("Ошибка получения юзера из бд.")

    return False


def addUser(role, firstname, lastname, passport, phone, login, password, db):
    try:
        id_role = None
        if role == 'administrator':
            id_role = 1
        if role == 'client':
            id_role = 2
        print(id_role)
        with db.cursor() as cursor:
            query = sql.SQL("CALL create_user({rol},{fn},{ln},{pasp},{ph},{lg},{psw})") \
                .format(rol=sql.Literal(id_role), fn=sql.Literal(firstname), ln=sql.Literal(lastname),
                         pasp=sql.Literal(passport), ph=sql.Literal(phone), lg=sql.Literal(login),
                        psw=sql.Literal(password))
            cursor.execute(query)
            db.commit()
    except Exception as e:
        print(e)
        print("Ошибка добавления пользователя в бд")
        return False

    return True

def getClientCardTable(client_id,db):
    try:
        with db.cursor(cursor_factory=DictCursor) as cursor:
            cursor.execute("SELECT * FROM client_card WHERE id_client = %(client_num)s",
                           {'client_num': client_id})
            res = cursor.fetchall()
            if not res:
                print("Карточек не найдено.")
                return False
            return res
    except Exception as e:
        print(e)
        print("Ошибка получения карточек клиента из бд.")
    return False

def addClientCard(id_cli, id_comp, minut, db):
    try:
        with db.cursor() as cursor:
            query = sql.SQL("CALL add_client_card({id_c},{if_co},{min})") \
                .format(id_c=sql.Literal(id_cli), if_co=sql.Literal(id_comp), min=sql.Literal(minut))
            cursor.execute(query)
            db.commit()
    except Exception as e:
        print("Ошибка добавления карточки" + e)
        return False

    return True

def showPCgameid(id_gam, db):
    try:
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM show_pc_by_game_id (%(id_gam)s)",
                           {'id_gam': id_gam})
            res = cursor.fetchall()
            if not res:
                print("Не найдено.")
                return False
            return res
    except Exception as e:
        print("Ошибка" + e)
        return False

    return True

