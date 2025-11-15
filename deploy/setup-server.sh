#!/bin/bash

# Fire Safety Inspector EC2 서버 초기 설정 스크립트
# Ubuntu 20.04/22.04 LTS 기준

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Fire Safety Inspector EC2 서버 설정${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 1. 시스템 업데이트
echo -e "${BLUE}[1/8]${NC} 시스템 업데이트 중..."
sudo apt update
sudo apt upgrade -y

# 2. 필수 패키지 설치
echo -e "${BLUE}[2/8]${NC} 필수 패키지 설치 중..."
sudo apt install -y curl wget git build-essential

# 3. Node.js 설치 (Node.js 18 LTS)
echo -e "${BLUE}[3/8]${NC} Node.js 설치 중..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}✓${NC} Node.js $(node --version) 설치 완료"
else
    echo -e "${YELLOW}!${NC} Node.js $(node --version) 이미 설치되어 있음"
fi

# 4. PM2 설치 (프로세스 관리자)
echo -e "${BLUE}[4/8]${NC} PM2 설치 중..."
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    echo -e "${GREEN}✓${NC} PM2 설치 완료"
else
    echo -e "${YELLOW}!${NC} PM2 이미 설치되어 있음"
fi

# 5. MariaDB 설치
echo -e "${BLUE}[5/8]${NC} MariaDB 설치 중..."
if ! command -v mysql &> /dev/null; then
    sudo apt install -y mariadb-server mariadb-client
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    echo -e "${GREEN}✓${NC} MariaDB 설치 완료"
else
    echo -e "${YELLOW}!${NC} MariaDB 이미 설치되어 있음"
fi

# 6. Nginx 설치
echo -e "${BLUE}[6/8]${NC} Nginx 설치 중..."
if ! command -v nginx &> /dev/null; then
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo -e "${GREEN}✓${NC} Nginx 설치 완료"
else
    echo -e "${YELLOW}!${NC} Nginx 이미 설치되어 있음"
fi

# 7. 방화벽 설정
echo -e "${BLUE}[7/8]${NC} 방화벽 설정 중..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # Node.js (개발용, 나중에 제거 가능)
echo -e "${GREEN}✓${NC} 방화벽 규칙 추가 완료"

# 8. 애플리케이션 디렉토리 생성
echo -e "${BLUE}[8/8]${NC} 애플리케이션 디렉토리 설정 중..."
APP_DIR="/var/www/fire-safety-inspector"
sudo mkdir -p ${APP_DIR}
sudo chown -R $USER:$USER ${APP_DIR}
echo -e "${GREEN}✓${NC} 디렉토리 생성: ${APP_DIR}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}서버 초기 설정 완료!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}설치된 버전:${NC}"
echo "  Node.js: $(node --version)"
echo "  npm: $(npm --version)"
echo "  PM2: $(pm2 --version)"
echo "  MariaDB: $(mysql --version | awk '{print $5}' | sed 's/,//')"
echo "  Nginx: $(nginx -v 2>&1 | awk '{print $3}')"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. MariaDB 보안 설정: sudo mysql_secure_installation"
echo "  2. 애플리케이션 코드 배포"
echo "  3. 데이터베이스 설정"
echo "  4. PM2로 서버 실행"
echo ""
