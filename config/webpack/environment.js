const { environment } = require("@rails/webpacker");
const erb = require("./loaders/erb");
const webpack = require("webpack");

environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    Popper: ["popper.js", "default"],
  })
);

environment.config.set("resolve.alias", {
  jquery: "jquery/src/jquery",
  "jquery-ui": "jquery-ui-dist/jquery-ui.js",
});

environment.loaders.prepend("erb", erb);
module.exports = environment;
