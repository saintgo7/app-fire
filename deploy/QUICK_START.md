# 빠른 시작 가이드

EC2 서버에서 Fire Safety Inspector를 빠르게 시작하는 방법

## 🚀 한 줄 설치

```bash
wget -O - https://raw.githubusercontent.com/saintgo7/app-fire/main/deploy/quick-install.sh | bash
```

## 📝 단계별 설치

### 1. EC2 인스턴스 접속

```bash
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

### 2. 저장소 클론

```bash
git clone https://github.com/saintgo7/app-fire.git
cd app-fire
```

### 3. 서버 초기 설정

```bash
cd deploy
chmod +x setup-server.sh
./setup-server.sh
```

### 4. MariaDB 보안 설정

```bash
sudo mysql_secure_installation
```

- Root 비밀번호 설정
- 익명 사용자 제거
- 원격 root 로그인 금지
- test 데이터베이스 제거

### 5. 데이터베이스 사용자 생성

```bash
sudo mysql -u root -p
```

```sql
CREATE USER 'fire_inspector'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 6. 환경 변수 설정

```bash
cd /var/www/fire-safety-inspector/backend
cp .env.example .env
nano .env
```

**필수 변경 항목**:
- `DB_PASSWORD`: 데이터베이스 비밀번호
- `JWT_SECRET`: JWT 시크릿 키 (랜덤 문자열)

JWT 시크릿 생성:
```bash
openssl rand -base64 64
```

### 7. 애플리케이션 배포

```bash
cd ../deploy
chmod +x deploy.sh
./deploy.sh
```

### 8. Nginx 설정

```bash
sudo cp /var/www/fire-safety-inspector/deploy/nginx.conf /etc/nginx/sites-available/fire-inspector
sudo ln -s /etc/nginx/sites-available/fire-inspector /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 9. 테스트

```bash
# 로컬 테스트
curl http://localhost:3000/health

# Nginx를 통한 테스트
curl http://localhost/api/health
```

## ✅ 완료!

서버가 실행 중입니다:
- API: `http://<EC2-PUBLIC-IP>/api`
- Health Check: `http://<EC2-PUBLIC-IP>/api/health`

## 📊 서버 관리

### 상태 확인

```bash
pm2 status
```

### 로그 확인

```bash
pm2 logs fire-inspector-api
```

### 서버 재시작

```bash
pm2 restart fire-inspector-api
```

### 서버 중지

```bash
pm2 stop fire-inspector-api
```

## 🔒 SSL 설정 (선택사항)

도메인이 있는 경우:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📝 다음 단계

1. Flutter 앱에서 API Base URL 변경
2. 소셜 로그인 설정 (Google, Kakao, Naver)
3. 정기 백업 설정
4. 모니터링 설정

자세한 내용은 [EC2_DEPLOYMENT_GUIDE.md](../EC2_DEPLOYMENT_GUIDE.md)를 참조하세요.
