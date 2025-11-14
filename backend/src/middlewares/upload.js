const multer = require('multer');
const path = require('path');
const fs = require('fs');

// uploads 디렉토리 생성
const uploadDir = process.env.UPLOAD_PATH || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 스토리지 설정
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // 날짜별 폴더 생성 (예: uploads/2025/11/14/)
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    const dateDir = path.join(uploadDir, String(year), month, day);

    if (!fs.existsSync(dateDir)) {
      fs.mkdirSync(dateDir, { recursive: true });
    }

    cb(null, dateDir);
  },
  filename: function (req, file, cb) {
    // 파일명: timestamp_랜덤문자열_원본파일명
    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(2, 8);
    const ext = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, ext);
    const safeName = baseName.replace(/[^a-zA-Z0-9가-힣]/g, '_');

    cb(null, `${timestamp}_${randomStr}_${safeName}${ext}`);
  },
});

// 파일 필터 (이미지만 허용)
const fileFilter = (req, file, cb) => {
  const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

  if (allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        '지원하지 않는 파일 형식입니다. (허용: JPEG, PNG, GIF, WEBP)'
      ),
      false
    );
  }
};

// Multer 설정
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB
  },
});

/**
 * 단일 파일 업로드 미들웨어
 */
const uploadSingle = upload.single('photo');

/**
 * 다중 파일 업로드 미들웨어 (최대 10개)
 */
const uploadMultiple = upload.array('photos', 10);

/**
 * 파일 삭제 헬퍼
 */
function deleteFile(filePath) {
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

/**
 * 상대 경로 반환 (uploads 기준)
 */
function getRelativePath(absolutePath) {
  return absolutePath.replace(uploadDir, '').replace(/\\/g, '/');
}

/**
 * 파일 정보 포맷팅
 */
function formatFileInfo(file, req) {
  const protocol = req.protocol;
  const host = req.get('host');
  const relativePath = getRelativePath(file.path);

  return {
    filename: file.filename,
    originalName: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
    path: relativePath,
    url: `${protocol}://${host}/uploads${relativePath}`,
  };
}

module.exports = {
  uploadSingle,
  uploadMultiple,
  deleteFile,
  formatFileInfo,
};
