-- Khởi tạo Database
DROP DATABASE IF EXISTS mobile_store_online;
CREATE DATABASE mobile_store_online;

use mobile_store_online;
-- Bỏ qua kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa các bảng trước khi tạo tránh lỗi
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `payment`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `preview`;
DROP TABLE IF EXISTS `rep_preview`;
DROP TABLE IF EXISTS `discount`;
DROP TABLE IF EXISTS `color`;
DROP TABLE IF EXISTS `storage`;
DROP TABLE IF EXISTS `product`;

-- Mở kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;

-- Khởi tạo bảng
CREATE TABLE `user` (
id INT PRIMARY KEY AUTO_INCREMENT,
phone_number NVARCHAR(255) UNIQUE,
address NVARCHAR(255),
full_name NVARCHAR(255),
birthday DATE,
email VARCHAR(255) UNIQUE,
password VARCHAR(255),
avatar NVARCHAR(255),
create_date timestamp DEFAULT CURRENT_TIMESTAMP,
modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
roles varchar(225) default 'USER',
active BIT DEFAULT 1,
reset_token_generated bit default false,
reset_password_token varchar(225) default null
);
CREATE TABLE `product` (
id INT PRIMARY KEY AUTO_INCREMENT,
name NVARCHAR(255),
price FLOAT,
quantity INT,
description NVARCHAR(500),
state BIT,
create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
percent_discount INT DEFAULT 0,
color_id INT,
storage_id INT,
category_id INT,
trademark_id INT
);
CREATE TABLE `orders`(
id INT PRIMARY KEY AUTO_INCREMENT,
total float,
create_date timestamp DEFAULT CURRENT_TIMESTAMP,
modified_date timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
state int,
user_id INT,
admin_name nvarchar(50)
);
CREATE TABLE `payment`(
id INT PRIMARY KEY AUTO_INCREMENT,
txn_ref nvarchar(20),
payment_amount float,
payment_method nvarchar(255),
state bit,
create_date timestamp DEFAULT CURRENT_TIMESTAMP,
order_id int
);
CREATE TABLE `order_detail` (
id INT PRIMARY KEY AUTO_INCREMENT,
quantity INT,
price FLOAT,
create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
order_id INT,
product_id INT
);
CREATE TABLE `preview`(
id INT PRIMARY KEY auto_increment,
rate float,
content NVARCHAR(255),
user_id INT,
create_date timestamp DEFAULT CURRENT_TIMESTAMP,
product_id int
);
CREATE TABLE `rep_preview`(
id INT PRIMARY KEY auto_increment,
create_date timestamp DEFAULT CURRENT_TIMESTAMP,
content NVARCHAR(255),
admin_id int,
preview_id int
);
CREATE TABLE `discount` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name NVARCHAR(255),
    percent FLOAT,
    product_id INT,
    description NVARCHAR(255),
    active BIT,
    special BIT DEFAULT FALSE,
    expiration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE `storage`(
id INT primary key auto_increment,
random_access_memory_value int,
random_access_memory_unit nvarchar(2),
read_only_memory_value int,
read_only_memory_unit nvarchar(2)
);

CREATE TABLE `image`(
id INT primary key auto_increment,
image_url  nvarchar(255),
product_id int
);
CREATE TABLE `color`(
id INT primary key auto_increment,
color nvarchar(255)
);
CREATE TABLE `category`
(
    id INT PRIMARY KEY auto_increment,
    name NVARCHAR(255),
    description NVARCHAR(255)
);
CREATE TABLE `trademark`
(
    id INT PRIMARY KEY auto_increment,
    name NVARCHAR(255),
    description NVARCHAR(255)
);
CREATE TABLE `cart_detail`
(
    id INT PRIMARY KEY auto_increment,
    product_id int,
    quantity int,
    cart_id int
);
CREATE TABLE `cart` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    session_id NVARCHAR(100)
);
-- Tringer
DELIMITER //
CREATE TRIGGER before_update_product
BEFORE UPDATE ON product FOR EACH ROW
BEGIN
  SET NEW.modified_date = CURRENT_TIMESTAMP;
END;
CREATE TRIGGER before_update_order
BEFORE UPDATE ON `orders` FOR EACH ROW
BEGIN
  SET NEW.modified_date = CURRENT_TIMESTAMP;
END;
CREATE TRIGGER before_update_discount
BEFORE UPDATE ON `discount` FOR EACH ROW
BEGIN
  SET NEW.modified_date = CURRENT_TIMESTAMP;
END;
CREATE TRIGGER before_update_cart
BEFORE UPDATE ON `cart` FOR EACH ROW
BEGIN
  SET NEW.update_date = CURRENT_TIMESTAMP;
END;
CREATE TRIGGER before_update_user
BEFORE UPDATE ON `user` FOR EACH ROW
BEGIN
  SET NEW.modified_date = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;
-- Thêm khóa ngoại
ALTER TABLE `orders` ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE;
ALTER TABLE `payment` ADD CONSTRAINT fk_payment_orders FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE `order_detail` ADD CONSTRAINT fk_orderDeatil_orders FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE `order_detail` ADD CONSTRAINT fk_orderDeatil_product FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
ALTER TABLE `cart_detail` ADD CONSTRAINT fk_cartDetail_product  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
ALTER TABLE `cart_detail` ADD CONSTRAINT fk_cartDetail_cart FOREIGN KEY (cart_id) REFERENCES cart(id) ON DELETE CASCADE;
ALTER TABLE `cart` ADD CONSTRAINT fk_cart_user  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE;
ALTER TABLE `preview` ADD CONSTRAINT fk_preview_user  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE;
ALTER TABLE `preview` ADD CONSTRAINT fk_preview_product  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
ALTER TABLE `rep_preview` ADD CONSTRAINT fk_repPreview_admin  FOREIGN KEY (admin_id) REFERENCES user(id) ON DELETE CASCADE;
ALTER TABLE `rep_preview` ADD CONSTRAINT fk_repPreview_preview  FOREIGN KEY (preview_id) REFERENCES preview(id) ON DELETE CASCADE;
ALTER TABLE `discount` ADD CONSTRAINT fk_discount_product FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
ALTER TABLE `product` ADD CONSTRAINT fk_product_storage FOREIGN KEY (storage_id) REFERENCES storage(id) ON DELETE CASCADE;
ALTER TABLE `product` ADD CONSTRAINT fk_product_color  FOREIGN KEY (color_id) REFERENCES color(id) ON DELETE CASCADE;
ALTER TABLE `product` ADD CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE;
ALTER TABLE `product` ADD CONSTRAINT fk_product_trademark  FOREIGN KEY (trademark_id) REFERENCES trademark(id) ON DELETE CASCADE;
ALTER TABLE `image` ADD CONSTRAINT fk_image_product  FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE;
-- Thêm dữ liệu
use mobile_store_online;
INSERT INTO user (phone_number ,address ,full_name , birthday, email ,password ,avatar, active,roles) VALUES 
("0387887142","TP. Hồ Chí Minh","Huỳnh Thanh Phi","2003-10-10","phihtps23333@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","phiht.png",true,"ROLE_USER"),
("0355333455","Hà Nội","Nguyễn Ánh Hoa","2002-05-10","hoanaps33444@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","hoana.png",true,"ROLE_USER"),
("0387887435","TP. Hồ Chí Minh","Nguyễn Minh Hậu","2003-10-10","haunmps23333@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","haunm.png",true,"ROLE_USER"),
("0384587435","TP. Hồ Chí Minh","Nguyễn Minh Ninh","2003-10-10","ninhnmps23333@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","haunm.png",true,"ROLE_ADMIN"),
("03845844247","TP. Hồ Chí Minh","Lê Anh Kiệt","2003-11-22","leanhkiet2018hd1@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0384577437","TP. Hồ Chí Minh","Tâm","2003-11-1","anhkietle223@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0384587017","TP. Hồ Chí Minh","Tình","2003-11-1","Tinh@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0382387437","TP. Hồ Chí Minh","Nam","2003-11-1","Nam@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0384581437","TP. Hồ Chí Minh","Hoài","2003-11-1","hoai@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0245874377","TP. Hồ Chí Minh","Hoa","2003-11-1","hoa@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0315587437","TP. Hồ Chí Minh","Đào","2003-11-1","dao@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER");
INSERT INTO user (phone_number ,address ,full_name , birthday, email ,password ,avatar, active,roles) VALUES 
("0215587437","TP. Hồ Chí Minh","Tuyet","2003-11-1","tuyet@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0215587438","TP. Hồ Chí Minh","Trung","2003-11-1","trung@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0215547437","TP. Hồ Chí Minh","Mỹ","2003-11-1","my@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0415587437","TP. Hồ Chí Minh","Xuân","2003-11-1","xuan@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0215517437","TP. Hồ Chí Minh","Nhi","2003-11-1","nhi@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0215587237","TP. Hồ Chí Minh","Thi","2003-11-1","thi@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0213587437","TP. Hồ Chí Minh","Giang","2003-11-1","giang@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0295587437","TP. Hồ Chí Minh","Linh","2003-11-1","linh@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER"),
("0215887437","TP. Hồ Chí Minh","Châu","2003-11-1","chau@gmail.com","$2a$10$Np1KuzBghglFg59ohy9RO.YjRo4wdpVPn/xil2KV3l.6iXt/l3BXG","kiet.png",true,"ROLE_USER");

-- Thêm dữ liệu cho bảng color
INSERT INTO color (color) VALUES ('Đen'), ('Trắng'), ('Vàng'), ('Bạc'), ('Xám Đen'), ('Hồng Vàng'), ('Xanh Đen Nửa Đêm'), ('Xanh Dương') ,("Chàm"),("Tím"),("Hồng"),("Đỏ"),("Xanh lá"),("Cam"),("Titan");
-- Thêm dữ liệu cho bảng storage
INSERT INTO storage (random_access_memory_value, random_access_memory_unit, read_only_memory_value, read_only_memory_unit) VALUES 
(1, 'GB', 16, 'GB'),
(1, 'GB', 32, 'GB'), 
(1, 'GB', 64, 'GB'), 
(2, 'GB', 32, 'GB'),
(2, 'GB', 64, 'GB'), 
(2, 'GB', 128, 'GB'), 
(4, 'GB', 64, 'GB'),
(4, 'GB', 128, 'GB'), 
(4, 'GB', 256, 'GB'), 
(6, 'GB', 64, 'GB'), 
(6, 'GB', 128, 'GB'), 
(6, 'GB', 256, 'GB') , 
(8, 'GB', 64, 'GB'), 
(8, 'GB', 128, 'GB'), 
(8, 'GB', 256, 'GB'), 
(8, 'GB', 526, 'GB'), 
(8, 'GB', 1, 'TB'), 
(12, 'GB', 64, 'GB'), 
(12, 'GB', 128, 'GB'), 
(12, 'GB', 256, 'GB'), 
(12, 'GB', 526, 'GB'), 
(12, 'GB', 1, 'TB'), 
(16, 'GB', 64, 'GB'), 
(16, 'GB', 128, 'GB'), 
(16, 'GB', 256, 'GB'),
(16, 'GB', 526, 'TB'),
(32, 'GB', 64, 'GB'), 
(32, 'GB', 128, 'GB'), 
(32, 'GB', 256, 'GB'),
(32, 'GB', 526, 'GB'),
(32, 'GB', 1, 'TB');
-- Thêm dữ liệu cho bảng category (danh mục iPhone)
INSERT INTO category (name, description) VALUES
('iPhone X', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 10.'),
('iPhone XS', 'Danh mục chứa các sản phẩm thuộc dòng iPhone XS.'),
('iPhone XS Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone XS.'),
('iPhone XR', 'Danh mục chứa các sản phẩm thuộc dòng iPhone XR.'),
('iPhone 11', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 11.'),
('iPhone 11 Pro', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 11.'),
('iPhone 11 Pro Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 11.'),
('iPhone 12', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 12.'),
('iPhone 12 Pro', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 12.'),
('iPhone 12 Pro Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 12.'),
('iPhone 13', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 13.'),
('iPhone 13 Pro', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 13.'),
('iPhone 13 Pro Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 13.'),
('iPhone 14', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 14.'),
('iPhone 14 Pro', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 14.'),
('iPhone 14 Pro Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 14.'),
('iPhone 15', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 15.'),
('iPhone 15 Pro', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 15.'),
('iPhone 15 Pro Max', 'Danh mục chứa các sản phẩm thuộc dòng iPhone 15.'),
('Samsung Galaxy S22', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy S22.'),
('Samsung Galaxy S22 Utral', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy S22.'),
('Samsung Galaxy S23', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy S23.'),
('Samsung Galaxy S23 Utral', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy S23.'),
('Samsung Galaxy Z Fold 5', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy Z Fold5.'),
('Samsung Galaxy Z Flip 5', 'Danh mục chứa các sản phẩm thuộc dòng Samsung Galaxy Z Flip5.'),
('OPPO Find N3 Flip', 'Danh mục chứa các sản phẩm thuộc dòng OPPO Find N3 Flip.'),
('OPPO Find N2 Flip', 'Danh mục chứa các sản phẩm thuộc dòng OPPO Find N2 Flip.'),
('OPPO Reno10 5G', 'Danh mục chứa các sản phẩm thuộc dòng OPPO Reno10 5G.'),
('PPO Reno8 T 5G', 'Danh mục chứa các sản phẩm thuộc dòng PPO Reno8 T 5G.'),
('PPO Reno8 Z 5G', 'Danh mục chứa các sản phẩm thuộc dòng PPO Reno8 T 5G.'),
('PPO Reno8', 'Danh mục chứa các sản phẩm thuộc dòng PPO Reno8 T 5G.'),
('Xiaomi 13T 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi 13T.'),
('Xiaomi 13T Pro 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi 13T.'),
('Xiaomi 12 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi 12.'),
('Xiaomi 12 Pro 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi Redmi.'),
('Realme 11 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi Redmi.'),
('Realme 11 Pro 5G', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi Redmi.'),
('Realme C55', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi Redmi.'),
('Realme C51', 'Danh mục chứa các sản phẩm thuộc dòng Xiaomi Redmi.'),
('Vivo v29e', 'Danh mục chứa các sản phẩm thuộc dòng Vivo.'),
('Vivo v27e', 'Danh mục chứa các sản phẩm thuộc dòng Vivo.'),
('Vivo v25 Pro 5G', 'Danh mục chứa các sản phẩm thuộc dòng Vivo.');

-- Thêm dữ liệu cho bảng trademark
INSERT INTO trademark (name, description) VALUES 
('Apple', 'Công ty công nghệ nổi tiếng với dòng sản phẩm iPhone'),
('Samsung', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Galaxy'),
('Xiaomi', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Mi'),
('Realme', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Mi'),
('OPPO', 'Công ty công nghệ nổi tiếng với dòng sản phẩm OPPO'),
('Vivo', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Vivo'),
('Lenovo', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Lenovo'),
('Sony', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Xperia'),
('Huawei', 'Công ty công nghệ nổi tiếng với dòng sản phẩm P30'),
('LG', 'Công ty công nghệ nổi tiếng với dòng sản phẩm G series'),
('Nokia', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Nokia 9'),
('Google', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Pixel'),
('OnePlus', 'Công ty công nghệ nổi tiếng với dòng sản phẩm OnePlus 8'),
('Motorola', 'Công ty công nghệ nổi tiếng với dòng sản phẩm Moto G'),
('HTC', 'Công ty công nghệ nổi tiếng với dòng sản phẩm HTC U'),
('BlackBerry', 'Công ty công nghệ nổi tiếng với dòng sản phẩm BlackBerry Key'),
('Asus', 'Công ty công nghệ nổi tiếng với dòng sản phẩm ROG Phone');

-- Thêm dữ liệu cho bảng product (iPhone) - Từ iPhone 7 trở lên
INSERT INTO `product` VALUES (1, 'iPhone X 64GB', 5000000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 7, 1, 1);
INSERT INTO `product` VALUES (2, 'iPhone X 64GB', 5000000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 1, 7, 1, 1);
INSERT INTO `product` VALUES (3, 'iPhone X 64GB', 5000000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 5, 7, 1, 1);
INSERT INTO `product` VALUES (4, 'iPhone X 128GB', 5900000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 8, 1, 1);
INSERT INTO `product` VALUES (5, 'iPhone X 128GB', 5900000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 1, 8, 1, 1);
INSERT INTO `product` VALUES (6, 'iPhone X 128GB', 5900000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 5, 8, 1, 1);
INSERT INTO `product` VALUES (7, 'iPhone X 256GB', 6500000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 2, 9, 1, 1);
INSERT INTO `product` VALUES (8, 'iPhone X 256GB', 6500000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 9, 1, 1);
INSERT INTO `product` VALUES (9, 'iPhone X 256GB', 6500000, 35, 'iPhone X - Bước đột phá với màn hình OLED, thiết kế không viền và Face ID. Cho trải nghiệm người dùng hiện đại.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 5, 9, 1, 1);
INSERT INTO `product` VALUES (10, 'iPhone XS 64GB', 6000000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 7, 2, 1);
INSERT INTO `product` VALUES (11, 'iPhone XS 64GB', 6000000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 7, 2, 1);
INSERT INTO `product` VALUES (12, 'iPhone XS 64GB', 6000000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 7, 2, 1);
INSERT INTO `product` VALUES (13, 'iPhone XS 128GB', 6900000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 8, 2, 1);
INSERT INTO `product` VALUES (14, 'iPhone XS 128GB', 6900000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 8, 2, 1);
INSERT INTO `product` VALUES (15, 'iPhone XS 128GB', 6900000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 8, 2, 1);
INSERT INTO `product` VALUES (16, 'iPhone XS 256GB', 7500000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 9, 2, 1);
INSERT INTO `product` VALUES (17, 'iPhone XS 256GB', 7500000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 9, 2, 1);
INSERT INTO `product` VALUES (18, 'iPhone XS 256GB', 7500000, 35, 'iPhone XS - Mô hình tiếp theo với hiệu suất mạnh mẽ, camera kép nâng cấp và màn hình OLED. Sự lựa chọn cao cấp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 9, 2, 1);
INSERT INTO `product` VALUES (19, 'iPhone XS Max 64GB', 7100000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 7, 3, 1);
INSERT INTO `product` VALUES (20, 'iPhone XS Max 64GB', 7100000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 7, 3, 1);
INSERT INTO `product` VALUES (21, 'iPhone XS Max 64GB', 7100000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 7, 3, 1);
INSERT INTO `product` VALUES (22, 'iPhone XS Max 128GB', 8000000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 8, 3, 1);
INSERT INTO `product` VALUES (23, 'iPhone XS Max 128GB', 8000000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 8, 3, 1);
INSERT INTO `product` VALUES (24, 'iPhone XS Max 128GB', 8000000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 8, 3, 1);
INSERT INTO `product` VALUES (25, 'iPhone XS Max 256GB', 8500000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 3, 9, 3, 1);
INSERT INTO `product` VALUES (26, 'iPhone XS Max 256GB', 8500000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 4, 9, 3, 1);
INSERT INTO `product` VALUES (27, 'iPhone XS Max 256GB', 8500000, 25, 'iPhone XS Max - Phiên bản lớn nhất với màn hình OLED lớn, pin dung lượng cao và camera chất lượng. Điện thoại đa phương tiện hàng đầu.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 1, 9, 3, 1);
INSERT INTO `product` VALUES (28, 'iPhone XR 64GB', 7000000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 10, 12, 7, 4, 1);
INSERT INTO `product` VALUES (29, 'iPhone XR 64GB', 7000000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 3, 7, 4, 1);
INSERT INTO `product` VALUES (30, 'iPhone XR 64GB', 7000000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 8, 7, 4, 1);
INSERT INTO `product` VALUES (31, 'iPhone XR 128GB', 7600000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 8, 4, 1);
INSERT INTO `product` VALUES (32, 'iPhone XR 128GB', 7600000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 1, 8, 4, 1);
INSERT INTO `product` VALUES (33, 'iPhone XR 128GB', 7600000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 14, 8, 4, 1);
INSERT INTO `product` VALUES (34, 'iPhone XR 256GB', 8500000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 1, 9, 4, 1);
INSERT INTO `product` VALUES (35, 'iPhone XR 256GB', 8500000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 8, 9, 4, 1);
INSERT INTO `product` VALUES (36, 'iPhone XR 256GB', 8500000, 35, 'iPhone XR - Sự kết hợp giữa hiệu suất ổn định và giá trị tốt. Màn hình Liquid Retina đẹp và camera chất lượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 3, 9, 4, 1);
INSERT INTO `product` VALUES (37, 'iPhone 11 64GB', 10990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 1, 7, 5, 1);
INSERT INTO `product` VALUES (38, 'iPhone 11 64GB', 10990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 2, 7, 5, 1);
INSERT INTO `product` VALUES (39, 'iPhone 11 64GB', 10990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 13, 7, 5, 1);
INSERT INTO `product` VALUES (40, 'iPhone 11 128GB', 11990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 10, 8, 5, 1);
INSERT INTO `product` VALUES (41, 'iPhone 11 128GB', 11990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 2, 8, 5, 1);
INSERT INTO `product` VALUES (42, 'iPhone 11 128GB', 11990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 13, 8, 5, 1);
INSERT INTO `product` VALUES (43, 'iPhone 11 256GB', 12990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 20, 1, 9, 5, 1);
INSERT INTO `product` VALUES (44, 'iPhone 11 256GB', 12990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 2, 9, 5, 1);
INSERT INTO `product` VALUES (45, 'iPhone 11 256GB', 12990000, 40, 'iPhone 11 - Mô hình nổi bật với hệ thống camera kép, pin dung lượng cao và hiệu suất mạnh mẽ. Sự lựa chọn tốt cho cả giải trí và công việc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 20, 13, 9, 5, 1);
INSERT INTO `product` VALUES (46, 'iPhone 11 Pro 64GB', 12990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 10, 7, 6, 1);
INSERT INTO `product` VALUES (47, 'iPhone 11 Pro 64GB', 12990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 7, 6, 1);
INSERT INTO `product` VALUES (48, 'iPhone 11 Pro 64GB', 12990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 13, 7, 6, 1);
INSERT INTO `product` VALUES (49, 'iPhone 11 Pro 128GB', 12790000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 8, 6, 1);
INSERT INTO `product` VALUES (50, 'iPhone 11 Pro 128GB', 12790000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 13, 8, 6, 1);
INSERT INTO `product` VALUES (51, 'iPhone 11 Pro 128GB', 12790000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 10, 8, 6, 1);
INSERT INTO `product` VALUES (52, 'iPhone 11 Pro 256GB', 13990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 2, 9, 6, 1);
INSERT INTO `product` VALUES (53, 'iPhone 11 Pro 256GB', 13990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 13, 9, 6, 1);
INSERT INTO `product` VALUES (54, 'iPhone 11 Pro 256GB', 13990000, 35, 'iPhone 11 Pro - Điện thoại chuyên nghiệp với hệ thống camera ba cảm biến, màn hình OLED và hiệu suất ấn tượng. Cho người dùng đòi hỏi cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 10, 10, 9, 6, 1);
INSERT INTO `product` VALUES (55, 'iPhone 11 Pro Max 64GB', 14990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 7, 7, 1);
INSERT INTO `product` VALUES (56, 'iPhone 11 Pro Max 64GB', 14990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 7, 7, 1);
INSERT INTO `product` VALUES (57, 'iPhone 11 Pro Max 64GB', 14990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 7, 7, 1);
INSERT INTO `product` VALUES (58, 'iPhone 11 Pro Max 128GB', 15990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 8, 7, 1);
INSERT INTO `product` VALUES (59, 'iPhone 11 Pro Max 128GB', 15990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 8, 7, 1);
INSERT INTO `product` VALUES (60, 'iPhone 11 Pro Max 128GB', 15990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 8, 7, 1);
INSERT INTO `product` VALUES (61, 'iPhone 11 Pro Max 256GB', 16990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 9, 7, 1);
INSERT INTO `product` VALUES (62, 'iPhone 11 Pro Max 256GB', 16990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 9, 7, 1);
INSERT INTO `product` VALUES (63, 'iPhone 11 Pro Max 256GB', 16990000, 30, 'iPhone 11 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Sự lựa chọn cao cấp nhất của Apple.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 9, 7, 1);
INSERT INTO `product` VALUES (64, 'iPhone 12 64GB', 17990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 13, 8, 1);
INSERT INTO `product` VALUES (65, 'iPhone 12 64GB', 17990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 13, 8, 1);
INSERT INTO `product` VALUES (66, 'iPhone 12 64GB', 17990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 13, 8, 1);
INSERT INTO `product` VALUES (67, 'iPhone 12 128GB', 18990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 8, 1);
INSERT INTO `product` VALUES (68, 'iPhone 12 128GB', 18990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 8, 1);
INSERT INTO `product` VALUES (69, 'iPhone 12 128GB', 18990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 8, 1);
INSERT INTO `product` VALUES (70, 'iPhone 12 256GB', 19990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 15, 8, 1);
INSERT INTO `product` VALUES (71, 'iPhone 12 256GB', 19990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 8, 1);
INSERT INTO `product` VALUES (72, 'iPhone 12 256GB', 19990000, 25, 'iPhone 12 - Mô hình với thiết kế mới, hỗ trợ 5G và hiệu suất mạnh mẽ. Màn hình Super Retina XDR cho trải nghiệm tuyệt vời.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 8, 1);
INSERT INTO `product` VALUES (73, 'iPhone 12 Pro 64GB', 20990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 13, 9, 1);
INSERT INTO `product` VALUES (74, 'iPhone 12 Pro 64GB', 20990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 13, 9, 1);
INSERT INTO `product` VALUES (75, 'iPhone 12 Pro 64GB', 20990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 13, 9, 1);
INSERT INTO `product` VALUES (76, 'iPhone 12 Pro 128GB', 21990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 14, 9, 1);
INSERT INTO `product` VALUES (77, 'iPhone 12 Pro 128GB', 21990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 14, 9, 1);
INSERT INTO `product` VALUES (78, 'iPhone 12 Pro 128GB', 21990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 14, 9, 1);
INSERT INTO `product` VALUES (79, 'iPhone 12 Pro 256GB', 22990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 15, 9, 1);
INSERT INTO `product` VALUES (80, 'iPhone 12 Pro 256GB', 22990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 9, 1);
INSERT INTO `product` VALUES (81, 'iPhone 12 Pro 256GB', 22990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 9, 1);
INSERT INTO `product` VALUES (82, 'iPhone 12 Pro 526GB', 23990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 9, 1);
INSERT INTO `product` VALUES (83, 'iPhone 12 Pro 526GB', 23990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 16, 9, 1);
INSERT INTO `product` VALUES (84, 'iPhone 12 Pro 526GB', 23990000, 30, 'iPhone 12 Pro - Sự chuyên nghiệp với hệ thống camera nâng cấp, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 16, 9, 1);
INSERT INTO `product` VALUES (85, 'iPhone 12 Pro Max 128GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 14, 10, 1);
INSERT INTO `product` VALUES (86, 'iPhone 12 Pro Max 128GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 14, 10, 1);
INSERT INTO `product` VALUES (87, 'iPhone 12 Pro Max 128GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 14, 10, 1);
INSERT INTO `product` VALUES (88, 'iPhone 12 Pro Max 256GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 15, 10, 1);
INSERT INTO `product` VALUES (89, 'iPhone 12 Pro Max 256GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 10, 1);
INSERT INTO `product` VALUES (90, 'iPhone 12 Pro Max 256GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 10, 1);
INSERT INTO `product` VALUES (91, 'iPhone 12 Pro Max 526GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 10, 1);
INSERT INTO `product` VALUES (92, 'iPhone 12 Pro Max 526GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 16, 10, 1);
INSERT INTO `product` VALUES (93, 'iPhone 12 Pro Max 526GB', 20990000, 25, 'iPhone 12 Pro Max - Phiên bản lớn nhất với camera chất lượng cao, màn hình lớn và pin dung lượng cao. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 16, 10, 1);
INSERT INTO `product` VALUES (94, 'iPhone 13 128GB', 18990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 14, 11, 1);
INSERT INTO `product` VALUES (95, 'iPhone 13 128GB', 18990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 11, 1);
INSERT INTO `product` VALUES (96, 'iPhone 13 128GB', 18990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 11, 1);
INSERT INTO `product` VALUES (97, 'iPhone 13 256GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 11, 1);
INSERT INTO `product` VALUES (98, 'iPhone 13 256GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 15, 11, 1);
INSERT INTO `product` VALUES (99, 'iPhone 13 256GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 11, 1);
INSERT INTO `product` VALUES (100, 'iPhone 13 526GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 16, 11, 1);
INSERT INTO `product` VALUES (101, 'iPhone 13 526GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 16, 11, 1);
INSERT INTO `product` VALUES (102, 'iPhone 13 526GB', 19990000, 25, 'iPhone 13 - Mô hình mới với thiết kế hiện đại, camera nâng cấp và hiệu suất mạnh mẽ. Trải nghiệm iOS tốt nhất.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 16, 11, 1);
INSERT INTO `product` VALUES (103, 'iPhone 13 Pro 128GB', 21990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 14, 12, 1);
INSERT INTO `product` VALUES (104, 'iPhone 13 Pro 128GB', 21990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 12, 1);
INSERT INTO `product` VALUES (105, 'iPhone 13 Pro 128GB', 21990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 12, 1);
INSERT INTO `product` VALUES (106, 'iPhone 13 Pro 256GB', 22990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 15, 12, 1);
INSERT INTO `product` VALUES (107, 'iPhone 13 Pro 256GB', 22990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 15, 12, 1);
INSERT INTO `product` VALUES (108, 'iPhone 13 Pro 256GB', 22990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 12, 1);
INSERT INTO `product` VALUES (109, 'iPhone 13 Pro 526GB', 23990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 16, 12, 1);
INSERT INTO `product` VALUES (110, 'iPhone 13 Pro 526GB', 23990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 12, 1);
INSERT INTO `product` VALUES (111, 'iPhone 13 Pro 526GB', 23990000, 30, 'iPhone 13 Pro - Sự chuyên nghiệp với hệ thống camera đa cảm biến, màn hình ProMotion và hiệu suất ấn tượng. Cho người dùng sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 16, 12, 1);
INSERT INTO `product` VALUES (112, 'iPhone 13 Pro Max 128GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 14, 13, 1);
INSERT INTO `product` VALUES (113, 'iPhone 13 Pro Max 128GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 13, 1);
INSERT INTO `product` VALUES (114, 'iPhone 13 Pro Max 128GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 13, 1);
INSERT INTO `product` VALUES (115, 'iPhone 13 Pro Max 256GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 13, 1);
INSERT INTO `product` VALUES (116, 'iPhone 13 Pro Max 256GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 15, 13, 1);
INSERT INTO `product` VALUES (117, 'iPhone 13 Pro Max 256GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 13, 1);
INSERT INTO `product` VALUES (118, 'iPhone 13 Pro Max 526GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 16, 13, 1);
INSERT INTO `product` VALUES (119, 'iPhone 13 Pro Max 526GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 16, 13, 1);
INSERT INTO `product` VALUES (120, 'iPhone 13 Pro Max 526GB', 20990000, 25, 'iPhone 13 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh xuất sắc.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 16, 13, 1);
INSERT INTO `product` VALUES (121, 'iPhone 14 128GB', 18990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 14, 14, 1);
INSERT INTO `product` VALUES (122, 'iPhone 14 128GB', 18990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 14, 1);
INSERT INTO `product` VALUES (123, 'iPhone 14 128GB', 18990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 14, 14, 1);
INSERT INTO `product` VALUES (124, 'iPhone 14 256GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 15, 14, 1);
INSERT INTO `product` VALUES (125, 'iPhone 14 256GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 14, 1);
INSERT INTO `product` VALUES (126, 'iPhone 14 256GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 15, 14, 1);
INSERT INTO `product` VALUES (127, 'iPhone 14 526GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 14, 1);
INSERT INTO `product` VALUES (128, 'iPhone 14 526GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 12, 16, 14, 1);
INSERT INTO `product` VALUES (129, 'iPhone 14 526GB', 19990000, 25, 'iPhone 14 - Dòng sản phẩm tiếp theo với thiết kế đột phá và công nghệ tiên tiến. Màn hình đẹp và hiệu suất ấn tượng.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 16, 14, 1);
INSERT INTO `product` VALUES (130, 'iPhone 14 Pro 128GB', 21990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 14, 15, 1);
INSERT INTO `product` VALUES (131, 'iPhone 14 Pro 128GB', 21990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 14, 15, 1);
INSERT INTO `product` VALUES (132, 'iPhone 14 Pro 128GB', 21990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 14, 15, 1);
INSERT INTO `product` VALUES (133, 'iPhone 14 Pro 256GB', 22990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 15, 1);
INSERT INTO `product` VALUES (134, 'iPhone 14 Pro 256GB', 22990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 15, 15, 1);
INSERT INTO `product` VALUES (135, 'iPhone 14 Pro 256GB', 22990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 15, 15, 1);
INSERT INTO `product` VALUES (136, 'iPhone 14 Pro 526GB', 23990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 15, 1);
INSERT INTO `product` VALUES (137, 'iPhone 14 Pro 526GB', 23990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 16, 15, 1);
INSERT INTO `product` VALUES (138, 'iPhone 14 Pro 526GB', 23990000, 30, 'iPhone 14 Pro - Mô hình chuyên nghiệp với hệ thống camera tiên tiến, màn hình OLED và khả năng xử lý mạnh mẽ. Cho trải nghiệm sáng tạo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 16, 15, 1);
INSERT INTO `product` VALUES (139, 'iPhone 14 Pro Max 128GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 14, 16, 1);
INSERT INTO `product` VALUES (140, 'iPhone 14 Pro Max 128GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 16, 1);
INSERT INTO `product` VALUES (141, 'iPhone 14 Pro Max 128GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 14, 16, 1);
INSERT INTO `product` VALUES (142, 'iPhone 14 Pro Max 256GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 16, 1);
INSERT INTO `product` VALUES (143, 'iPhone 14 Pro Max 256GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 15, 16, 1);
INSERT INTO `product` VALUES (144, 'iPhone 14 Pro Max 256GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 15, 16, 1);
INSERT INTO `product` VALUES (145, 'iPhone 14 Pro Max 526GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 16, 1);
INSERT INTO `product` VALUES (146, 'iPhone 14 Pro Max 526GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 16, 16, 1);
INSERT INTO `product` VALUES (147, 'iPhone 14 Pro Max 526GB', 20990000, 25, 'iPhone 14 Pro Max - Phiên bản lớn nhất với màn hình lớn, pin dung lượng cao và camera chất lượng. Điện thoại chụp ảnh và quay video đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 5, 16, 16, 1);
INSERT INTO `product` VALUES (148, 'iPhone 15 128GB', 18990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 17, 1);
INSERT INTO `product` VALUES (149, 'iPhone 15 128GB', 18990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 14, 17, 1);
INSERT INTO `product` VALUES (150, 'iPhone 15 128GB', 18990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 17, 1);
INSERT INTO `product` VALUES (151, 'iPhone 15 256GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 15, 17, 1);
INSERT INTO `product` VALUES (152, 'iPhone 15 256GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 13, 15, 17, 1);
INSERT INTO `product` VALUES (153, 'iPhone 15 256GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 15, 17, 1);
INSERT INTO `product` VALUES (154, 'iPhone 15 526GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 3, 16, 17, 1);
INSERT INTO `product` VALUES (155, 'iPhone 15 526GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 17, 1);
INSERT INTO `product` VALUES (156, 'iPhone 15 526GB', 19990000, 25, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 16, 17, 1);
INSERT INTO `product` VALUES (157, 'iPhone 15 Pro 128GB', 21990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 18, 1);
INSERT INTO `product` VALUES (158, 'iPhone 15 Pro 128GB', 21990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 18, 1);
INSERT INTO `product` VALUES (159, 'iPhone 15 Pro 128GB', 21990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 18, 1);
INSERT INTO `product` VALUES (160, 'iPhone 15 Pro 256GB', 22990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 15, 15, 18, 1);
INSERT INTO `product` VALUES (161, 'iPhone 15 Pro 256GB', 22990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 15, 18, 1);
INSERT INTO `product` VALUES (162, 'iPhone 15 Pro 256GB', 22990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 18, 1);
INSERT INTO `product` VALUES (163, 'iPhone 15 Pro 526GB', 23990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 18, 1);
INSERT INTO `product` VALUES (164, 'iPhone 15 Pro 526GB', 23990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 16, 18, 1);
INSERT INTO `product` VALUES (165, 'iPhone 15 Pro 526GB', 23990000, 30, 'iPhone 15 - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo.', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 18, 1);
INSERT INTO `product` VALUES (166, 'iPhone 15 Pro Max 128GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 14, 19, 1);
INSERT INTO `product` VALUES (167, 'iPhone 15 Pro Max 128GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 14, 19, 1);
INSERT INTO `product` VALUES (168, 'iPhone 15 Pro Max 128GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 14, 19, 1);
INSERT INTO `product` VALUES (169, 'iPhone 15 Pro Max 256GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 15, 15, 19, 1);
INSERT INTO `product` VALUES (170, 'iPhone 15 Pro Max 256GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 11, 15, 19, 1);
INSERT INTO `product` VALUES (171, 'iPhone 15 Pro Max 256GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 15, 19, 1);
INSERT INTO `product` VALUES (172, 'iPhone 15 Pro Max 526GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 16, 19, 1);
INSERT INTO `product` VALUES (173, 'iPhone 15 Pro Max 526GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 16, 19, 1);
INSERT INTO `product` VALUES (174, 'iPhone 15 Pro Max 526GB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 16, 19, 1);
INSERT INTO `product` VALUES (175, 'iPhone 15 Pro Max 1TB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 8, 17, 19, 1);
INSERT INTO `product` VALUES (176, 'iPhone 15 Pro Max 1TB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 1, 17, 19, 1);
INSERT INTO `product` VALUES (177, 'iPhone 15 Pro Max 1TB', 20990000, 25, 'iPhone 15 Pro - Dòng sản phẩm đỉnh cao với công nghệ mới, camera vô cùng nâng cao và hiệu suất không giới hạn. Trải nghiệm di động hoàn hảo', b'1', '2023-12-20 00:54:12', '2023-12-20 01:12:29', 0, 2, 17, 19, 1);
INSERT INTO `product` VALUES (178, 'Samsung S22 256GB', 26550000, 20, 'Samsung S22 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 1 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 11, 15, 20, 2);
INSERT INTO `product` VALUES (179, 'Samsung S22 256GB', 26550000, 20, 'Samsung S22 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 1 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 15, 20, 2);
INSERT INTO `product` VALUES (180, 'Samsung S22 526GB', 26550000, 20, 'Samsung S22 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 1 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 20, 2);
INSERT INTO `product` VALUES (181, 'Samsung S22 526GB', 26550000, 20, 'Samsung S22 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 1 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 16, 20, 2);
INSERT INTO `product` VALUES (182, 'Samsung S22 Ultra 256GB', 27190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 20, 21, 2);
INSERT INTO `product` VALUES (183, 'Samsung S22 Ultra 256GB', 27190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 20, 21, 2);
INSERT INTO `product` VALUES (184, 'Samsung S22 Ultra 526GB', 28190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 21, 21, 2);
INSERT INTO `product` VALUES (185, 'Samsung S22 Ultra 526GB', 28190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 12, 21, 21, 2);
INSERT INTO `product` VALUES (186, 'Samsung S22 Ultra 1TB', 28190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 12, 22, 21, 2);
INSERT INTO `product` VALUES (187, 'Samsung S22 Ultra 1TB', 28190000, 34, 'Samsung S22 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 2 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 22, 21, 2);
INSERT INTO `product` VALUES (188, 'Samsung S23 256GB', 26550000, 20, 'Samsung S23 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 15, 22, 2);
INSERT INTO `product` VALUES (189, 'Samsung S23 256GB', 26550000, 20, 'Samsung S23 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 22, 2);
INSERT INTO `product` VALUES (190, 'Samsung S23 526GB', 26550000, 20, 'Samsung S23 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 16, 22, 2);
INSERT INTO `product` VALUES (191, 'Samsung S23 526GB', 26550000, 20, 'Samsung S23 là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 8GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 22, 2);
INSERT INTO `product` VALUES (192, 'Samsung S23 Ultra 256GB', 27190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 20, 23, 2);
INSERT INTO `product` VALUES (193, 'Samsung S23 Ultra 256GB', 27190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 20, 23, 2);
INSERT INTO `product` VALUES (194, 'Samsung S23 Ultra 526GB', 28190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 21, 23, 2);
INSERT INTO `product` VALUES (195, 'Samsung S23 Ultra 526GB', 28190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 21, 23, 2);
INSERT INTO `product` VALUES (196, 'Samsung S23 Ultra 1TB', 28190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2022.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 22, 23, 2);
INSERT INTO `product` VALUES (197, 'Samsung S23 Ultra 1TB', 28190000, 34, 'Samsung S23 Ultra là dòng điện thoại cao cấp của Samsung, sở hữu camera độ phân giải 200MP ấn tượng, chip Snapdragon 8 Gen 3 mạnh mẽ, bộ nhớ RAM 12GB mang lại hiệu suất xử lý vượt trội cùng khung viền vuông vức sang trọng. Sản phẩm được ra mắt từ đầu năm 2023.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 22, 23, 2);
INSERT INTO `product` VALUES (198, 'Samsung Z Fold 5 256GB', 40990000, 15, 'Samsung Galaxy Z Fold 5 12GB 256GB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 20, 24, 2);
INSERT INTO `product` VALUES (199, 'Samsung Z Fold 5 256GB', 40990000, 15, 'Samsung Galaxy Z Fold 5 12GB 256GB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 20, 24, 2);
INSERT INTO `product` VALUES (200, 'Samsung Z Fold 5 526GB', 40990000, 15, 'Samsung Galaxy Z Fold 5 12GB 526GB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 21, 24, 2);
INSERT INTO `product` VALUES (201, 'Samsung Z Fold 5 526GB', 40990000, 15, 'Samsung Galaxy Z Fold 5 12GB 526GB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 21, 24, 2);
INSERT INTO `product` VALUES (202, 'Samsung Z Fold 5 1TB', 47990000, 15, 'Samsung Galaxy Z Fold 5 12GB 1TB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 1, 24, 2);
INSERT INTO `product` VALUES (203, 'Samsung Z Fold 5 1TB', 47990000, 15, 'Samsung Galaxy Z Fold 5 12GB 1TB tạo nên trải nghiệm xử lý tác vụ siêu mượt mà thông qua chipset Snapdragon 8 Gen 2 đỉnh cao cùng dung lượng RAM lên tới 12GB. Máy được trang bị công nghệ màn hình Dynamic AMOLED 2X 120Hz với kích thước có thể lên tới 7.6 inch khi mở, đem lại trải nghiệm hình ảnh sắc nét trong từng điểm ảnh. Bên cạnh đó, phân khúc smartphone gập này còn sở hữu cụm camera hiện đại với độ sắc nét đạt tới 50MP cùng viên pin 4400mAh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 8, 24, 2);
INSERT INTO `product` VALUES (204, 'Samsung Z Flip 5 256GB', 25990000, 20, 'Samsung Galaxy Z Flip 5 có thiết kế màn hình rộng 6.7 inch và độ phân giải Full HD+ (1080 x 2640 Pixels), dung lượng RAM 8GB, bộ nhớ trong 256GB. Màn hình Dynamic AMOLED 2X của điện thoại này hiển thị rõ nét và sắc nét, mang đến trải nghiệm ấn tượng khi sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 25, 2);
INSERT INTO `product` VALUES (205, 'Samsung Z Flip 5 256GB', 25990000, 20, 'Samsung Galaxy Z Flip 5 có thiết kế màn hình rộng 6.7 inch và độ phân giải Full HD+ (1080 x 2640 Pixels), dung lượng RAM 8GB, bộ nhớ trong 256GB. Màn hình Dynamic AMOLED 2X của điện thoại này hiển thị rõ nét và sắc nét, mang đến trải nghiệm ấn tượng khi sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 15, 25, 2);
INSERT INTO `product` VALUES (206, 'Samsung Z Flip 5 526GB', 29990000, 30, 'Samsung Galaxy Z Flip 5 có thiết kế màn hình rộng 6.7 inch và độ phân giải Full HD+ (1080 x 2640 Pixels), dung lượng RAM 8GB, bộ nhớ trong 526GB. Màn hình Dynamic AMOLED 2X của điện thoại này hiển thị rõ nét và sắc nét, mang đến trải nghiệm ấn tượng khi sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 25, 2);
INSERT INTO `product` VALUES (207, 'Samsung Z Flip 5 526GB', 29990000, 30, 'Samsung Galaxy Z Flip 5 có thiết kế màn hình rộng 6.7 inch và độ phân giải Full HD+ (1080 x 2640 Pixels), dung lượng RAM 8GB, bộ nhớ trong 526GB. Màn hình Dynamic AMOLED 2X của điện thoại này hiển thị rõ nét và sắc nét, mang đến trải nghiệm ấn tượng khi sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 16, 25, 2);
INSERT INTO `product` VALUES (208, 'OPPO Find N3 Flip 256GB', 22990000, 60, 'OPPO Find N3 Flip có kích thước nhỏ gọn khi gập với màn hình chính rộng 6.8 inch và màn hình phụ 3.26 inch. Chất lượng ảnh chụp được nâng tầm hơn nhờ sự hợp tác với Hasselblad đi kèm cảm biến chính lên đến 50MP. Hiệu năng mạnh mẽ từ chip Dimensity 9200 cũng hỗ trợ xử lý tốt mọi yêu cầu của người dùng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 26, 5);
INSERT INTO `product` VALUES (209, 'OPPO Find N3 Flip 256GB', 22990000, 60, 'OPPO Find N3 Flip có kích thước nhỏ gọn khi gập với màn hình chính rộng 6.8 inch và màn hình phụ 3.26 inch. Chất lượng ảnh chụp được nâng tầm hơn nhờ sự hợp tác với Hasselblad đi kèm cảm biến chính lên đến 50MP. Hiệu năng mạnh mẽ từ chip Dimensity 9200 cũng hỗ trợ xử lý tốt mọi yêu cầu của người dùng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 15, 26, 5);
INSERT INTO `product` VALUES (210, 'OPPO Find N3 Flip 526GB', 22990000, 60, 'OPPO Find N3 Flip có kích thước nhỏ gọn khi gập với màn hình chính rộng 6.8 inch và màn hình phụ 3.26 inch. Chất lượng ảnh chụp được nâng tầm hơn nhờ sự hợp tác với Hasselblad đi kèm cảm biến chính lên đến 50MP. Hiệu năng mạnh mẽ từ chip Dimensity 9200 cũng hỗ trợ xử lý tốt mọi yêu cầu của người dùng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 26, 5);
INSERT INTO `product` VALUES (211, 'OPPO Find N3 Flip 526GB', 22990000, 60, 'OPPO Find N3 Flip có kích thước nhỏ gọn khi gập với màn hình chính rộng 6.8 inch và màn hình phụ 3.26 inch. Chất lượng ảnh chụp được nâng tầm hơn nhờ sự hợp tác với Hasselblad đi kèm cảm biến chính lên đến 50MP. Hiệu năng mạnh mẽ từ chip Dimensity 9200 cũng hỗ trợ xử lý tốt mọi yêu cầu của người dùng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 16, 26, 5);
INSERT INTO `product` VALUES (212, 'OPPO Find N2 Flip 256GB', 19900000, 25, 'OPPO Find N2 Flip 256GB sở hữu thiết kế trẻ trung, hiện đại. Chiếc smartphone này được trang bị màn hình AMOLED rộng 6.8 inch với độ phân giải Full HD mang đến những trải nghiệm mượt mà. Bên cạnh đó, nó còn có khả năng hoạt động mạnh mẽ cho người dùng thoải mái sử dụng các tác vụ từ cơ bản đến nâng cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 27, 5);
INSERT INTO `product` VALUES (213, 'OPPO Find N2 Flip 256GB', 19900000, 25, 'OPPO Find N2 Flip 256GB sở hữu thiết kế trẻ trung, hiện đại. Chiếc smartphone này được trang bị màn hình AMOLED rộng 6.8 inch với độ phân giải Full HD mang đến những trải nghiệm mượt mà. Bên cạnh đó, nó còn có khả năng hoạt động mạnh mẽ cho người dùng thoải mái sử dụng các tác vụ từ cơ bản đến nâng cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 27, 5);
INSERT INTO `product` VALUES (214, 'OPPO Find N2 Flip 526GB', 19900000, 25, 'OPPO Find N2 Flip 526GB sở hữu thiết kế trẻ trung, hiện đại. Chiếc smartphone này được trang bị màn hình AMOLED rộng 6.8 inch với độ phân giải Full HD mang đến những trải nghiệm mượt mà. Bên cạnh đó, nó còn có khả năng hoạt động mạnh mẽ cho người dùng thoải mái sử dụng các tác vụ từ cơ bản đến nâng cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 27, 5);
INSERT INTO `product` VALUES (215, 'OPPO Find N2 Flip 526GB', 19900000, 25, 'OPPO Find N2 Flip 526GB sở hữu thiết kế trẻ trung, hiện đại. Chiếc smartphone này được trang bị màn hình AMOLED rộng 6.8 inch với độ phân giải Full HD mang đến những trải nghiệm mượt mà. Bên cạnh đó, nó còn có khả năng hoạt động mạnh mẽ cho người dùng thoải mái sử dụng các tác vụ từ cơ bản đến nâng cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 27, 5);
INSERT INTO `product` VALUES (216, 'OPPO Reno10 5G 256GB', 10490000, 30, 'OPPO Reno10 5G 256GB Chính Hãng tiếp tục trở thành chuyên gia chân dung đời mới với camera tele 32MP. Điện thoại sở hữu thiết kế thời trang và màn hình siêu nét có tần số quét 120Hz. Chip Dimensity 7050 5G cho khả năng xử lý mượt mà đi kèm bộ nhớ lớn. Dung lượng pin 5000mAh và công suất sạc nhanh 67W kéo dài hoạt động cả ngày dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 15, 28, 5);
INSERT INTO `product` VALUES (217, 'OPPO Reno10 5G 256GB', 10490000, 30, 'OPPO Reno10 5G 256GB Chính Hãng tiếp tục trở thành chuyên gia chân dung đời mới với camera tele 32MP. Điện thoại sở hữu thiết kế thời trang và màn hình siêu nét có tần số quét 120Hz. Chip Dimensity 7050 5G cho khả năng xử lý mượt mà đi kèm bộ nhớ lớn. Dung lượng pin 5000mAh và công suất sạc nhanh 67W kéo dài hoạt động cả ngày dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 4, 15, 28, 5);
INSERT INTO `product` VALUES (218, 'OPPO Reno10 5G 526GB', 10490000, 30, 'OPPO Reno10 5G 526GB Chính Hãng tiếp tục trở thành chuyên gia chân dung đời mới với camera tele 32MP. Điện thoại sở hữu thiết kế thời trang và màn hình siêu nét có tần số quét 120Hz. Chip Dimensity 7050 5G cho khả năng xử lý mượt mà đi kèm bộ nhớ lớn. Dung lượng pin 5000mAh và công suất sạc nhanh 67W kéo dài hoạt động cả ngày dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 28, 5);
INSERT INTO `product` VALUES (219, 'OPPO Reno10 5G 526GB', 10490000, 30, 'OPPO Reno10 5G 526GB Chính Hãng tiếp tục trở thành chuyên gia chân dung đời mới với camera tele 32MP. Điện thoại sở hữu thiết kế thời trang và màn hình siêu nét có tần số quét 120Hz. Chip Dimensity 7050 5G cho khả năng xử lý mượt mà đi kèm bộ nhớ lớn. Dung lượng pin 5000mAh và công suất sạc nhanh 67W kéo dài hoạt động cả ngày dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 4, 16, 28, 5);
INSERT INTO `product` VALUES (220, 'OPPO Reno8 T 5G 128GB', 10090000, 60, 'OPPO RENO8 T 5G 128GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 14, 29, 5);
INSERT INTO `product` VALUES (221, 'OPPO Reno8 T 5G 128GB', 10090000, 60, 'OPPO RENO8 T 5G 128GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 14, 14, 29, 5);
INSERT INTO `product` VALUES (222, 'OPPO Reno8 T 5G 256GB', 12900000, 60, 'OPPO RENO8 T 5G 256GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 29, 5);
INSERT INTO `product` VALUES (223, 'OPPO Reno8 T 5G 256GB', 12900000, 60, 'OPPO RENO8 T 5G 256GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 14, 15, 29, 5);
INSERT INTO `product` VALUES (224, 'OPPO Reno8 Z 5G 256GB', 10090000, 60, 'OPPO RENO8 Z 5G 256GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 15, 30, 5);
INSERT INTO `product` VALUES (225, 'OPPO Reno8 Z 5G 256GB', 10090000, 60, 'OPPO RENO8 Z 5G 256GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 30, 5);
INSERT INTO `product` VALUES (226, 'OPPO Reno8 Z 5G 526GB', 10090000, 60, 'OPPO RENO8 Z 5G 526GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 16, 30, 5);
INSERT INTO `product` VALUES (227, 'OPPO Reno8 Z 5G 526GB', 10090000, 60, 'OPPO RENO8 Z 5G 526GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 30, 5);
INSERT INTO `product` VALUES (228, 'OPPO Reno8 64GB', 10090000, 60, 'OPPO RENO8 64GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 13, 31, 5);
INSERT INTO `product` VALUES (229, 'OPPO Reno8 64GB', 10090000, 60, 'OPPO RENO8 64GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 13, 31, 5);
INSERT INTO `product` VALUES (230, 'OPPO Reno8 128GB', 10090000, 60, 'OPPO RENO8 128GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 14, 31, 5);
INSERT INTO `product` VALUES (231, 'OPPO Reno8 128GB', 10090000, 60, 'OPPO RENO8 128GB sở hữu thiết kế mỏng nhẹ, vuông vức với mặt lưng sáng bóng. Chiếc máy này sở hữu màn hình AMOLED rộng 6.7 inch. Hiệu năng hoạt động mạnh mẽ nhờ được trang bị chip Snapdragon 695 5G 8 nhân, dung lượng pin 4800mAh tích hợp sạc nhanh 67W. Camera chính 108MP mang đến cho người dùng những thước phim, hình ảnh sắc nét và chuyên nghiệp.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 14, 31, 5);
INSERT INTO `product` VALUES (232, 'Xiaomi 13T 5G 256GB', 12900000, 30, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 31, 3);
INSERT INTO `product` VALUES (233, 'Xiaomi 13T 5G 256GB', 12900000, 30, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 15, 31, 3);
INSERT INTO `product` VALUES (234, 'Xiaomi 13T 5G 526GB', 12900000, 30, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 16, 31, 3);
INSERT INTO `product` VALUES (235, 'Xiaomi 13T 5G 526GB', 12900000, 30, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 31, 3);
INSERT INTO `product` VALUES (236, 'Xiaomi 13T Pro 5G 526GB', 15990000, 40, 'Xiaomi 13T Pro 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 32, 3);
INSERT INTO `product` VALUES (237, 'Xiaomi 13T Pro 5G 526GB', 15990000, 40, 'Xiaomi 13T Pro 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 32, 3);
INSERT INTO `product` VALUES (238, 'Xiaomi 13T Pro 5G 1TB', 15990000, 40, 'Xiaomi 13T Pro 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 17, 32, 3);
INSERT INTO `product` VALUES (239, 'Xiaomi 13T Pro 5G 1TB', 15990000, 40, 'Xiaomi 13T Pro 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 17, 32, 3);
INSERT INTO `product` VALUES (240, 'Xiaomi 12 5G 256GB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 15, 33, 3);
INSERT INTO `product` VALUES (241, 'Xiaomi 12 5G 256GB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 11, 15, 33, 3);
INSERT INTO `product` VALUES (242, 'Xiaomi 12 5G 526GB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 33, 3);
INSERT INTO `product` VALUES (243, 'Xiaomi 12 5G 526GB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 11, 16, 33, 3);
INSERT INTO `product` VALUES (244, 'Xiaomi 12 5G 1TB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 17, 33, 3);
INSERT INTO `product` VALUES (245, 'Xiaomi 12 5G 1TB', 13990000, 40, 'Điện thoại Xiaomi đang dần khẳng định chỗ đứng của mình trong phân khúc flagship bằng việc ra mắt Xiaomi 12 với bộ thông số ấn tượng, máy có một thiết kế gọn gàng, hiệu năng mạnh mẽ, màn hình hiển thị chi tiết cùng khả năng chụp ảnh sắc nét nhờ trang bị ống kính đến từ Sony.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 11, 17, 33, 3);
INSERT INTO `product` VALUES (246, 'Xiaomi Note 12 Pro 256GB', 11900000, 40, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 34, 3);
INSERT INTO `product` VALUES (247, 'Xiaomi Note 12 Pro 256GB', 11900000, 40, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 15, 34, 3);
INSERT INTO `product` VALUES (248, 'Xiaomi Note 12 Pro 526GB', 11900000, 40, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 34, 3);
INSERT INTO `product` VALUES (249, 'Xiaomi Note 12 Pro 526GB', 11900000, 40, 'Xiaomi 13T 5G là mẫu máy thuộc phân khúc tầm trung đáng chú ý tại thị trường Việt Nam. Điện thoại ấn tượng nhờ được trang bị chip Dimensity 9200+, camera 50 MP có kèm sự hợp tác với Leica cùng kiểu thiết kế tinh tế đầy sang trọng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 34, 3);
INSERT INTO `product` VALUES (250, 'Xiaomi Note 12 Pro 5G 526GB', 11900000, 40, 'Xiaomi Redmi Note 12 Pro 5G mẫu điện thoại tầm trung được kỳ vọng sẽ trở thành sản phẩm quốc dân trong năm 2023, nhờ sở hữu khá nhiều sự nâng cấp với camera 50 MP, chip MediaTek mạnh mẽ cùng ngôn ngữ thiết kế mới vô cùng tối giản, hiện đại', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 35, 3);
INSERT INTO `product` VALUES (251, 'Xiaomi Note 12 Pro 5G 526GB', 11900000, 40, 'Xiaomi Redmi Note 12 Pro 5G mẫu điện thoại tầm trung được kỳ vọng sẽ trở thành sản phẩm quốc dân trong năm 2023, nhờ sở hữu khá nhiều sự nâng cấp với camera 50 MP, chip MediaTek mạnh mẽ cùng ngôn ngữ thiết kế mới vô cùng tối giản, hiện đại', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 35, 3);
INSERT INTO `product` VALUES (252, 'Xiaomi Note 12 Pro 5G 1TB', 11900000, 40, 'Xiaomi Redmi Note 12 Pro 5G mẫu điện thoại tầm trung được kỳ vọng sẽ trở thành sản phẩm quốc dân trong năm 2023, nhờ sở hữu khá nhiều sự nâng cấp với camera 50 MP, chip MediaTek mạnh mẽ cùng ngôn ngữ thiết kế mới vô cùng tối giản, hiện đại', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 13, 35, 3);
INSERT INTO `product` VALUES (253, 'Xiaomi Note 12 Pro 5G 1TB', 11900000, 40, 'Xiaomi Redmi Note 12 Pro 5G mẫu điện thoại tầm trung được kỳ vọng sẽ trở thành sản phẩm quốc dân trong năm 2023, nhờ sở hữu khá nhiều sự nâng cấp với camera 50 MP, chip MediaTek mạnh mẽ cùng ngôn ngữ thiết kế mới vô cùng tối giản, hiện đại', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 18, 35, 3);
INSERT INTO `product` VALUES (254, 'Realme 11 5G 256GB', 12999000, 100, 'Realme 11 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 15, 36, 4);
INSERT INTO `product` VALUES (255, 'Realme 11 5G 256GB', 12999000, 100, 'Realme 11 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 4, 15, 36, 4);
INSERT INTO `product` VALUES (256, 'Realme 11 5G 526GB', 12999000, 100, 'Realme 11 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 16, 36, 4);
INSERT INTO `product` VALUES (257, 'Realme 11 5G 526GB', 12999000, 100, 'Realme 11 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 4, 16, 36, 4);
INSERT INTO `product` VALUES (258, 'Realme 11 Pro 5G 256GB', 12999000, 100, 'Realme 11 Pro 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 15, 37, 4);
INSERT INTO `product` VALUES (259, 'Realme 11 Pro 5G 256GB', 12999000, 100, 'Realme 11 Pro 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 15, 37, 4);
INSERT INTO `product` VALUES (260, 'Realme 11 Pro 5G 526GB', 12999000, 100, 'Realme 11 Pro 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 13, 16, 37, 4);
INSERT INTO `product` VALUES (261, 'Realme 11 Pro 5G 526GB', 12999000, 100, 'Realme 11 Pro 5G với một vẻ ngoài đẹp mắt, chất lượng ảnh chụp sắc nét cũng như một hiệu năng đầy mạnh mẽ.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 2, 16, 37, 4);
INSERT INTO `product` VALUES (262, 'Realme C55 128GB', 7999000, 100, 'Điện thoại dành được khá nhiều sự quan tâm của đông đảo người dùng khi mở bán với mức giá hấp dẫn, trang bị cấu hình tốt, camera AI 64 MP, màn hình lớn cùng khả năng sạc pin siêu nhanh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 14, 38, 4);
INSERT INTO `product` VALUES (263, 'Realme C55 128GB', 7999000, 100, 'Điện thoại dành được khá nhiều sự quan tâm của đông đảo người dùng khi mở bán với mức giá hấp dẫn, trang bị cấu hình tốt, camera AI 64 MP, màn hình lớn cùng khả năng sạc pin siêu nhanh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 14, 38, 4);
INSERT INTO `product` VALUES (264, 'Realme C55 256GB', 7999000, 100, 'Điện thoại dành được khá nhiều sự quan tâm của đông đảo người dùng khi mở bán với mức giá hấp dẫn, trang bị cấu hình tốt, camera AI 64 MP, màn hình lớn cùng khả năng sạc pin siêu nhanh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 3, 15, 38, 4);
INSERT INTO `product` VALUES (265, 'Realme C55 256GB', 7999000, 100, 'Điện thoại dành được khá nhiều sự quan tâm của đông đảo người dùng khi mở bán với mức giá hấp dẫn, trang bị cấu hình tốt, camera AI 64 MP, màn hình lớn cùng khả năng sạc pin siêu nhanh.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 38, 4);
INSERT INTO `product` VALUES (266, 'Realme C51 64GB', 3999000, 100, 'Được đánh giá với hiệu năng ổn định, màn hình sắc nét cùng viên pin dung lượng lớn, sản phẩm này phù hợp cho những người dùng có đang có nhu cầu tìm mua một chiếc máy giá rẻ có thể đáp ứng tốt nhiều tác vụ trong thời gian dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 13, 39, 4);
INSERT INTO `product` VALUES (267, 'Realme C51 64GB', 3999000, 100, 'Được đánh giá với hiệu năng ổn định, màn hình sắc nét cùng viên pin dung lượng lớn, sản phẩm này phù hợp cho những người dùng có đang có nhu cầu tìm mua một chiếc máy giá rẻ có thể đáp ứng tốt nhiều tác vụ trong thời gian dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 13, 39, 4);
INSERT INTO `product` VALUES (268, 'Realme C51 128GB', 4999000, 100, 'Được đánh giá với hiệu năng ổn định, màn hình sắc nét cùng viên pin dung lượng lớn, sản phẩm này phù hợp cho những người dùng có đang có nhu cầu tìm mua một chiếc máy giá rẻ có thể đáp ứng tốt nhiều tác vụ trong thời gian dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 14, 39, 4);
INSERT INTO `product` VALUES (269, 'Realme C51 128GB', 4999000, 100, 'Được đánh giá với hiệu năng ổn định, màn hình sắc nét cùng viên pin dung lượng lớn, sản phẩm này phù hợp cho những người dùng có đang có nhu cầu tìm mua một chiếc máy giá rẻ có thể đáp ứng tốt nhiều tác vụ trong thời gian dài.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 14, 39, 4);
INSERT INTO `product` VALUES (270, 'Vivo V29e 5G 256GB', 9000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 40, 6);
INSERT INTO `product` VALUES (271, 'Vivo V29e 5G 256GB', 9000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 15, 40, 6);
INSERT INTO `product` VALUES (272, 'Vivo V29e 5G 526GB', 9000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 40, 6);
INSERT INTO `product` VALUES (273, 'Vivo V29e 5G 526GB', 9000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 40, 6);
INSERT INTO `product` VALUES (274, 'Vivo V27e 5G 256GB', 7000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 15, 41, 6);
INSERT INTO `product` VALUES (275, 'Vivo V27e 5G 256GB', 7000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 15, 41, 6);
INSERT INTO `product` VALUES (276, 'Vivo V27e 5G 526GB', 7000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 41, 6);
INSERT INTO `product` VALUES (277, 'Vivo V27e 5G 526GB', 7000000, 100, 'Máy có một thiết kế tối ưu đem đến trải nghiệm thoải mái, màn hình hiển thị sắc nét cùng với khả năng chụp ảnh đỉnh cao.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 10, 16, 41, 6);
INSERT INTO `product` VALUES (278, 'Vivo V25 Pro 5G 526GB', 10000000, 100, 'Vivo V25 Pro 5G vừa được ra mắt với một mức giá bán cực kỳ hấp dẫn, thế mạnh của máy thuộc về phần hiệu năng nhờ trang bị con chip MediaTek Dimensity 1300 và cụm camera sắc nét 64 MP, hứa hẹn mang lại cho người dùng những trải nghiệm ổn định trong suốt quá trình sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 16, 42, 6);
INSERT INTO `product` VALUES (279, 'Vivo V25 Pro 5G 526GB', 10000000, 100, 'Vivo V25 Pro 5G vừa được ra mắt với một mức giá bán cực kỳ hấp dẫn, thế mạnh của máy thuộc về phần hiệu năng nhờ trang bị con chip MediaTek Dimensity 1300 và cụm camera sắc nét 64 MP, hứa hẹn mang lại cho người dùng những trải nghiệm ổn định trong suốt quá trình sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 16, 42, 6);
INSERT INTO `product` VALUES (280, 'Vivo V25 Pro 5G 1TB', 11000000, 100, 'Vivo V25 Pro 5G vừa được ra mắt với một mức giá bán cực kỳ hấp dẫn, thế mạnh của máy thuộc về phần hiệu năng nhờ trang bị con chip MediaTek Dimensity 1300 và cụm camera sắc nét 64 MP, hứa hẹn mang lại cho người dùng những trải nghiệm ổn định trong suốt quá trình sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 1, 17, 42, 6);
INSERT INTO `product` VALUES (281, 'Vivo V25 Pro 5G 1TB', 11000000, 100, 'Vivo V25 Pro 5G vừa được ra mắt với một mức giá bán cực kỳ hấp dẫn, thế mạnh của máy thuộc về phần hiệu năng nhờ trang bị con chip MediaTek Dimensity 1300 và cụm camera sắc nét 64 MP, hứa hẹn mang lại cho người dùng những trải nghiệm ổn định trong suốt quá trình sử dụng.', b'1', '2023-12-20 00:54:12', '2023-12-20 00:54:12', 0, 8, 17, 42, 6);

INSERT INTO discount (name,percent,active, expiration_date,product_id) VALUES
("MAGIAMGIA1",10,true,"2024-10-20 01:44:34",1),
("MAGIAMGIA2",10,true,"2024-10-20 01:44:34",2);
INSERT INTO preview (rate,content,user_id,product_id) VALUES
(5.0,"Sản phẩm rất tốt",1,1),
(4.5,"Phục vụ tốt",1,2),
(3.2,"Sản phẩm rất tốt",2,2),
(2.5,"Phục vụ tốt",2,1);
INSERT INTO rep_preview (content,admin_id,preview_id) VALUES
("Cảm ơn quý khách",3,1),
("Cảm ơn quý khách",3,3);

INSERT INTO `image` (image_url, product_id) VALUES
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114115/s16/iphone-x-64-gb-tb-1-2-650x650.png', 1),-- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',2),-- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',3),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114115/s16/iphone-x-64-gb-tb-1-2-650x650.png', 4),-- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',5),-- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',6),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114115/s16/iphone-x-64-gb-tb-1-2-650x650.png', 7),-- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',8),-- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/114111/s16/iphone-x-256-gb-650x650.png',9),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',10),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',11), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',12), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',13),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',14), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',15), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',16),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',17), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',18), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',19),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',20), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',21), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',22),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',23), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',24), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190323/s16/iphone-xs-vang-64-gb-1-650x650.png',25),-- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190322/s16/iphone-xs-max-256gb-160523-031654-650x650.png',26), -- 4
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190321/s16/iPhone-XS-Max-black-thumb-650x650.png',27), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-red.png',28), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-do-1-1200x1200.jpg',28), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-yellow.png',29), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-vang-1-1200x1200.jpg',29), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-blue.png',30), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-xanh-duong-1-1200x1200.jpg',30), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-white.png',31), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-trang-1-1200x1200.jpg',31), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-black.png',32), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-black.png',32), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-orange.png',33), -- 14
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-cam-1-1200x1200.jpg',33), -- 14
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-black.png',34), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-black.png',34), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-blue.png',35), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-xanh-duong-1-1200x1200.jpg',35), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-yellow.png',36), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/190325/s16/iphone-xr-vang-1-1200x1200.jpg',36), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-black-thumbtz-650x650.png',37), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-1-650x650.jpg',37), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-2-650x650.jpg',37), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',38), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',38), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',38), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',39), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',39), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',39), -- 13 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-purple-thumbtz-650x650.png',40), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-1-650x650.jpg',40), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-2-650x650.jpg',40), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',41), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',41), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',41), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',42), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',42), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',42), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-black-thumbtz-650x650.png',43), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-1-650x650.jpg',43), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-2-650x650.jpg',43), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',44), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',44), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',44), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',45), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',45), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',45), -- 13 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-purple-thumbtz-650x650.png',46), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-1-650x650.jpg',46), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-2-650x650.jpg',46), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',47), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',47), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',47), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',48), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',48), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',48), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',49), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',49), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',49), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',50), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',50), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',50), -- 13 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-purple-thumbtz-650x650.png',51), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-1-650x650.jpg',51), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-2-650x650.jpg',51), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',52), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',52), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',52), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',53), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',53), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',53), -- 13 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-purple-thumbtz-650x650.png',54), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-1-650x650.jpg',54), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-2-650x650.jpg',54), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',55), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',55), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',55), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',56), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',56), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',56), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-black-thumbtz-650x650.png',57), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-1-650x650.jpg',57), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-2-650x650.jpg',57), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',58), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',58), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',58), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',59), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',59), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',59), -- 13 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-purple-thumbtz-650x650.png',60), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-1-650x650.jpg',60), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/210644/s16/iphone-11-128gb-tim-2-650x650.jpg',60), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-white-thumbtz-650x650.png',61), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-1-650x650.jpg',61), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-trang-2-650x650.jpg',61), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-green-1-650x650.png',62), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-1-650x650.jpg',62), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-xanh-la-2-650x650.jpg',62), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-black-thumbtz-650x650.png',63), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-1-650x650.jpg',63), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/153856/s16/iphone-11-den-2-650x650.jpg',63), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',64), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',64), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',64), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',65), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',65), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',65), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',66), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',66), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',66), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-thumbtz-650x650.png',67), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-1-650x650.jpg',67), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-2-650x650.jpg',67), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-thumbtz-650x650.png',68), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-1-650x650.jpg',68), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-2-650x650.jpg',68), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-black-thumbtz-650x650.png',69), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-black-2-650x650.jpeg',69), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-den-1-1-650x650.jpeg',69), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',70), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',70), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',70), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',71), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',71), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',71), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',72), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',72), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',72), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-black-thumbtz-650x650.png',73), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-black-2-650x650.jpeg',73), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-den-1-1-650x650.jpeg',73), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-thumbtz-650x650.png',74), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-1-650x650.jpg',74), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-2-650x650.jpg',74), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-thumbtz-650x650.png',75), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-1-650x650.jpg',75), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-2-650x650.jpg',75), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',76), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',76), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',76), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',77), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',77), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',77), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',78), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',78), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',78), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-thumbtz-650x650.png',79), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-1-650x650.jpg',79), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-2-650x650.jpg',79), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-thumbtz-650x650.png',80), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-1-650x650.jpg',80), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-2-650x650.jpg',80), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',81), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',81), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',81), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',82), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',82), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',82), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',83), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',83), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',83), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',84), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',84), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',84), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',85), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',85), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',85), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',86), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',86), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',86), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',87), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',87), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',87), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-thumbtz-650x650.png',88), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-1-650x650.jpg',88), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-blue-2-650x650.jpg',88), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-thumbtz-650x650.png',89), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-1-650x650.jpg',89), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-white-2-650x650.jpg',89), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',90), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',90), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',90), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-thumbtz-650x650.png',91), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-1-650x650.jpg',91), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-purple-2-650x650.jpg',91), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-thumbtz-650x650.png',92), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-1-650x650.jpg',92), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-red-2-650x650.jpg',92), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-thumbtz-650x650.png',93), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-1-650x650.jpg',93), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/213031/s16/iphone-12-green-2-650x650.jpg',93), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-pink-thumbtz-650x650.png',94), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-1-650x650.jpg',94), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-2-650x650.jpg',94), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-black-thumbtz-650x650.png',95), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-1-650x650.jpg',95), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-2-650x650.jpg',95), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',96), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',96), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',96), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-thumbtz-650x650.png',97), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-2-650x650.jpeg',97), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-3-650x650.jpeg',97), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-blue-thumbtz-650x650.png',98), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-1-650x650.jpg',98), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-2-650x650.jpg',98), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',99), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',99), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',99), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-pink-thumbtz-650x650.png',100), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-1-650x650.jpg',100), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-2-650x650.jpg',100), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-black-thumbtz-650x650.png',101), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-1-650x650.jpg',101), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-2-650x650.jpg',101), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',102), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',102), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',102), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-thumbtz-650x650.png',103), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-2-650x650.jpeg',103), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-3-650x650.jpeg',103), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-blue-thumbtz-650x650.png',104), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-1-650x650.jpg',104), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-2-650x650.jpg',104), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',105), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',105), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',105), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-pink-thumbtz-650x650.png',106), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-1-650x650.jpg',106), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-2-650x650.jpg',106), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-black-thumbtz-650x650.png',107), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-1-650x650.jpg',107), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-2-650x650.jpg',107), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',108), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',108), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',108), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-thumbtz-650x650.png',109), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-2-650x650.jpeg',109), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-3-650x650.jpeg',109), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-blue-thumbtz-650x650.png',110), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-1-650x650.jpg',110), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-2-650x650.jpg',110), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',111), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',111), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',111), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-pink-thumbtz-650x650.png',112), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-1-650x650.jpg',112), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-hong-2-650x650.jpg',112), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-black-thumbtz-650x650.png',113), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-1-650x650.jpg',113), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-2-650x650.jpg',113), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',114), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',114), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',114), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-thumbtz-650x650.png',115), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-2-650x650.jpeg',115), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-3-650x650.jpeg',115), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-blue-thumbtz-650x650.png',116), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-1-650x650.jpg',116), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-xanh-duong-2-650x650.jpg',116), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',117), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',117), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',117), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-black-thumbtz-650x650.png',118), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-1-650x650.jpg',118), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-den-2-650x650.jpg',118), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-white-thumbtz-650x650.png',119), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-1-650x650.jpg',119), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-trang-2-650x650.jpg',119), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-thumbtz-650x650.png',120), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-2-650x650.jpeg',120), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/223602/s16/iphone-13-green-3-650x650.jpeg',120), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-purple-thumbtz-650x650.png',121), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1_purple_color-1-650x650.jpg',121), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-4-650x650.jpg',121), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-blue-thumbtz-650x650.png',122), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1b_blue_color-1-650x650.jpg',122), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-2-650x650.jpg',122), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-red-thumbtz-650x650.png',123), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1b_productred_color-1-650x650.jpg',123),-- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-3-650x650.jpg',123), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-black-thumbtz-650x650.png',124), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1a_midnight_color-1-650x650.jpg',124), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-650x650.jpg',124), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-white-thumbtz-650x650.png',125), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1_starlight_color-1-650x650.jpg',125), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-1-650x650.jpg',125), -- 2 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289663/s16/iphone-14-gold-thumbtz-650x650.png',126), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289663/s16/iphone-14-gold-glr-1-650x650.jpeg',126), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289663/s16/iphone-14-gold-glr-2-650x650.jpeg',126), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-blue-thumbtz-650x650.png',127), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1b_blue_color-1-650x650.jpg',127), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-2-650x650.jpg',127), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-red-thumbtz-650x650.png',128), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1b_productred_color-1-650x650.jpg',128),-- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-3-650x650.jpg',128), -- 12
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone-14-black-thumbtz-650x650.png',129), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-1a_midnight_color-1-650x650.jpg',129), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/240259/s16/iphone_14_pdp_position-2_design-2-650x650.jpg',129), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone-14-pro-purple-thumbtz-650x650.png',130), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-1b_deep_purple_color-1-650x650.jpg',130), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-2_design-2-3-650x650.jpg',130), -- 10
('',131),
('',132),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone-14-pro-purple-thumbtz-650x650.png',133), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-1b_deep_purple_color-1-650x650.jpg',133), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-2_design-2-3-650x650.jpg',133), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone-14-pro-gold-thumbtz-650x650.png',134), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-1a_gold_color-1-650x650.jpg',134), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-2_design-2-2-650x650.jpg',134), -- 3
('',135),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone-14-pro-purple-thumbtz-650x650.png',136), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-1b_deep_purple_color-1-650x650.jpg',136), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289691/s16/iphone_14_pro_pdp_position-2_design-2-3-650x650.jpg',136), -- 10
('',137),
('',138),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-purple-thumbtz-650x650.png',139), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-1_deep_purple_color-1-650x650.jpg',139), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-3-650x650.jpg',139), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-black-thumbtz-650x650.png',140), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-1_space_black_color-1-650x650.jpg',140), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-650x650.jpg',140), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-gold-thumbtz-650x650.png',141), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/phone_14_pro_max_pdp_position-1_gold_color-1-650x650.jpg',141), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-2-650x650.jpg',141), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-purple-thumbtz-650x650.png',142), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-1_deep_purple_color-1-650x650.jpg',142), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-3-650x650.jpg',142), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-black-thumbtz-650x650.png',143), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-1_space_black_color-1-650x650.jpg',143), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-650x650.jpg',143), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-gold-thumbtz-650x650.png',144), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/phone_14_pro_max_pdp_position-1_gold_color-1-650x650.jpg',144), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-2-650x650.jpg',144), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-purple-thumbtz-650x650.png',145), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-1_deep_purple_color-1-650x650.jpg',145), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-3-650x650.jpg',145), -- 10
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone-14-pro-max-gold-thumbtz-650x650.png',146), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/phone_14_pro_max_pdp_position-1_gold_color-1-650x650.jpg',146), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/289700/s16/iphone_14_pro_max_pdp_position-2_design-2-2-650x650.jpg',146), -- 3
('',147),
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-black-thumbtz_0-650x650.png',148), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-black-2-650x650.jpg',148), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-black-3-650x650.jpg',148), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-thumbtz_0-650x650.png',149), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-2-650x650.jpg',149), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-3-650x650.jpg',149), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-thumbtz_0-650x650.png',150), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-2-650x650.jpg',150), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-3-650x650.jpg',150), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-thumbtz_0-650x650.png',151), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-2-650x650.jpg',151), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-3-650x650.jpg',151), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-green-thumbtz_0-650x650.png',152), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-green-1-650x650.jpg',152), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-green-3-650x650.jpg',152), -- 13
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-thumbtz_0-650x650.png',153), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-2-650x650.jpg',153), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-3-650x650.jpg',153), -- 8 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-thumbtz_0-650x650.png',154), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-2-650x650.jpg',154), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-yellow-3-650x650.jpg',154), -- 3
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-thumbtz_0-650x650.png',155), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-2-650x650.jpg',155), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-blue-3-650x650.jpg',155), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-thumbtz_0-650x650.png',156), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-2-650x650.jpg',156), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/281570/s16/iphone-15-pink-3-650x650.jpg',156), -- 11
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-thumbtz-650x650.png',157), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-1-650x650.jpg',157), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-2-650x650.jpg',157), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',158), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',158), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',158), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',159), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',159), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',159), -- 2 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-thumbtz-650x650.png',160), -- 15
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-tu-nhien-1-650x650.jpg',160), -- 15 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-tu-nhien-2-650x650.jpg',160), -- 15
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',161), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',161), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',161), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',162), -- 2 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',162), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',162), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-thumbtz-650x650.png',163), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-1-650x650.jpg',163), -- 8 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-2-650x650.jpg',163), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',164), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',164), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',164), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',165), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',165), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',165), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-thumbtz-650x650.png',166), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-1-650x650.jpg',166), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-2-650x650.jpg',166), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',167), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',167), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',167), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',168), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',168), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',168), -- 2 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-thumbtz-650x650.png',169), -- 15
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-tu-nhien-1-650x650.jpg',169), -- 15 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-tu-nhien-2-650x650.jpg',169), -- 15
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',170), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',170), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',170), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',171), -- 2 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',171), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',171), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-thumbtz-650x650.png',172), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-1-650x650.jpg',172), -- 8 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-2-650x650.jpg',172), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',173), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',173), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',173), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',174), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',174), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',174), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-thumbtz-650x650.png',175), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-1-650x650.jpg',175), -- 8 
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-blue-2-650x650.jpg',175), -- 8
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-thumbtz-1-2-650x650.png',176), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-1-650x650.jpg',176), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-black-2-650x650.jpg',176), -- 1
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-white-thumbtz-650x650.png',177), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-1-650x650.jpg',177), -- 2
('https://img.tgdd.vn/imgt/f_webp,fit_outside,quality_100/https://cdn.tgdd.vn/Products/Images/42/299033/s16/iphone-15-pro-trang-2-650x650.jpg',177), -- 2
-- SamSung
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-hong-1.jpg',178), -- 11
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-hong-5.jpg',178), -- 11
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-hong-6.jpg',178), -- 11
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-trang-glr-1.jpg',179), -- 2
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-trang-glr-5.jpg',179), -- 2
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-trang-glr-6.jpg',179), -- 2
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-den-1.jpg',180), -- 1
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-den-5.jpg',180), -- 1
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-den-6.jpg',180), -- 1
('https://cdn.tgdd.vn/Products/Images/42/231110/Galaxy-S22-Green-600x600.jpg',181), -- 13
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-xanh-la-glr-5.jpg',181), -- 13
('https://cdn.tgdd.vn/Products/Images/42/231110/samsung-galaxy-s22-xanh-la-glr-6.jpg',181), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_front_green_211119_2.jpg',182), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicebackl30_green_211119_1.jpg',182), -- 13
('',182), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_front_phantomwhite_211119_1_1.jpg',183), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicepenbackl30_phantomwhite_211119_1.jpg',183), -- 2
('',183), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s22-ultra-12gb-256gb.png',184), -- 1 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicepenbackl30_phantomblack_211119_1.png',184), -- 1
('',184),-- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_front_burgundy_211119_2.jpg',185), -- 12
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicepenbackr30_burgundy_211119_1.jpg',185), -- 12
('',185), -- 12
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_front_burgundy_211119_2.jpg',186), -- 12
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicepenbackr30_burgundy_211119_1.jpg',186), -- 12
('',186), -- 12
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s22-ultra-12gb-256gb.png',187), -- 1 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/m/sm-s908_galaxys22ultra_devicepenbackl30_phantomblack_211119_1.png',187), -- 1
('',187),-- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_3_.png',188), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_9_.png',188), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb.png',189), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_5_.png',189), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_2_.png',190), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_7_.png',190), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_1_.png',191), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-s23-128gb_11_.png',191), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-xanh.png',192), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-xanh-1.png',192), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-tim.png',193), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-tim-1.png',193), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-kem.png',194), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-kem-1.png',194), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-den.png',195), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-den-2.png',195), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-tim.png',196), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-tim-1.png',196), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-kem.png',197), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-kem-1.png',197), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-xam-1.jpg',198), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-xam-5.jpg',198), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-kem-1.jpg',199),  -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-kem-5.jpg',199), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-fold-5-256gb_1.png',200), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/6/f/6f93ebef-6bb2-4371-a0db-ceb7a3d921c4.jpg',200), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-kem-1.jpg',201),  -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-kem-5.jpg',201), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-xam-1.jpg',202), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-fold-5-xam-5.jpg',202), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-fold-5-256gb_1.png',203), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/6/f/6f93ebef-6bb2-4371-a0db-ceb7a3d921c4.jpg',203), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip5-tim-4_2.jpg',204), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip5-tim-1_2.jpg',204), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip5-kem-4_2.jpg',205), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip5-kem-1_2.jpg',205), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip-xam-4_2.jpg',206), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-z-flip-xam-1_2.jpg',206), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-flip-xanh-2_1_1.jpg',207), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/a/galaxy-z-flip-xanh-1_1_1.jpg',207), -- 13
-- Oppo
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip.png',208), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_2_.png',208), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_4_.png',209), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_7_.png',209), -- 3 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip.png',210), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_2_.png',210), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_4_.png',211), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n3-flip_7_.png',211), -- 3 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n2-flip.png',212), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_find_n2_flip_2_.jpg',212), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/n/2/n2_flip_-_combo_product_-_purple.png',213), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_find_n2_flip.jpg',213), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-find-n2-flip.png',214), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_find_n2_flip_2_.jpg',214), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/n/2/n2_flip_-_combo_product_-_purple.png',215), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_find_n2_flip.jpg',215), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/reno10_5g_-_combo_product_-_blue_-_copy.png',216), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/t/_/t_i_xu_ng_13__1_13.png',216), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/reno10_5g_-_combo_product_-_grey.png',217), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/2/p2d8l4cpsmeihtgu_-_copy.png',217), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/reno10_5g_-_combo_product_-_blue_-_copy.png',218), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/t/_/t_i_xu_ng_13__1_13.png',218), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/reno10_5g_-_combo_product_-_grey.png',219), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/2/p2d8l4cpsmeihtgu_-_copy.png',219), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-reno-8t-4g-256gb.png',220), -- 1
('',220), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/6/3/638106973185744517_oppo-reno8-t-4g-cam-4.jpg',221), -- 14
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8_t_256gb_6_.jpg',221), -- 14
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo-reno-8t-4g-256gb.png',222), -- 1
('',222), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/6/3/638106973185744517_oppo-reno8-t-4g-cam-4.jpg',223), -- 14
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8_t_256gb_6_.jpg',223), -- 14
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/h/photo_2022-08-05_09-40-15.jpg',224), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8z_01.jpg',224), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/h/photo_2022-08-05_09-40-14.jpg',225), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8z.jpg',225), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/h/photo_2022-08-05_09-40-15.jpg',226), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8z_01.jpg',226), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/p/h/photo_2022-08-05_09-40-14.jpg',227), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno8z.jpg',227), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/c/o/combo_product_-_reno8_4g_-_black.png',228), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_panther_a__product_images__starlight_black__1_side1_fa_rgb.jpg',228), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/c/o/combo_product_-_reno8_4g_-_gold.png',229), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno4g.jpg',229), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/c/o/combo_product_-_reno8_4g_-_black.png',230), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_panther_a__product_images__starlight_black__1_side1_fa_rgb.jpg',230), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/c/o/combo_product_-_reno8_4g_-_gold.png',231), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/o/p/oppo_reno4g.jpg',231), -- 3
-- Xiaomi
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-den-01.jpg',232), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-den-03.jpg',232), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-13t_1_2.png',233), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-03.jpg',233), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-la-01.jpg',234), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-la-02.jpg',234), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-13t_1_2.png',235), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-03.jpg',235), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-den-01.jpg',236), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-den-03.jpg',236), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-13t_1_2.png',237), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-03.jpg',237), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-la-01.jpg',238), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-la-02.jpg',238), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-13t_1_2.png',239), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiami-13t-xanh-03.jpg',239), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/t/_/t_i_xu_ng_2__3_1.png',240), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_015_2.jpg',240), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-12-pro_arenamobiles_1.jpg',241), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_009_2.jpg',241), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/t/_/t_i_xu_ng_2__3_1.png',242), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_015_2.jpg',242), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-12-pro_arenamobiles_1.jpg',243), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_009_2.jpg',243), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/t/_/t_i_xu_ng_2__3_1.png',244), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_015_2.jpg',244), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-12-pro_arenamobiles_1.jpg',245), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/g/s/gsmarena_009_2.jpg',245), -- 11
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g.png',246), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g-den-2.jpg',246), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/redmi-note-12-pro-4g-1-xanh-nhat.jpg',247), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-12-pro-4g-2.jpg',247), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g.png',248), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g-den-2.jpg',248), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/redmi-note-12-pro-4g-1-xanh-nhat.jpg',249), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-12-pro-4g-2.jpg',249), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g.png',250), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-4g-den-2.jpg',250), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/redmi-note-12-pro-4g-1-xanh-nhat.jpg',251), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-12-pro-4g-2.jpg',251), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12s_4__1.jpg',252), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12s_5__1.jpg',252), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12s_8_.jpg',253), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12s_13_.jpg',253), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-vang-1.jpg',254), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11_3_.png',254), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-xam-1.jpg',255), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11_3_.png',255), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-vang-1.jpg',256), -- 3 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11_3_.png',256), -- 3  
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-xam-1.jpg',257), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11_3_.png',257), -- 4
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-pro.png',258), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme_11_pro_3.png',258), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-pro_1_.png',259), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme_11_pro_1.png',259), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-pro.png',260), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme_11_pro_3.png',260), -- 13
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-11-pro_1_.png',261), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme_11_pro_1.png',261), -- 2
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/g/rgrgrtyt6.jpg',262), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/7/3/733535867.jpeg',262), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/g/rgrgrtyt6_4_.jpg',263), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/1/8/1891295540.jpeg',263), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/g/rgrgrtyt6.jpg',264), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/7/3/733535867.jpeg',264), -- 3
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/g/rgrgrtyt6_4_.jpg',265), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/1/8/1891295540.jpeg',265), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-den-011.png',266), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-den-2_1.jpg',266), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51_2.png',267), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-xanh-3_1.jpg',267), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-den-011.png',268), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-den-2_1.jpg',268), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51_2.png',269), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/r/e/realme-c51-xanh-3_1.jpg',269), -- 8
-- Vivo
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_12_.png',270), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_14_.png',270), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_3__1_2.png',271), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_4_.png',271), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_12_.png',272), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_14_.png',272), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_3__1_2.png',273), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v29e_4_.png',273), -- 8
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27e-ra-mat-2.jpg',274), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27-023.jpeg',274), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27e.png',275), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27-022.jpeg',275), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27e-ra-mat-2.jpg',276), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27-023.jpeg',276), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27e.png',277), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v27-022.jpeg',277), -- 10
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro.png',278), -- 1 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-5g-3.jpg',278), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-5g-2.jpg',278), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/e/0/e061bd2ab13b5e2263236cb206248daa.png',279), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-xanh-glr-3.jpg',279), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-xanh-glr-3.jpg',279), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro.png',280), -- 1 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-5g-3.jpg',280), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-5g-2.jpg',280), -- 1
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/e/0/e061bd2ab13b5e2263236cb206248daa.png',281), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-xanh-glr-3.jpg',281), -- 8 
('https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:80/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-v25-pro-xanh-glr-3.jpg',281); -- 8 
-- Inserting sample data into the "orders" table
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000.0, 4,'2023-01-2' ,3);
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000.0, 4,'2023-01-14' ,2);
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000.0, 4,'2023-01-22' ,11);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-02-11' ,17);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-02-15' ,20);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-02-24' ,15);
INSERT INTO orders (total, state, create_date, user_id) VALUES (59000000, 3,'2023-03-14' ,4);
INSERT INTO orders (total, state, create_date, user_id) VALUES (49000000, 1,'2023-03-25' ,8);
INSERT INTO orders (total, state, create_date, user_id) VALUES (49000000, 1,'2023-03-26' ,11);
INSERT INTO orders (total, state, create_date, user_id) VALUES (89000000, 2,'2023-04-15' ,7);
INSERT INTO orders (total, state, create_date, user_id) VALUES (89000000, 2,'2023-04-18' ,10);
INSERT INTO orders (total, state, create_date, user_id) VALUES (89000000, 2,'2023-04-20' ,12);
INSERT INTO orders (total, state, create_date, user_id) VALUES (99000000, 4,'2023-05-03' ,19);
INSERT INTO orders (total, state, create_date, user_id) VALUES (99000000, 4,'2023-05-09' ,3);
INSERT INTO orders (total, state, create_date, user_id) VALUES (99000000, 4,'2023-05-24' ,13);
INSERT INTO orders (total, state, create_date, user_id) VALUES (109000000, 1,'2023-06-14' ,14);
INSERT INTO orders (total, state, create_date, user_id) VALUES (109000000, 1,'2023-06-17' ,18);
INSERT INTO orders (total, state, create_date, user_id) VALUES (109000000, 1,'2023-06-25' ,20);
INSERT INTO orders (total, state, create_date, user_id) VALUES (49000000, 2,'2023-07-07' ,6);
INSERT INTO orders (total, state, create_date, user_id) VALUES (49000000, 2,'2023-07-08' ,2);
INSERT INTO orders (total, state, create_date, user_id) VALUES (49000000, 2,'2023-07-28' ,5);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-08-12' ,7);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-08-17' ,11);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-08-28' ,3);
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000, 1,'2023-09-07' ,2);
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000, 1,'2023-09-17' ,5);
INSERT INTO orders (total, state, create_date, user_id) VALUES (79000000, 1,'2023-09-25' ,17);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-10-04' ,19);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-10-12' ,8);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 2,'2023-10-30' ,13);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-11-17' ,4);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-11-22' ,9);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 3,'2023-11-26' ,10);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 4,'2023-12-03' ,19);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 4,'2023-12-12' ,13);
INSERT INTO orders (total, state, create_date, user_id) VALUES (69000000, 4,'2023-12-28' ,10);

-- Inserting sample data into the "order_detail" table
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 11990000.0,'2023-01-22', 1, 3);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 19990000.0,'2023-01-22', 1, 9);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 15990000.0,'2023-01-14', 2, 4);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 33990000.0,'2023-01-22', 3, 15);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 39590000.0,'2023-01-22', 3, 23);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 19900000.0,'2023-02-11 00:00:00', 4, 36);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 10090000.0,'2023-02-15 00:00:00', 5, 38);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 10090000.0,'2023-02-24 00:00:00', 6, 40);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 41990000.0,'2023-03-14 00:00:00', 7, 22);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 23990000.0,'2023-03-14 00:00:00', 7, 12);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (3, 25990000.0,'2023-03-25 00:00:00', 8, 33);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 11900000.0,'2023-03-26 00:00:00', 9, 47);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 25990000.0,'2023-04-15 00:00:00', 10, 28);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 22990000.0,'2023-04-18 00:00:00', 11, 16);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 15990000.0,'2023-04-18 00:00:00', 11, 42);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 11900000.0,'2023-04-20 00:00:00', 12, 47);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 30990000.0,'2023-05-03 00:00:00', 13, 18);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 44990000.0,'2023-05-09 00:00:00', 14, 25);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 38990000.0,'2023-05-09 00:00:00', 14, 21);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 12900000.0,'2023-05-24 00:00:00', 15, 39);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (2, 10490000.0,'2023-06-14 00:00:00', 16, 37);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 28090000.0,'2023-06-17 00:00:00', 17, 24);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 27990000.0,'2023-06-25 00:00:00', 18, 17);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 19990000.0,'2023-07-07 00:00:00', 19, 9);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 35990000.0,'2023-07-08 00:00:00', 20, 20);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 10090000.0,'2023-07-28 00:00:00', 21, 40);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 24990000.0,'2023-07-28 00:00:00', 21, 10);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 10090000.0,'2023-08-12 00:00:00', 22, 41);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 13990000.0,'2023-08-17 00:00:00', 23, 45);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 28090000.0,'2023-08-28 00:00:00', 24, 24);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 24990000.0,'2023-09-07 00:00:00', 25, 7);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 44990000.0,'2023-09-07 00:00:00', 25, 25);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 10090000.0,'2023-09-07 00:00:00', 25, 40);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 23990000.0,'2023-09-17 00:00:00', 26, 12);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 30990000.0,'2023-09-25 00:00:00', 27, 18);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 19900000.0,'2023-10-04 00:00:00', 28, 36);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 13990000.0,'2023-10-12 00:00:00', 29, 45);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 27990000.0,'2023-10-30 00:00:00', 30, 17);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 39590000.0,'2023-10-30 00:00:00', 30, 23);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 39590000.0,'2023-11-17 00:00:00', 31, 23);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 16550000.0,'2023-11-22 00:00:00', 32, 29);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 17190000.0,'2023-11-26 00:00:00', 33, 30);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 21990000.0,'2023-11-26 00:00:00', 33, 6);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 22990000.0,'2023-12-03 00:00:00', 34, 35);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 17990000.0,'2023-12-12 00:00:00', 35, 5);
INSERT INTO order_detail (quantity, price, create_date, order_id, product_id) VALUES (1, 11900000.0,'2023-12-28 00:00:00', 36, 49);

UPDATE orders AS o
JOIN (
    SELECT order_id, SUM(price) AS total_price
    FROM order_detail
    GROUP BY order_id
) AS od ON o.id = od.order_id
SET o.total = od.total_price;