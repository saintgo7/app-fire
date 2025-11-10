-- Migration 001: Create Initial Tables
-- Created: 2025-01-10
-- Description: 초기 테이블 생성

-- 마이그레이션 버전 테이블 생성
CREATE TABLE IF NOT EXISTS migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_version (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 이미 schema.sql에 정의된 테이블들은 여기서 다시 생성하지 않음
-- 대신 schema.sql을 먼저 실행해야 함
