from DB import *
from flask_login import UserMixin


class LoginUser(UserMixin):
    def from_DB(self, user_id, db):
        self.__user = getUser(user_id, db)
        return self

    def create(self, user):
        self.__user = user
        return self

    def get_id(self):
        return str(self.__user['id'])

    def getName(self):
        return self.__user['first_name'] if self.__user else "error"

    def getLastName(self):
        return self.__user['last_name'] if self.__user else "error"

    def getPassport(self):
        return self.__user['passport'] if self.__user else "error"

    def getPhone(self):
        return self.__user['phone_number'] if self.__user else "error"

    def getRoleId(self):
        return self.__user['position_id'] if self.__user else "error"

    def getLastVisit(self):
        return self.__user['last_visit'] if self.__user else "error"
