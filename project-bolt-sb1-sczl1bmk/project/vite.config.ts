import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { copyFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

function safePublicCopy() {
  return {
    name: 'safe-public-copy',
    closeBundle() {
      const publicDir = 'public';
      const outDir = 'dist';

      try {
        const files = readdirSync(publicDir);
        files.forEach(file => {
          // Skip files with spaces in the name
          if (file.includes(' ')) {
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
            // Skip files that cause errors
          }
        });
      } catch (err) {
        // Skip if public dir doesn't exist
      }
    }
  };
}

export default defineConfig({
  plugins: [react(), safePublicCopy()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  publicDir: 'public',
});
