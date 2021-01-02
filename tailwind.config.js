module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: ['./app/views/**/*.html.erb'],
  theme: {
    extend: {
      zIndex: {
        '-1': -1
      }
    },
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
