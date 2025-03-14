import Head from 'next/head'
import Link from 'next/link'
import Image from 'next/image'
import logo from '../public/landholderslawlogo.png'
import ContactForm from './contact-form/page'

export default function Home() {
  // Replace with your own business details
  const businessName = "Landholders Law"
  const businessDescription = "Expert real estate legal services in Chicago, IL."
  const fullUrl = "https://landholderslaw.com" // Change to your domain
  // const logoUrl = "../public/landholderslawlogo.png"        // Path to your logo

  // JSON-LD for a Legal Service (Schema.org)
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "LegalService",
    "name": "Landholders Law",
    "image": `${fullUrl}/landholderslawlogo.png`,
    "url": fullUrl,
    "description": businessDescription,
    "priceRange": "$$$", // Example price range
    "address": {
      "@type": "PostalAddress",
      "postOfficeBoxNumber": "PO Box 5191",
      "addressLocality": "Lansing",
      "addressRegion": "IL",
      "postalCode": "60438",
      "addressCountry": "US"
    },
    "telephone": "+1-312-375-6773",
    "areaServed": "Chicago, IL",
    // Additional fields can be added if relevant
  }

  return (
    <>
      <Head>
        {/* Essential Meta Tags */}
        <title>Ted M. Word Esq. - Landholders Law</title>
        <meta
          name="description"
          content="Ted M. Word Esq. provides expert real estate legal services in Chicago, IL. At Landholders Law, we handle property transactions, contract review, zoning, and title disputes."
        />
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        {/* Open Graph / Facebook */}
        <meta property="og:title" content="Ted M. Word Esq. - Landholders Law" />
        <meta
          property="og:description"
          content="Expert real estate legal services in Chicago, IL. Handling property transactions, contract review, zoning, title disputes, and more."
        />
        <meta property="og:url" content={fullUrl} />
        <meta property="og:type" content="website" />
        <meta property="og:image" content={`${fullUrl}/landholderslawlogo.png`} />

        {/* Twitter Card */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content="Ted M. Word Esq. - Landholders Law" />
        <meta
          name="twitter:description"
          content="Expert real estate legal services in Chicago, IL. Handling property transactions, contract review, zoning, title disputes, and more."
        />
        <meta name="twitter:image" content={`${fullUrl}/landholderslawlogo.png`} />

        {/* Canonical URL (optional if you have a single home page or for SEO best practice) */}
        <link rel="canonical" href={fullUrl} />

        {/* JSON-LD Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
        />
      </Head>

      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        {/* Header with Logo */}
        <header className="bg-white dark:bg-gray-900 shadow-lg">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col md:flex-row justify-between items-center py-8">
              <div className="flex items-center">
                <Image
                  src={logo}
                  alt="Landholders Law Logo"
                  width={64}
                  height={64}
                  className="mr-4"
                />
                <div>
                  <h1 className="text-4xl font-bold text-gray-900 dark:text-white">
                    {businessName}
                  </h1>
                  <p className="text-2xl text-gray-600 dark:text-gray-300">
                    Attorney Ted M. Word Esq.
                  </p>
                </div>
              </div>
              <nav className="mt-4 md:mt-0 space-x-4">
                <Link
                  href="/profile"
                  className="text-xl text-gray-900 dark:text-white hover:underline"
                >
                  About Me
                </Link>
              </nav>
            </div>
          </div>
        </header>

        {/* Tagline */}
        <section className="bg-gradient-to-r from-yellow-600 to-yellow-700 py-6">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p className="text-3xl font-bold text-white italic">
              Attorney by training, Husband by choice, Father by calling, and Gentleman by God!
            </p>
          </div>
        </section>

        {/* Hero Section: Services & Consultation Form */}
        <section className="bg-gray-100 dark:bg-gray-800 py-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-start">
              <div>
                <h2 className="text-4xl md:text-5xl font-extrabold text-gray-900 dark:text-white mb-8">
                  Our Services
                </h2>
                <div className="space-y-6">
                  {/* Service: Real Estate */}
                  <div className="bg-white dark:bg-gray-800 p-6 rounded-md shadow-lg hover:shadow-2xl transition">
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white">
                      Real Estate
                    </h3>
                    <ul className="mt-4 space-y-2 text-lg text-gray-800 dark:text-gray-300">
                      <li>
                        <strong>Residential:</strong> Buying, selling, and financing homes.
                      </li>
                      <li>
                        <strong>Commercial:</strong> Negotiation and contracts for commercial deals.
                      </li>
                      <li>
                        <strong>Disputes:</strong> Resolution of property disputes.
                      </li>
                    </ul>
                  </div>
                  {/* Service: Land Trusts */}
                  <div className="bg-white dark:bg-gray-800 p-6 rounded-md shadow-lg hover:shadow-2xl transition">
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white">
                      Land Trusts
                    </h3>
                    <ul className="mt-4 space-y-2 text-lg text-gray-800 dark:text-gray-300">
                      <li>
                        <strong>Asset Protection:</strong> Secure your property assets.
                      </li>
                      <li>
                        <strong>Privacy:</strong> Maintain ownership privacy.
                      </li>
                      <li>
                        <strong>Wealth Transfer:</strong> Efficient transfer of assets.
                      </li>
                    </ul>
                  </div>
                  {/* Service: Estate Planning */}
                  <div className="bg-white dark:bg-gray-800 p-6 rounded-md shadow-lg hover:shadow-2xl transition">
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-white">
                      Estate Planning
                    </h3>
                    <ul className="mt-4 space-y-2 text-lg text-gray-800 dark:text-gray-300">
                      <li>
                        <strong>Wills & Trusts:</strong> Comprehensive planning for your legacy.
                      </li>
                      <li>
                        <strong>Probate:</strong> Guidance through the probate process.
                      </li>
                      <li>
                        <strong>Tax Strategies:</strong> Minimize estate tax liabilities.
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              {/* Consultation Form */}
              <div className="self-start">
                <ContactForm />
              </div>
            </div>
          </div>
        </section>

        {/* About Section */}
        <section className="bg-white dark:bg-gray-900 py-20">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
            <h3 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white text-center">
              About {businessName}
            </h3>
            <p className="mt-6 text-lg text-gray-800 dark:text-gray-300 leading-relaxed text-center">
              At Landholders Law, we are dedicated to providing comprehensive legal solutions for all
              your real estate needs. With decades of experience and deep expertise in property law,
              our practice offers personalized services to ensure your investments are secure.
            </p>
          </div>
        </section>

        {/* Footer */}
        <footer className="bg-white dark:bg-gray-900 shadow-inner py-6">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p className="text-gray-800 dark:text-gray-300">
              &copy; {new Date().getFullYear()} {businessName}. All rights reserved.
            </p>
          </div>
        </footer>
      </div>
    </>
  )
}
