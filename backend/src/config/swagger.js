const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Fire Safety Inspection API',
      version: '1.0.0',
      description: '소방 안전 점검 앱을 위한 REST API',
      contact: {
        name: 'Fire Safety Team',
        email: 'contact@firesafety.kr',
      },
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: '로컬 개발 서버',
      },
      {
        url: 'http://ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com:3000',
        description: 'AWS EC2 프로덕션 서버',
      },
    ],
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Building: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            building_name: { type: 'string', example: '현대자동차 건물' },
            category: { type: 'string', example: '[개황] 현대자동차 건물' },
            region_sido: { type: 'string', example: '서울특별시' },
            region_sigungu: { type: 'string', example: '도봉구' },
            region_dong: { type: 'string', example: '방학동' },
            address_jibun: { type: 'string', example: '서울특별시 도봉구 방학동 670-10' },
            address_road: { type: 'string', example: '서울특별시 도봉구 방학로 165' },
            fire_station: { type: 'string', example: '도봉소방서' },
            grade_level: { type: 'string', example: '3급대상' },
            total_area: { type: 'number', example: 1258.8 },
            floor_above: { type: 'integer', example: 6 },
            floor_below: { type: 'integer', example: 1 },
            has_sprinkler: { type: 'string', enum: ['Y', 'N'], example: 'N' },
            has_smoke_control: { type: 'string', enum: ['Y', 'N'], example: 'N' },
            requires_self_inspection: { type: 'string', enum: ['Y', 'N'], example: 'Y' },
          },
        },
        Inspection: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            building_id: { type: 'integer', example: 1 },
            inspector_id: { type: 'integer', example: 1 },
            inspection_type: { type: 'string', example: '정기' },
            inspection_date: { type: 'string', format: 'date', example: '2025-11-14' },
            overall_status: { type: 'string', example: '정상' },
            status: { type: 'string', enum: ['draft', 'completed', 'submitted', 'approved'], example: 'completed' },
            notes: { type: 'string', example: '전반적으로 양호함' },
          },
        },
        InspectionItem: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            inspection_id: { type: 'integer', example: 1 },
            category: { type: 'string', example: '소화기' },
            item_title: { type: 'string', example: '소화기: 위치 표시' },
            status: { type: 'string', enum: ['normal', 'defective', 'not_applicable'], example: 'normal' },
            memo: { type: 'string', example: '위치 표시 명확함' },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer', example: 1 },
            email: { type: 'string', example: 'inspector@firesafety.kr' },
            name: { type: 'string', example: '김점검' },
            role: { type: 'string', enum: ['admin', 'inspector', 'viewer'], example: 'inspector' },
            organization: { type: 'string', example: '서울소방청' },
            fire_station: { type: 'string', example: '도봉소방서' },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: '오류가 발생했습니다' },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: '인증 관련 API' },
      { name: 'Buildings', description: '건물 관리 API' },
      { name: 'Inspections', description: '점검 관리 API' },
      { name: 'Users', description: '사용자 관리 API' },
      { name: 'Sync', description: '데이터 동기화 API' },
      { name: 'Upload', description: '파일 업로드 API' },
    ],
  },
  apis: ['./src/routes/*.js'], // API 문서가 포함된 파일 경로
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
