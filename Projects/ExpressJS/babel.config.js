module.exports = {
  presets: ["@babel/env"],
  plugins:
    process.env.NODE_ENV === "production" ? ["@babel/plugin-transform-runtime"] : ["@babel/plugin-transform-runtime"],
  ignore: ["./src/public/**/*.js"],
};
