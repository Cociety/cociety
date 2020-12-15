module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [],
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
