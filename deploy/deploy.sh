#!/bin/bash

# Fire Safety Inspector 배포 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 설정
APP_DIR="/var/www/fire-safety-inspector"
BACKEND_DIR="${APP_DIR}/backend"
REPO_URL="https://github.com/saintgo7/app-fire.git"  # 실제 저장소 URL로 변경
BRANCH="main"  # 또는 배포할 브랜치

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Fire Safety Inspector 배포${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. 저장소 클론 또는 업데이트
echo -e "${BLUE}[1/7]${NC} 코드 가져오기..."
if [ -d "${APP_DIR}/.git" ]; then
    echo "기존 저장소 업데이트 중..."
    cd ${APP_DIR}
    git fetch origin
    git checkout ${BRANCH}
    git pull origin ${BRANCH}
else
    echo "저장소 클론 중..."
    sudo rm -rf ${APP_DIR}
    git clone -b ${BRANCH} ${REPO_URL} ${APP_DIR}
    cd ${APP_DIR}
fi

# 2. 백엔드 의존성 설치
echo -e "${BLUE}[2/7]${NC} 백엔드 의존성 설치 중..."
cd ${BACKEND_DIR}
npm install --production

# 3. 환경 변수 확인
echo -e "${BLUE}[3/7]${NC} 환경 변수 확인 중..."
if [ ! -f "${BACKEND_DIR}/.env" ]; then
    echo -e "${YELLOW}!${NC} .env 파일이 없습니다. .env.example을 복사합니다."
    cp ${BACKEND_DIR}/.env.example ${BACKEND_DIR}/.env
    echo -e "${RED}⚠${NC}  ${BACKEND_DIR}/.env 파일을 편집해주세요!"
    read -p "지금 편집하시겠습니까? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nano ${BACKEND_DIR}/.env
    fi
fi

# 4. 데이터베이스 초기화 (선택)
echo -e "${BLUE}[4/7]${NC} 데이터베이스 초기화..."
read -p "데이터베이스를 초기화하시겠습니까? (기존 데이터 삭제) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd ${BACKEND_DIR}/database
    ./init-db.sh
fi

# 5. PM2로 기존 프로세스 중지 및 삭제
echo -e "${BLUE}[5/7]${NC} 기존 프로세스 정리..."
pm2 delete fire-inspector-api 2>/dev/null || true

# 6. PM2로 서버 시작
echo -e "${BLUE}[6/7]${NC} 서버 시작 중..."
cd ${BACKEND_DIR}
pm2 start ecosystem.config.js

# 7. PM2 설정 저장 및 자동 시작 설정
echo -e "${BLUE}[7/7]${NC} PM2 설정 저장..."
pm2 save
pm2 startup | tail -n 1 | sudo bash || true

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}배포 완료!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}서버 상태 확인:${NC}"
pm2 status
echo ""
echo -e "${YELLOW}로그 확인:${NC}"
echo "  pm2 logs fire-inspector-api"
echo ""
echo -e "${YELLOW}서버 재시작:${NC}"
echo "  pm2 restart fire-inspector-api"
echo ""
echo -e "${YELLOW}서버 중지:${NC}"
echo "  pm2 stop fire-inspector-api"
echo ""
echo -e "${YELLOW}API 테스트:${NC}"
echo "  curl http://localhost:3000/health"
echo ""
