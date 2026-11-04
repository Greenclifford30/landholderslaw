import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { DeadlinesClient } from "./deadlines-client";

describe("DeadlinesClient", () => {
  it("filters contractual dates and exposes deadline details", () => {
    render(<DeadlinesClient />);

    fireEvent.click(screen.getByRole("tab", { name: "Contractual only" }));
    expect(screen.getByText("Financing contingency")).toBeVisible();
    expect(screen.getByText("Attorney review response")).toBeVisible();
    expect(screen.queryByText("Zoning certificate follow-up")).not.toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "View Financing contingency" }));
    expect(screen.getByRole("dialog")).toBeVisible();
    expect(screen.getByText("Last reminder")).toBeVisible();
  });
});
