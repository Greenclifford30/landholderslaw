import Image from "next/image";
import Link from "next/link";
import logo from "@/public/landholderslawlogo.png";

export default function SiteFooter() {
  return (
    <footer className="bg-charcoal text-paper">
      <div className="site-shell grid grid-cols-1 border-x border-paper/15 lg:grid-cols-12">
        <div className="border-b border-paper/15 px-5 py-10 sm:px-8 lg:col-span-4 lg:border-r lg:border-b-0 lg:px-12">
          <Image
            src={logo}
            alt="Landholders Law"
            className="h-auto w-full max-w-64"
            sizes="256px"
          />
        </div>
        <div className="grid grid-cols-1 gap-9 px-5 py-10 text-sm leading-6 sm:grid-cols-2 sm:px-8 lg:col-span-8 lg:px-12">
          <div>
            <p className="font-semibold text-gold">Contact</p>
            <address className="mt-3 not-italic text-paper/72">
              PO Box 5191
              <br />
              Lansing, Illinois 60438
              <br />
              <a className="footer-link" href="tel:+13123756773">
                (312) 375-6773
              </a>
            </address>
          </div>
          <div>
            <p className="font-semibold text-gold">Landholders Law</p>
            <p className="mt-3 max-w-md text-paper/72">
              Personal property counsel for Chicago-area clients and clients across Illinois.
            </p>
            <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2">
              <Link className="footer-link" href="/profile">
                Attorney profile
              </Link>
              <Link className="footer-link" href="/#consultation">
                Request a consultation
              </Link>
            </div>
          </div>
        </div>
      </div>
      <div className="site-shell flex flex-col gap-2 border-x border-t border-paper/15 px-5 py-5 text-xs leading-5 text-paper/55 sm:flex-row sm:items-center sm:justify-between sm:px-8 lg:px-12 xl:px-16">
        <p>© {new Date().getFullYear()} Landholders Law. All rights reserved.</p>
        <p>Submitting a request does not create an attorney-client relationship.</p>
      </div>
    </footer>
  );
}
