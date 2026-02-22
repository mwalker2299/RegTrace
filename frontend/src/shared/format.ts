export function formatDisplayName(first: string, last: string) {
  const f = first.trim();
  const l = last.trim();
  if (!f && !l) return "Unknown";
  return [f, l].filter(Boolean).join(" ");
}
