module.exports = {
  env: {
    browser: true,
    node: true,
    commonjs: true,
    es2021: true,
    jest: true,
  },
  extends: ["eslint:recommended", "prettier", "plugin:prettier/recommended", "plugin:yaml/recommended"],
  plugins: ["prettier", "node", "import", "html", "yaml", "jest"],
  overrides: [
    {
      files: [".eslintrc.{js,cjs}"],
      parserOptions: {
        sourceType: "script",
      },
    },
  ],
  parserOptions: {
    ecmaVersion: "latest",
  },
  rules: {
    // "off" or 0 - turn the rule off
    // "warn" or 1 - turn the rule on as a warning (doesn’t affect exit code)
    // "error" or 2 - turn the rule on as an error (exit code is 1 when triggered)
    // "no-var": "off",

    indent: ["error", 2],
    semi: ["error", "always"],
    "prefer-arrow-callback": "error", // Require using arrow functions for callbacks
    "require-await": "off",
    "arrow-parens": "off", //["error", "as-needed"], // a => {}
    "no-unused-vars": "off",
    "no-param-reassign": ["error", { props: false }],
    "no-useless-escape": "off",
    "no-self-assign": "off",
    "no-unused-expressions": [
      "error",
      {
        allowTernary: true, // a || b
        allowShortCircuit: true, // a ? b : 0
        allowTaggedTemplates: true,
      },
    ],
    // "import/no-extraneous-dependencies": ["error", { "includeInternal": true,"devDependencies": false }],
    "import/no-extraneous-dependencies": "off",
    "max-len": [
      "error",
      {
        code: 120,
        ignoreComments: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
      },
    ], // prettier의 printWidth 옵션 대신 사용
  },
};
