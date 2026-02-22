import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";

export default defineConfig({
  plugins: [react()],
  test: {
    name: "component",
    environment: "jsdom",
    globals: true,
    include: ["src/**/*.component.test.tsx"],
    setupFiles: ["src/test/setup.component.ts"],
  },
});
