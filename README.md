# Звіт з нормалізації - База даних стрімінгового сервісу
Структура бази даних містить сутності, пов'язані з фільмами, жанрами, акторами, режисерами, студіями, клієнтами, підписками та платіжними операціями. Схему було досліджено з метою мінімізації надмірності та усунення можливих аномалій вставлення, видалення та оновлення.

# Функціональні залежності початкової схеми

## Genre(genre_id, name, description)
Первинний ключ: genre_id

Альтернативний ключ: name

Функціональні залежності
genre_id - name, description

name - genre_id, description

Друга залежність існує, оскільки атрибут name є унікальним.

## Studio(studio_id, name, country, founded_date)
Первинний ключ: studio_id

Функціональні залежності
studio_id - name, country, founded_date

## Film(film_id, title, release_year, duration, age_restriction, studio_id)
Первинний ключ: film_id

Функціональні залежності
film_id - title, release_year, duration, age_restriction, studio_id

## FilmGenre(film_id, genre_id)
Складений первинний ключ: (film_id, genre_id)

Це відношення містить лише ключові атрибути.

Функціональні залежності
(film_id, genre_id) - film_id, genre_id

## Actor(actor_id, first_name, last_name, country, photo, birth_date)
Первинний ключ: actor_id

Функціональні залежності
actor_id - first_name, last_name, country, photo, birth_date

## FilmActor(film_id, actor_id)
Складений первинний ключ: (film_id, actor_id)

Це відношення використовується для реалізації зв'язку багато-до-багатьох між фільмами та акторами.

Функціональні залежності
(film_id, actor_id) - film_id, actor_id

## Director(director_id, first_name, last_name, country)
Первинний ключ: director_id

Функціональні залежності
director_id - first_name, last_name, country

## FilmDirector(film_id, director_id)
Складений первинний ключ: (film_id, director_id)

Ця таблиця зберігає зв'язки між фільмами та режисерами.

Функціональні залежності
(film_id, director_id) - film_id, director_id

## Customer(customer_id, first_name, last_name, email, password, registration_date, birth_date, is_deleted)
Первинний ключ: customer_id

Альтернативний ключ: email

Функціональні залежності
customer_id - first_name, last_name, email, password, registration_date, birth_date, is_deleted

email - customer_id, first_name, last_name, password, registration_date, birth_date, is_deleted

Друга функціональна залежність з'являється, оскільки електронні адреси (email) мають бути унікальними для кожного клієнта.

## Subscription(subscription_id, start_date, end_date, type, price, customer_id)
Первинний ключ: subscription_id

Функціональні залежності
subscription_id - start_date, end_date, type, price, customer_id

## Payment(payment_id, amount, payment_type, payment_date, status, customer_id, subscription_id)
Первинний ключ: payment_id

Функціональні залежності
payment_id - amount, payment_type, payment_date, status, customer_id, subscription_id

# Аналіз нормальних форм
Цей розділ перевіряє, чи задовольняє схема бази даних вимогам 1NF, 2NF та 3NF.

## Перша нормальна форма (1NF)
Відношення задовольняє 1NF, якщо:

- кожен атрибут містить неподільні значення,

- відсутні групи, що повторюються,

- кожна таблиця має визначений первинний ключ.

- атрибути містять лише атомарні (неподільні) значення,

- немає вкладених або багатозначних атрибутів,

- кожне відношення містить первинний ключ.

Отже, схема відповідає Першій нормальній формі (1NF).

## Друга нормальна форма (2NF)
Відношення знаходиться у 2NF, якщо:

- воно вже задовольняє 1NF,

- неключові атрибути повністю залежать від усього первинного ключа.

Складені первинні ключі використовуються лише у наступних відношеннях:

  - FilmGenre (film_id, genre_id)
  
  - FilmActor (film_id, actor_id)
  
  - FilmDirector (film_id, director_id)

Ці таблиці не містять додаткових неключових атрибутів, тому часткові залежності тут неможливі.

Решта відношень використовують первинні ключі, що складаються з одного атрибута.

Схема бази даних задовольняє Другу нормальну форму (2NF).

## Третя нормальна форма (3NF)
Щоб задовольняти 3NF:

- відношення має вже знаходитися у 2NF,

- не повинно існувати транзитивних залежностей між неключовими атрибутами.

У схемі не виявлено транзитивних залежностей.

Наприклад:

інформація про студію виділена у відношення Studio,

інформація про акторів зберігається незалежно в таблиці Actor,

дані про режисерів ізольовані в сутності Director,

дані клієнта не дублюються в таблицях підписок або платежів.

Відношення зберігають посилання через зовнішні ключі замість повторення описових даних.

Схема задовольняє Третю нормальну форму (3NF).

# Звіт з нормалізації бази даних: Модуль клієнтів, підписок та платежів
Цей розділ демонструє процес нормалізації підсистеми клієнтських підписок та платежів для бази даних.

Приклад ілюструє, як початково неструктуроване відношення можна крок за кроком перетворити на схему, яка задовольняє Першу, Другу та Третю нормальні форми (1NF, 2NF та 3NF).

1. Початковий стан (Ненормалізоване відношення / 0NF)
На ранньому етапі проєктування інформація про клієнтів, підписки та платежі могла зберігатися в одній великій таблиці, імпортованій із зовнішніх джерел, таких як електронні таблиці або CSV-файли.

```sql
CREATE TABLE customer_payment_raw (
    customer_email     VARCHAR(255),
    subscription_type  VARCHAR(100),
    payment_date       TIMESTAMP,
    customer_name      VARCHAR(255), -- Проблема 1NF: Ім'я та прізвище разом
    contacts           TEXT,         -- Проблема 1NF: Кілька значень
    subscription_price DECIMAL(10,2),
    start_date         DATE,
    end_date           DATE,
    amount             DECIMAL(10,2),
    payment_status     VARCHAR(50),
    payment_type       VARCHAR(50),
    PRIMARY KEY (customer_email, subscription_type, payment_date)
);

```

1.1. Проблеми початкового дизайну
Оригінальна структура містить кілька проблем нормалізації.

1. Порушення 1NF (Атомарні значення)
Деякі атрибути не є атомарними:

customer_name зберігає ім'я та прізвище разом в одній колонці,

contacts може містити кілька значень, розділених комами.

2. Порушення 2NF (Часткові залежності)
Таблиця використовує складений первинний ключ:

(customer_email, subscription_type, payment_date)

Однак:

customer_name залежить лише від customer_email,

subscription_price залежить лише від subscription_type.

Ці атрибути не залежать повністю від усього ключа.

3. Порушення 3NF (Транзитивні залежності)
Інформація про підписку та інформація про платежі змішані разом.

Наприклад:

start_date та end_date описують період підписки,

payment_date та amount описують фінансову транзакцію.

Це може спричинити надмірність, якщо з однією підпискою пов'язано кілька платежів.

2. Функціональні залежності
З оригінального відношення можна виділити наступні залежності.

Часткові залежності
customer_email → customer_name, contacts

subscription_type → subscription_price

Повні залежності
(customer_email, subscription_type, payment_date) → amount, payment_status, payment_type, start_date, end_date

n (де є дати початку/кінця) та таблиця payment (де є сума і дата транзакції). Вони пов'язані через subscription_id та customer_id.
