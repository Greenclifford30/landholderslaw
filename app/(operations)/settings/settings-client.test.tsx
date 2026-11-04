import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { SettingsClient } from "./settings-client";

describe("SettingsClient", () => {
  it("keeps configuration local and supports reset and save feedback", () => {
    render(<SettingsClient />);

    const firmName = screen.getByLabelText("Firm display name");
    fireEvent.change(firmName, { target: { value: "Landholders Law Group" } });
    expect(screen.getByText("Unsaved mock changes")).toBeVisible();

    fireEvent.click(screen.getByRole("button", { name: "Reset" }));
    expect(firmName).toHaveValue("Landholders Law");

    fireEvent.change(firmName, { target: { value: "Landholders Law Group" } });
    fireEvent.click(screen.getByRole("button", { name: "Save changes" }));
    expect(screen.getByText("Mock settings saved until you leave or refresh this page.")).toBeVisible();
  });

  it("exposes notification controls and protects unavailable security actions", () => {
    render(<SettingsClient />);

    fireEvent.click(screen.getByRole("tab", { name: /Notifications/ }));
    const digest = screen.getByRole("switch", { name: /Daily operations digest/ });
    expect(digest).toHaveAttribute("aria-checked", "false");
    fireEvent.click(digest);
    expect(digest).toHaveAttribute("aria-checked", "true");

    fireEvent.click(screen.getByRole("tab", { name: /Access & security/ }));
    expect(screen.getByRole("button", { name: "Manage sign-in" })).toBeDisabled();
  });
});
