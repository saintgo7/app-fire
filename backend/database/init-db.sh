#!/bin/bash

# Fire Safety Inspector 데이터베이스 초기화 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Fire Safety Inspector DB 초기화${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# .env 파일 로드
if [ -f "../.env" ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
    echo -e "${GREEN}✓${NC} .env 파일 로드 완료"
else
    echo -e "${RED}✗${NC} .env 파일을 찾을 수 없습니다."
    echo -e "${YELLOW}→${NC} backend/.env 파일을 생성해주세요."
    exit 1
fi

# 변수 설정
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-fire_safety_inspector}
DB_USER=${DB_USER:-root}

echo ""
echo -e "${YELLOW}데이터베이스 설정:${NC}"
echo -e "  Host: ${DB_HOST}"
echo -e "  Port: ${DB_PORT}"
echo -e "  Database: ${DB_NAME}"
echo -e "  User: ${DB_USER}"
echo ""

# 확인 메시지
read -p "$(echo -e ${YELLOW}경고: 기존 데이터베이스가 삭제됩니다. 계속하시겠습니까? [y/N]: ${NC})" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${RED}✗${NC} 취소되었습니다."
    exit 1
fi

echo ""
echo -e "${GREEN}[1/4]${NC} 데이터베이스 삭제 및 재생성..."

# 데이터베이스 삭제 및 재생성
mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} <<EOF
DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 데이터베이스 생성 완료"
else
    echo -e "${RED}✗${NC} 데이터베이스 생성 실패"
    exit 1
fi

echo ""
echo -e "${GREEN}[2/4]${NC} 테이블 스키마 생성..."

# 스키마 실행
mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < schema.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 테이블 생성 완료"
else
    echo -e "${RED}✗${NC} 테이블 생성 실패"
    exit 1
fi

echo ""
echo -e "${GREEN}[3/4]${NC} Seed 데이터 삽입..."

# Seed 데이터 실행
if [ -f "seed.sql" ]; then
    mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < seed.sql
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Seed 데이터 삽입 완료"
    else
        echo -e "${YELLOW}!${NC} Seed 데이터 삽입 중 일부 오류 발생"
    fi
else
    echo -e "${YELLOW}!${NC} seed.sql 파일을 찾을 수 없습니다. 건너뜁니다."
fi

echo ""
echo -e "${GREEN}[4/4]${NC} 테이블 확인..."

# 생성된 테이블 확인
TABLE_COUNT=$(mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${DB_NAME}';")

echo -e "${GREEN}✓${NC} 총 ${TABLE_COUNT}개의 테이블이 생성되었습니다."

# 테이블 목록 출력
echo ""
echo -e "${YELLOW}생성된 테이블:${NC}"
mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SHOW TABLES;"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}데이터베이스 초기화 완료!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo -e "  1. cd .. (backend 디렉토리로 이동)"
echo -e "  2. npm install (의존성 설치)"
echo -e "  3. npm run dev (서버 실행)"
echo ""
