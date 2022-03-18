module.exports = {
  content: ['./app/views/**/*.html.erb'],
    enabled: false,
    options: {
      safelist: [
        'field_error',
        'field_with_errors'
      ],
    },
  theme: {
    extend: {
      zIndex: {
        '-1': -1
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
