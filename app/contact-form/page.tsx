import type { Metadata } from "next";
import ConsultationForm from "@/components/consultation-form";
import SiteFooter from "@/components/site-footer";
import SiteHeader from "@/components/site-header";

export const metadata: Metadata = {
  title: "Request a Consultation | Landholders Law",
  description: "Request a consultation with Landholders Law.",
  robots: { index: false, follow: true },
};

export default function ContactFormPage() {
  return (
    <div className="public-site min-h-screen bg-paper text-ink">
      <a className="skip-link" href="#main-content">
        Skip to main content
      </a>
      <SiteHeader />
      <main id="main-content" className="bg-limestone">
        <section className="site-shell grid grid-cols-1 border-x border-ink/20 lg:grid-cols-12">
          <div className="border-b border-ink/20 px-5 py-14 sm:px-8 lg:col-span-4 lg:border-r lg:border-b-0 lg:px-12 lg:py-20">
            <h1 className="font-display text-5xl leading-tight tracking-[-0.03em]">
              Request a consultation.
            </h1>
            <p className="mt-6 leading-7 text-ink/75">
              Share your contact information and the service you are considering.
            </p>
          </div>
          <div className="bg-paper px-5 py-14 sm:px-8 lg:col-span-8 lg:px-12 lg:py-20">
            <ConsultationForm />
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
