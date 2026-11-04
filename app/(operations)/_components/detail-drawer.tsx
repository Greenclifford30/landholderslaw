"use client";

import { useEffect, useRef } from "react";
import { X } from "lucide-react";

interface DetailDrawerProps {
  title: string;
  description?: string;
  open: boolean;
  onClose: () => void;
  returnFocusRef?: React.RefObject<HTMLElement | null>;
  children: React.ReactNode;
}

export function DetailDrawer({
  title,
  description,
  open,
  onClose,
  returnFocusRef,
  children,
}: DetailDrawerProps) {
  const closeButtonRef = useRef<HTMLButtonElement>(null);
  const drawerRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!open) return;
    const previousOverflow = document.body.style.overflow;
    const returnFocusTarget = returnFocusRef?.current;
    document.body.style.overflow = "hidden";
    closeButtonRef.current?.focus();

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        onClose();
        return;
      }

      if (event.key === "Tab") {
        const focusable = Array.from(
          drawerRef.current?.querySelectorAll<HTMLElement>(
            'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
          ) ?? [],
        ).filter((element) => !element.hasAttribute("hidden"));
        if (!focusable.length) return;
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (event.shiftKey && document.activeElement === first) {
          event.preventDefault();
          last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
          event.preventDefault();
          first.focus();
        }
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", handleKeyDown);
      returnFocusTarget?.focus();
    };
  }, [onClose, open, returnFocusRef]);

  if (!open) return null;

  return (
    <div className="ops-drawer-layer">
      <button
        type="button"
        className="ops-drawer-scrim"
        aria-label="Dismiss details"
        tabIndex={-1}
        onClick={onClose}
      />
      <aside
        ref={drawerRef}
        className="ops-drawer"
        role="dialog"
        aria-modal="true"
        aria-labelledby="ops-drawer-title"
        aria-describedby={description ? "ops-drawer-description" : undefined}
      >
        <header className="ops-drawer-header">
          <div>
            <h2 id="ops-drawer-title">{title}</h2>
            {description ? <p id="ops-drawer-description">{description}</p> : null}
          </div>
          <button
            ref={closeButtonRef}
            type="button"
            className="ops-icon-button"
            aria-label="Close details"
            onClick={onClose}
          >
            <X aria-hidden="true" size={20} />
          </button>
        </header>
        <div className="ops-drawer-body">{children}</div>
      </aside>
    </div>
  );
}

