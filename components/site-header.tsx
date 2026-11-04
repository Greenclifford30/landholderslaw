import Link from "next/link";
import { Phone } from "lucide-react";

export default function SiteHeader() {
  return (
    <header className="bg-charcoal text-paper">
      <div className="site-shell flex min-h-24 flex-wrap items-center justify-between gap-x-8 gap-y-4 border-x border-paper/15 px-5 py-5 sm:px-8 lg:px-12 xl:px-16">
        <Link className="group min-w-fit no-underline" href="/" aria-label="Landholders Law home">
          <span className="block font-display text-2xl leading-none tracking-[-0.02em] sm:text-3xl">
            Landholders Law
          </span>
          <span className="mt-2 block text-xs tracking-[0.12em] text-paper/65 uppercase">
            Ted M. Word, Esq.
          </span>
        </Link>

        <nav className="order-3 flex w-full flex-wrap items-center gap-x-5 gap-y-1 border-t border-paper/15 pt-4 text-sm sm:order-2 sm:w-auto sm:border-0 sm:pt-0" aria-label="Primary navigation">
          <Link className="nav-link" href="/#services">
            Services
          </Link>
          <Link className="nav-link" href="/profile">
            Attorney
          </Link>
          <Link className="nav-link" href="/#consultation">
            Consultation
          </Link>
        </nav>

        <a
          className="order-2 inline-flex min-h-11 items-center gap-2 text-sm font-semibold text-gold no-underline transition-colors hover:text-paper sm:order-3"
          href="tel:+13123756773"
        >
          <Phone aria-hidden="true" size={17} strokeWidth={1.8} />
          <span className="hidden md:inline">(312) 375-6773</span>
          <span className="md:hidden">Call</span>
        </a>
      </div>
    </header>
  );
}
