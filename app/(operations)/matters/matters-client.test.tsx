import { fireEvent, render, screen, within } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { MattersClient } from "./matters-client";

describe("MattersClient", () => {
  it("searches by client, property, and matter reference", () => {
    render(<MattersClient />);
    const search = screen.getByLabelText("Search matters");

    fireEvent.change(search, { target: { value: "Avery Brooks" } });
    expect(screen.getByRole("link", { name: "Buyer #1042" })).toBeVisible();
    expect(screen.queryByRole("link", { name: "Seller #1067" })).not.toBeInTheDocument();

    fireEvent.change(search, { target: { value: "Ridge Road" } });
    expect(screen.getByRole("link", { name: "Buyer #1101" })).toBeVisible();

    fireEvent.change(search, { target: { value: "Seller #1114" } });
    expect(screen.getByRole("link", { name: "Seller #1114" })).toBeVisible();
  });

  it("combines filters, shows a recoverable empty state, and clears them", () => {
    render(<MattersClient />);

    fireEvent.change(screen.getByLabelText("Type"), { target: { value: "Buyer" } });
    fireEvent.change(screen.getByLabelText("Status"), { target: { value: "Post-Closing Pending" } });

    expect(screen.getByText("No matters match these filters")).toBeVisible();
    fireEvent.click(screen.getByRole("button", { name: "Clear all filters" }));

    expect(screen.getByRole("link", { name: "Buyer #1042" })).toBeVisible();
    expect(screen.getByRole("link", { name: "Seller #1114" })).toBeVisible();
  });

  it("opens a matter preview and links to the shared overview route", () => {
    render(<MattersClient />);

    fireEvent.click(screen.getByRole("button", { name: "Preview Buyer #1042" }));
    const dialog = screen.getByRole("dialog");

    expect(within(dialog).getByText("5324 S. Calumet Avenue")).toBeVisible();
    expect(within(dialog).getByRole("link", { name: /Open matter/ })).toHaveAttribute(
      "href",
      "/matters/1042",
    );
  });
});

