DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS subscription CASCADE;
DROP TABLE IF EXISTS film_genre CASCADE;
DROP TABLE IF EXISTS film_actor CASCADE;
DROP TABLE IF EXISTS film_director CASCADE;
DROP TABLE IF EXISTS film CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS actor CASCADE;
DROP TABLE IF EXISTS director CASCADE;
DROP TABLE IF EXISTS studio CASCADE;

CREATE TABLE IF NOT EXISTS customer(
	customer_id SERIAL PRIMARY KEY,
	first_name VARCHAR(32) NOT NULL,
	last_name VARCHAR(32) NOT NULL,
	email varchar(64) unique NOT NULL,
	password text NOT NULL CHECK (length(password) >= 6),
	registration_date date,
	birth_date date,
	is_deleted boolean
	);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_type') THEN
        CREATE TYPE subscription_type AS ENUM ('сімейна', 'студентська', 'стандартна');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type') THEN
        CREATE TYPE payment_type AS ENUM ('готівка', 'переказ', 'за реквізитами', 'промокод');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'restriction') THEN
        CREATE TYPE restriction AS ENUM ('0+', '12+', '16+', '18+', '21+');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS subscription(
	subscription_id SERIAL PRIMARY KEY,
	start_date date,
	end_date date,
	type subscription_type not null,
	price real,
	customer_id INTEGER REFERENCES customer(customer_id)
);

CREATE TABLE IF NOT EXISTS payment(
	payment_id SERIAL PRIMARY KEY,
	amount real CHECK (amount >= 0),
	payment_type payment_type,
	payment_date date,
	status boolean,
	customer_id INTEGER REFERENCES customer(customer_id),
	subscription_id INTEGER REFERENCES subscription(subscription_id)
);

CREATE TABLE IF NOT EXISTS studio( 
    studio_id SERIAL PRIMARY KEY,
    name varchar(400) NOT NULL UNIQUE,
    country varchar(300) NOT NULL,
    founded_date date
);

CREATE TABLE IF NOT EXISTS film( 
    film_id SERIAL PRIMARY KEY,
    title text,
    release_year INT,
    duration smallint CHECK (duration > 0), 
    age_restriction restriction, 
    studio_id INTEGER REFERENCES studio(studio_id)
);

CREATE TABLE IF NOT EXISTS genre(
    genre_id SERIAL PRIMARY KEY,
    name varchar(64) UNIQUE,
    description text
);

CREATE TABLE IF NOT EXISTS film_genre( 
    film_id INTEGER REFERENCES film(film_id),
    genre_id INTEGER REFERENCES genre(genre_id),
	PRIMARY KEY (film_id, genre_id)

);

CREATE TABLE IF NOT EXISTS actor(
    actor_id SERIAL PRIMARY KEY,
    first_name varchar(64) NOT NULL,
    last_name varchar(64) NOT NULL,
    country varchar(64) NOT NULL,
    birth_date date
);

CREATE TABLE IF NOT EXISTS director(
	director_id SERIAL PRIMARY KEY,
    first_name varchar(64) NOT NULL,
    last_name varchar(64) NOT NULL,
    country varchar(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS film_actor( 
    film_id INTEGER REFERENCES film(film_id),
    actor_id INTEGER REFERENCES actor(actor_id),
	PRIMARY KEY (film_id, actor_id)
);

CREATE TABLE IF NOT EXISTS film_director( 
    film_id INTEGER REFERENCES film(film_id),
    director_id INTEGER REFERENCES director(director_id),
	PRIMARY KEY (film_id, director_id)
);
