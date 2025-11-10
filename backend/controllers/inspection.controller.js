const { pool } = require('../config/database');

// 점검 목록 조회
exports.getInspections = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status, startDate, endDate, limit = 20, offset = 0 } = req.query;

    let query = `
      SELECT i.*, b.name as building_name, b.address as building_address
      FROM inspections i
      LEFT JOIN buildings b ON i.building_id = b.id
      WHERE i.user_id = ?
    `;
    const params = [userId];

    if (status) {
      query += ' AND i.status = ?';
      params.push(status);
    }

    if (startDate && endDate) {
      query += ' AND i.inspection_date BETWEEN ? AND ?';
      params.push(startDate, endDate);
    }

    query += ' ORDER BY i.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [inspections] = await pool.query(query, params);

    res.json({
      success: true,
      data: inspections,
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset)
      }
    });
  } catch (error) {
    console.error('점검 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '점검 목록을 가져오는 중 오류가 발생했습니다.'
    });
  }
};

// 특정 점검 조회
exports.getInspectionById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const [inspections] = await pool.query(
      `SELECT i.*, b.name as building_name, b.address as building_address
       FROM inspections i
       LEFT JOIN buildings b ON i.building_id = b.id
       WHERE i.id = ? AND i.user_id = ?`,
      [id, userId]
    );

    if (inspections.length === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없습니다.'
      });
    }

    // 체크리스트 항목 조회
    const [checklistItems] = await pool.query(
      `SELECT c.*, GROUP_CONCAT(p.photo_url) as photos
       FROM checklist_items c
       LEFT JOIN inspection_photos p ON c.id = p.checklist_item_id
       WHERE c.inspection_id = ?
       GROUP BY c.id
       ORDER BY c.order_index`,
      [id]
    );

    const inspection = {
      ...inspections[0],
      checklist: checklistItems.map(item => ({
        ...item,
        photos: item.photos ? item.photos.split(',') : []
      }))
    };

    res.json({
      success: true,
      data: inspection
    });
  } catch (error) {
    console.error('점검 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '점검을 가져오는 중 오류가 발생했습니다.'
    });
  }
};

// 점검 생성
exports.createInspection = async (req, res) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const userId = req.user.userId;
    const {
      buildingId,
      inspectionDate,
      inspectorName,
      inspectionType,
      notes,
      checklist
    } = req.body;

    // 점검 생성
    const [result] = await connection.query(
      `INSERT INTO inspections (user_id, building_id, inspection_date, inspector_name, inspection_type, notes, status)
       VALUES (?, ?, ?, ?, ?, ?, 'in_progress')`,
      [userId, buildingId, inspectionDate, inspectorName, inspectionType, notes]
    );

    const inspectionId = result.insertId;

    // 체크리스트 항목 추가
    if (checklist && checklist.length > 0) {
      for (let i = 0; i < checklist.length; i++) {
        const item = checklist[i];
        await connection.query(
          `INSERT INTO checklist_items (inspection_id, category, title, description, status, memo, order_index)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [inspectionId, item.category, item.title, item.description, item.status, item.memo, i]
        );
      }
    }

    await connection.commit();

    res.status(201).json({
      success: true,
      message: '점검이 생성되었습니다.',
      data: { id: inspectionId }
    });
  } catch (error) {
    await connection.rollback();
    console.error('점검 생성 오류:', error);
    res.status(500).json({
      success: false,
      message: '점검 생성 중 오류가 발생했습니다.'
    });
  } finally {
    connection.release();
  }
};

// 점검 업데이트
exports.updateInspection = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const { status, overallResult, notes } = req.body;

    const [result] = await pool.query(
      `UPDATE inspections
       SET status = ?, overall_result = ?, notes = ?, updated_at = NOW()
       WHERE id = ? AND user_id = ?`,
      [status, overallResult, notes, id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없거나 권한이 없습니다.'
      });
    }

    res.json({
      success: true,
      message: '점검이 업데이트되었습니다.'
    });
  } catch (error) {
    console.error('점검 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      message: '점검 업데이트 중 오류가 발생했습니다.'
    });
  }
};

// 점검 삭제
exports.deleteInspection = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const [result] = await pool.query(
      'DELETE FROM inspections WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '점검을 찾을 수 없거나 권한이 없습니다.'
      });
    }

    res.json({
      success: true,
      message: '점검이 삭제되었습니다.'
    });
  } catch (error) {
    console.error('점검 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '점검 삭제 중 오류가 발생했습니다.'
    });
  }
};

// 체크리스트 항목 조회
exports.getChecklistItems = async (req, res) => {
  try {
    const { id } = req.params;

    const [items] = await pool.query(
      'SELECT * FROM checklist_items WHERE inspection_id = ? ORDER BY order_index',
      [id]
    );

    res.json({
      success: true,
      data: items
    });
  } catch (error) {
    console.error('체크리스트 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '체크리스트를 가져오는 중 오류가 발생했습니다.'
    });
  }
};

// 체크리스트 항목 추가
exports.addChecklistItem = async (req, res) => {
  try {
    const { id } = req.params;
    const { category, title, description, status, memo } = req.body;

    const [result] = await pool.query(
      `INSERT INTO checklist_items (inspection_id, category, title, description, status, memo)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id, category, title, description, status, memo]
    );

    res.status(201).json({
      success: true,
      message: '체크리스트 항목이 추가되었습니다.',
      data: { id: result.insertId }
    });
  } catch (error) {
    console.error('체크리스트 추가 오류:', error);
    res.status(500).json({
      success: false,
      message: '체크리스트 추가 중 오류가 발생했습니다.'
    });
  }
};

// 체크리스트 항목 업데이트
exports.updateChecklistItem = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { status, memo } = req.body;

    const [result] = await pool.query(
      'UPDATE checklist_items SET status = ?, memo = ?, updated_at = NOW() WHERE id = ?',
      [status, memo, itemId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '체크리스트 항목을 찾을 수 없습니다.'
      });
    }

    res.json({
      success: true,
      message: '체크리스트 항목이 업데이트되었습니다.'
    });
  } catch (error) {
    console.error('체크리스트 업데이트 오류:', error);
    res.status(500).json({
      success: false,
      message: '체크리스트 업데이트 중 오류가 발생했습니다.'
    });
  }
};

// 체크리스트 항목 삭제
exports.deleteChecklistItem = async (req, res) => {
  try {
    const { itemId } = req.params;

    const [result] = await pool.query(
      'DELETE FROM checklist_items WHERE id = ?',
      [itemId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '체크리스트 항목을 찾을 수 없습니다.'
      });
    }

    res.json({
      success: true,
      message: '체크리스트 항목이 삭제되었습니다.'
    });
  } catch (error) {
    console.error('체크리스트 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '체크리스트 삭제 중 오류가 발생했습니다.'
    });
  }
};

// 사진 업로드 (기본 구현 - multer 설정 필요)
exports.uploadPhoto = async (req, res) => {
  res.status(501).json({
    success: false,
    message: '사진 업로드 기능은 multer 설정 후 구현됩니다.'
  });
};

// 사진 삭제
exports.deletePhoto = async (req, res) => {
  try {
    const { photoId } = req.params;

    const [result] = await pool.query(
      'DELETE FROM inspection_photos WHERE id = ?',
      [photoId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: '사진을 찾을 수 없습니다.'
      });
    }

    res.json({
      success: true,
      message: '사진이 삭제되었습니다.'
    });
  } catch (error) {
    console.error('사진 삭제 오류:', error);
    res.status(500).json({
      success: false,
      message: '사진 삭제 중 오류가 발생했습니다.'
    });
  }
};
