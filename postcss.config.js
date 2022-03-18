module.exports = {
  plugins: {
    'postcss-import': {},
    'postcss-flexbugs-fixes': {},
    'tailwindcss/nesting': 'postcss-nested',
    'tailwindcss': {},
    'autoprefixer': {},
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3,
      features: { 'nesting-rules': false }
    }
  }
}
