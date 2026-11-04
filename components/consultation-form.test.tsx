import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import ConsultationForm from "./consultation-form";

const validForm = {
  name: "Jordan Lee",
  phone: "3123756773",
  email: "jordan@example.com",
};

function completeForm() {
  fireEvent.change(screen.getByLabelText("Name"), { target: { value: validForm.name } });
  fireEvent.change(screen.getByLabelText("Phone"), { target: { value: validForm.phone } });
  fireEvent.change(screen.getByLabelText("Email"), { target: { value: validForm.email } });
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("ConsultationForm", () => {
  it("shows field errors and focuses the first invalid field", () => {
    render(<ConsultationForm />);

    fireEvent.click(screen.getByRole("button", { name: "Request consultation" }));

    expect(screen.getByText("Enter your name.")).toBeVisible();
    expect(screen.getByText("Enter a 10-digit phone number.")).toBeVisible();
    expect(screen.getByText("Enter a valid email address.")).toBeVisible();
    expect(screen.getByLabelText("Name")).toHaveFocus();
  });

  it("submits the preserved API payload and clears the form on success", async () => {
    const fetchMock = vi.fn().mockResolvedValue({ ok: true });
    vi.stubGlobal("fetch", fetchMock);
    render(<ConsultationForm />);
    completeForm();
    fireEvent.change(screen.getByLabelText("Service"), { target: { value: "land-trusts" } });

    fireEvent.click(screen.getByRole("button", { name: "Request consultation" }));

    await waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(1));
    expect(fetchMock).toHaveBeenCalledWith("/api/consultation", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: "Jordan Lee",
        phone: "(312) 375-6773",
        email: "jordan@example.com",
        requestedService: "land-trusts",
      }),
    });
    expect(await screen.findByText(/Your consultation request was sent/)).toBeVisible();
    expect(screen.getByLabelText("Name")).toHaveValue("");
    expect(screen.getByLabelText("Service")).toHaveValue("real-estate");
  });

  it("exposes the submitting state while the request is pending", async () => {
    let resolveRequest: ((value: { ok: boolean }) => void) | undefined;
    const fetchMock = vi.fn().mockImplementation(
      () => new Promise<{ ok: boolean }>((resolve) => { resolveRequest = resolve; }),
    );
    vi.stubGlobal("fetch", fetchMock);
    render(<ConsultationForm />);
    completeForm();

    fireEvent.click(screen.getByRole("button", { name: "Request consultation" }));

    const pendingButton = await screen.findByRole("button", { name: "Sending request…" });
    expect(pendingButton).toBeDisabled();
    resolveRequest?.({ ok: true });
    await screen.findByText(/Your consultation request was sent/);
  });

  it("shows a recoverable telephone fallback when the API fails", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: false, status: 503 }));
    render(<ConsultationForm />);
    completeForm();

    fireEvent.click(screen.getByRole("button", { name: "Request consultation" }));

    const alert = await screen.findByRole("alert");
    expect(alert).toHaveTextContent("We could not send your request");
    expect(screen.getByRole("link", { name: "(312) 375-6773" })).toHaveAttribute(
      "href",
      "tel:+13123756773",
    );
  });
});
