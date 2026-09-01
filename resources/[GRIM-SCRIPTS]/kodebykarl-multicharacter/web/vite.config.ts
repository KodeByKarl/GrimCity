import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

function stripCrossOrigin() {
  return {
    name: 'strip-crossorigin',
    transformIndexHtml(html: string) {
      return html
        .replace(/\s+crossorigin(?:="[^"]*")?/g, '')
        .replace(/\s+crossorigin(?:=\{[^}]*\})?/g, '');
    },
  };
}

export default defineConfig({
  plugins: [react(), stripCrossOrigin()],
  base: './',
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    assetsDir: 'assets',
    cssCodeSplit: false,
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
});
