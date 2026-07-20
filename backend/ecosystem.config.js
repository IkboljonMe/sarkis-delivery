module.exports = {
  apps: [
    {
      name: 'sarkis-backend',
      script: 'dist/src/main.js',
      instances: 1, // Set to 'max' if you want to use all CPU cores (Cluster mode)
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000, 
      }
    }
  ]
};
