DROP TABLE IF EXISTS genres CASCADE;

CREATE TABLE genres (
                        id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                        name varchar NOT NULL UNIQUE
);

DROP TABLE IF EXISTS authors CASCADE;

CREATE TABLE authors (
    --                        обязательные поля
                         id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                         name varchar NOT NULL UNIQUE,
                         dateOfBirth varchar NOT NULL,
    --                         необязательные поля
                         dateOfDeath varchar,
                         description varchar
);

DROP TABLE IF EXISTS books CASCADE;

CREATE TABLE books (
--                        обязательные поля
                       id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                       name varchar NOT NULL UNIQUE,
                       genre_id int NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
                       author_id int NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
                       status varchar NOT NULL,
                       year int NOT NULL check ( year > 0  AND year < 2050),
--                         необязательные поля
                       description varchar

);

DROP TABLE IF EXISTS clients CASCADE;

CREATE TABLE clients (
                         id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--      обязательные поля
                         name varchar NOT NULL UNIQUE,
                         age int NOT NULL check (age > 0 AND age < 111),
                         email varchar NOT NULL UNIQUE,
                         sex varchar NOT NULL,
                         phoneNumber varchar UNIQUE NOT NULL,
--      необязательные поля
                         deliveryAddress varchar,
                         description varchar,
                         favoriteGenre varchar

);

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
                        id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                        client_id int NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
                        book_id int NOT NULL UNIQUE REFERENCES books(id) ON DELETE CASCADE
);