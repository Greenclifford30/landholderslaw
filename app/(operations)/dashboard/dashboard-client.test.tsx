import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { DashboardClient } from "./dashboard-client";

describe("DashboardClient", () => {
  it("filters the attention spine without losing semantic urgency labels", () => {
    render(<DashboardClient />);

    expect(screen.getByText("Financing contingency is overdue")).toBeVisible();
    expect(screen.getByText("Attorney review response needs a decision")).toBeVisible();

    fireEvent.click(screen.getByRole("tab", { name: "Overdue" }));

    expect(screen.getByText("Financing contingency is overdue")).toBeVisible();
    expect(screen.queryByText("Attorney review response needs a decision")).not.toBeInTheDocument();
    expect(screen.getByText("Overdue", { selector: ".ops-status-text" })).toBeVisible();

    fireEvent.click(screen.getByRole("tab", { name: "Approvals" }));
    expect(screen.getByText("Attorney review response needs a decision")).toBeVisible();
    expect(screen.getByText("Approval", { selector: ".ops-status-text" })).toBeVisible();
  });

  it("opens an approval drawer, explains Operations permissions, and restores focus", async () => {
    render(<DashboardClient />);

    const trigger = screen.getByRole("button", { name: /View approval/i });
    fireEvent.click(trigger);

    expect(screen.getByRole("dialog")).toBeVisible();
    expect(screen.getByText("Attorney decision required")).toBeVisible();
    expect(screen.getByText(/Operations can review/)).toBeVisible();
    const openMatter = screen.getByRole("link", { name: /Open matter/ });
    expect(openMatter).toHaveAttribute("href", "/matters/1067");

    const closeButton = screen.getByRole("button", { name: "Close details" });
    expect(closeButton).toHaveFocus();
    fireEvent.keyDown(window, { key: "Tab", shiftKey: true });
    expect(openMatter).toHaveFocus();
    fireEvent.keyDown(window, { key: "Tab" });
    expect(closeButton).toHaveFocus();

    fireEvent.keyDown(window, { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).not.toBeInTheDocument());
    expect(trigger).toHaveFocus();
  });
});

