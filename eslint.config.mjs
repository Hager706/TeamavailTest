// eslint.config.mjs
import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,

  // Node + Jest (server code, tests)
  {
    files: ["server.js", "jest.config.js", "tests/**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script", // CommonJS
      globals: {
        ...globals.node,
        ...globals.jest,
      },
    },
  },

  // Browser code (frontend scripts in /public)
  {
    files: ["public/**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script",
      globals: {
        ...globals.browser, // adds document, alert, window, etc.
      },
    },
  },
];