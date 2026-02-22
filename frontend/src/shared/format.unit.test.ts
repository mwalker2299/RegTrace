import { describe, expect, it } from "vitest";
import { formatDisplayName } from "./format";

describe("formatDisplayName", () => {
  it("joins first and last names", () => {
    expect(formatDisplayName("Phillip", "Fry")).toBe("Phillip Fry");
  });

  it("handles blanks", () => {
    expect(formatDisplayName("  ", "  ")).toBe("Unknown");
    expect(formatDisplayName("Phillip", "  ")).toBe("Phillip");
    expect(formatDisplayName("  ", "Fry")).toBe("Fry");
  });
});
