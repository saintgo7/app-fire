module.exports = {
  apps: [
    {
      name: 'fire-inspector-api',
      script: './server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
      },
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      merge_logs: true,
      // 재시작 설정
      min_uptime: '10s',
      max_restarts: 10,
      // 크론 재시작 (매일 새벽 4시)
      cron_restart: '0 4 * * *',
    },
  ],
};
