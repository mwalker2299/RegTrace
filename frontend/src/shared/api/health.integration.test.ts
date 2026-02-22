import { describe, it, expect } from "vitest";

type HealthResponse = {
  status: "ok";
};

// Sanity test used as first integration test to verify that the test setup is working correctly.
// Ideally, this would exercise actual frontend code that calls the health endpoint.
describe("health endpoint", () => {
  it("returns {status: ok}", async () => {
    const res = await fetch("/api/v1/healthz");

    expect(res.ok).toBe(true);

    const data = (await res.json()) as HealthResponse;
    expect(data.status).toEqual("ok");
  });
});
