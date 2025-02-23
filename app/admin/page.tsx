'use client'
// app/admin/page.tsx
import { useState, useEffect } from 'react';
export default function AdminDashboard() {
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    // Toggle the "dark" class on the document root element based on darkMode state
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Admin Dashboard
          </h1>
          {/* Dark Mode Toggle Button */}
          <button
            onClick={() => setDarkMode(!darkMode)}
            className="px-4 py-2 rounded bg-blue-600 dark:bg-blue-500 text-white hover:bg-blue-700 dark:hover:bg-blue-400"
          >
            {darkMode ? 'Light Mode' : 'Dark Mode'}
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* Top Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
          {/* Clients Card */}
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-orange-500 rounded-full flex-shrink-0"></div>
              <div className="ml-4">
                <h2 className="text-lg font-medium text-gray-900 dark:text-white">
                  Clients
                </h2>
                <p className="text-sm text-gray-500">25 Active</p>
              </div>
            </div>
          </div>

          {/* Documents Card */}
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-orange-500 rounded-full flex-shrink-0"></div>
              <div className="ml-4">
                <h2 className="text-lg font-medium text-gray-900 dark:text-white">
                  Documents
                </h2>
                <p className="text-sm text-gray-500">12 New</p>
              </div>
            </div>
          </div>

          {/* Appointments Card */}
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-orange-500 rounded-full flex-shrink-0"></div>
              <div className="ml-4">
                <h2 className="text-lg font-medium text-gray-900 dark:text-white">
                  Appointments
                </h2>
                <p className="text-sm text-gray-500">3 Upcoming</p>
              </div>
            </div>
          </div>

          {/* Tasks Card */}
          <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-orange-500 rounded-full flex-shrink-0"></div>
              <div className="ml-4">
                <h2 className="text-lg font-medium text-gray-900 dark:text-white">
                  Tasks
                </h2>
                <p className="text-sm text-gray-500">7 Pending</p>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Activity Section */}
        <section className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow mb-6">
          <div className="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4">
            <h2 className="text-xl font-bold text-gray-800 dark:text-white">
              Recent Activity
            </h2>
          </div>
          <div className="space-y-4">
            <p className="text-gray-700 dark:text-gray-300">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id
              libero at ipsum tristique tempor. Fusce consequat, nisl in volutpat
              laoreet, erat sapien dignissim sapien, nec dignissim sem arcu in
              mauris.
            </p>
            <p className="text-gray-700 dark:text-gray-300">
              Sed euismod, magna vel dapibus gravida, urna velit pretium risus, at
              porttitor ex orci nec justo. Proin lacinia lacus vitae dui consequat,
              vel fermentum arcu suscipit.
            </p>
          </div>
        </section>

        {/* Upcoming Appointments Section */}
        <section className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow mb-6">
          <div className="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4">
            <h2 className="text-xl font-bold text-gray-800 dark:text-white">
              Upcoming Appointments
            </h2>
          </div>
          <div className="space-y-6">
            {/* Appointment Item */}
            <div className="flex items-center space-x-4">
              <div className="w-16 h-16 bg-orange-500 rounded-md flex-shrink-0"></div>
              <div>
                <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                  Court Hearing
                </h3>
                <p className="text-sm text-gray-500">Date: MM/DD/YYYY</p>
                <p className="text-gray-600 dark:text-gray-300">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer
                  nec odio. Praesent libero. Sed cursus ante dapibus diam.
                </p>
              </div>
            </div>
            {/* Another Appointment Item */}
            <div className="flex items-center space-x-4">
              <div className="w-16 h-16 bg-orange-500 rounded-md flex-shrink-0"></div>
              <div>
                <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                  Client Meeting
                </h3>
                <p className="text-sm text-gray-500">Date: MM/DD/YYYY</p>
                <p className="text-gray-600 dark:text-gray-300">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer
                  nec odio. Praesent libero. Sed cursus ante dapibus diam.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Client Information Summary */}
        <section className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <div className="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4">
            <h2 className="text-xl font-bold text-gray-800 dark:text-white">
              Client Information
            </h2>
          </div>
          <p className="text-gray-700 dark:text-gray-300">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec in
            venenatis magna. Vivamus luctus, nunc ac viverra faucibus, arcu lorem
            cursus risus, eget efficitur nisi lorem ac magna. Nulla facilisi.
          </p>
        </section>
      </main>
    </div>
  );
}
