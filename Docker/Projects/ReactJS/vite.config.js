import react from "@vitejs/plugin-react";
import path from "path";
import { defineConfig } from "vite";
import svgr from "vite-plugin-svgr";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), svgr()],
  server: {
    hmr: {
      overlay: false, // HMR overlay를 비활성화하여 리렌더링 줄이기
    },
    host: "0.0.0.0",
    port: 5173,
    open: true,
  },
  build: {
    outDir: "dist",
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, "index.html"),
      },
      output: {
        assetFileNames: (assetInfo) => {
          if (/\.(gif|jpe?g|png|svg)$/.test(assetInfo.name)) {
            return "assets/images/[name]-[hash][extname]";
          }
          if (/\.css$/.test(assetInfo.name)) {
            return "assets/css/[name]-[hash][extname]";
          }
          return "assets/[name]-[hash][extname]";
        },
      },
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src"),
    },
  },
});
