# 🚀 EC2 배포 체크리스트

이 체크리스트를 따라 단계별로 배포를 진행하세요.

## 📋 사전 준비

### AWS 계정 및 리소스
- [ ] AWS 계정 생성 완료
- [ ] 결제 정보 등록 완료
- [ ] IAM 사용자 생성 (권장)
- [ ] 도메인 구매 (선택사항, 권장)

### 로컬 환경
- [ ] Git 설치
- [ ] SSH 클라이언트 설치
- [ ] 이 저장소 클론 완료

---

## 1️⃣ EC2 인스턴스 생성

### AWS Console 접속
- [ ] [AWS Console](https://console.aws.amazon.com/) 로그인
- [ ] EC2 서비스로 이동
- [ ] 리전 선택 (서울: ap-northeast-2 권장)

### 인스턴스 설정
- [ ] "인스턴스 시작" 클릭
- [ ] **AMI 선택**: Ubuntu Server 22.04 LTS (64-bit x86)
- [ ] **인스턴스 타입**:
  - [ ] 프리티어: t2.micro
  - [ ] 권장: t3.small 이상
- [ ] **키 페어 생성**:
  - [ ] 이름: `fire-inspector-key`
  - [ ] 키 파일 다운로드 및 안전한 위치에 보관
  - [ ] 권한 설정: `chmod 400 fire-inspector-key.pem`

### 네트워크 설정
- [ ] 새 보안 그룹 생성: `fire-inspector-sg`
- [ ] 보안 그룹 규칙 추가:
  - [ ] SSH (22) - My IP
  - [ ] HTTP (80) - 0.0.0.0/0
  - [ ] HTTPS (443) - 0.0.0.0/0
  - [ ] Custom TCP (3000) - My IP (개발용, 나중에 제거)

### 스토리지
- [ ] 크기: 20GB 이상
- [ ] 타입: gp3 (권장)

### 인스턴스 시작
- [ ] "인스턴스 시작" 클릭
- [ ] 인스턴스 ID 기록: `_________________`
- [ ] Public IP 기록: `_________________`

---

## 2️⃣ SSH 접속 및 초기 설정

### SSH 접속
```bash
ssh -i fire-inspector-key.pem ubuntu@<EC2-PUBLIC-IP>
```
- [ ] SSH 접속 성공

### 저장소 클론
```bash
git clone https://github.com/saintgo7/app-fire.git
cd app-fire
```
- [ ] 저장소 클론 완료

### 서버 초기 설정 실행
```bash
cd deploy
chmod +x setup-server.sh
./setup-server.sh
```
- [ ] Node.js 설치 완료
- [ ] PM2 설치 완료
- [ ] MariaDB 설치 완료
- [ ] Nginx 설치 완료
- [ ] 방화벽 설정 완료

---

## 3️⃣ MariaDB 설정

### 보안 설정
```bash
sudo mysql_secure_installation
```
- [ ] Root 비밀번호 설정
  - 비밀번호: `_________________` (안전하게 보관!)
- [ ] 익명 사용자 제거: Yes
- [ ] 원격 root 로그인 금지: Yes
- [ ] test 데이터베이스 제거: Yes
- [ ] 권한 테이블 리로드: Yes

### 사용자 생성
```bash
sudo mysql -u root -p
```

```sql
CREATE USER 'fire_inspector'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
- [ ] 데이터베이스 사용자 생성 완료
- [ ] 비밀번호 기록: `_________________` (안전하게 보관!)

---

## 4️⃣ 환경 변수 설정

### .env 파일 생성
```bash
cd /var/www/fire-safety-inspector/backend
cp .env.example .env
nano .env
```

### .env 파일 수정
- [ ] `DB_PASSWORD` - MariaDB 비밀번호 입력
- [ ] `JWT_SECRET` - 랜덤 문자열 생성 및 입력
  ```bash
  openssl rand -base64 64
  ```
- [ ] `CORS_ORIGIN` - 실제 도메인 또는 `*` 입력
- [ ] 기타 설정 확인

### 환경 변수 확인
```bash
cat .env
```
- [ ] 모든 필수 항목 설정 완료

---

## 5️⃣ 애플리케이션 배포

### 배포 스크립트 실행
```bash
cd /var/www/fire-safety-inspector/deploy
chmod +x deploy.sh
./deploy.sh
```

### 배포 과정 확인
- [ ] 코드 업데이트 완료
- [ ] npm 의존성 설치 완료
- [ ] 데이터베이스 초기화 선택 완료
- [ ] PM2 서버 시작 완료

### 서버 상태 확인
```bash
pm2 status
pm2 logs fire-inspector-api --lines 20
```
- [ ] 서버 실행 중
- [ ] 에러 없음

### API 테스트
```bash
curl http://localhost:3000/health
```
- [ ] 응답 정상 (status: "ok")

---

## 6️⃣ Nginx 설정

### 설정 파일 복사
```bash
sudo cp /var/www/fire-safety-inspector/deploy/nginx.conf /etc/nginx/sites-available/fire-inspector
```
- [ ] 설정 파일 복사 완료

### 도메인 설정 (있는 경우)
```bash
sudo nano /etc/nginx/sites-available/fire-inspector
```
- [ ] `server_name`을 실제 도메인으로 변경

### 설정 활성화
```bash
sudo ln -s /etc/nginx/sites-available/fire-inspector /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # 선택사항
```
- [ ] 심볼릭 링크 생성 완료

### 설정 테스트 및 재시작
```bash
sudo nginx -t
sudo systemctl restart nginx
```
- [ ] 설정 테스트 통과
- [ ] Nginx 재시작 완료

### Nginx 테스트
```bash
curl http://localhost/api/health
curl http://<EC2-PUBLIC-IP>/api/health
```
- [ ] Nginx를 통한 API 접근 성공

---

## 7️⃣ 도메인 연결 (선택사항)

### DNS 설정
- [ ] 도메인 등록 기관 접속
- [ ] A 레코드 추가:
  - 호스트: `@` 또는 `api`
  - 값: `<EC2-PUBLIC-IP>`
  - TTL: 3600
- [ ] DNS 전파 대기 (최대 48시간, 보통 몇 분)

### DNS 전파 확인
```bash
nslookup your-domain.com
dig your-domain.com
```
- [ ] DNS가 EC2 IP를 가리킴

### Nginx 설정 업데이트
```bash
sudo nano /etc/nginx/sites-available/fire-inspector
```
- [ ] `server_name`을 도메인으로 변경
- [ ] Nginx 재시작

### 도메인 테스트
```bash
curl http://your-domain.com/api/health
```
- [ ] 도메인을 통한 접근 성공

---

## 8️⃣ SSL 인증서 설정 (선택사항, 권장)

### Certbot 설치
```bash
sudo apt install certbot python3-certbot-nginx
```
- [ ] Certbot 설치 완료

### SSL 인증서 발급
```bash
sudo certbot --nginx -d your-domain.com
```
- [ ] 이메일 입력
- [ ] 약관 동의
- [ ] HTTP to HTTPS 리다이렉트: Yes
- [ ] 인증서 발급 완료

### HTTPS 테스트
```bash
curl https://your-domain.com/api/health
```
- [ ] HTTPS 접근 성공
- [ ] 브라우저에서 자물쇠 아이콘 확인

### 자동 갱신 설정
```bash
sudo certbot renew --dry-run
```
- [ ] 자동 갱신 테스트 성공

---

## 9️⃣ Flutter 앱 설정

### API URL 업데이트
`lib/core/config/environment.dart` 파일에서:
- [ ] Production URL 업데이트:
  ```dart
  return 'https://your-domain.com/api';
  ```

### 프로덕션 빌드
```bash
cd <flutter-project-directory>
chmod +x scripts/build-production.sh
./scripts/build-production.sh
```
- [ ] 프로덕션 빌드 완료

### 앱 테스트
- [ ] 로그인 기능 테스트
- [ ] 점검 기능 테스트
- [ ] 네트워크 연결 확인

---

## 🔟 배포 후 설정

### 자동 백업 설정
```bash
crontab -e
```
```
0 3 * * * cd /var/www/fire-safety-inspector/backend/database && ./backup.sh
```
- [ ] Cron 작업 추가 완료

### PM2 자동 시작 설정
```bash
pm2 startup
pm2 save
```
- [ ] PM2 자동 시작 설정 완료

### 방화벽 활성화
```bash
sudo ufw enable
sudo ufw status
```
- [ ] 방화벽 활성화 완료

### 보안 업데이트 설정
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```
- [ ] 자동 보안 업데이트 설정 완료

---

## 1️⃣1️⃣ 모니터링 설정

### 로그 확인
- [ ] PM2 로그: `pm2 logs fire-inspector-api`
- [ ] Nginx 로그: `sudo tail -f /var/log/nginx/fire-inspector-access.log`
- [ ] MariaDB 로그: `sudo tail -f /var/log/mysql/error.log`

### 리소스 모니터링
```bash
htop
df -h
free -h
```
- [ ] CPU/메모리 사용량 정상
- [ ] 디스크 공간 충분

---

## 1️⃣2️⃣ 최종 체크

### 기능 테스트
- [ ] API Health Check 작동
- [ ] 사용자 로그인 가능
- [ ] 데이터베이스 연결 정상
- [ ] 파일 업로드 작동 (있는 경우)

### 성능 테스트
- [ ] 응답 속도 적절
- [ ] 동시 접속 처리 가능
- [ ] 메모리 누수 없음

### 보안 체크
- [ ] SSH 비밀번호 로그인 비활성화
- [ ] 방화벽 활성화
- [ ] SSL 인증서 설치 (프로덕션)
- [ ] 환경 변수 보안
- [ ] 데이터베이스 비밀번호 강력

---

## 📝 배포 정보 기록

### 서버 정보
- EC2 인스턴스 ID: `_________________`
- Public IP: `_________________`
- 도메인: `_________________`
- 리전: `_________________`

### 인증 정보 (안전하게 보관!)
- SSH 키 파일 위치: `_________________`
- MariaDB root 비밀번호: `_________________`
- MariaDB fire_inspector 비밀번호: `_________________`
- JWT Secret: `_________________`

### 배포 날짜
- 초기 배포: `_________________`
- 마지막 업데이트: `_________________`

---

## 🎉 완료!

모든 체크리스트를 완료했다면 배포가 성공적으로 완료되었습니다!

### 다음 단계
1. ✅ 앱 스토어에 앱 등록 (Google Play, App Store)
2. ✅ 사용자 테스트 진행
3. ✅ 피드백 수집 및 개선
4. ✅ 정기 백업 확인
5. ✅ 모니터링 알림 설정

### 유지보수
- 주간: 로그 확인, 리소스 사용량 체크
- 월간: 백업 테스트, 보안 업데이트
- 분기: 성능 최적화, 데이터베이스 정리

---

## 🆘 문제 발생 시

1. **로그 확인**: `pm2 logs`, Nginx 로그, MariaDB 로그
2. **문서 참조**: `EC2_DEPLOYMENT_GUIDE.md`
3. **GitHub Issues**: 문제 보고 및 질문
4. **백업 복원**: 필요 시 최근 백업으로 복원

---

**배포 완료 날짜**: __________

**배포자**: __________

**서명**: __________
