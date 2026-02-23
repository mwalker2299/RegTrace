import { useState } from "react";

/**
 * NOTE (placeholder):
 * This is a deliberately simple, time-boxed ready-check implementation for the demo.
 * It calls the API directly from the component to prove the FE<->BE<->DB wiring quickly.
 *
 * How I'd actually do this (3-layer API approach):
 *
 * Layer 1: a single HTTP client (shared/api/client.ts)
 *   - Adds JWT header
 *   - Normalises errors
 *   - Parses JSON safely
 *
 * Layer 2: feature API modules (features/.../api.ts)
 *   - Define endpoint-specific request/response shapes (DTOs) and
 *     expose small functions that call the shared client (no React concerns).
 *
 * Layer 3: feature hooks (features/.../hooks.ts)
 *   - Provide React-friendly wrappers around feature API functions
 *     (loading/error state, caching/invalidation, and UI-oriented data shaping).
 */

type ReadyResponse = {
  status: string;
};

function joinUrl(base: string, path: string) {
  const b = base.replace(/\/+$/, "");
  const p = path.replace(/^\/+/, "");
  return `${b}/${p}`;
}

function App() {
  const apiBase = import.meta.env.VITE_API_BASE as string | undefined;

  const [statusText, setStatusText] = useState<string>("");
  const [errorText, setErrorText] = useState<string>("");
  const [loading, setLoading] = useState(false);

  const checkReady = async () => {
    setLoading(true);
    setErrorText("");
    setStatusText("");

    try {
      if (!apiBase) throw new Error("VITE_API_BASE is not set");

      const url = joinUrl(apiBase, "readyz");
      const res = await fetch(url, {
        method: "GET",
        headers: { Accept: "application/json" },
      });

      if (!res.ok) {
        throw new Error(`Ready check failed: ${res.status} ${res.statusText}`);
      }

      const data = (await res.json()) as ReadyResponse;
      setStatusText(data.status ?? "");
    } catch (e) {
      setErrorText(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  const handleReadyClick: React.MouseEventHandler<HTMLButtonElement> = () => {
    void checkReady();
  };

  return (
    <div style={{ padding: 16 }}>
      <h1>App</h1>

      <button onClick={handleReadyClick} disabled={loading || !apiBase}>
        {loading ? "Checking..." : "Check API readiness/DB availability"}
      </button>

      {!apiBase && (
        <p style={{ marginTop: 12 }}>
          Set <code>VITE_API_BASE</code> (e.g. <code>/api/v1</code>)
        </p>
      )}

      {statusText && (
        <p style={{ marginTop: 12 }}>
          API readiness/DB up: <strong>{statusText}</strong>
        </p>
      )}

      {errorText && (
        <p style={{ marginTop: 12 }}>
          Error: <strong>{errorText}</strong>
        </p>
      )}
    </div>
  );
}

export default App;
