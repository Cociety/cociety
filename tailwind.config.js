module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  safelist: [
    'field_error',
    'field_with_errors'
  ],
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
