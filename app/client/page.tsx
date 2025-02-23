// app/client/page.tsx
"use client";

import Link from "next/link";

export default function ClientPortal() {
  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Client Portal
          </h1>
          <nav className="space-x-4">
            <Link
              href="/"
              className="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
            >
              Home
            </Link>
            <Link
              href="/client/profile"
              className="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
            >
              Profile
            </Link>
            <Link
              href="/client/messages"
              className="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
            >
              Messages
            </Link>
            <Link
              href="/client/appointments"
              className="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
            >
              Appointments
            </Link>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8 space-y-6">
        {/* Welcome Section */}
        <section className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            Welcome, Client Name
          </h2>
          <p className="mt-2 text-gray-600 dark:text-gray-300">
            Here you can view your case details, upcoming appointments, and more.
          </p>
        </section>

        {/* Dashboard Panels */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Case Status Panel */}
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
              Case Status
            </h3>
            <p className="mt-2 text-gray-600 dark:text-gray-300">
              Your case is currently in progress. Lorem ipsum dolor sit amet,
              consectetur adipiscing elit.
            </p>
            <div className="mt-4">
              <Link
                href="/client/case-details"
                className="inline-block px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                View Details
              </Link>
            </div>
          </div>

          {/* Document Upload Panel */}
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
              Upload Documents
            </h3>
            <p className="mt-2 text-gray-600 dark:text-gray-300">
              Securely upload any documents related to your case.
            </p>
            <div className="mt-4">
              <Link
                href="/client/upload"
                className="inline-block px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Upload Now
              </Link>
            </div>
          </div>
        </div>

        {/* Appointments and Messages */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Upcoming Appointments */}
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
              Upcoming Appointments
            </h3>
            <ul className="mt-4 space-y-4">
              <li className="flex items-center">
                <div className="w-12 h-12 bg-orange-500 rounded-md flex-shrink-0"></div>
                <div className="ml-4">
                  <p className="text-gray-900 dark:text-white">Court Hearing</p>
                  <p className="text-sm text-gray-600 dark:text-gray-300">MM/DD/YYYY</p>
                </div>
              </li>
              <li className="flex items-center">
                <div className="w-12 h-12 bg-orange-500 rounded-md flex-shrink-0"></div>
                <div className="ml-4">
                  <p className="text-gray-900 dark:text-white">Client Meeting</p>
                  <p className="text-sm text-gray-600 dark:text-gray-300">MM/DD/YYYY</p>
                </div>
              </li>
            </ul>
          </div>

          {/* Messages Panel */}
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
              Messages
            </h3>
            <ul className="mt-4 space-y-4">
              <li className="bg-gray-100 dark:bg-gray-700 p-4 rounded">
                <p className="text-gray-900 dark:text-white font-medium">Message Subject</p>
                <p className="text-gray-600 dark:text-gray-300 text-sm">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                </p>
              </li>
              <li className="bg-gray-100 dark:bg-gray-700 p-4 rounded">
                <p className="text-gray-900 dark:text-white font-medium">Another Message</p>
                <p className="text-gray-600 dark:text-gray-300 text-sm">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                </p>
              </li>
            </ul>
            <div className="mt-4">
              <Link
                href="/client/messages"
                className="inline-block px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                View All Messages
              </Link>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white dark:bg-gray-800 py-6">
        <div className="max-w-7xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <p className="text-gray-700 dark:text-gray-300">
            &copy; {new Date().getFullYear()} Landholders Law. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
