import type { Metadata } from "next";
import { AppShell } from "./_components/app-shell";
import "./operations.css";

export const metadata: Metadata = {
  title: "Operations Prototype | Landholders Law",
  description: "Fictional internal transaction operations prototype.",
  robots: {
    index: false,
    follow: false,
    nocache: true,
  },
};

export default function OperationsLayout({ children }: { children: React.ReactNode }) {
  return <AppShell>{children}</AppShell>;
}

