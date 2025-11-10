#!/bin/bash

# Fire Safety Inspector 데이터베이스 백업 스크립트

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Fire Safety Inspector DB 백업${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# .env 파일 로드
if [ -f "../.env" ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
else
    echo "Error: .env 파일을 찾을 수 없습니다."
    exit 1
fi

# 변수 설정
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-fire_safety_inspector}
DB_USER=${DB_USER:-root}

# 백업 디렉토리 생성
BACKUP_DIR="./backups"
mkdir -p ${BACKUP_DIR}

# 백업 파일명 (날짜-시간 포함)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

echo "데이터베이스 백업 중..."
echo "파일: ${BACKUP_FILE}"
echo ""

# mysqldump 실행
mysqldump -h ${DB_HOST} \
          -P ${DB_PORT} \
          -u ${DB_USER} \
          -p${DB_PASSWORD} \
          --single-transaction \
          --routines \
          --triggers \
          --events \
          ${DB_NAME} > ${BACKUP_FILE}

if [ $? -eq 0 ]; then
    # 백업 파일 압축
    gzip ${BACKUP_FILE}
    BACKUP_FILE="${BACKUP_FILE}.gz"

    FILE_SIZE=$(ls -lh ${BACKUP_FILE} | awk '{print $5}')
    echo -e "${GREEN}✓${NC} 백업 완료!"
    echo "  파일: ${BACKUP_FILE}"
    echo "  크기: ${FILE_SIZE}"
    echo ""

    # 30일 이상 된 백업 파일 삭제
    echo "오래된 백업 파일 정리 중..."
    find ${BACKUP_DIR} -name "*.sql.gz" -mtime +30 -delete

    BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.sql.gz 2>/dev/null | wc -l)
    echo -e "${GREEN}✓${NC} 현재 ${BACKUP_COUNT}개의 백업 파일이 있습니다."
else
    echo "Error: 백업 실패"
    exit 1
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}백업 완료!${NC}"
echo -e "${GREEN}================================================${NC}"
