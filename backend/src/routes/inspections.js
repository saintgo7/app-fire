const express = require('express');
const router = express.Router();
const { query, transaction, paginate } = require('../config/database');

/**
 * GET /api/inspections
 * 점검 목록 조회
 */
router.get('/', async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      building_id,
      inspector_id,
      status,
      date_from,
      date_to,
    } = req.query;

    const { limit: queryLimit, offset } = paginate(page, limit);
    const where = ['i.is_deleted = 0'];
    const params = [];

    if (building_id) {
      where.push('i.building_id = ?');
      params.push(building_id);
    }
    if (inspector_id) {
      where.push('i.inspector_id = ?');
      params.push(inspector_id);
    }
    if (status) {
      where.push('i.status = ?');
      params.push(status);
    }
    if (date_from) {
      where.push('i.inspection_date >= ?');
      params.push(date_from);
    }
    if (date_to) {
      where.push('i.inspection_date <= ?');
      params.push(date_to);
    }

    const whereClause = where.join(' AND ');

    // 총 개수
    const countResult = await query(
      `SELECT COUNT(*) as total FROM inspections i WHERE ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    // 데이터 조회 (건물명, 점검자명 포함)
    const inspections = await query(
      `SELECT
        i.*,
        b.building_name,
        b.address_road,
        u.name as inspector_name
       FROM inspections i
       LEFT JOIN buildings b ON i.building_id = b.id
       LEFT JOIN users u ON i.inspector_id = u.id
       WHERE ${whereClause}
       ORDER BY i.inspection_date DESC, i.created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, queryLimit, offset]
    );

    res.json({
      success: true,
      data: inspections,
      pagination: {
        page: parseInt(page),
        limit: queryLimit,
        total,
        totalPages: Math.ceil(total / queryLimit),
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/inspections/:id
 * 점검 상세 조회 (항목 및 사진 포함)
 */
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // 점검 기본 정보
    const inspections = await query(
      `SELECT
        i.*,
        b.building_name,
        b.address_road,
        b.fire_station,
        u.name as inspector_name,
        u.email as inspector_email
       FROM inspections i
       LEFT JOIN buildings b ON i.building_id = b.id
       LEFT JOIN users u ON i.inspector_id = u.id
       WHERE i.id = ? AND i.is_deleted = 0`,
      [id]
    );

    if (inspections.length === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없습니다',
      });
    }

    // 점검 항목
    const items = await query(
      `SELECT * FROM inspection_items WHERE inspection_id = ? ORDER BY item_order, id`,
      [id]
    );

    // 각 항목별 사진
    for (const item of items) {
      const photos = await query(
        `SELECT * FROM inspection_photos WHERE inspection_item_id = ? ORDER BY created_at`,
        [item.id]
      );
      item.photos = photos;
    }

    res.json({
      success: true,
      data: {
        ...inspections[0],
        items,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/inspections
 * 새 점검 생성 (항목 포함)
 */
router.post('/', async (req, res, next) => {
  try {
    const { building_id, inspector_id, inspection_type, inspection_date, items } = req.body;

    const result = await transaction(async (conn) => {
      // 점검 생성
      const inspectionResult = await conn.query(
        `INSERT INTO inspections (building_id, inspector_id, inspection_type, inspection_date, started_at, status)
         VALUES (?, ?, ?, ?, NOW(), 'draft')`,
        [building_id, inspector_id, inspection_type, inspection_date]
      );

      const inspectionId = Number(inspectionResult.insertId);

      // 점검 항목 생성
      if (items && items.length > 0) {
        for (let i = 0; i < items.length; i++) {
          const item = items[i];
          await conn.query(
            `INSERT INTO inspection_items (inspection_id, category, item_title, item_order, status, memo)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [inspectionId, item.category, item.item_title, i + 1, item.status, item.memo]
          );
        }
      }

      return inspectionId;
    });

    res.status(201).json({
      success: true,
      data: {
        id: result,
        building_id,
        inspection_type,
        inspection_date,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/inspections/:id
 * 점검 수정
 */
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { overall_status, notes, status } = req.body;

    const result = await query(
      `UPDATE inspections SET
        overall_status = ?,
        notes = ?,
        status = ?,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ? AND is_deleted = 0`,
      [overall_status, notes, status, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '점검이 수정되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/inspections/:id/complete
 * 점검 완료 처리
 */
router.put('/:id/complete', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      `UPDATE inspections SET
        status = 'completed',
        completed_at = NOW(),
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ? AND is_deleted = 0`,
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '점검이 완료되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/inspections/:id/items/:itemId
 * 점검 항목 업데이트
 */
router.put('/:id/items/:itemId', async (req, res, next) => {
  try {
    const { itemId } = req.params;
    const { status, memo } = req.body;

    const result = await query(
      `UPDATE inspection_items SET
        status = ?,
        memo = ?,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [status, memo, itemId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검 항목을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '점검 항목이 수정되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * DELETE /api/inspections/:id
 * 점검 삭제 (soft delete)
 */
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      'UPDATE inspections SET is_deleted = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '점검이 삭제되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/inspections/:id/statistics
 * 점검 통계 (정상/불량/해당없음 개수)
 */
router.get('/:id/statistics', async (req, res, next) => {
  try {
    const { id } = req.params;

    const stats = await query(
      `SELECT
        COUNT(*) as total_items,
        SUM(CASE WHEN status = 'normal' THEN 1 ELSE 0 END) as normal_count,
        SUM(CASE WHEN status = 'defective' THEN 1 ELSE 0 END) as defective_count,
        SUM(CASE WHEN status = 'not_applicable' THEN 1 ELSE 0 END) as na_count,
        SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) as unchecked_count
       FROM inspection_items
       WHERE inspection_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: stats[0],
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
