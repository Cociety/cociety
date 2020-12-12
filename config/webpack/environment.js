const { environment } = require('@rails/webpacker')

const css = environment.loaders.get('css')
const sass = environment.loaders.get('sass')

const postCssConfig = css.use.find(u => u.loader === 'postcss-loader')
const postSassConfig = sass.use.find(u => u.loader === 'postcss-loader')

if (postCssConfig) {
  delete postCssConfig.options.config
}

if (postSassConfig) {
  delete postCssConfig.options.config
}

module.exports = environment