const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('Starting localtunnel on port 8080...');
const tunnel = exec('npx localtunnel --port 8080');

tunnel.stdout.on('data', (data) => {
  console.log(data.toString().trim());
  const match = data.toString().match(/your url is: (https:\/\/[^\s]+)/);
  if (match && match[1]) {
    const url = match[1];
    console.log(\n? Tunnel started successfully!);
    
    // Auto-update api_service.dart
    const apiServicePath = path.join(__dirname, '..', 'admin_app', 'lib', 'api_service.dart');
    if (fs.existsSync(apiServicePath)) {
      let content = fs.readFileSync(apiServicePath, 'utf8');
      content = content.replace(/static const String baseUrl = '.*';/, static const String baseUrl = ' + url + /api';);
      fs.writeFileSync(apiServicePath, content);
      console.log(? Automatically updated api_service.dart with the new URL!);
      console.log(?? Please do a Hot Restart in your Flutter app now.);
    }
  }
});

tunnel.stderr.on('data', (data) => {
  console.error(data.toString());
});

tunnel.on('close', (code) => {
  console.log(Tunnel closed with code  + code);
});
