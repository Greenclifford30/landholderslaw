import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { TasksClient } from "./tasks-client";

describe("TasksClient", () => {
  it("filters attention work and supports local completion state", () => {
    render(<TasksClient />);

    fireEvent.click(screen.getByRole("tab", { name: "Blocked & waiting" }));
    expect(screen.getByText("Confirm financing extension with lender")).toBeVisible();
    expect(screen.getByText("Follow up with municipality")).toBeVisible();
    expect(screen.queryByText("Record Attorney review outcome")).not.toBeInTheDocument();

    fireEvent.click(screen.getByRole("tab", { name: "All open" }));
    fireEvent.click(screen.getByRole("button", { name: "Mark Confirm financing extension with lender complete" }));
    expect(screen.queryByText("Confirm financing extension with lender")).not.toBeInTheDocument();

    fireEvent.click(screen.getByRole("tab", { name: "Completed" }));
    expect(screen.getByText("Confirm financing extension with lender")).toBeVisible();
    expect(screen.getByText("Completed", { selector: ".ops-status-text" })).toBeVisible();
  });
});
