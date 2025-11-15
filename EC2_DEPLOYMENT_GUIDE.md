# EC2 서버 배포 가이드

Fire Safety Inspector 애플리케이션을 AWS EC2에 배포하는 전체 과정을 안내합니다.

## 📋 목차

1. [사전 준비](#사전-준비)
2. [EC2 인스턴스 생성](#ec2-인스턴스-생성)
3. [서버 초기 설정](#서버-초기-설정)
4. [애플리케이션 배포](#애플리케이션-배포)
5. [데이터베이스 설정](#데이터베이스-설정)
6. [Nginx 설정](#nginx-설정)
7. [SSL 인증서 설정](#ssl-인증서-설정)
8. [모니터링 및 로그](#모니터링-및-로그)
9. [문제 해결](#문제-해결)

---

## 사전 준비

### 필요한 것

- AWS 계정
- SSH 클라이언트 (Terminal, PuTTY 등)
- 도메인 (선택사항, SSL 사용 시 필요)
- Git 저장소 (GitHub, GitLab 등)

### 권장 사양

**최소 사양**:
- 인스턴스 타입: t2.micro (프리티어)
- vCPU: 1
- 메모리: 1GB
- 스토리지: 8GB

**권장 사양**:
- 인스턴스 타입: t3.small
- vCPU: 2
- 메모리: 2GB
- 스토리지: 20GB

---

## EC2 인스턴스 생성

### 1. AWS Console 접속

1. [AWS Console](https://console.aws.amazon.com/) 로그인
2. EC2 서비스로 이동
3. "인스턴스 시작" 클릭

### 2. AMI 선택

- **Ubuntu Server 22.04 LTS** 선택 (권장)
- 64비트 (x86) 아키텍처

### 3. 인스턴스 타입 선택

- 프리티어: **t2.micro**
- 프로덕션: **t3.small** 이상

### 4. 키 페어 생성

1. "새 키 페어 생성" 클릭
2. 키 페어 이름: `fire-inspector-key`
3. 키 페어 파일 다운로드 (`.pem`)
4. 안전한 위치에 보관

### 5. 네트워크 설정

**보안 그룹 규칙**:
| 유형 | 프로토콜 | 포트 | 소스 | 설명 |
|------|----------|------|------|------|
| SSH | TCP | 22 | My IP | SSH 접속 |
| HTTP | TCP | 80 | 0.0.0.0/0 | 웹 접속 |
| HTTPS | TCP | 443 | 0.0.0.0/0 | 보안 웹 접속 |
| Custom TCP | TCP | 3000 | My IP | 개발용 (선택) |

### 6. 스토리지 구성

- 최소 **20GB** gp3 볼륨 권장
- 데이터가 많으면 더 늘릴 것

### 7. 인스턴스 시작

"인스턴스 시작" 클릭 후 대기

---

## 서버 초기 설정

### 1. SSH 접속

#### macOS/Linux

```bash
# 키 파일 권한 변경
chmod 400 fire-inspector-key.pem

# SSH 접속
ssh -i fire-inspector-key.pem ubuntu@<EC2-PUBLIC-IP>
```

#### Windows (PuTTY)

1. PuTTYgen으로 `.pem` 파일을 `.ppk`로 변환
2. PuTTY에서 Host Name: `ubuntu@<EC2-PUBLIC-IP>`
3. Connection → SSH → Auth에서 `.ppk` 파일 선택
4. Open 클릭

### 2. 자동 설정 스크립트 실행

```bash
# 저장소 클론
git clone https://github.com/saintgo7/app-fire.git
cd app-fire

# 설정 스크립트 실행
cd deploy
chmod +x setup-server.sh
./setup-server.sh
```

이 스크립트는 다음을 자동으로 설치합니다:
- ✅ Node.js 18 LTS
- ✅ PM2 (프로세스 관리자)
- ✅ MariaDB
- ✅ Nginx
- ✅ 방화벽 설정

### 3. MariaDB 보안 설정

```bash
sudo mysql_secure_installation
```

설정 권장 사항:
- Root 비밀번호 설정: **Yes** (강력한 비밀번호)
- 익명 사용자 제거: **Yes**
- 원격 root 로그인 금지: **Yes**
- test 데이터베이스 제거: **Yes**
- 권한 테이블 리로드: **Yes**

### 4. 데이터베이스 사용자 생성

```bash
sudo mysql -u root -p
```

MySQL 프롬프트에서:

```sql
CREATE USER 'fire_inspector'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## 애플리케이션 배포

### 1. 저장소 설정

배포 스크립트에서 저장소 URL 수정:

```bash
nano deploy/deploy.sh

# REPO_URL 변경
REPO_URL="https://github.com/your-username/app-fire.git"
```

### 2. 환경 변수 설정

```bash
cd /var/www/fire-safety-inspector/backend
cp .env.example .env
nano .env
```

`.env` 파일 예시:

```env
# Server Configuration
PORT=3000
NODE_ENV=production

# MariaDB Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_inspector
DB_PASSWORD=your_secure_password
DB_NAME=fire_safety_inspector

# JWT Secret (강력한 임의 문자열)
JWT_SECRET=your_very_long_and_secure_random_string_change_this_in_production
JWT_EXPIRES_IN=7d

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# CORS (실제 도메인으로 변경)
CORS_ORIGIN=https://your-domain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**중요**: `JWT_SECRET`을 반드시 변경하세요!

```bash
# 랜덤 문자열 생성
openssl rand -base64 64
```

### 3. 배포 스크립트 실행

```bash
cd /var/www/fire-safety-inspector/deploy
chmod +x deploy.sh
./deploy.sh
```

배포 스크립트는 다음을 수행합니다:
1. 코드 클론/업데이트
2. npm 의존성 설치
3. 데이터베이스 초기화 (선택)
4. PM2로 서버 시작

---

## 데이터베이스 설정

### 수동 초기화

```bash
cd /var/www/fire-safety-inspector/backend/database
./init-db.sh
```

### 백업 설정 (Cron)

```bash
crontab -e

# 매일 새벽 3시 자동 백업
0 3 * * * cd /var/www/fire-safety-inspector/backend/database && ./backup.sh
```

---

## Nginx 설정

### 1. Nginx 설정 파일 복사

```bash
sudo cp /var/www/fire-safety-inspector/deploy/nginx.conf /etc/nginx/sites-available/fire-inspector

# 도메인 수정
sudo nano /etc/nginx/sites-available/fire-inspector
# server_name을 실제 도메인으로 변경
```

### 2. 심볼릭 링크 생성

```bash
sudo ln -s /etc/nginx/sites-available/fire-inspector /etc/nginx/sites-enabled/
```

### 3. 기본 사이트 비활성화 (선택)

```bash
sudo rm /etc/nginx/sites-enabled/default
```

### 4. 설정 테스트 및 재시작

```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 5. 테스트

```bash
curl http://localhost/api/health
```

응답 예시:
```json
{
  "status": "ok",
  "timestamp": "2025-01-10T12:00:00.000Z",
  "uptime": 123.456
}
```

---

## SSL 인증서 설정

### Let's Encrypt (무료)

#### 1. Certbot 설치

```bash
sudo apt install certbot python3-certbot-nginx
```

#### 2. 인증서 발급

```bash
sudo certbot --nginx -d your-domain.com
```

프롬프트에 따라 진행:
- 이메일 입력
- 약관 동의
- HTTP to HTTPS 리다이렉트: **Yes**

#### 3. 자동 갱신 설정

```bash
# 테스트
sudo certbot renew --dry-run

# Cron 작업 (자동 설정됨)
# /etc/cron.d/certbot
```

#### 4. 테스트

```bash
curl https://your-domain.com/api/health
```

---

## 모니터링 및 로그

### PM2 모니터링

#### 프로세스 상태 확인

```bash
pm2 status
```

#### 실시간 로그

```bash
pm2 logs fire-inspector-api
```

#### 특정 로그만 보기

```bash
# 에러 로그만
pm2 logs fire-inspector-api --err

# 출력 로그만
pm2 logs fire-inspector-api --out
```

#### 리소스 사용량

```bash
pm2 monit
```

### Nginx 로그

```bash
# Access 로그
sudo tail -f /var/log/nginx/fire-inspector-access.log

# Error 로그
sudo tail -f /var/log/nginx/fire-inspector-error.log
```

### MariaDB 로그

```bash
sudo tail -f /var/log/mysql/error.log
```

### 시스템 리소스

```bash
# CPU, 메모리 사용량
htop

# 디스크 사용량
df -h

# 네트워크 연결
netstat -tulpn
```

---

## 유지보수

### 서버 재시작

```bash
# PM2 재시작
pm2 restart fire-inspector-api

# Nginx 재시작
sudo systemctl restart nginx

# MariaDB 재시작
sudo systemctl restart mariadb
```

### 서버 중지

```bash
pm2 stop fire-inspector-api
```

### 코드 업데이트

```bash
cd /var/www/fire-safety-inspector/deploy
./deploy.sh
```

### 데이터베이스 백업

```bash
cd /var/www/fire-safety-inspector/backend/database
./backup.sh
```

### 로그 로테이션

PM2는 자동으로 로그를 관리하지만, 수동으로 정리할 수도 있습니다:

```bash
pm2 flush  # 모든 로그 삭제
```

---

## 문제 해결

### 서버가 시작되지 않음

```bash
# PM2 로그 확인
pm2 logs fire-inspector-api --lines 100

# 포트 사용 확인
sudo lsof -i :3000

# 프로세스 강제 종료
sudo kill -9 <PID>
```

### 데이터베이스 연결 오류

```bash
# MariaDB 상태 확인
sudo systemctl status mariadb

# .env 파일 확인
cat /var/www/fire-safety-inspector/backend/.env

# 데이터베이스 연결 테스트
mysql -u fire_inspector -p fire_safety_inspector
```

### Nginx 오류

```bash
# 설정 테스트
sudo nginx -t

# 로그 확인
sudo tail -f /var/log/nginx/error.log

# 재시작
sudo systemctl restart nginx
```

### 메모리 부족

```bash
# 메모리 사용량 확인
free -h

# PM2 메모리 제한 설정
pm2 start ecosystem.config.js --max-memory-restart 500M
```

### 디스크 공간 부족

```bash
# 디스크 사용량 확인
df -h

# 큰 파일 찾기
du -h --max-depth=1 / | sort -hr | head -10

# 오래된 로그 삭제
pm2 flush
sudo journalctl --vacuum-time=7d
```

---

## 보안 권장사항

### 1. SSH 보안 강화

```bash
sudo nano /etc/ssh/sshd_config
```

권장 설정:
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

재시작:
```bash
sudo systemctl restart sshd
```

### 2. 방화벽 활성화

```bash
sudo ufw enable
sudo ufw status
```

### 3. 자동 보안 업데이트

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. Fail2Ban 설치 (SSH 보호)

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 5. 정기 백업

- 데이터베이스: 매일 자동 백업
- 업로드 파일: S3 또는 외부 스토리지로 백업
- 설정 파일: Git으로 버전 관리

---

## 성능 최적화

### PM2 클러스터 모드

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'fire-inspector-api',
    script: './server.js',
    instances: 'max',  // CPU 코어 수만큼
    exec_mode: 'cluster',
  }]
};
```

### Nginx 캐싱

```nginx
# Nginx 설정에 추가
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=100m;
proxy_cache api_cache;
proxy_cache_valid 200 5m;
```

### 데이터베이스 최적화

```sql
-- 인덱스 최적화
OPTIMIZE TABLE users, buildings, inspections;

-- 쿼리 캐시 활성화
SET GLOBAL query_cache_size = 1048576;
```

---

## 모니터링 도구 (선택사항)

### 1. PM2 Plus (무료/유료)

```bash
pm2 link <secret_key> <public_key>
```

웹 대시보드에서 실시간 모니터링

### 2. CloudWatch (AWS)

- EC2 메트릭 자동 수집
- 커스텀 메트릭 설정 가능
- 알람 설정

### 3. New Relic (유료)

Node.js APM 모니터링

---

## 체크리스트

배포 전:
- [ ] EC2 인스턴스 생성
- [ ] 보안 그룹 설정
- [ ] 키 페어 안전하게 보관
- [ ] 도메인 DNS 설정 (선택)

배포:
- [ ] 서버 초기 설정 완료
- [ ] MariaDB 설치 및 보안 설정
- [ ] 데이터베이스 사용자 생성
- [ ] `.env` 파일 설정
- [ ] 애플리케이션 배포
- [ ] 데이터베이스 초기화

배포 후:
- [ ] Nginx 설정
- [ ] SSL 인증서 설치 (선택)
- [ ] 백업 Cron 설정
- [ ] PM2 자동 시작 설정
- [ ] 모니터링 설정
- [ ] API 테스트

---

## 추가 리소스

- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

---

## 지원

문제가 발생하면:
1. 로그 확인 (`pm2 logs`, Nginx 로그, MariaDB 로그)
2. [GitHub Issues](https://github.com/saintgo7/app-fire/issues)에 문의
3. `EC2_DEPLOYMENT_GUIDE.md` 문제 해결 섹션 참조
