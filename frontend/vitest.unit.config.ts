import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";

export default defineConfig({
  plugins: [react()],
  test: {
    name: "unit",
    environment: "node",
    globals: true,
    include: ["src/**/*.unit.test.ts"],
  },
});
