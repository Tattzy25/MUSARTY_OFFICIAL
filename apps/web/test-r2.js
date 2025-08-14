const fs = require('fs');

// Load environment variables from .env.local
const envContent = fs.readFileSync('.env.local', 'utf8');
const envVars = {};
envContent.split('\n').forEach(line => {
  const match = line.match(/^([^#][^=]*)=(.*)$/);
  if (match) {
    envVars[match[1]] = match[2].replace(/^"|"$/g, '');
  }
});

const accessKeyId = envVars.R2_ACCESS_KEY_ID;
const secretAccessKey = envVars.R2_SECRET_ACCESS_KEY;
const accountId = envVars.CLOUDFLARE_ACCOUNT_ID;
const bucketName = 'components-code';

console.log('🔍 Cloudflare R2 Configuration Analysis');
console.log('=' .repeat(50));
console.log(`Account ID: ${accountId}`);
console.log(`Access Key ID: ${accessKeyId}`);
console.log(`Access Key Length: ${accessKeyId ? accessKeyId.length : 'undefined'} characters`);
console.log(`Secret Key Length: ${secretAccessKey ? secretAccessKey.length : 'undefined'} characters`);
console.log(`Bucket: ${bucketName}`);
console.log('');

// Validate credentials format
let hasErrors = false;

if (!accessKeyId) {
  console.log('❌ R2_ACCESS_KEY_ID is missing');
  hasErrors = true;
} else if (accessKeyId.length !== 32) {
  console.log(`❌ R2_ACCESS_KEY_ID has invalid length: ${accessKeyId.length} (should be 32)`);
  console.log('   This suggests the access key is incomplete or corrupted.');
  hasErrors = true;
} else {
  console.log('✅ R2_ACCESS_KEY_ID format looks correct');
}

if (!secretAccessKey) {
  console.log('❌ R2_SECRET_ACCESS_KEY is missing');
  hasErrors = true;
} else if (secretAccessKey.length !== 64) {
  console.log(`❌ R2_SECRET_ACCESS_KEY has invalid length: ${secretAccessKey.length} (should be 64)`);
  console.log('   This suggests the secret key is incomplete or corrupted.');
  hasErrors = true;
} else {
  console.log('✅ R2_SECRET_ACCESS_KEY format looks correct');
}

if (!accountId) {
  console.log('❌ CLOUDFLARE_ACCOUNT_ID is missing');
  hasErrors = true;
} else if (accountId.length !== 32) {
  console.log(`❌ CLOUDFLARE_ACCOUNT_ID has invalid length: ${accountId.length} (should be 32)`);
  hasErrors = true;
} else {
  console.log('✅ CLOUDFLARE_ACCOUNT_ID format looks correct');
}

console.log('');

if (hasErrors) {
  console.log('🚨 CONFIGURATION ISSUES DETECTED');
  console.log('=' .repeat(50));
  console.log('The R2 credentials in your .env.local file appear to be invalid.');
  console.log('');
  console.log('📋 To fix this issue:');
  console.log('1. Go to Cloudflare Dashboard > R2 Object Storage > Manage R2 API tokens');
  console.log('2. Click "Create API token"');
  console.log('3. Select "Custom token"');
  console.log('4. Set permissions: "Object Read and Write" for bucket "components-code"');
  console.log('5. Copy the FULL Access Key ID (32 characters) and Secret Access Key (64 characters)');
  console.log('6. Update your .env.local file with the complete credentials');
  console.log('');
  console.log('⚠️  Make sure you copy the entire key without truncation!');
} else {
  console.log('✅ All credential formats look correct!');
  console.log('If you\'re still having issues, the credentials might be expired or have insufficient permissions.');
}

console.log('');
console.log('🔧 Next steps:');
console.log('- Verify credentials in Cloudflare Dashboard');
console.log('- Ensure the API token has "Object Read and Write" permissions');
console.log('- Check that the bucket "components-code" exists');
console.log('- Re-run this test after updating credentials');