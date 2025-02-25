'use client'
import Head from 'next/head'
import Link from 'next/link'
import Image from 'next/image'
import { useState } from 'react'
import logo from '../public/landholderslawlogo.png'

export default function Home() {
  const [formData, setFormData] = useState({
    name: '',
    number: '',
    email: '',
    service: 'real-estate',
  })

  const [errors, setErrors] = useState({
    name: '',
    number: '',
    email: '',
    service: '',
  })
  const CONSULTATION_API = "https://dv29xveh03.execute-api.us-east-1.amazonaws.com/development/consultation";
  const validate = () => {
    const newErrors = { name: '', number: '', email: '', service: '' }
    let isValid = true

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required'
      isValid = false
    }
    if (!formData.number.trim()) {
      newErrors.number = 'Phone number is required'
      isValid = false
    }
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required'
      isValid = false
    } else if (!/^\S+@\S+\.\S+$/.test(formData.email)) {
      newErrors.email = 'Email is invalid'
      isValid = false
    }
    if (!formData.service) {
      newErrors.service = 'Please select a service'
      isValid = false
    }

    setErrors(newErrors)
    return isValid
  }

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
  
    if (!validate()) {
      return
    }
  
    try {
      // Optionally, show some loading state here
      const response = await fetch(CONSULTATION_API, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: formData.name,
          phone: formData.number,       // if 'number' is your phone field
          email: formData.email,
          requestedService: formData.service,
        }),
      })

      if (!response.ok) {
        // If we get a 4xx or 5xx status code
        throw new Error(`Request failed with status ${response.status}`)
      }
      // On success
      alert('Your consultation request has been submitted!')
      setFormData({ name: '', number: '', email: '', service: 'real-estate' })
  
    } catch (error) {
      console.error('Error submitting consultation request:', error)
      alert('There was a problem submitting your consultation. Please try again later.')
    } finally {
      // Optionally, clear a loading state here
    }
  }
  

  return (
    <>
      <Head>
        <title>Ted M. Word Esq. - Landholders Law</title>
        <meta
          name="description"
          content="Ted M. Word Esq. provides expert real estate legal services in Chicago, IL. At Landholders Law, we handle property transactions, contract review, zoning, and title disputes."
        />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        {/* Updated Header with Logo */}
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
                    Landholders Law
                  </h1>
                  <p className="text-2xl text-gray-600 dark:text-gray-300">
                    Attorney Ted M. Word Esq.
                  </p>
                </div>
              </div>
              <nav className="mt-4 md:mt-0 space-x-4">
                <Link
                  href="/admin"
                  className="text-xl text-gray-900 dark:text-white hover:underline"
                >
                  Admin
                </Link>
                <Link
                  href="/client"
                  className="text-xl text-gray-900 dark:text-white hover:underline"
                >
                  Client
                </Link>
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

        {/* Enhanced Tagline */}
        <section className="bg-gradient-to-r from-yellow-600 to-yellow-700 py-6">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p className="text-3xl font-bold text-white">
              Expert Real Estate Attorney Services in Chicago, IL
            </p>
          </div>
        </section>

        {/* Hero Section: Two Columns (Stacked Services & Consultation Form) */}
        <section className="bg-gray-100 dark:bg-gray-800 py-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-start">
              {/* Left Column: Stacked Service Cards */}
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

              {/* Right Column: Consultation Form (Aligned to Top) */}
              <div className="self-start">
                <div className="bg-white dark:bg-gray-800 p-8 rounded-md shadow-lg">
                  <h3 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-white mb-4">
                    Request a Consultation
                  </h3>
                  <form onSubmit={handleSubmit} noValidate className="space-y-6">
                    <div>
                      <label
                        htmlFor="name"
                        className="block text-lg font-medium text-gray-900 dark:text-gray-300"
                      >
                        Name
                      </label>
                      <input
                        type="text"
                        name="name"
                        id="name"
                        value={formData.name}
                        onChange={handleChange}
                        className="mt-1 block w-full p-3 border border-gray-400 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-gray-900 dark:text-white bg-white dark:bg-gray-800"
                        required
                      />
                      {errors.name && (
                        <p className="text-red-600 text-sm mt-1">{errors.name}</p>
                      )}
                    </div>

                    <div>
                      <label
                        htmlFor="number"
                        className="block text-lg font-medium text-gray-900 dark:text-gray-300"
                      >
                        Phone Number
                      </label>
                      <input
                        type="tel"
                        name="number"
                        id="number"
                        value={formData.number}
                        onChange={handleChange}
                        className="mt-1 block w-full p-3 border border-gray-400 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-gray-900 dark:text-white bg-white dark:bg-gray-800"
                        required
                      />
                      {errors.number && (
                        <p className="text-red-600 text-sm mt-1">{errors.number}</p>
                      )}
                    </div>

                    <div>
                      <label
                        htmlFor="email"
                        className="block text-lg font-medium text-gray-900 dark:text-gray-300"
                      >
                        Email
                      </label>
                      <input
                        type="email"
                        name="email"
                        id="email"
                        value={formData.email}
                        onChange={handleChange}
                        className="mt-1 block w-full p-3 border border-gray-400 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-gray-900 dark:text-white bg-white dark:bg-gray-800"
                        required
                      />
                      {errors.email && (
                        <p className="text-red-600 text-sm mt-1">{errors.email}</p>
                      )}
                    </div>

                    <div>
                      <label
                        htmlFor="service"
                        className="block text-lg font-medium text-gray-900 dark:text-gray-300"
                      >
                        Service Requested
                      </label>
                      <select
                        name="service"
                        id="service"
                        value={formData.service}
                        onChange={handleChange}
                        className="mt-1 block w-full p-3 border border-gray-400 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-gray-900 dark:text-white bg-white dark:bg-gray-800"
                        required
                      >
                        <option value="real-estate">Real Estate</option>
                        <option value="land-trusts">Land Trusts</option>
                        <option value="estate-planning">Estate Planning</option>
                      </select>
                      {errors.service && (
                        <p className="text-red-600 text-sm mt-1">{errors.service}</p>
                      )}
                    </div>

                    <div>
                      <button
                        type="submit"
                        className="w-full bg-green-600 text-white p-3 rounded-md hover:bg-green-700 transition"
                      >
                        Submit Request
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Optional About Section */}
        <section className="bg-white dark:bg-gray-900 py-20">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
            <h3 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white text-center">
              About Landholders Law
            </h3>
            <p className="mt-6 text-lg text-gray-800 dark:text-gray-300 leading-relaxed text-center">
              At Landholders Law, we are dedicated to providing comprehensive legal solutions for all your real estate needs. With decades of experience and deep expertise in property law, our practice offers personalized services to ensure your investments are secure.
            </p>
          </div>
        </section>

        {/* Footer */}
        <footer className="bg-white dark:bg-gray-900 shadow-inner py-6">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <p className="text-gray-800 dark:text-gray-300">
              &copy; {new Date().getFullYear()} Landholders Law. All rights reserved.
            </p>
          </div>
        </footer>
      </div>
    </>
  )
}
