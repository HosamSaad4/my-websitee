-- =========================================================
-- قاعدة بيانات نظام إدارة صيدلية السعادة - النصيرات
-- Pharmacy Management System - Al-Sa'ada Pharmacy - Al-Nuseirat
-- =========================================================

CREATE DATABASE IF NOT EXISTS pharmacy_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pharmacy_db;

-- ---------------------------------------------------------
-- جدول المستخدمين (موظفي الصيدلية)
-- ---------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'cashier') NOT NULL DEFAULT 'cashier',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- مستخدم افتراضي: admin / admin123 (مدير كامل الصلاحيات)
INSERT INTO users (username, password, full_name, role) VALUES
('admin', '$2y$10$XhZvDhOQtQcEKgFBr9HdkuENRnj6RL9FKcvwt7paVzXVY8ABNMUAu', 'مدير الصيدلية', 'admin');

-- ---------------------------------------------------------
-- جدول الأدوية (المخزون)
-- ---------------------------------------------------------
CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL DEFAULT 'أخرى',
    unit VARCHAR(50) NOT NULL DEFAULT 'حبة',
    quantity INT NOT NULL DEFAULT 0,
    purchase_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    selling_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    expiry_date DATE DEFAULT NULL,
    barcode VARCHAR(50) DEFAULT NULL,
    min_quantity INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_barcode (barcode)
) ENGINE=InnoDB;

-- بيانات تجريبية للأدوية
INSERT INTO medicines (name, category, unit, quantity, purchase_price, selling_price, expiry_date, barcode, min_quantity) VALUES
('باراسيتامول 500 مجم', 'مسكنات', 'علبة', 120, 2.50, 4.00, '2027-06-30', '6221000001', 20),
('أموكسيسيلين 500 مجم', 'مضادات حيوية', 'علبة', 45, 6.00, 9.50, '2026-12-15', '6221000002', 15),
('فيتامين سي 1000 مجم', 'فيتامينات', 'علبة', 80, 8.00, 12.00, '2027-03-20', '6221000003', 20),
('إيبوبروفين 400 مجم', 'مسكنات', 'علبة', 8, 3.00, 5.00, '2026-09-10', '6221000004', 15),
('أوميبرازول 20 مجم', 'مضادات الحموضة', 'علبة', 30, 5.50, 8.50, '2027-01-05', '6221000005', 10),
('شراب سعال للأطفال', 'أدوية الأطفال', 'زجاجة', 25, 7.00, 11.00, '2026-08-01', '6221000006', 10);

-- ---------------------------------------------------------
-- جدول فواتير المبيعات
-- ---------------------------------------------------------
CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    customer_name VARCHAR(100) DEFAULT 'عميل نقدي',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- جدول تفاصيل عناصر كل فاتورة
-- ---------------------------------------------------------
CREATE TABLE sale_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    medicine_id INT NOT NULL,
    medicine_name VARCHAR(150) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- جدول كشكول النواقص (قائمة الأصناف التي تحتاج إعادة طلب)
-- مستوحى من ميزة "كشكول النواقص" في نظام فارماكير (راجع الفصل الثاني، البند 2.1.4)
-- ---------------------------------------------------------
CREATE TABLE shortage_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    quantity_to_order INT NOT NULL DEFAULT 0,
    status ENUM('pending', 'ordered', 'received') NOT NULL DEFAULT 'pending',
    note VARCHAR(255) DEFAULT NULL,
    created_by INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- جدول إعدادات النظام (تخزين مرن بصيغة مفتاح/قيمة)
-- يُستخدم لإعدادات تنبيهات البريد الإلكتروني التلقائية للمخزون المنخفض
-- ---------------------------------------------------------
CREATE TABLE settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT
) ENGINE=InnoDB;

INSERT INTO settings (setting_key, setting_value) VALUES
('alerts_enabled', '1'),
('alert_recipient_email', 'mutazyaser1@gmail.com'),
('smtp_host', 'smtp.gmail.com'),
('smtp_port', '587'),
('smtp_username', 'mqrinawi1990@gmail.com'),
('smtp_password', ''),
('smtp_from_email', 'mqrinawi1990@gmail.com'),
('smtp_from_name', 'نظام إدارة صيدلية السعادة'),
('last_alert_sent_date', ''),
('last_alert_error', '');
