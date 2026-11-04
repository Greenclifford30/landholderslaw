import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { ApprovalsClient } from "./approvals-client";

describe("ApprovalsClient", () => {
  it("keeps attorney decisions unavailable to the Operations role", () => {
    render(<ApprovalsClient />);

    expect(screen.getByRole("button", { name: /Approve/ })).toBeDisabled();
    expect(screen.getByRole("button", { name: /Request changes/ })).toBeDisabled();
    expect(screen.getByText(/Attorney permissions are required/)).toBeVisible();

    fireEvent.click(screen.getByRole("tab", { name: "Changes requested" }));
    expect(screen.getByText("Confirm the effective date with the lender before resubmitting.")).toBeVisible();
  });
});
