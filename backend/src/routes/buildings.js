const express = require('express');
const router = express.Router();
const { query, paginate } = require('../config/database');

/**
 * GET /api/buildings
 * 건물 목록 조회 (페이지네이션, 필터링)
 */
router.get('/', async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      sido,
      sigungu,
      dong,
      fire_station,
      search,
      grade_level,
      self_inspection,
    } = req.query;

    const { limit: queryLimit, offset } = paginate(page, limit);
    const where = ['is_deleted = 0'];
    const params = [];

    // 필터 조건 추가
    if (sido) {
      where.push('region_sido = ?');
      params.push(sido);
    }
    if (sigungu) {
      where.push('region_sigungu = ?');
      params.push(sigungu);
    }
    if (dong) {
      where.push('region_dong = ?');
      params.push(dong);
    }
    if (fire_station) {
      where.push('fire_station = ?');
      params.push(fire_station);
    }
    if (grade_level) {
      where.push('grade_level = ?');
      params.push(grade_level);
    }
    if (self_inspection) {
      where.push('requires_self_inspection = ?');
      params.push(self_inspection);
    }
    if (search) {
      where.push('(building_name LIKE ? OR address_jibun LIKE ? OR address_road LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    const whereClause = where.join(' AND ');

    // 총 개수 조회
    const countResult = await query(
      `SELECT COUNT(*) as total FROM buildings WHERE ${whereClause}`,
      params
    );
    const total = countResult[0].total;

    // 데이터 조회
    const buildings = await query(
      `SELECT * FROM buildings
       WHERE ${whereClause}
       ORDER BY building_name ASC
       LIMIT ? OFFSET ?`,
      [...params, queryLimit, offset]
    );

    res.json({
      success: true,
      data: buildings,
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
 * GET /api/buildings/:id
 * 특정 건물 상세 조회
 */
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const buildings = await query(
      'SELECT * FROM buildings WHERE id = ? AND is_deleted = 0',
      [id]
    );

    if (buildings.length === 0) {
      return res.status(404).json({
        success: false,
        message: '건물을 찾을 수 없습니다',
      });
    }

    // 최근 점검 이력도 함께 조회
    const recentInspections = await query(
      `SELECT id, inspection_type, inspection_date, overall_status, status
       FROM inspections
       WHERE building_id = ? AND is_deleted = 0
       ORDER BY inspection_date DESC
       LIMIT 5`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...buildings[0],
        recent_inspections: recentInspections,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/buildings
 * 새 건물 등록
 */
router.post('/', async (req, res, next) => {
  try {
    const buildingData = req.body;

    const result = await query(
      `INSERT INTO buildings (
        building_name, category, region_sido, region_sigungu, region_dong,
        address_jibun, address_road, latitude, longitude,
        main_usage, is_apartment, total_area, household_count,
        floor_above, floor_below, approval_date,
        has_sprinkler, has_smoke_control, has_water_spray,
        fire_station, is_tunnel, grade_level, requires_self_inspection
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        buildingData.building_name,
        buildingData.category,
        buildingData.region_sido,
        buildingData.region_sigungu,
        buildingData.region_dong,
        buildingData.address_jibun,
        buildingData.address_road,
        buildingData.latitude,
        buildingData.longitude,
        buildingData.main_usage,
        buildingData.is_apartment || 'N',
        buildingData.total_area,
        buildingData.household_count || 0,
        buildingData.floor_above || 0,
        buildingData.floor_below || 0,
        buildingData.approval_date,
        buildingData.has_sprinkler || 'N',
        buildingData.has_smoke_control || 'N',
        buildingData.has_water_spray || 'N',
        buildingData.fire_station,
        buildingData.is_tunnel || 'N',
        buildingData.grade_level,
        buildingData.requires_self_inspection || 'N',
      ]
    );

    res.status(201).json({
      success: true,
      data: {
        id: Number(result.insertId),
        ...buildingData,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/buildings/:id
 * 건물 정보 수정
 */
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const buildingData = req.body;

    const result = await query(
      `UPDATE buildings SET
        building_name = ?, category = ?, region_sido = ?, region_sigungu = ?, region_dong = ?,
        address_jibun = ?, address_road = ?, latitude = ?, longitude = ?,
        main_usage = ?, is_apartment = ?, total_area = ?, household_count = ?,
        floor_above = ?, floor_below = ?, approval_date = ?,
        has_sprinkler = ?, has_smoke_control = ?, has_water_spray = ?,
        fire_station = ?, is_tunnel = ?, grade_level = ?, requires_self_inspection = ?,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = ? AND is_deleted = 0`,
      [
        buildingData.building_name,
        buildingData.category,
        buildingData.region_sido,
        buildingData.region_sigungu,
        buildingData.region_dong,
        buildingData.address_jibun,
        buildingData.address_road,
        buildingData.latitude,
        buildingData.longitude,
        buildingData.main_usage,
        buildingData.is_apartment,
        buildingData.total_area,
        buildingData.household_count,
        buildingData.floor_above,
        buildingData.floor_below,
        buildingData.approval_date,
        buildingData.has_sprinkler,
        buildingData.has_smoke_control,
        buildingData.has_water_spray,
        buildingData.fire_station,
        buildingData.is_tunnel,
        buildingData.grade_level,
        buildingData.requires_self_inspection,
        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '건물을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '건물 정보가 수정되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * DELETE /api/buildings/:id
 * 건물 삭제 (soft delete)
 */
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      'UPDATE buildings SET is_deleted = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '건물을 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      message: '건물이 삭제되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/buildings/regions/sidos
 * 시/도 목록 조회
 */
router.get('/regions/sidos', async (req, res, next) => {
  try {
    const sidos = await query(
      `SELECT DISTINCT region_sido FROM buildings WHERE is_deleted = 0 ORDER BY region_sido`
    );

    res.json({
      success: true,
      data: sidos.map((row) => row.region_sido),
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/buildings/regions/sigungus
 * 시/군/구 목록 조회
 */
router.get('/regions/sigungus', async (req, res, next) => {
  try {
    const { sido } = req.query;

    let sql = `SELECT DISTINCT region_sigungu FROM buildings WHERE is_deleted = 0`;
    const params = [];

    if (sido) {
      sql += ` AND region_sido = ?`;
      params.push(sido);
    }

    sql += ` ORDER BY region_sigungu`;

    const sigungus = await query(sql, params);

    res.json({
      success: true,
      data: sigungus.map((row) => row.region_sigungu),
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
