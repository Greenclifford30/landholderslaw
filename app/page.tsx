import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, FileKey2, House, Phone, ShieldCheck } from "lucide-react";
import ConsultationForm from "@/components/consultation-form";
import SiteFooter from "@/components/site-footer";
import SiteHeader from "@/components/site-header";

export const metadata: Metadata = {
  title: "Landholders Law | Real Estate Counsel in Illinois",
  description:
    "Direct, attorney-led real estate, land trust, and estate planning counsel for clients in Chicago and across Illinois.",
  alternates: { canonical: "/" },
  openGraph: {
    title: "Landholders Law | Personal Property Counsel",
    description:
      "Direct counsel from Ted M. Word, Esq. for property decisions in Chicago and across Illinois.",
    url: "/",
    type: "website",
    images: ["/landholderslawlogo.png"],
  },
};

const structuredData = {
  "@context": "https://schema.org",
  "@type": "LegalService",
  name: "Landholders Law",
  url: "https://landholderslaw.com",
  image: "https://landholderslaw.com/landholderslawlogo.png",
  telephone: "+1-312-375-6773",
  areaServed: ["Chicago", "Illinois"],
  address: {
    "@type": "PostalAddress",
    postOfficeBoxNumber: "PO Box 5191",
    addressLocality: "Lansing",
    addressRegion: "IL",
    postalCode: "60438",
    addressCountry: "US",
  },
  employee: {
    "@type": "Person",
    name: "Ted M. Word",
    jobTitle: "Attorney",
  },
};

export default function Home() {
  return (
    <div className="public-site min-h-screen bg-paper text-ink">
      <a className="skip-link" href="#main-content">
        Skip to main content
      </a>
      <SiteHeader />

      <main id="main-content">
        <section className="overflow-hidden bg-limestone" aria-labelledby="home-title">
          <div className="site-shell border-x border-ink/20">
            <div className="grid min-h-[38rem] grid-cols-1 lg:grid-cols-12">
              <div className="flex flex-col justify-between border-b border-ink/20 px-5 py-12 sm:px-8 sm:py-16 lg:col-span-9 lg:border-r lg:border-b-0 lg:px-12 lg:py-20 xl:px-16">
                <div className="max-w-4xl">
                  <h1
                    id="home-title"
                    className="font-display text-[clamp(3.15rem,7.2vw,6rem)] leading-[0.96] tracking-[-0.035em] text-balance"
                  >
                    Clear counsel for the property decision in front of you.
                  </h1>
                  <p className="mt-8 max-w-2xl text-lg leading-8 text-ink/80 sm:text-xl">
                    Work directly with Ted M. Word, Esq. on real estate matters,
                    land trusts, and estate planning across Chicago and Illinois.
                  </p>
                </div>

                <div className="mt-12 flex flex-col gap-3 sm:flex-row sm:items-center">
                  <a className="button-primary" href="#consultation">
                    Request a consultation
                    <ArrowRight aria-hidden="true" size={19} strokeWidth={1.8} />
                  </a>
                  <a className="button-secondary" href="tel:+13123756773">
                    <Phone aria-hidden="true" size={18} strokeWidth={1.8} />
                    (312) 375-6773
                  </a>
                </div>
              </div>

              <div className="flex flex-col bg-charcoal text-paper lg:col-span-3">
                <div className="flex min-h-44 flex-1 items-end border-b border-paper/20 p-6 sm:p-8 lg:min-h-0">
                  <p className="font-display text-3xl leading-tight sm:text-4xl">
                    Ted M. Word,
                    <br />
                    Esq.
                  </p>
                </div>
                <div className="grid grid-cols-2 divide-x divide-paper/20 lg:grid-cols-1 lg:divide-x-0 lg:divide-y lg:divide-paper/20">
                  <p className="p-6 text-sm leading-6 text-paper/80 sm:p-8">
                    More than 25 years of experience
                  </p>
                  <p className="p-6 text-sm leading-6 text-paper/80 sm:p-8">
                    Member of the Illinois Bar
                  </p>
                </div>
              </div>
            </div>

            <div className="flex flex-wrap items-center justify-between gap-3 border-t border-ink/20 px-5 py-4 text-sm text-ink/70 sm:px-8 lg:px-12 xl:px-16">
              <span>Personal property counsel</span>
              <span>Chicago · Lansing · Illinois</span>
            </div>
          </div>
        </section>

        <section id="services" className="bg-charcoal text-paper" aria-labelledby="services-title">
          <div className="site-shell grid grid-cols-1 border-x border-paper/15 lg:grid-cols-12">
            <div className="border-b border-paper/15 px-5 py-14 sm:px-8 lg:col-span-5 lg:border-r lg:border-b-0 lg:px-12 lg:py-24 xl:px-16">
              <House aria-hidden="true" size={38} strokeWidth={1.35} className="text-gold" />
              <h2
                id="services-title"
                className="mt-8 font-display text-5xl leading-none tracking-[-0.03em] sm:text-6xl"
              >
                Real Estate
              </h2>
              <p className="mt-7 max-w-md text-lg leading-8 text-paper/75">
                Guidance for high-stakes property decisions, with the attorney handling
                your matter close to the work from the first conversation forward.
              </p>
            </div>

            <div className="lg:col-span-7">
              {[
                ["Buying and selling", "Counsel through residential and commercial property transactions."],
                ["Contracts and financing", "Clear review of the documents and obligations shaping the deal."],
                ["Property disputes", "Practical guidance when ownership or property interests are contested."],
              ].map(([title, copy]) => (
                <div
                  className="grid min-h-40 grid-cols-1 content-center border-b border-paper/15 px-5 py-9 last:border-b-0 sm:grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] sm:gap-8 sm:px-8 lg:px-12"
                  key={title}
                >
                  <h3 className="font-display text-2xl text-gold sm:text-3xl">{title}</h3>
                  <p className="mt-3 max-w-xl leading-7 text-paper/75 sm:mt-0">{copy}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="bg-paper" aria-label="Additional practice areas">
          <div className="site-shell border-x border-ink/20">
            <PracticeRow
              icon={<FileKey2 aria-hidden="true" size={30} strokeWidth={1.45} />}
              title="Land Trusts"
              copy="Counsel for property owners considering how title, privacy, and transfer goals fit together."
            />
            <PracticeRow
              icon={<ShieldCheck aria-hidden="true" size={30} strokeWidth={1.45} />}
              title="Estate Planning"
              copy="Planning guidance for how property and other assets should be handled and transferred."
            />
          </div>
        </section>

        <section id="attorney" className="bg-limestone" aria-labelledby="attorney-title">
          <div className="site-shell grid grid-cols-1 border-x border-ink/20 lg:grid-cols-12">
            <div className="border-b border-ink/20 px-5 py-14 sm:px-8 lg:col-span-8 lg:border-r lg:border-b-0 lg:px-12 lg:py-24 xl:px-16">
              <h2
                id="attorney-title"
                className="max-w-3xl font-display text-4xl leading-[1.08] tracking-[-0.025em] text-balance sm:text-6xl"
              >
                Direct counsel from an attorney who makes the next step understandable.
              </h2>
              <p className="mt-8 max-w-2xl text-lg leading-8 text-ink/75">
                Ted is a Tuskegee University graduate, earned his Juris Doctor from
                Loyola University, and is a member of the Illinois Bar.
              </p>
              <Link className="text-link mt-9" href="/profile">
                Meet Ted M. Word, Esq.
                <ArrowRight aria-hidden="true" size={18} strokeWidth={1.8} />
              </Link>
            </div>
            <blockquote className="flex items-end bg-gold-deep px-5 py-14 text-paper sm:px-8 lg:col-span-4 lg:p-12">
              <p className="font-display text-2xl leading-snug sm:text-3xl">
                “Attorney by training, Husband by choice, Father by calling, and
                Gentleman by God!”
              </p>
            </blockquote>
          </div>
        </section>

        <section id="consultation" className="bg-paper" aria-labelledby="consultation-title">
          <div className="site-shell grid grid-cols-1 border-x border-ink/20 lg:grid-cols-12">
            <div className="border-b border-ink/20 px-5 py-14 sm:px-8 lg:col-span-4 lg:border-r lg:border-b-0 lg:px-12 lg:py-20 xl:px-16">
              <h2
                id="consultation-title"
                className="font-display text-4xl leading-tight tracking-[-0.025em] sm:text-5xl"
              >
                Start with a focused conversation.
              </h2>
              <p className="mt-6 leading-7 text-ink/75">
                Tell the firm how to reach you and which service you are considering.
              </p>
              <a className="text-link mt-8" href="tel:+13123756773">
                <Phone aria-hidden="true" size={18} strokeWidth={1.8} />
                Call (312) 375-6773
              </a>
            </div>
            <div className="px-5 py-14 sm:px-8 lg:col-span-8 lg:px-12 lg:py-20 xl:px-16">
              <ConsultationForm />
            </div>
          </div>
        </section>
      </main>

      <SiteFooter />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
    </div>
  );
}

function PracticeRow({
  icon,
  title,
  copy,
}: {
  icon: React.ReactNode;
  title: string;
  copy: string;
}) {
  return (
    <div className="grid grid-cols-[auto_minmax(0,1fr)] gap-x-5 border-b border-ink/20 px-5 py-10 last:border-b-0 sm:grid-cols-[3rem_minmax(12rem,0.7fr)_minmax(0,1.3fr)] sm:items-center sm:gap-8 sm:px-8 lg:px-12 xl:px-16">
      <div className="text-gold-deep">{icon}</div>
      <h2 className="font-display text-3xl sm:text-4xl">{title}</h2>
      <p className="col-start-2 mt-3 max-w-2xl leading-7 text-ink/75 sm:col-start-3 sm:mt-0">
        {copy}
      </p>
    </div>
  );
}
