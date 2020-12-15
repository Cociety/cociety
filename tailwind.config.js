module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: {
    enabled: true,
    content: ['./app/views/**/*.html.erb']
  },
  theme: {
    extend: {},
  },
  variants: {
    extend: {
      borderRadius: ['first', 'last']
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
