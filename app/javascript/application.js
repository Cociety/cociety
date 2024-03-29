// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import AlpineJS from "alpinejs"


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

class Cociety {
  fileChangeHandler = function(input, label) {
    const files = input.files;
    if (files && files.length) {
      label.innerText = files[0].name;
    }
  }
};

window.cociety = new Cociety();

ActiveStorage.start()
AlpineJS.start