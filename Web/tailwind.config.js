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
          accent: '#B69A67',
          'accent-light': '#D4C29A',
          'warm-ivory': '#F8F6F0',
          'text-primary': '#242824',
          'text-secondary': '#777A73',
          'text-muted': '#A1A39D',
          border: '#E8E5DC',
          background: '#F8F7F3',
        }
      }
    },
  },
  plugins: [],
}
