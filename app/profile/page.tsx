import type { Metadata } from "next";
import Link from "next/link";
import { ArrowLeft, ArrowRight, Phone } from "lucide-react";
import AttorneyPortrait from "@/components/attorney-portrait";
import SiteFooter from "@/components/site-footer";
import SiteHeader from "@/components/site-header";

export const metadata: Metadata = {
  title: "Ted M. Word, Esq. | Landholders Law",
  description:
    "Meet Ted M. Word, Esq., an Illinois attorney with more than 25 years of experience serving property clients.",
  alternates: { canonical: "/profile" },
  openGraph: {
    title: "Ted M. Word, Esq. | Landholders Law",
    description: "Attorney-led property counsel for clients in Chicago and across Illinois.",
    url: "/profile",
    type: "profile",
    images: ["/landholderslawlogo.png"],
  },
};

export default function Profile() {
  return (
    <div className="public-site min-h-screen bg-paper text-ink">
      <a className="skip-link" href="#main-content">
        Skip to main content
      </a>
      <SiteHeader />

      <main id="main-content">
        <section className="bg-charcoal text-paper" aria-labelledby="profile-title">
          <div className="site-shell border-x border-paper/15 px-5 py-14 sm:px-8 sm:py-20 lg:px-12 xl:px-16">
            <Link className="text-link-light" href="/">
              <ArrowLeft aria-hidden="true" size={18} strokeWidth={1.8} />
              Back to the practice
            </Link>
            <h1
              id="profile-title"
              className="mt-12 max-w-5xl font-display text-[clamp(3.4rem,8vw,6rem)] leading-[0.95] tracking-[-0.035em]"
            >
              Ted M. Word,
              <br />
              Esq.
            </h1>
            <p className="mt-8 max-w-2xl text-xl leading-8 text-paper/75">
              Personal property counsel for Chicago-area clients and clients across Illinois.
            </p>
          </div>
        </section>

        <section className="bg-limestone" aria-labelledby="about-ted">
          <div className="site-shell grid grid-cols-1 border-x border-ink/20 lg:grid-cols-12">
            <div className="border-b border-ink/20 p-5 sm:p-8 lg:col-span-5 lg:border-r lg:border-b-0 lg:p-12 xl:p-16">
              <AttorneyPortrait />
              <p className="mt-5 max-w-md text-sm leading-6 text-ink/65">
                Ted M. Word, Esq., attorney and founder of Landholders Law.
              </p>
            </div>

            <div className="px-5 py-14 sm:px-8 lg:col-span-7 lg:px-12 lg:py-20 xl:px-16">
              <h2
                id="about-ted"
                className="font-display text-4xl leading-tight tracking-[-0.025em] sm:text-5xl"
              >
                Experience grounded in clear, personal counsel.
              </h2>
              <div className="mt-8 max-w-3xl space-y-6 text-lg leading-8 text-ink/80">
                <p>
                  With more than 25 years of experience, Ted Word helps clients navigate
                  important property decisions with direct guidance and a clear next step.
                </p>
                <p>
                  His practice focuses on real estate matters, land trusts, and estate
                  planning for homeowners, property investors, and businesses in Chicago
                  and throughout Illinois.
                </p>
              </div>

              <blockquote className="mt-12 border-y border-ink/25 py-8 font-display text-2xl leading-snug sm:text-3xl">
                “Attorney by training, Husband by choice, Father by calling, and
                Gentleman by God!”
              </blockquote>
            </div>
          </div>
        </section>

        <section className="bg-paper" aria-label="Education and bar information">
          <div className="site-shell border-x border-ink/20">
            <CredentialRow
              title="Education"
              copy="Ted is a graduate of Tuskegee University and earned his Juris Doctor from Loyola University."
            />
            <CredentialRow title="Bar membership" copy="Ted is a member of the Illinois Bar." />
            <CredentialRow
              title="Experience"
              copy="More than 25 years helping clients understand consequential property decisions."
            />
          </div>
        </section>

        <section className="bg-gold-deep text-paper" aria-labelledby="profile-cta-title">
          <div className="site-shell grid grid-cols-1 border-x border-paper/20 px-5 py-14 sm:px-8 lg:grid-cols-[minmax(0,1fr)_auto] lg:items-end lg:gap-12 lg:px-12 lg:py-20 xl:px-16">
            <div>
              <h2
                id="profile-cta-title"
                className="max-w-3xl font-display text-4xl leading-tight tracking-[-0.025em] sm:text-5xl"
              >
                Bring the property decision in front of you.
              </h2>
              <p className="mt-5 max-w-2xl text-lg leading-8 text-paper/80">
                Request a consultation or call the firm to begin a focused conversation.
              </p>
            </div>
            <div className="mt-9 flex flex-col gap-3 sm:flex-row lg:mt-0 lg:flex-col">
              <Link className="button-light" href="/#consultation">
                Request a consultation
                <ArrowRight aria-hidden="true" size={19} strokeWidth={1.8} />
              </Link>
              <a className="button-outline-light" href="tel:+13123756773">
                <Phone aria-hidden="true" size={18} strokeWidth={1.8} />
                (312) 375-6773
              </a>
            </div>
          </div>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}

function CredentialRow({ title, copy }: { title: string; copy: string }) {
  return (
    <div className="grid grid-cols-1 border-b border-ink/20 px-5 py-10 last:border-b-0 sm:grid-cols-[minmax(12rem,0.7fr)_minmax(0,1.3fr)] sm:gap-10 sm:px-8 lg:px-12 xl:px-16">
      <h2 className="font-display text-3xl sm:text-4xl">{title}</h2>
      <p className="mt-4 max-w-2xl text-lg leading-8 text-ink/75 sm:mt-0">{copy}</p>
    </div>
  );
}
