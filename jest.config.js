module.exports = {
      testEnvironment: 'node',
      collectCoverage: true,
      coverageDirectory: 'coverage',
      coverageReporters: ['text', 'lcov', 'html'],
      testMatch: ['**/test/**/*.js', '**/?(*.)+(spec|test).js'],
      verbose: true,
      setupFilesAfterEnv: ['<rootDir>/test/setup.js']
    };