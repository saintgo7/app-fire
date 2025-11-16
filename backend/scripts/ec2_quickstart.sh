#!/bin/bash
# EC2 백엔드 서버 빠른 시작 스크립트

echo "🚒 소방 안전 점검 앱 - EC2 배포 시작"
echo "======================================"
echo ""

# 1. 시스템 업데이트
echo "📦 1. 시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

# 2. Node.js 설치
echo "📦 2. Node.js 18 설치 중..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node --version
npm --version

# 3. PM2 설치
echo "📦 3. PM2 설치 중..."
sudo npm install -g pm2
pm2 --version

# 4. MariaDB 설치
echo "📦 4. MariaDB 설치 중..."
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# 5. Git 설치
echo "📦 5. Git 설치 중..."
sudo apt install -y git
git --version

# 6. 프로젝트 클론
echo "📦 6. 프로젝트 클론 중..."
cd ~
git clone https://github.com/saintgo7/app-fire.git
cd app-fire/backend

# 7. npm 패키지 설치
echo "📦 7. npm 패키지 설치 중..."
npm install

# 8. 환경 변수 파일 생성
echo "📦 8. 환경 변수 파일 생성 중..."
cat > .env << 'ENVFILE'
NODE_ENV=production
PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_safety_user
DB_PASSWORD=Change_This_Password_123!
DB_NAME=fire_safety_db

JWT_SECRET=CHANGE_THIS_TO_RANDOM_SECRET_STRING_12345678901234567890
UPLOAD_DIR=./uploads
CORS_ORIGIN=*
ENVFILE

echo ""
echo "✅ 기본 설치 완료!"
echo ""
echo "📝 다음 단계:"
echo "1. nano .env 으로 비밀번호와 JWT_SECRET 변경"
echo "2. MariaDB 데이터베이스 설정 (아래 명령어 참고)"
echo ""
echo "MariaDB 설정 명령어:"
echo "  sudo mysql -u root -p"
echo "  CREATE DATABASE fire_safety_db;"
echo "  CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_password';"
echo "  GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';"
echo "  FLUSH PRIVILEGES;"
echo "  EXIT;"
echo ""
echo "  mysql -u fire_safety_user -p fire_safety_db < ~/app-fire/backend/sql/schema.sql"
echo ""
echo "3. pm2 start src/index.js --name fire-safety-api"
echo "4. pm2 save"
echo ""
