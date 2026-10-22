CREATE TABLE administrators (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE DEFAULT NULL,
    password_hash VARCHAR(255) NOT NULL,
    city VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    parent_id INT DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_percent INT NOT NULL CHECK (discount_percent BETWEEN 1 AND 100),
    expires_at TIMESTAMPTZ DEFAULT NULL,
    usage_limit INT DEFAULT NULL,
    used_count INT NOT NULL DEFAULT 0
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
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_promo FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id) ON DELETE SET NULL
);

CREATE TABLE order_positions (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_positions_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_positions_product KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    method VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    text TEXT DEFAULT NULL,
    photos JSONB DEFAULT NULL,
    likes INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO administrators (username, password_hash) VALUES
('admin_main', 'hash_pass_12345'), ('moderator_elena', 'hash_pass_54321'),
('support_ivan', 'hash_pass_98765'), ('admin_sergey', 'hash_pass_11111'),
('moderator_anna', 'hash_pass_22222'), ('content_manager', 'hash_pass_33333'),
('ceo_admin', 'hash_pass_44444'), ('dev_user', 'hash_pass_55555'),
('sysops_root', 'hash_pass_66666'), ('security_officer', 'hash_pass_77777'),
('analyst_mark', 'hash_pass_88888'), ('hr_olga', 'hash_pass_99999'),
('sales_director', 'hash_pass_00000'), ('marketing_guru', 'hash_pass_abcde'),
('lead_dev', 'hash_pass_bcdef'), ('dba_alex', 'hash_pass_cdefg'),
('support_maria', 'hash_pass_defgh'), ('content_assistant', 'hash_pass_efghi'),
('guest_admin', 'hash_pass_fghij'), ('temp_mod', 'hash_pass_ghijk');

INSERT INTO users (name, email, phone, password_hash, city) VALUES
('Александр Иванов', 'ivanov@example.com', '+79991112233', 'u_hash_1', 'Москва'),
('Мария Петрова', 'petrova@example.com', '+79992223344', 'u_hash_2', 'Санкт-Петербург'),
('Дмитрий Сидоров', 'sidorov@example.com', '+79993334455', 'u_hash_3', 'Новосибирск'),
('Елена Кузнецова', 'kuznecova@example.com', '+79994445566', 'u_hash_4', 'Екатеринбург'),
('Алексей Смирнов', 'smirnov@example.com', '+79995556677', 'u_hash_5', 'Казань'),
('Ольга Попова', 'popova@example.com', '+79996667788', 'u_hash_6', 'Нижний Новгород'),
('Игорь Васильев', 'vasiliev@example.com', '+79997778899', 'u_hash_7', 'Челябинск'),
('Татьяна Соколова', 'sokolova@example.com', '+79998889900', 'u_hash_8', 'Самара'),
('Михаил Новиков', 'novikov@example.com', '+79999990011', 'u_hash_9', 'Омск'),
('Наталья Федорова', 'fedorova@example.com', '+79990001122', 'u_hash_10', 'Ростов-на-Дону'),
('Андрей Морозов', 'morozov@example.com', '+79991234567', 'u_hash_11', 'Уфа'),
('Светлана Волкова', 'volkova@example.com', '+79992345678', 'u_hash_12', 'Красноярск'),
('Сергей Лебедев', 'lebedev@example.com', '+79993456789', 'u_hash_13', 'Пермь'),
('Юлия Семенова', 'semenova@example.com', '+79994567890', 'u_hash_14', 'Воронеж'),
('Артем Егоров', 'egorov@example.com', '+79995678901', 'u_hash_15', 'Волгоград'),
('Ирина Козлова', 'kozlova@example.com', '+79996789012', 'u_hash_16', 'Краснодар'),
('Николай Степанов', 'stepanov@example.com', '+79997890123', 'u_hash_17', 'Саратов'),
('Евгения Николаева', 'nikolaeva@example.com', '+79998901234', 'u_hash_18', 'Тюмень'),
('Владимир Макаров', 'makarov@example.com', '+79999012345', 'u_hash_19', 'Тольятти'),
('Ксения Орлова', 'orlova@example.com', '+79990123456', 'u_hash_20', 'Ижевск');

INSERT INTO categories (id, name, slug, parent_id) VALUES
(1, 'Одежда', 'odezhda', NULL),
(2, 'Обувь', 'obuv', NULL),
(3, 'Аксессуары', 'aksessuary', NULL),
(4, 'Дом и сад', 'dom-i-sad', NULL),
(5, 'Электроника', 'elektronika', NULL),
(6, 'Мужская одежда', 'muzhskaya-odezhda', 1),
(7, 'Женская одежда', 'zhenskaya-odezhda', 1),
(8, 'Детская одежда', 'detskaya-odezhda', 1),
(9, 'Кроссовки', 'krossovki', 2),
(10, 'Туфли', 'tufli', 2),
(11, 'Сумки', 'sumki', 3),
(12, 'Часы', 'chasy', 3),
(13, 'Постельное белье', 'postelnoe-belie', 4),
(14, 'Декор для дома', 'dekor-dlya-doma', 4),
(15, 'Смартфоны', 'smartfony', 5),
(16, 'Наушники', 'naushniki', 5),
(17, 'Куртки', 'kurtki', 6),
(18, 'Платья', 'platya', 7),
(19, 'Рюкзаки', 'ryukzaki', 3),
(20, 'Гаджеты', 'gadzhety', 5);

SELECT setval('categories_id_seq', 20);

INSERT INTO promo_codes (code, discount_percent, expires_at, usage_limit, used_count) VALUES
('WELCOME10', 10, '2027-12-31 23:59:59+03', 1000, 150),
('SALE20', 20, '2027-06-01 00:00:00+03', 500, 45),
('BLACKFRIDAY50', 50, '2026-11-30 23:59:59+03', 100, 99),
('ECOFRIENDLY', 15, NULL, NULL, 12),
('HIT2026', 12, '2026-12-31 23:59:59+03', 200, 30),
('SUMMER30', 30, '2027-08-31 23:59:59+03', 300, 0),
('WINTER25', 25, '2027-02-28 23:59:59+03', 300, 120),
('CYBER15', 15, '2026-12-05 23:59:59+03', 500, 450),
('SPRING10', 10, '2027-05-31 23:59:59+03', 400, 0),
('AUTUMN15', 15, '2026-11-30 23:59:59+03', 400, 380),
('BIRTHDAY', 25, NULL, NULL, 89),
('SECRET5', 5, '2027-01-01 00:00:00+03', 50, 5),
('VIP35', 35, '2027-03-15 00:00:00+03', 20, 18),
('FREE5', 5, NULL, 1000, 850),
('FIRSTORDER', 10, NULL, NULL, 540),
('STUDENT12', 12, '2027-09-01 00:00:00+03', 1000, 65),
('GIFT7', 7, '2027-01-01 00:00:00+03', 100, 14),
('BONUS22', 22, '2027-04-01 00:00:00+03', 250, 0),
('LASTCHANCE40', 40, '2026-10-31 23:59:59+03', 50, 49),
('SUPERDEAL90', 90, '2026-11-11 11:11:11+03', 5, 4);

INSERT INTO products (name, description, price, old_price, category_id, brand, material, image_url, stock, is_eco, is_hit) VALUES
('Хлопковая футболка EcoStyle', 'Удобная футболка из органического хлопка.', 1500.00, 1900.00, 6, 'EcoWear', 'Хлопок', 'http://img.com', 50, TRUE, FALSE),
('Зимняя куртка Alpha', 'Теплая непромокаемая куртка.', 8500.00, NULL, 17, 'NordForce', 'Полиэстер', 'http://img.com', 15, FALSE, TRUE),
('Платье вечернее Silk', 'Элегантное шелковое платье.', 6200.00, 7500.00, 18, 'Glow Fashion', 'Шелк', 'http://img.com', 8, FALSE, FALSE),
('Беговые кроссовки Air', 'Легкие кроссовки для бега.', 4900.00, 5500.00, 9, 'RunSpeed', 'Текстиль/Сетка', 'http://img.com', 30, FALSE, TRUE),
('Кожаные туфли Classic', 'Строгие мужские туфли.', 7000.00, NULL, 10, 'Richards', 'Кожа', 'http://img.com', 12, FALSE, FALSE),
('Рюкзак городской Canvas', 'Прочный рюкзак на каждый день.', 2800.00, 3200.00, 19, 'PackGo', 'Брезент/Хлопок', 'http://img.com', 25, TRUE, TRUE),
('Кожаная сумка-шоппер', 'Вместительная женская сумка.', 5400.00, NULL, 11, 'BagArt', 'Кожа', 'http://img.com', 7, FALSE, FALSE),
('Умные часы Chrono', 'Смарт-часы с пульсометром.', 12500.00, 15000.00, 12, 'TechTime', 'Сталь/Силикон', 'http://img.com', 20, FALSE, TRUE),
('Постельное белье Лён', 'Комплект из натурального льна.', 4200.00, 4800.00, 13, 'HomeCozy', 'Лён', 'http://img.com', 40, TRUE, FALSE),
('Ароматическая свеча Wood', 'Свеча с ароматом дерева и костра.', 950.00, NULL, 14, 'HomeCozy', 'Воск', 'http://img.com', 100, TRUE, FALSE),
('Смартфон X-Phone 15', 'Флагманский smartphone 256GB.', 79900.00, 89900.00, 15, 'NextGen', 'Стекло/Алюминий', 'http://img.com', 10, FALSE, TRUE),
