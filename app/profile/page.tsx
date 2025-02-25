import Head from 'next/head'
import Image from 'next/image'
import Link from 'next/link'
import tedPhoto from '../../public/profile.png' // Ensure you have a 650x650 image here

export default function Profile() {
  return (
    <>
      <Head>
        <title>Ted M. Word Esq. Profile - Landholders Law</title>
        <meta
          name="description"
          content="Profile page for Ted M. Word Esq. showcasing his background, education, bar information, and social media links."
        />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        {/* Common Header with Nav Bar */}
        <header className="bg-white dark:bg-gray-900 shadow">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex flex-col md:flex-row justify-between items-center py-8">
              <div className="flex items-center">
                <Image
                  src="/landholderslawlogo.png"
                  alt="Landholders Law Logo"
                  width={64}
                  height={64}
                  className="mr-4"
                />
                <div>
                  <h1 className="text-4xl font-bold text-gray-900 dark:text-white">
                    Landholders Law
                  </h1>
                  <p className="text-2xl text-gray-600 dark:text-gray-300">
                    Attorney Ted M. Word Esq.
                  </p>
                </div>
              </div>
              <nav className="mt-4 md:mt-0 space-x-4">
                <Link
                  href="/"
                  className="text-gray-900 dark:text-white hover:underline"
                >
                  Home
                </Link>
                {/* <Link
                  href="/client"
                  className="text-gray-900 dark:text-white hover:underline"
                >
                  Client Portal
                </Link> */}
                <Link
                  href="/about"
                  className="text-gray-900 dark:text-white hover:underline"
                >
                  About
                </Link>
              </nav>
            </div>
          </div>
        </header>

        {/* Page Title */}
        {/* <section className="bg-gray-100 dark:bg-gray-800 py-6">
          <div className="max-w-7xl mx-auto text-center px-4 sm:px-6 lg:px-8">
            <h2 className="text-4xl font-bold text-gray-900 dark:text-white">
              Ted M. Word Esq. Profile
            </h2>
          </div>
        </section> */}

        {/* Main Content: Two-Column Layout */}
        <main className="py-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {/* Left Column: Profile Photo */}
              <div className="flex justify-center md:justify-start">
                <Image
                  src={tedPhoto}
                  alt="Photo of Ted M. Word Esq."
                  width={400}
                  height={400}
                  className="rounded-md shadow-lg"
                />
              </div>
              {/* Right Column: Profile Details */}
              <div className="space-y-8">
                {/* About Section with Social Links */}
                <section>
                  <h3 className="text-4xl font-bold text-gray-900 dark:text-white">
                    About Ted M. Word Esq.
                  </h3>
                  <p className="mt-4 text-2xl text-gray-700 dark:text-gray-300">
                  With over 25 years of experience, Ted Word is a distinguished real estate attorney dedicated to helping clients navigate the complexities of property law. Whether handling transactions, contract negotiations, or real estate disputes, he brings a wealth of knowledge and a client-focused approach to every case.



His deep understanding of real estate law, combined with his commitment to excellence, has made him a trusted advocate for homeowners, investors, and businesses alike.



Guided by his personal motto—

“Attorney by training, Husband by choice, Father by calling, and Gentleman by God!”—

Ted Word upholds integrity, professionalism, and service in every aspect of his work.
                  </p>
                  {/* <div className="mt-6 flex space-x-4">
                    <Link
                      href="https://twitter.com/yourprofile"
                      className="text-blue-500 hover:underline"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Twitter
                    </Link>
                    <Link
                      href="https://linkedin.com/in/yourprofile"
                      className="text-blue-700 hover:underline"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      LinkedIn
                    </Link>
                    <Link
                      href="https://facebook.com/yourprofile"
                      className="text-blue-600 hover:underline"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Facebook
                    </Link>
                  </div> */}
                </section>

                {/* Education Section */}
                <section>
                  <h3 className="text-4xl font-bold text-gray-900 dark:text-white">
                    Education
                  </h3>
                  <p className="mt-4 text-2xl text-gray-700 dark:text-gray-300">
                  A proud graduate of Tuskegee University, Ted earned his bachelor’s degree before obtaining his Juris Doctor from Loyola University. 
                  </p>
                </section>

                {/* Bar Information Section */}
                <section>
                  <h3 className="text-4xl font-bold text-gray-900 dark:text-white">
                    Bar Information
                  </h3>
                  <p className="mt-4 text-2xl text-gray-700 dark:text-gray-300">
                    Ted is a proud member of the Illinois Bar.
                  </p>
                </section>
              </div>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-gray-100 dark:bg-gray-800 shadow-inner py-6">
          <div className="max-w-7xl mx-auto text-center px-4 sm:px-6 lg:px-8">
            <p className="text-gray-700 dark:text-gray-300">
              &copy; {new Date().getFullYear()} Landholders Law. All rights reserved.
            </p>
          </div>
        </footer>
      </div>
    </>
  )
}
