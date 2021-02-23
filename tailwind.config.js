module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: {
    content: ['./app/views/**/*.html.erb'],
    enabled: false,
    options: {
      safelist: [
        'field_error',
        'field_with_errors'
      ],
    },
    preserveHtmlElements: true
  },
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
