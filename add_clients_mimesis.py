import mimesis.enums
import psycopg2
from config import host, user, password, db_name, port
from mimesis import Person, Generic
from mimesis.locales import Locale
from random import randrange


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


person = Person(locale=Locale.RU)
generic = Generic(Locale.RU)
db = connect()
gender = [mimesis.enums.Gender.MALE, mimesis.enums.Gender.FEMALE]
for i in range(1, 1000):
    with db.cursor() as cursor:
        gender_int = randrange(0, 2)
        firstname = person.first_name(gender[gender_int])
        lastname = person.last_name(gender[gender_int])
        passport = str(randrange(1000, 9999)) + ' ' + str(randrange(100000, 999999))
        phone = person.telephone(mask='+7##########')
        login = person.username()
        password = person.password()
        cursor.execute("CALL create_user(%s,%s,%s,%s,%s,%s,%s)",
                       (2, firstname, lastname, passport, phone, login, password))
        db.commit()

db.close()
