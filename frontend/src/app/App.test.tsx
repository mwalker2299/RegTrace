import { render, screen } from "@testing-library/react";
import App from "./App";

describe("App", () => {
  it("renders successfully", () => {
    render(<App />);
    expect(screen.getByText(/app/i)).toBeInTheDocument();
  });
});
