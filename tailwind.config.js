module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: ['./app/views/**/*.html.erb'],
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
