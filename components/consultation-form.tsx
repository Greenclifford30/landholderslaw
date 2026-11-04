"use client";

import { useRef, useState } from "react";
import { ArrowRight } from "lucide-react";

type FormData = {
  name: string;
  number: string;
  email: string;
  service: "real-estate" | "land-trusts" | "estate-planning";
};

type FieldErrors = Partial<Record<keyof FormData, string>>;

const initialForm: FormData = {
  name: "",
  number: "",
  email: "",
  service: "real-estate",
};

export function formatPhoneNumber(value: string) {
  const digits = value.replace(/\D/g, "").slice(0, 10);
  if (digits.length < 4) return digits;
  if (digits.length < 7) return `(${digits.slice(0, 3)}) ${digits.slice(3)}`;
  return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
}

export default function ConsultationForm() {
  const [formData, setFormData] = useState<FormData>(initialForm);
  const [errors, setErrors] = useState<FieldErrors>({});
  const [status, setStatus] = useState<"idle" | "submitting" | "success" | "error">("idle");
  const nameRef = useRef<HTMLInputElement>(null);
  const phoneRef = useRef<HTMLInputElement>(null);
  const emailRef = useRef<HTMLInputElement>(null);

  const updateField = <Key extends keyof FormData>(key: Key, value: FormData[Key]) => {
    setFormData((current) => ({ ...current, [key]: value }));
    setErrors((current) => ({ ...current, [key]: undefined }));
    if (status !== "idle" && status !== "submitting") setStatus("idle");
  };

  const validate = () => {
    const nextErrors: FieldErrors = {};
    if (!formData.name.trim()) nextErrors.name = "Enter your name.";
    if (formData.number.replace(/\D/g, "").length !== 10) {
      nextErrors.number = "Enter a 10-digit phone number.";
    }
    if (!/^\S+@\S+\.\S+$/.test(formData.email)) {
      nextErrors.email = "Enter a valid email address.";
    }
    if (!formData.service) nextErrors.service = "Choose a service.";
    setErrors(nextErrors);

    const firstInvalid = (Object.keys(nextErrors) as Array<keyof FieldErrors>)[0];
    if (firstInvalid === "name") nameRef.current?.focus();
    if (firstInvalid === "number") phoneRef.current?.focus();
    if (firstInvalid === "email") emailRef.current?.focus();

    return Object.keys(nextErrors).length === 0;
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!validate()) return;
    setStatus("submitting");

    try {
      const response = await fetch("/api/consultation", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: formData.name,
          phone: formData.number,
          email: formData.email,
          requestedService: formData.service,
        }),
      });
      if (!response.ok) throw new Error(`Request failed with ${response.status}`);
      setFormData(initialForm);
      setErrors({});
      setStatus("success");
    } catch {
      setStatus("error");
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate aria-label="Consultation request">
      <div className="grid grid-cols-1 gap-x-6 gap-y-7 sm:grid-cols-2">
        <FormField label="Name" error={errors.name} errorId="name-error">
          <input
            ref={nameRef}
            className="form-control"
            id="consultation-name"
            name="name"
            autoComplete="name"
            value={formData.name}
            onChange={(event) => updateField("name", event.target.value)}
            aria-invalid={Boolean(errors.name)}
            aria-describedby={errors.name ? "name-error" : undefined}
          />
        </FormField>

        <FormField label="Phone" error={errors.number} errorId="phone-error">
          <input
            ref={phoneRef}
            className="form-control"
            id="consultation-phone"
            name="number"
            type="tel"
            autoComplete="tel"
            inputMode="tel"
            value={formData.number}
            onChange={(event) => updateField("number", formatPhoneNumber(event.target.value))}
            aria-invalid={Boolean(errors.number)}
            aria-describedby={errors.number ? "phone-error" : undefined}
          />
        </FormField>

        <FormField label="Email" error={errors.email} errorId="email-error">
          <input
            ref={emailRef}
            className="form-control"
            id="consultation-email"
            name="email"
            type="email"
            autoComplete="email"
            value={formData.email}
            onChange={(event) => updateField("email", event.target.value)}
            aria-invalid={Boolean(errors.email)}
            aria-describedby={errors.email ? "email-error" : undefined}
          />
        </FormField>

        <FormField label="Service" error={errors.service} errorId="service-error">
          <select
            className="form-control"
            id="consultation-service"
            name="service"
            value={formData.service}
            onChange={(event) => updateField("service", event.target.value as FormData["service"])}
            aria-invalid={Boolean(errors.service)}
            aria-describedby={errors.service ? "service-error" : undefined}
          >
            <option value="real-estate">Real Estate</option>
            <option value="land-trusts">Land Trusts</option>
            <option value="estate-planning">Estate Planning</option>
          </select>
        </FormField>
      </div>

      <div className="mt-8 border-t border-ink/20 pt-7">
        <button className="button-primary w-full sm:w-auto" type="submit" disabled={status === "submitting"}>
          {status === "submitting" ? "Sending request…" : "Request consultation"}
          <ArrowRight aria-hidden="true" size={19} strokeWidth={1.8} />
        </button>
        <p className="mt-5 max-w-2xl text-sm leading-6 text-ink/65">
          Please do not include confidential details. Submitting this form does not create
          an attorney-client relationship.
        </p>
      </div>

      <div className="mt-6" aria-live="polite" aria-atomic="true">
        {status === "success" && (
          <p className="status-message status-success" role="status">
            Your consultation request was sent. The firm will use the information you provided to follow up.
          </p>
        )}
        {status === "error" && (
          <p className="status-message status-error" role="alert">
            We could not send your request. Please call <a href="tel:+13123756773">(312) 375-6773</a>.
          </p>
        )}
      </div>
    </form>
  );
}

function FormField({
  label,
  error,
  errorId,
  children,
}: {
  label: string;
  error?: string;
  errorId: string;
  children: React.ReactNode;
}) {
  const id = `consultation-${label.toLowerCase()}`;
  return (
    <div>
      <label className="form-label" htmlFor={id}>
        {label}
      </label>
      <div className="mt-2">{children}</div>
      {error && (
        <p className="form-error" id={errorId}>
          {error}
        </p>
      )}
    </div>
  );
}
