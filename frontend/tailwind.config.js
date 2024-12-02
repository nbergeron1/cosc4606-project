/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  extend: {
    gridTemplateColumns: {
      // Simple 2 column grid
      '2': '200px minmax(200px, 1fr) 100px',
    }
  },
  plugins: [],
}
