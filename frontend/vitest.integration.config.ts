import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";

export default defineConfig({
  plugins: [react()],
  test: {
    name: "integration",
    environment: "jsdom",
    globals: true,
    include: ["src/**/*.integration.test.ts?(x)"],
    setupFiles: ["src/test/setup.integration.ts"],
    testTimeout: 15_000,
    hookTimeout: 15_000,
  },
});
