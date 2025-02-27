'use client'
import { useState } from 'react'

export default function ContactForm() {
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

  // Formats the phone number to (xxx) xxx-xxxx
  const formatPhoneNumber = (value: string) => {
    const digits = value.replace(/\D/g, '')
    if (digits.length < 4) {
      return digits
    } else if (digits.length < 7) {
      return `(${digits.slice(0, 3)}) ${digits.slice(3)}`
    } else {
      return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6, 10)}`
    }
  }

  const validate = () => {
    const newErrors = { name: '', number: '', email: '', service: '' }
    let isValid = true

    // Validate Name: required and only letters, spaces, hyphens, and apostrophes allowed
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required'
      isValid = false
    } else if (!/^[a-zA-Z\s'-]+$/.test(formData.name.trim())) {
      newErrors.name = 'Name contains invalid characters'
      isValid = false
    }

    // Validate Phone Number: required and must be exactly 10 digits (formatted)
    const phoneDigits = formData.number.replace(/\D/g, '')
    if (!phoneDigits) {
      newErrors.number = 'Phone number is required'
      isValid = false
    } else if (phoneDigits.length !== 10) {
      newErrors.number = 'Phone number must be 10 digits'
      isValid = false
    }

    // Validate Email: required and proper email format
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required'
      isValid = false
    } else if (!/^\S+@\S+\.\S+$/.test(formData.email)) {
      newErrors.email = 'Email is invalid'
      isValid = false
    }

    // Validate Service: required and must be one of the allowed options
    if (!formData.service) {
      newErrors.service = 'Please select a service'
      isValid = false
    } else if (!['real-estate', 'land-trusts', 'estate-planning'].includes(formData.service)) {
      newErrors.service = 'Invalid service selected'
      isValid = false
    }

    setErrors(newErrors)
    return isValid
  }

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target

    if (name === 'number') {
      // Only allow digits, and format the phone number automatically
      const formatted = formatPhoneNumber(value)
      setFormData(prev => ({
        ...prev,
        [name]: formatted,
      }))
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value,
      }))
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!validate()) {
      return
    }

    try {
      // Optionally, show some loading state here
      const response = await fetch('/api/consultation', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: formData.name,
          phone: formData.number, // Formatted phone number
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
  )
}
