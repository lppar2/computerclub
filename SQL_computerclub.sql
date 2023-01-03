-- Создание таблиц

DROP TABLE IF EXISTS users, position_identify, games, rooms, 
computers, client_card, game_rental_card,game_on_pc, disk_on_shelf CASCADE;

CREATE TABLE position_identify
(
	position_id smallint PRIMARY KEY,
	position_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS users 
(
	id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	position_id smallint REFERENCES position_identify(position_id),
	first_name VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	passport VARCHAR(11) NOT NULL UNIQUE,
	phone_number VARCHAR(12) NOT NULL UNIQUE,
	login VARCHAR(45) NOT NULL UNIQUE,
	password TEXT NOT NULL,
	last_visit TIMESTAMP
);


CREATE TABLE IF NOT EXISTS games
(
	id_game INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(45) NOT NULL,
	developer VARCHAR(45) NOT NULL,
	year SMALLINT NOT NULL,
	genre VARCHAR(45) NOT NULL,
	have_physical_copy BOOLEAN NOT NULL,
	is_rented BOOLEAN DEFAULT false
);


CREATE TABLE IF NOT EXISTS rooms
(
	id_room INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(20) NOT NULL UNIQUE,
	description VARCHAR(100) NOT NULL

);
ALTER TABLE rooms ADD COLUMN pc_count SMALLINT;
ALTER TABLE rooms ADD COLUMN pc_free SMALLINT;
SELECT * FROM rooms;

UPDATE rooms SET pc_count=5 WHERE id_room=3;


CREATE TABLE IF NOT EXISTS computers
(
	id_computer INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_room INTEGER REFERENCES rooms(id_room),
	graphics_card VARCHAR(40) NOT NULL,
	cpu VARCHAR(40) NOT NULL
);


CREATE TABLE IF NOT EXISTS client_card
(
	id_client_card INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_client INTEGER REFERENCES users(id),
	id_computer INTEGER REFERENCES computers(id_computer),
	date TIMESTAMP,
	price DECIMAL,
	minutes INTEGER NOT NULL
);


CREATE TABLE IF NOT EXISTS game_rental_card
(
	id_game_rent INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	id_client INTEGER REFERENCES users(id),
	id_game INTEGER REFERENCES games(id_game),
	rent_start TIMESTAMP,
	rent_end TIMESTAMP NOT NULL,
	price DECIMAL NOT NULL,
	returned BOOLEAN DEFAULT false
);
-- drop table game_rental_card
	
CREATE TABLE IF NOT EXISTS game_on_pc
(
	id_game INTEGER REFERENCES games(id_game),
	id_computer INTEGER REFERENCES computers(id_computer)
);
	

CREATE TABLE IF NOT EXISTS disk_on_shelf
(
	id_game INTEGER REFERENCES games(id_game),
	id_room INTEGER REFERENCES rooms(id_room)
);
	
select * from client_card;
-- Заполнение таблиц

INSERT INTO games (name, developer, year, genre, have_physical_copy)
VALUES
('The Withcher 3: Wild Hunt', 'CD PROJECT RED', 2015,'Action/RPG', true),
('Kingdom Come: Deliverance', 'Warhorse Studios', 2018, 'Action/RPG', true),
('Dota 2', 'Valve', 2013, 'MOBA', false),
('Counter-Strike: Global Offensive', ' Valve, Hidden Path Entertainment', 2012, 'Шутер от первого лица', false),
('Valorant', 'Riot Games', 2020, 'Шутер от первого лица', false),
('League of Legends', 'Riot Games', 2009, 'MOBA', false),
('God of War', 'Santa Monica Studio', 2018, 'Action-adventure', true),
('God of War: Ragnarök', 'Santa Monica Studio', 2022, 'Action-adventure', true),
('Genshin Impact', 'miHoYo Limited', 2020, 'Action/RPG', false),
('Detroit: Become Human', 'Quantic Dream', 2018, 'Интерактивное кино, приключенческий боевик', true),
('Until Dawn', 'Supermassive Games', 2015, 'Интерактивное кино, survival horror', true),
('Doki Doki Literature Club!', 'Team Salvato', 2017, '	визуальная новелла, психологические ужасы', false),
('Cyberpunk 2077', 'CD Projekt RED', 2020, 'Action/RPG', true),
('Elden Ring', 'FromSoftware', 2022, 'Ролевой боевик, открытый мир', true),
('Stray', 'BlueTwelve Studio', 2022, 'Квест', true),
('Uncharted 4: A Thief’s End', 'Naughty Dog', 2016, 'Action-adventure, шутер от третьего лица', true),
('Resident Evil Village', 'Capcom', 2021, 'survival horror', true),
('The Quarry', 'Supermassive Games', 2022, 'Интерактивное кино, survival horror', true),
('Spider-Man: Miles Morales', 'Insomniac Games', 2020, 'Action-adventure', true),
('The Last of Us Part II', 'Naughty Dog', 2020, 'Survival horror, Action-adventure', true);


-- SELECT * FROM games
-- where have_physical_copy = true

INSERT INTO rooms (name, description)
VALUES
('Черный зал', 'Темный зал в готическом стиле. Идеально подойдет для прохождения хоррор игр!'),
('Минимал', 'Ничего лишнего, только хай-тек!'),
('Как дома', 'Теплое освещение, мягкие диваны и много комнатных растений. Как будто никуда не выходил');

INSERT INTO position_identify
VALUES
(1, 'administrator'),
(2, 'client');


INSERT INTO computers (id_room, graphics_card, cpu)
VALUES 
(1, 'NVIDIA GeForce GTX 1050 Ti', 'Intel Core i3-10100F'),
(1, 'NVIDIA GeForce GTX 1650', 'Intel Core i3-10105F'),
(1, 'Intel Core i5-12600KF', 'NVIDIA GeForce RTX 3070'),
(1, 'AMD Ryzen 5 5600X', 'AMD Radeon RX 6900 XT'),
(1, 'Intel Core i7-12700K', 'NVIDIA GeForce RTX 3080 Ti'),
(2, 'AMD Radeon RX 6700 XT', 'AMD Ryzen 5 5600X'),
(2, 'Intel Core i5-12600KF', 'NVIDIA GeForce RTX 3070'),
(2, 'Intel Core i7-12700K', 'NVIDIA GeForce RTX 3080 Ti'),
(2, 'NVIDIA GeForce RTX 2060', 'Intel Core i5-10400F'),
(2, 'Intel Core i5-12600KF', 'NVIDIA GeForce RTX 2060'),
(3, 'NVIDIA GeForce GTX 1650', 'Intel Core i3-10105F'),
(3, 'NVIDIA GeForce GTX 1660', 'AMD Ryzen 5 3500'),
(3, 'Intel Core i5-11400F', 'NVIDIA GeForce RTX 3060'),
(3, 'Intel Core i5-12600KF', 'NVIDIA GeForce RTX 3070'),
(3, 'Intel Core i7-12700K', 'NVIDIA GeForce RTX 3080 Ti');

-- select * from computers

INSERT INTO game_on_pc (id_game, id_computer)
VALUES
(1, 1),(1, 2),(1, 7),(1, 10),(1, 13),(1, 14),(1, 15),
(2, 6),(2, 7),(2, 8),(2, 11),(2, 12),
(3, 6), (3, 9), (3, 10), (3, 11), (3, 14), (3, 15),
(4, 1), (4, 3), (4, 7), (4, 8), (4, 9), (4, 10),(4, 12),
(5, 6), (5, 9), (5, 10), (5, 11),
(6, 7), (6, 8), (6, 10), (6, 11),
(7, 5), (7, 9), (7, 13),
(8, 7), (8, 8), (8, 9), (8, 10), (8, 12),
(9, 10), (9, 11), (9, 13),
(10, 6), (10, 11), (10, 12),
(11, 1), (11, 3), (11, 5),
(12, 2), (12, 3), (12, 13),
(13, 7), (13, 8), (13, 9), (13, 12),
(14, 1), (14, 4), (14, 5), (14, 9),
(15, 7), (15, 9),
(16, 3), (16, 9), (16, 15),
(17, 1), (17, 2), (17, 3), (17, 4), (17,5),
(18, 2), (18, 3), (18, 4), (18, 5), (18, 10), 
(19, 8), (19, 9),
(20, 2), (20, 5), (20, 8);

INSERT INTO disk_on_shelf (id_game, id_room)
VALUES
(1, 3), (2, 2), (7, 3), (8, 3), (10, 2), (11, 1), 
(13, 2), (14, 1), (15, 3), (16, 2), (17, 1),
(18, 1), (19, 2), (20, 1);


-- Создание ролей
DROP OWNED BY administrator;
DROP OWNED BY client;
DROP ROLE IF EXISTS administrator;
DROP ROLE IF EXISTS client;
CREATE ROLE administrator;
CREATE ROLE client;

ALTER TABLE client_card ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC
	TO administrator;
	
GRANT INSERT ON ALL TABLES IN SCHEMA PUBLIC
	TO administrator;
	
GRANT SELECT ON client_card, users, game_rental_card, game_on_pс
	TO client;

GRANT CONNECT ON DATABASE computerclub TO administrator, client;





GRANT UPDATE ON client_card_id_client_card_seq, game_rental_card_id_game_rent_seq
	TO administrator;

-- Добавлять новые записи могут только только администраторы
GRANT INSERT ON client_card, users, game_rental_card
	TO administrator;

-- Удалять записи о клиентах, карточке клиента и карточке аренды может только администратор
GRANT DELETE ON client_card, users, game_rental_card
	TO administrator;

-- Новые записи о клиентах, карточке клиента и карточке аренды может вставлять только администратор
CREATE POLICY insert_data ON client_card
	FOR INSERT
	TO administrator
	WITH CHECK (true);

CREATE POLICY insert_data1 ON users
	FOR INSERT
	TO administrator
	WITH CHECK (true);
	
CREATE POLICY insert_data2 ON game_rental_card
	FOR INSERT
	TO administrator
	WITH CHECK (true);


-- Обновлять данные о клиенте может как сам клиент, так и администратор при предъявлении клиентом нового номера/паспорта
GRANT UPDATE (first_name, last_name, passport, phone_number) ON users
TO administrator, client;


-- поиск пользователей по их атрибутам
CREATE INDEX name_ind ON users(first_name);
CREATE INDEX lastname_ind ON users(last_name);


--АВТОМАТИЗАЦИЯ

-- функция создания нового пользователя
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP PROCEDURE create_user;
CREATE OR REPLACE PROCEDURE create_user(position_number INTEGER, first_name VARCHAR(20), last_name VARCHAR(20), passport VARCHAR(11), phone_number VARCHAR(12),
							  login VARCHAR(45), password TEXT) AS $$
DECLARE given_role TEXT;
BEGIN
	IF (SELECT EXISTS (SELECT users.login FROM users WHERE users.login = create_user.login) OR 
		(SELECT EXISTS (SELECT users.passport FROM users WHERE users.passport = create_user.passport)) OR
		(SELECT EXISTS (SELECT users.phone_number FROM users WHERE users.phone_number = create_user.phone_number)))THEN
		RAISE EXCEPTION 'Обнаружены повторяющиеся данные, которые должны быть уникальными (логин, пасспорт или номер телефона).';
	ELSE
		INSERT INTO users(position_id, first_name,last_name,passport,
							phone_number, login, password)
		VALUES(position_number, first_name,last_name,passport, 
			   phone_number, login,
			  crypt(password, gen_salt('bf')));
		EXECUTE format('CREATE ROLE %I WITH LOGIN PASSWORD %L', login, password);
		given_role := (SELECT position_name FROM position_identify WHERE
					   position_id	= (SELECT position_id FROM users 
									   WHERE users.login = create_user.login));
		EXECUTE FORMAT('GRANT %I TO %I', given_role, create_user.login);
		EXECUTE FORMAT('GRANT CONNECT ON DATABASE computerclub TO %I', create_user.login);
	END IF;
	END;
	$$ LANGUAGE plpgsql;



select * from users;
select * from client_card;

-- drop owned by kirill_shnash;
-- drop role kirill_shnash;
-- drop owned by diano4ka;
-- drop role diano4ka;
-- drop owned by arthur_21;
-- drop role arthur_21;
-- drop owned by first_user;
-- drop role first_user;
-- CALL create_user(1, 'Кирилл', 'Шнашнешков', '3615 183999', '+7985123022', 'kirill_shnash', 'iodqwd8954');
-- CALL create_user(1, 'Диана', 'Клинова', '4215 200114', '+79636548710', 'diano4ka', 'ilovebober333');
-- CALL create_user(1, 'Артур', 'Дедов', '8964 777456', '+79654844712', 'arthur_21', 'dwger32');




-- Функции позволяющие автоматически заполнять дату старта аренды или дату посещения клуба
CREATE OR REPLACE FUNCTION generate_date() RETURNS TRIGGER
AS $$
BEGIN
UPDATE client_card SET date = CURRENT_TIMESTAMP WHERE date IS NULL;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_date_rent() RETURNS TRIGGER
AS $$
BEGIN
UPDATE game_rental_card SET rent_start = CURRENT_TIMESTAMP WHERE rent_start IS NULL;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_add_date
AFTER INSERT ON client_card 
FOR EACH ROW
EXECUTE FUNCTION generate_date();

CREATE OR REPLACE TRIGGER trigger_add_date_rent
AFTER INSERT ON game_rental_card
FOR EACH ROW
EXECUTE FUNCTION generate_date_rent();

CREATE OR REPLACE FUNCTION count_price(minutes INTEGER) RETURNS DECIMAL AS $$
	SELECT minutes*6.50 AS RESULT;
$$ LANGUAGE SQL;



CREATE OR REPLACE PROCEDURE add_client_card(id_client INTEGER, id_computer INTEGER, minutes INTEGER) AS $$
	BEGIN
		INSERT INTO client_card(id_client, id_computer, price, minutes) 
		VALUES (add_client_card.id_client , add_client_card.id_computer,count_price(add_client_card.minutes) , 
				add_client_card.minutes);
		UPDATE users SET last_visit = CURRENT_TIMESTAMP
			WHERE add_client_card.id_client = users.id;
	END;
	$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_rent_card(id_client INTEGER, id_game INTEGER, rent_end TIMESTAMP, price DECIMAL) AS $$
	BEGIN
		INSERT INTO game_rental_card(id_client, id_game, rent_end, price) 
		VALUES (add_rent_card.id_client , add_rent_card.id_game,add_rent_card.rent_end , 
				add_rent_card.price);
		UPDATE games SET is_rented = True
			WHERE add_rent_card.id_game = games.id_game;
	END;
	$$ LANGUAGE plpgsql;

-- CALL add_rent_card(4, 1, '2022-12-28 06:11:35.372759', 780)

SELECT * FROM public.game_rental_card;
SELECT * FROM client_card;
SELECT * FROM users;
-- CALL add_client_card(4, 9, 79);
-- CALL add_client_card(4, 7, 128);

-- DROP FUNCTION show_pc_by_game_id(integer);
CREATE OR REPLACE FUNCTION show_pc_by_game_id(id INTEGER) RETURNS TABLE 
(
        name VARCHAR,
        id_computer INTEGER,
		id_room INTEGER
) 		
AS $$
	BEGIN
		RETURN QUERY SELECT games.name, game_on_pc.id_computer, computers.id_room 
	FROM game_on_pc, computers, games
		WHERE game_on_pc.id_computer = computers.id_computer
		AND game_on_pc.id_game=show_pc_by_game_id.id
		AND games.id_game=game_on_pc.id_game;
	END;
	$$ LANGUAGE plpgsql;

SELECT * FROM show_pc_by_game_id(8); -- ПРИМЕР ВЫЗОВА ФУНКЦИИ


CREATE OR REPLACE VIEW show_all_rooms AS
	SELECT name AS Зал, description AS Описание
	FROM rooms;

CREATE OR REPLACE VIEW outdated_rent AS
	SELECT id_client, rent_start, rent_end 
	FROM game_rental_card
	WHERE rent_end < CURRENT_TIMESTAMP 
	AND returned = false
	
SELECT * FROM outdated_rent;
-- SELECT * FROM show_all_rooms
-- DROP VIEW show_all_games
SELECT * FROM COMPUTERS;

CREATE OR REPLACE PROCEDURE register_room (id_client INTEGER, minutes INTEGER) AS $$
	BEGIN
		IF (SELECT rooms.pc_free FROM rooms WHERE rooms.id_room=1)=0 
		THEN
			IF (SELECT rooms.pc_free FROM rooms WHERE rooms.id_room=2)=0 
				THEN
					IF (SELECT rooms.pc_free FROM rooms WHERE rooms.id_room=3)=0 
						THEN
							RAISE EXCEPTION 'все занято';
			ELSE CALL add_client_card(id_client, 2, minutes);
			UPDATE rooms SET pc_free=((SELECT rooms.pc_free FROM rooms WHERE id_room=1)-1) WHERE id_room=1;
			END IF;
				ELSE CALL add_client_card(id_client, 9, minutes);
				UPDATE rooms SET pc_free=((SELECT rooms.pc_free FROM rooms WHERE id_room=2)-1)  WHERE id_room=2;
				END IF;
					ELSE CALL add_client_card(id_client, 13, minutes);
					UPDATE rooms SET pc_free=((SELECT rooms.pc_free FROM rooms WHERE id_room=3)-1)  WHERE id_room=3;
					END IF;
	END;
	$$ LANGUAGE plpgsql;

CALL register_room(4, 45);
SELECT * FROM rooms;


SELECT * FROM client_card;

UPDATE rooms SET pc_free=1 WHERE id_room=1;
UPDATE rooms SET pc_free=2 WHERE id_room=2;
UPDATE rooms SET pc_free=4 WHERE id_room=3;


