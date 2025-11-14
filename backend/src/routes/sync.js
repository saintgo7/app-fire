const express = require('express');
const router = express.Router();
const { query, transaction } = require('../config/database');

/**
 * POST /api/sync/inspections
 * 앱에서 점검 데이터 동기화
 */
router.post('/inspections', async (req, res, next) => {
  try {
    const { inspections } = req.body;

    if (!Array.isArray(inspections)) {
      return res.status(400).json({
        success: false,
        message: 'inspections는 배열이어야 합니다',
      });
    }

    const syncedIds = [];

    for (const inspection of inspections) {
      try {
        await transaction(async (conn) => {
          // 점검 upsert
          const result = await conn.query(
            `INSERT INTO inspections (
              id, building_id, inspector_id, inspection_type, inspection_date,
              started_at, completed_at, overall_status, notes, status,
              created_at, updated_at, synced_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE
              overall_status = VALUES(overall_status),
              notes = VALUES(notes),
              status = VALUES(status),
              updated_at = VALUES(updated_at),
              synced_at = NOW()`,
            [
              inspection.id,
              inspection.building_id,
              inspection.inspector_id,
              inspection.inspection_type,
              inspection.inspection_date,
              inspection.started_at,
              inspection.completed_at,
              inspection.overall_status,
              inspection.notes,
              inspection.status,
              inspection.created_at,
              inspection.updated_at,
            ]
          );

          const inspectionId = inspection.id || Number(result.insertId);

          // 점검 항목 동기화
          if (inspection.items && Array.isArray(inspection.items)) {
            for (const item of inspection.items) {
              await conn.query(
                `INSERT INTO inspection_items (
                  id, inspection_id, category, item_title, item_order, status, memo
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                  status = VALUES(status),
                  memo = VALUES(memo),
                  updated_at = NOW()`,
                [
                  item.id,
                  inspectionId,
                  item.category,
                  item.item_title,
                  item.item_order,
                  item.status,
                  item.memo,
                ]
              );
            }
          }

          syncedIds.push(inspectionId);
        });
      } catch (err) {
        console.error('Sync error for inspection:', inspection.id, err.message);
      }
    }

    res.json({
      success: true,
      message: `${syncedIds.length}개의 점검이 동기화되었습니다`,
      data: { syncedIds },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/sync/buildings
 * 앱으로 건물 데이터 다운로드 (특정 지역)
 */
router.get('/buildings', async (req, res, next) => {
  try {
    const { sido, sigungu, fire_station, updated_after } = req.query;

    const where = ['is_deleted = 0'];
    const params = [];

    if (sido) {
      where.push('region_sido = ?');
      params.push(sido);
    }
    if (sigungu) {
      where.push('region_sigungu = ?');
      params.push(sigungu);
    }
    if (fire_station) {
      where.push('fire_station = ?');
      params.push(fire_station);
    }
    if (updated_after) {
      where.push('updated_at > ?');
      params.push(updated_after);
    }

    const buildings = await query(
      `SELECT * FROM buildings WHERE ${where.join(' AND ')} ORDER BY id`,
      params
    );

    res.json({
      success: true,
      data: buildings,
      total: buildings.length,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
