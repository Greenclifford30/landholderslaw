import { fireEvent, render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { AppShell } from "./app-shell";

vi.mock("next/navigation", () => ({
  usePathname: vi.fn(() => "/dashboard"),
}));

describe("AppShell", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("marks the active route and links every mocked workspace", () => {
    render(<AppShell><p>Page content</p></AppShell>);

    expect(screen.getByRole("link", { name: "Dashboard" })).toHaveAttribute("aria-current", "page");
    expect(screen.getByRole("link", { name: "Approvals" })).toHaveAttribute("href", "/approvals");
    expect(screen.getByRole("link", { name: "Settings" })).toHaveAttribute("href", "/settings");
  });

  it("searches fictional matters globally", () => {
    render(<AppShell><p>Page content</p></AppShell>);

    fireEvent.change(screen.getByLabelText("Search matters"), { target: { value: "Calumet" } });
    expect(screen.getByRole("link", { name: /Buyer #1042/ })).toHaveAttribute("href", "/matters/1042");
    expect(screen.getByText("5324 S. Calumet Avenue")).toBeVisible();
  });
});

