const express = require('express');
const router = express.Router();
const inspectionController = require('../controllers/inspection.controller');
const { verifyToken } = require('../controllers/auth.controller');

// 모든 점검 라우트는 인증 필요
router.use(verifyToken);

// 점검 목록 조회
router.get('/', inspectionController.getInspections);

// 특정 점검 조회
router.get('/:id', inspectionController.getInspectionById);

// 점검 생성
router.post('/', inspectionController.createInspection);

// 점검 업데이트
router.put('/:id', inspectionController.updateInspection);

// 점검 삭제
router.delete('/:id', inspectionController.deleteInspection);

// 체크리스트 항목 관리
router.get('/:id/checklist', inspectionController.getChecklistItems);
router.post('/:id/checklist', inspectionController.addChecklistItem);
router.put('/:id/checklist/:itemId', inspectionController.updateChecklistItem);
router.delete('/:id/checklist/:itemId', inspectionController.deleteChecklistItem);

// 점검 사진 관리
router.post('/:id/photos', inspectionController.uploadPhoto);
router.delete('/:id/photos/:photoId', inspectionController.deletePhoto);

module.exports = router;
