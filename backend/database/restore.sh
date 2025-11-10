#!/bin/bash

# Fire Safety Inspector 데이터베이스 복원 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Fire Safety Inspector DB 복원${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# .env 파일 로드
if [ -f "../.env" ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
else
    echo -e "${RED}Error:${NC} .env 파일을 찾을 수 없습니다."
    exit 1
fi

# 변수 설정
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-fire_safety_inspector}
DB_USER=${DB_USER:-root}
BACKUP_DIR="./backups"

# 백업 파일 목록 표시
echo -e "${YELLOW}사용 가능한 백업 파일:${NC}"
echo ""

# 백업 파일이 있는지 확인
if [ ! -d "${BACKUP_DIR}" ] || [ -z "$(ls -A ${BACKUP_DIR}/*.sql.gz 2>/dev/null)" ]; then
    echo -e "${RED}백업 파일이 없습니다.${NC}"
    exit 1
fi

# 백업 파일 목록을 배열로 저장
mapfile -t BACKUP_FILES < <(ls -t ${BACKUP_DIR}/*.sql.gz)

# 번호와 함께 파일 목록 표시
for i in "${!BACKUP_FILES[@]}"; do
    FILE="${BACKUP_FILES[$i]}"
    FILENAME=$(basename "$FILE")
    FILE_DATE=$(stat -c %y "$FILE" | cut -d' ' -f1,2 | cut -d'.' -f1)
    FILE_SIZE=$(ls -lh "$FILE" | awk '{print $5}')
    echo "  [$((i+1))] ${FILENAME} (${FILE_DATE}, ${FILE_SIZE})"
done

echo ""
read -p "$(echo -e ${YELLOW}복원할 백업 파일 번호를 선택하세요: ${NC})" CHOICE

# 입력 검증
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUP_FILES[@]}" ]; then
    echo -e "${RED}잘못된 선택입니다.${NC}"
    exit 1
fi

SELECTED_FILE="${BACKUP_FILES[$((CHOICE-1))]}"
echo ""
echo -e "${YELLOW}선택한 파일:${NC} $(basename ${SELECTED_FILE})"
echo ""

# 경고 메시지
echo -e "${RED}경고: 현재 데이터베이스의 모든 데이터가 삭제되고 백업 데이터로 복원됩니다!${NC}"
read -p "$(echo -e ${YELLOW}계속하시겠습니까? [y/N]: ${NC})" -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}취소되었습니다.${NC}"
    exit 0
fi

echo ""
echo "데이터베이스 복원 중..."

# 압축 해제 및 복원
gunzip -c ${SELECTED_FILE} | mysql -h ${DB_HOST} \
                                    -P ${DB_PORT} \
                                    -u ${DB_USER} \
                                    -p${DB_PASSWORD} \
                                    ${DB_NAME}

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓${NC} 복원 완료!"
    echo ""

    # 테이블 개수 확인
    TABLE_COUNT=$(mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${DB_NAME}';")
    echo "  테이블 개수: ${TABLE_COUNT}"

    # 데이터 개수 확인
    USER_COUNT=$(mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -se "SELECT COUNT(*) FROM users;")
    INSPECTION_COUNT=$(mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -se "SELECT COUNT(*) FROM inspections;")

    echo "  사용자: ${USER_COUNT}명"
    echo "  점검 기록: ${INSPECTION_COUNT}건"
else
    echo ""
    echo -e "${RED}Error: 복원 실패${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}복원 완료!${NC}"
echo -e "${GREEN}================================================${NC}"
