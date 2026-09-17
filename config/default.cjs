const defaultBase = 'mongodb://localhost:27017';

/**
 * Build a mongo connection string that keeps auth/host intact and selects the CE database.
 * Avoid String#replace(/\/[^/]*$/, '') which strips the authority from URIs that have no DB path
 * (e.g. mongodb://user:pass@host:27017 → mongodb:/).
 */
function resolveMongo(uri) {
  const dbName = process.env.TEST_SUITE ? 'formio-ce-test' : 'formio-ce';
  const base = uri || defaultBase;
  const match = base.match(/^(mongodb(?:\+srv)?:\/\/[^/?#]+)(?:\/[^?]*)?(\?.*)?$/i);
  if (match) {
    return `${match[1]}/${dbName}${match[2] || ''}`;
  }
  return `${defaultBase}/${dbName}`;
}

module.exports = {
  port: Number(process.env.PORT) || 3001,
  appPort: 8080,
  host: 'localhost:3001',
  protocol: 'http',
  allowedOrigins: ['*'],
  domain: 'http://localhost:3001',
  basePath: '',
  mongo: resolveMongo(process.env.MONGO),
  mongoConfig: '',
  mongoCA: '',
  mongoSecret: '--- change me now ---',
  reservedForms: [
    'submissions',
    'submission',
    'exists',
    'export',
    'role',
    'current',
    'logout',
    'import',
    'form',
    'access',
    'token',
    'recaptcha',
    'captcha',
  ],
  jwt: {
    secret: '--- change me now ---',
    expireTime: 240,
  },
  email: {
    type: 'sendgrid',
    username: 'sendgrid-user',
    password: 'sendgrid-pass',
  },
  settings: {
    office365: {
      tenant: '',
      clientId: '',
      email: '',
      cert: '',
      thumbprint: '',
    },
    email: {
      gmail: {
        auth: {
          user: '',
          pass: '',
        },
      },
      sendgrid: {
        auth: {
          api_user: '',
          api_key: '',
        },
      },
    },
  },
};
