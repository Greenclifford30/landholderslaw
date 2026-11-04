import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://landholderslaw.com"),
  title: {
    default: "Landholders Law | Personal Property Counsel",
    template: "%s",
  },
  description:
    "Attorney-led real estate, land trust, and estate planning counsel for Chicago and Illinois.",
  applicationName: "Landholders Law",
  icons: { icon: "/favicon.ico" },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
