// vite.config.ts
import { defineConfig } from "file:///home/project/node_modules/vite/dist/node/index.js";
import react from "file:///home/project/node_modules/@vitejs/plugin-react/dist/index.mjs";
import { copyFileSync, readdirSync, statSync } from "fs";
import { join } from "path";
function safePublicCopy() {
  return {
    name: "safe-public-copy",
    closeBundle() {
      const publicDir = "public";
      const outDir = "dist";
      try {
        const files = readdirSync(publicDir);
        files.forEach((file) => {
          if (file.includes(" ")) {
            return;
          }
          const srcPath = join(publicDir, file);
          const destPath = join(outDir, file);
          try {
            const stat = statSync(srcPath);
            if (stat.isFile() && stat.size > 0) {
              copyFileSync(srcPath, destPath);
            }
          } catch (err) {
          }
        });
      } catch (err) {
      }
    }
  };
}
var vite_config_default = defineConfig({
  plugins: [react(), safePublicCopy()],
  optimizeDeps: {
    exclude: ["lucide-react"]
  },
  publicDir: "public"
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvaG9tZS9wcm9qZWN0XCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCIvaG9tZS9wcm9qZWN0L3ZpdGUuY29uZmlnLnRzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9ob21lL3Byb2plY3Qvdml0ZS5jb25maWcudHNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJztcbmltcG9ydCByZWFjdCBmcm9tICdAdml0ZWpzL3BsdWdpbi1yZWFjdCc7XG5pbXBvcnQgeyBjb3B5RmlsZVN5bmMsIHJlYWRkaXJTeW5jLCBzdGF0U3luYyB9IGZyb20gJ2ZzJztcbmltcG9ydCB7IGpvaW4gfSBmcm9tICdwYXRoJztcblxuZnVuY3Rpb24gc2FmZVB1YmxpY0NvcHkoKSB7XG4gIHJldHVybiB7XG4gICAgbmFtZTogJ3NhZmUtcHVibGljLWNvcHknLFxuICAgIGNsb3NlQnVuZGxlKCkge1xuICAgICAgY29uc3QgcHVibGljRGlyID0gJ3B1YmxpYyc7XG4gICAgICBjb25zdCBvdXREaXIgPSAnZGlzdCc7XG5cbiAgICAgIHRyeSB7XG4gICAgICAgIGNvbnN0IGZpbGVzID0gcmVhZGRpclN5bmMocHVibGljRGlyKTtcbiAgICAgICAgZmlsZXMuZm9yRWFjaChmaWxlID0+IHtcbiAgICAgICAgICAvLyBTa2lwIGZpbGVzIHdpdGggc3BhY2VzIGluIHRoZSBuYW1lXG4gICAgICAgICAgaWYgKGZpbGUuaW5jbHVkZXMoJyAnKSkge1xuICAgICAgICAgICAgcmV0dXJuO1xuICAgICAgICAgIH1cblxuICAgICAgICAgIGNvbnN0IHNyY1BhdGggPSBqb2luKHB1YmxpY0RpciwgZmlsZSk7XG4gICAgICAgICAgY29uc3QgZGVzdFBhdGggPSBqb2luKG91dERpciwgZmlsZSk7XG5cbiAgICAgICAgICB0cnkge1xuICAgICAgICAgICAgY29uc3Qgc3RhdCA9IHN0YXRTeW5jKHNyY1BhdGgpO1xuICAgICAgICAgICAgaWYgKHN0YXQuaXNGaWxlKCkgJiYgc3RhdC5zaXplID4gMCkge1xuICAgICAgICAgICAgICBjb3B5RmlsZVN5bmMoc3JjUGF0aCwgZGVzdFBhdGgpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0gY2F0Y2ggKGVycikge1xuICAgICAgICAgICAgLy8gU2tpcCBmaWxlcyB0aGF0IGNhdXNlIGVycm9yc1xuICAgICAgICAgIH1cbiAgICAgICAgfSk7XG4gICAgICB9IGNhdGNoIChlcnIpIHtcbiAgICAgICAgLy8gU2tpcCBpZiBwdWJsaWMgZGlyIGRvZXNuJ3QgZXhpc3RcbiAgICAgIH1cbiAgICB9XG4gIH07XG59XG5cbmV4cG9ydCBkZWZhdWx0IGRlZmluZUNvbmZpZyh7XG4gIHBsdWdpbnM6IFtyZWFjdCgpLCBzYWZlUHVibGljQ29weSgpXSxcbiAgb3B0aW1pemVEZXBzOiB7XG4gICAgZXhjbHVkZTogWydsdWNpZGUtcmVhY3QnXSxcbiAgfSxcbiAgcHVibGljRGlyOiAncHVibGljJyxcbn0pO1xuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUF5TixTQUFTLG9CQUFvQjtBQUN0UCxPQUFPLFdBQVc7QUFDbEIsU0FBUyxjQUFjLGFBQWEsZ0JBQWdCO0FBQ3BELFNBQVMsWUFBWTtBQUVyQixTQUFTLGlCQUFpQjtBQUN4QixTQUFPO0FBQUEsSUFDTCxNQUFNO0FBQUEsSUFDTixjQUFjO0FBQ1osWUFBTSxZQUFZO0FBQ2xCLFlBQU0sU0FBUztBQUVmLFVBQUk7QUFDRixjQUFNLFFBQVEsWUFBWSxTQUFTO0FBQ25DLGNBQU0sUUFBUSxVQUFRO0FBRXBCLGNBQUksS0FBSyxTQUFTLEdBQUcsR0FBRztBQUN0QjtBQUFBLFVBQ0Y7QUFFQSxnQkFBTSxVQUFVLEtBQUssV0FBVyxJQUFJO0FBQ3BDLGdCQUFNLFdBQVcsS0FBSyxRQUFRLElBQUk7QUFFbEMsY0FBSTtBQUNGLGtCQUFNLE9BQU8sU0FBUyxPQUFPO0FBQzdCLGdCQUFJLEtBQUssT0FBTyxLQUFLLEtBQUssT0FBTyxHQUFHO0FBQ2xDLDJCQUFhLFNBQVMsUUFBUTtBQUFBLFlBQ2hDO0FBQUEsVUFDRixTQUFTLEtBQUs7QUFBQSxVQUVkO0FBQUEsUUFDRixDQUFDO0FBQUEsTUFDSCxTQUFTLEtBQUs7QUFBQSxNQUVkO0FBQUEsSUFDRjtBQUFBLEVBQ0Y7QUFDRjtBQUVBLElBQU8sc0JBQVEsYUFBYTtBQUFBLEVBQzFCLFNBQVMsQ0FBQyxNQUFNLEdBQUcsZUFBZSxDQUFDO0FBQUEsRUFDbkMsY0FBYztBQUFBLElBQ1osU0FBUyxDQUFDLGNBQWM7QUFBQSxFQUMxQjtBQUFBLEVBQ0EsV0FBVztBQUNiLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
