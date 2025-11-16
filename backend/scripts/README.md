# Backend Scripts

이 폴더에는 백엔드 서버 배포 및 관리를 위한 스크립트들이 포함되어 있습니다.

## 📜 스크립트 목록

### ec2_quickstart.sh
**용도:** AWS EC2 인스턴스에서 백엔드 서버를 빠르게 설정하고 실행하기 위한 자동화 스크립트

**실행 방법:**
```bash
# EC2 인스턴스에 SSH 접속 후
wget https://raw.githubusercontent.com/saintgo7/app-fire/main/backend/scripts/ec2_quickstart.sh
chmod +x ec2_quickstart.sh
./ec2_quickstart.sh
```

**포함 작업:**
- 시스템 업데이트
- Node.js 18 설치
- PM2 설치
- MariaDB 설치 및 설정
- Git 설치
- 프로젝트 클론
- npm 패키지 설치
- .env 파일 생성

**실행 후 작업:**
1. `.env` 파일에서 비밀번호 및 JWT_SECRET 변경
2. MariaDB 데이터베이스 및 사용자 생성
3. SQL 스키마 임포트
4. PM2로 서버 시작

### import-sql.js
**용도:** SQL 스키마 파일을 MariaDB로 임포트

**실행 방법:**
```bash
node import-sql.js
```

## 🔗 관련 문서

- [AWS EC2 배포 가이드](../../docs/AWS_EC2_DEPLOYMENT.md)
- [Flutter 앱 실행 가이드](../../docs/FLUTTER_RUN_GUIDE.md)

---

**최근 업데이트:** 2025-01-14
