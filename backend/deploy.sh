#!/bin/bash

# Fire Safety Backend 배포 스크립트
# EC2 서버에서 실행하세요

set -e  # 에러 발생 시 스크립트 중단

echo "========================================="
echo "🔥 Fire Safety Backend 배포 시작"
echo "========================================="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 환경 변수
PROJECT_DIR="/home/ubuntu/app-fire"
BACKEND_DIR="$PROJECT_DIR/backend"
SQL_DIR="/home/ubuntu/eng_sql"

# 1. 시스템 업데이트
echo -e "${YELLOW}📦 시스템 패키지 업데이트...${NC}"
sudo apt update

# 2. Node.js 설치 확인
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}📦 Node.js 설치 중...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo -e "${GREEN}✅ Node.js 이미 설치됨: $(node -v)${NC}"
fi

# 3. MariaDB 설치 확인
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}📦 MariaDB 설치 중...${NC}"
    sudo apt install -y mariadb-server
    sudo systemctl start mariadb
    sudo systemctl enable mariadb

    echo -e "${YELLOW}⚠️  MariaDB 보안 설정을 실행해주세요:${NC}"
    echo "sudo mysql_secure_installation"
else
    echo -e "${GREEN}✅ MariaDB 이미 설치됨${NC}"
fi

# 4. Git 저장소 클론 또는 업데이트
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}📥 Git 저장소 클론 중...${NC}"
    cd /home/ubuntu
    git clone https://github.com/saintgo7/app-fire.git
else
    echo -e "${YELLOW}🔄 Git 저장소 업데이트 중...${NC}"
    cd "$PROJECT_DIR"
    git pull origin claude/review-current-code-01EFxfuyignexFkXbVQaQbFP
fi

# 5. 백엔드 의존성 설치
echo -e "${YELLOW}📦 npm 패키지 설치 중...${NC}"
cd "$BACKEND_DIR"
npm install

# 6. 환경변수 파일 확인
if [ ! -f "$BACKEND_DIR/.env" ]; then
    echo -e "${YELLOW}⚙️  .env 파일 생성 중...${NC}"
    cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"

    echo -e "${RED}⚠️  중요: .env 파일을 수정해주세요!${NC}"
    echo "nano $BACKEND_DIR/.env"
    echo ""
    echo "필수 설정:"
    echo "  - DB_PASSWORD=실제_비밀번호"
    echo "  - JWT_SECRET=랜덤_시크릿_키"
    echo ""
    read -p "계속하려면 Enter를 누르세요..."
else
    echo -e "${GREEN}✅ .env 파일 존재${NC}"
fi

# 7. 데이터베이스 생성 확인
echo -e "${YELLOW}🗄️  데이터베이스 설정 확인 중...${NC}"
echo ""
echo "다음 명령어를 실행하여 DB를 생성해주세요:"
echo ""
echo -e "${GREEN}sudo mysql -u root -p${NC}"
echo ""
echo "그 다음 MySQL에서:"
echo "  CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "  CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_password';"
echo "  GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';"
echo "  FLUSH PRIVILEGES;"
echo "  EXIT;"
echo ""
read -p "데이터베이스를 생성했나요? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ 데이터베이스를 먼저 생성해주세요${NC}"
    exit 1
fi

# 8. 스키마 생성
echo -e "${YELLOW}📊 데이터베이스 스키마 생성 중...${NC}"
mysql -u fire_safety_user -p fire_safety_db < "$BACKEND_DIR/sql/schema.sql"

# 9. SQL 데이터 import (선택사항)
if [ -d "$SQL_DIR" ]; then
    echo -e "${YELLOW}📥 SQL 데이터 import 하시겠습니까? (y/n)${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}📥 SQL 데이터 import 중... (시간이 걸릴 수 있습니다)${NC}"
        node "$BACKEND_DIR/scripts/import-sql.js" "$SQL_DIR"
    fi
else
    echo -e "${YELLOW}⚠️  SQL 데이터 디렉토리를 찾을 수 없습니다: $SQL_DIR${NC}"
    echo "필요한 경우 나중에 수동으로 import하세요."
fi

# 10. PM2 설치 및 서버 시작
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}📦 PM2 설치 중...${NC}"
    sudo npm install -g pm2
fi

echo -e "${YELLOW}🚀 서버 시작 중...${NC}"

# 기존 프로세스 중지
pm2 delete fire-safety-api 2>/dev/null || true

# 새 프로세스 시작
cd "$BACKEND_DIR"
pm2 start src/index.js --name fire-safety-api

# PM2 저장 및 부팅 시 자동 시작
pm2 save
pm2 startup | tail -n 1 | sudo bash

# 11. 방화벽 설정 (선택사항)
echo -e "${YELLOW}🔥 방화벽 설정 (ufw)${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 3000/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    echo -e "${GREEN}✅ 방화벽 규칙 추가됨${NC}"
fi

# 12. Nginx 설정 (선택사항)
echo -e "${YELLOW}🌐 Nginx 리버스 프록시를 설정하시겠습니까? (y/n)${NC}"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v nginx &> /dev/null; then
        sudo apt install -y nginx
    fi

    # Nginx 설정 파일 생성
    sudo tee /etc/nginx/sites-available/fire-safety-api > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # 심볼릭 링크 생성
    sudo ln -sf /etc/nginx/sites-available/fire-safety-api /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default

    # Nginx 테스트 및 재시작
    sudo nginx -t && sudo systemctl restart nginx

    echo -e "${GREEN}✅ Nginx 설정 완료${NC}"
fi

echo ""
echo "========================================="
echo -e "${GREEN}✅ 배포 완료!${NC}"
echo "========================================="
echo ""
echo "서버 정보:"
echo "  - API 주소: http://$(curl -s ifconfig.me):3000"
echo "  - API 문서: http://$(curl -s ifconfig.me):3000/api-docs"
echo "  - 헬스체크: http://$(curl -s ifconfig.me):3000/health"
echo ""
echo "PM2 명령어:"
echo "  - 상태 확인: pm2 status"
echo "  - 로그 보기: pm2 logs fire-safety-api"
echo "  - 재시작: pm2 restart fire-safety-api"
echo "  - 중지: pm2 stop fire-safety-api"
echo ""
echo "테스트:"
echo "  curl http://localhost:3000/health"
echo ""
