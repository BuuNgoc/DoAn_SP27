/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#173F35',
          'primary-dark': '#0F2B24',
          'primary-light': '#244C40',
          'primary-surface': '#EBF2EF',
          secondary: '#E8DFD0',
          'secondary-light': '#F2ECE1',
          accent: '#B69A67',
          'accent-light': '#D4C29A',
          gold: '#E4B85E',
          'gold-bright': '#D4AF37',
          'warm-ivory': '#F8F6F0',
          'sand-beige': '#E8DFD0',
          background: '#FAF7F2',
          'background-subtle': '#F2F0EB',
          surface: '#FFFFFF',
          'text-primary': '#242824',
          'text-secondary': '#777A73',
          'text-muted': '#A1A39D',
          border: '#E8E5DC',
          error: '#B83A2E',
          success: '#27AE60',
          warning: '#D97706',
          info: '#2980B9',
        }
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'Inter', 'system-ui', 'sans-serif'],
        serif: ['"Playfair Display"', 'Georgia', 'serif'],
      },
      boxShadow: {
        'luxury': '0 8px 24px -4px rgba(23, 63, 53, 0.08)',
        'card': '0 2px 8px -2px rgba(23, 63, 53, 0.06)',
      }
    },
  },
  plugins: [],
}
