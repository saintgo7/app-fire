-- Fire Safety Inspector MariaDB Schema
-- 소방시설 점검 관리 시스템 데이터베이스 스키마

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS fire_safety_inspector
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE fire_safety_inspector;

-- 사용자 테이블
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255),
    display_name VARCHAR(255),
    photo_url TEXT,
    phone_number VARCHAR(50),
    login_provider ENUM('google', 'kakao', 'naver', 'email') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_uid (uid),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 건물 정보 테이블
CREATE TABLE buildings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    building_type VARCHAR(100),
    total_floors INT,
    total_area DECIMAL(10, 2),
    owner_name VARCHAR(255),
    owner_contact VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_location (latitude, longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 점검 테이블
CREATE TABLE inspections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    building_id INT NOT NULL,
    inspection_date DATE NOT NULL,
    inspector_name VARCHAR(255) NOT NULL,
    inspection_type VARCHAR(100),
    status ENUM('in_progress', 'completed', 'submitted') DEFAULT 'in_progress',
    overall_result ENUM('pass', 'fail', 'conditional_pass'),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_building (building_id),
    INDEX idx_date (inspection_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 체크리스트 항목 테이블
CREATE TABLE checklist_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspection_id INT NOT NULL,
    category VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('normal', 'defective', 'not_applicable'),
    memo TEXT,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_inspection (inspection_id),
    INDEX idx_category (category),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 점검 사진 테이블
CREATE TABLE inspection_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    checklist_item_id INT NOT NULL,
    photo_url TEXT NOT NULL,
    thumbnail_url TEXT,
    caption TEXT,
    file_size INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (checklist_item_id) REFERENCES checklist_items(id) ON DELETE CASCADE,
    INDEX idx_checklist_item (checklist_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 점검 일정 테이블
CREATE TABLE schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    building_id INT NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
    reminder_enabled BOOLEAN DEFAULT TRUE,
    reminder_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_building (building_id),
    INDEX idx_date (scheduled_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 법령 정보 테이블
CREATE TABLE legal_regulations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    content TEXT NOT NULL,
    law_reference VARCHAR(255),
    effective_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 보고서 테이블
CREATE TABLE reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inspection_id INT NOT NULL,
    report_type VARCHAR(100) DEFAULT 'pdf',
    file_url TEXT,
    file_size INT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_inspection (inspection_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 알림 테이블
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    related_id INT,
    related_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 기본 체크리스트 템플릿 데이터 삽입
INSERT INTO legal_regulations (title, category, content, law_reference) VALUES
('소화기 설치 기준', '소화기', '소화기는 각 층마다 보행거리 20m 이내마다 설치해야 합니다.', '화재예방, 소방시설 설치·유지 및 안전관리에 관한 법률 시행령 제15조'),
('옥내소화전 설치 기준', '소화전', '옥내소화전은 각 층마다 설치하되, 해당 층의 각 부분으로부터 하나의 옥내소화전 호스접결구까지의 수평거리가 25m 이하가 되도록 설치해야 합니다.', '화재예방, 소방시설 설치·유지 및 안전관리에 관한 법률 시행령 제16조'),
('자동화재탐지설비 설치 기준', '화재탐지', '자동화재탐지설비는 감지기, 발신기, 수신기 및 음향장치로 구성되며, 특정소방대상물의 모든 층에 설치해야 합니다.', '화재예방, 소방시설 설치·유지 및 안전관리에 관한 법률 시행령 제22조'),
('스프링클러설비 설치 기준', '스프링클러', '스프링클러설비는 모든 층에 설치하되, 스프링클러헤드는 천장 또는 반자의 각 부분으로부터 수평거리 2.3m 이하가 되도록 설치해야 합니다.', '화재예방, 소방시설 설치·유지 및 안전관리에 관한 법률 시행령 제19조');
