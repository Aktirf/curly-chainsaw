CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (name) VALUES ('user'), ('admin');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE DEFAULT NULL,
    password_hash TEXT NOT NULL,
    role_id INT NOT NULL DEFAULT 1,
    city VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    parent_id INT DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_percent INT NOT NULL CHECK (discount_percent BETWEEN 1 AND 100),
    expires_at TIMESTAMPTZ DEFAULT NULL,
    usage_limit INT DEFAULT NULL,
    used_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    price DECIMAL(10,2) NOT NULL,
    old_price DECIMAL(10,2) DEFAULT NULL,
    category_id INT DEFAULT NULL,
    brand VARCHAR(100) DEFAULT NULL,
    material VARCHAR(50) DEFAULT NULL,
    image_url VARCHAR(500) DEFAULT NULL,
    stock INT NOT NULL DEFAULT 0,
    is_eco BOOLEAN NOT NULL DEFAULT FALSE,
    is_hit BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'new',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    delivery_method VARCHAR(50) DEFAULT NULL,
    delivery_address VARCHAR(500) DEFAULT NULL,
    payment_method VARCHAR(30) DEFAULT NULL,
    promo_code_id INT DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_promo FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id) ON DELETE SET NULL
);

CREATE TABLE order_positions (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_positions_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_positions_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    method VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    text TEXT DEFAULT NULL,
    likes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 1. В ролях строго 2 записи
INSERT INTO roles (id, name) VALUES 
(1, 'user'), 
(2, 'administrator');

-- 2. Пользователи (300 штук). 
-- Используем генератор, чтобы получить 300 реалистичных записей, как в вашем примере.
-- Всем выдаем роль 'user' (id=1), кроме каждого 10-го (он будет 'administrator' (id=2)).
WITH user_names AS (
    SELECT 
        ARRAY['Александр', 'Мария', 'Дмитрий', 'Елена', 'Алексей', 'Ольга', 'Игорь', 'Татьяна', 'Михаил', 'Наталья', 'Андрей', 'Светлана', 'Сергей', 'Юлия', 'Артем', 'Ирина', 'Николай', 'Евгения', 'Владимир', 'Ксения'] AS first_names,
        ARRAY['Иванов', 'Петрова', 'Сидоров', 'Кузнецова', 'Смирнов', 'Попова', 'Васильев', 'Соколова', 'Новиков', 'Федорова', 'Морозов', 'Волкова', 'Лебедев', 'Семенова', 'Егоров', 'Козлова', 'Степанов', 'Николаева', 'Макаров', 'Орлова'] AS last_names,
        ARRAY['Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань', 'Нижний Новгород', 'Челябинск', 'Самара', 'Омск', 'Ростов-на-Дону', 'Уфа', 'Красноярск', 'Пермь', 'Воронеж', 'Волгоград', 'Краснодар', 'Саратов', 'Тюмень', 'Тольятти', 'Ижевск'] AS cities,
        ARRAY['ivanov', 'petrova', 'sidorov', 'kuznecova', 'smirnov', 'popova', 'vasiliev', 'sokolova', 'novikov', 'fedorova', 'morozov', 'volkova', 'lebedev', 'semenova', 'egorov', 'kozlova', 'stepanov', 'nikolaeva', 'makarov', 'orlova'] AS email_prefixes
)
INSERT INTO users (name, email, phone, password_hash, role_id, city)
SELECT 
    first_names[floor(random() * 20 + 1)] || ' ' || last_names[floor(random() * 20 + 1)],
    email_prefixes[floor(random() * 20 + 1)] || i || '@example.com',
    '+79' || LPAD((floor(random() * 999999999))::text, 9, '0'),
    'u_hash_' || i,
    CASE WHEN i % 10 = 0 THEN 2 ELSE 1 END, -- Каждый 10-й — админ
    cities[floor(random() * 20 + 1)]
FROM generate_series(1, 300) AS i, user_names;

-- 3. Категории (300 штук)
WITH cat_names AS (
    SELECT ARRAY['Смартфоны', 'Ноутбуки', 'Наушники', 'Кроссовки', 'Футболки', 'Джинсы', 'Диваны', 'Кресла', 'Столы', 'Настольные лампы', 'Чайники', 'Пылесосы', 'Книги', 'Мячи', 'Рюкзаки'] AS names
)
INSERT INTO categories (name, slug, parent_id)
SELECT 
    names[floor(random() * 15 + 1)] || ' (' || i || ')',
    'category-' || i,
    CASE WHEN i > 1 AND random() > 0.8 THEN floor(random() * (i - 1) + 1)::int ELSE NULL END
FROM generate_series(1, 300) AS i, cat_names;

-- 4. Промокоды (300 штук)
WITH promo_data AS (
    SELECT ARRAY['SALE', 'WINTER', 'SUMMER', 'WELCOME', 'ECO', 'VIP', 'BLACK', 'FRIDAY', 'PROMO', 'DISCOUNT'] AS prefixes
)
INSERT INTO promo_codes (code, discount_percent, expires_at, usage_limit, used_count)
SELECT 
    prefixes[floor(random() * 10 + 1)] || i || 'X',
    floor(random() * 50 + 5)::int,
    NOW() + (i || ' days')::interval,
    floor(random() * 1000)::int,
    floor(random() * 100)::int
FROM generate_series(1, 300) AS i, promo_data;

-- 5. Товары (300 штук)
WITH prod_data AS (
    SELECT 
        ARRAY['Смартфон', 'Ноутбук', 'Наушники', 'Кроссовки', 'Футболка', 'Джинсы', 'Диван', 'Кресло', 'Стол', 'Лампа', 'Чайник', 'Пылесос', 'Книга', 'Мяч', 'Рюкзак'] AS item_types,
        ARRAY['Apple', 'Samsung', 'Sony', 'Nike', 'Adidas', 'IKEA', 'Bosch', 'Xiaomi', 'Huawei', 'LG', 'Philips'] AS brands,
        ARRAY['Пластик', 'Металл', 'Дерево', 'Хлопок', 'Кожа', 'Стекло', 'Ткань', 'Силикон'] AS materials
)
INSERT INTO products (name, description, price, old_price, category_id, brand, material, image_url, stock, is_eco, is_hit)
SELECT 
    item_types[floor(random() * 15 + 1)] || ' ' || brands[floor(random() * 11 + 1)] || ' модель ' || i,
    'Отличный выбор для повседневного использования. Высокое качество и надежность.',
    (random() * 50000 + 500)::numeric(10,2),
    (random() * 70000 + 1000)::numeric(10,2),
    floor(random() * 300 + 1)::int,
    brands[floor(random() * 11 + 1)],
    materials[floor(random() * 8 + 1)],
    'https://example.com/images/' || i || '.jpg',
    floor(random() * 100)::int,
    random() > 0.6,
    random() > 0.8
FROM generate_series(1, 300) AS i, prod_data;

-- 6. Заказы (300 штук)
WITH order_data AS (
    SELECT 
        ARRAY['Новый', 'В обработке', 'Отправлен', 'Доставлен', 'Отменен'] AS statuses,
        ARRAY['Курьер', 'Самовывоз', 'Почта России', 'СДЭК'] AS deliveries,
        ARRAY['Карта', 'Наличные', 'Онлайн', 'СБП'] AS payments,
        ARRAY['ул. Ленина', 'ул. Пушкина', 'пр. Мира', 'ул. Гагарина', 'ул. Советская', 'ул. Кирова', 'Ленинградский пр.'] AS streets
)
INSERT INTO orders (user_id, status, total_amount, delivery_method, delivery_address, payment_method, promo_code_id)
SELECT 
    floor(random() * 300 + 1)::int,
    statuses[floor(random() * 5 + 1)],
    (random() * 100000 + 1000)::numeric(10,2),
    deliveries[floor(random() * 4 + 1)],
    streets[floor(random() * 7 + 1)] || ', д. ' || floor(random() * 150 + 1)::text || ', кв. ' || floor(random() * 300 + 1)::text,
    payments[floor(random() * 4 + 1)],
    CASE WHEN random() > 0.5 THEN floor(random() * 300 + 1)::int ELSE NULL END
FROM generate_series(1, 300) AS i, order_data;

-- 7. Позиции заказов (300 штук)
INSERT INTO order_positions (order_id, product_id, quantity)
SELECT 
    floor(random() * 300 + 1)::int,
    floor(random() * 300 + 1)::int,
    floor(random() * 5 + 1)::int
FROM generate_series(1, 300) AS i;

-- 8. Платежи (300 штук)
WITH pay_data AS (
    SELECT 
        ARRAY['Карта', 'Наличные', 'Онлайн', 'СБП'] AS methods,
        ARRAY['Ожидает', 'Успешно', 'Отклонен', 'Возврат'] AS statuses
)
INSERT INTO payments (order_id, amount, method, status, paid_at)
SELECT 
    i, 
    (random() * 100000 + 1000)::numeric(10,2),
    methods[floor(random() * 4 + 1)],
    statuses[floor(random() * 4 + 1)],
    CASE WHEN random() > 0.3 THEN NOW() - (i || ' hours')::interval ELSE NULL END
FROM generate_series(1, 300) AS i, pay_data;

-- 9. Отзывы (300 штук)
WITH review_texts AS (
    SELECT ARRAY[
        'Отличный товар, очень доволен покупкой!', 
        'Быстрая доставка, все в порядке.', 
        'Качество на высоте, рекомендую к покупке.', 
        'Не понравилось, ожидал большего за эти деньги.', 
        'Все супер, буду заказывать еще!', 
        'Соответствует описанию, спасибо продавцу.',
        'Упаковка была немного повреждена, но товар цел.',
        'Сначала были сомнения, но в итоге остался доволен.',
        'Цена/качество - лучшее предложение на рынке.'
    ] AS texts
)
INSERT INTO reviews (product_id, user_id, rating, text, likes)
SELECT 
    floor(random() * 300 + 1)::int,
    floor(random() * 300 + 1)::int,
    floor(random() * 5 + 1)::int,
    texts[floor(random() * 9 + 1)],
    floor(random() * 50)::int
FROM generate_series(1, 300) AS i, review_texts;