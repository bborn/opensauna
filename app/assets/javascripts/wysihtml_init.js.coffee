$.rich_text_init = ->
  $(".wysihtml5").each (i, elem) ->
    $(elem).wysihtml5 "deepExtend",
      "font-styles": false
      emphasis: true
      lists: false
      html: true
      link: true
      image: false
      color: false
      stylesheets: ["/assets/editor-bootstrap.css"]

$(document).ready ->
  $.rich_text_init
