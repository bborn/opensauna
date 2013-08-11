#= require turbolinks
#= require jquery
#= require jquery.turbolinks
#= require jquery_ujs
#= require url
#= require topics
#= require bootstrap
#= require bootstrap-wysihtml5
#= require underscore
#= require wysihtml_init
#= require dashboard
#= require jquery.main.js
#= require_self

$.mason = ->
  $("#urls").masonry
    columnWidth: (containerWidth) ->
      containerWidth / 3
    itemSelector: ".url"


$.tablet = ->
  viewport = $(window).width()
  if viewport >= 768 and viewport < 960
    true
  else
    false

$.phone = ->
  viewport = $(window).width()
  if viewport < 768
    true
  else
    false

$.colorBoxIt = (elem) ->
  $("#{elem} a[rel='colorbox'], #{elem} img[rel='colorbox']").colorbox
    height: ->
      height = "90%"
      height = "100%"  if $.phone() or $.tablet()
      height

    width: ->
      width = "75%"
      if $.phone()
        width = "100%"
      else width = "90%"  if $.tablet()
      width

    current: "item {current} of {total}"
    fixed: true
    html: "Content"
    onLoad: ->
      $("body").css overflow: "hidden"
      $("#cboxTitle, #cboxOverlay, #cboxCurrent, #cboxNext, #cboxPrevious, #cboxSlideshow, #cboxClose").on "touchmove", false

    onComplete: ->
      $("#cboxLoadedContent").html $(this).parents("li.url .thumbnail").html()

      id = $(this).parents("li.url").attr("id")
      $("#cboxLoadedContent .description").load('/urls/'+id+'/long_text_for_item');
      window.current_url = $("#cboxLoadedContent h3 a").attr("href")
      $("#cboxLoadedContent h3 a").click (e) ->
        window.open window.current_url
        e.stopPropagation()
        false

      $("li.url .video").css visibility: "hidden"

    onClosed: ->
      $("body").css overflow: "auto"
      window.current_url = ""


$.openLink = (background) ->
  unless typeof(window.current_url) is 'undefined'
    window.open window.current_url
    self.focus() if background

$(document).bind "cbox_cleanup", ->
  $("li.url .video").css visibility: "visible"

$(document).ready ->

  $("*[data-href]").live "click", ->
    Turbolinks.visit $(this).data("href")

  $("#quick_dash_chooser").live 'change', ->
    dash_id = $(this).find('select[name=id]').val()
    Turbolinks.visit dash_id

  $('.selectpicker').selectpicker();

  $('*[data-fp-apikey]').each () ->
    element = $(this);
    if element.prev() is not 'button'
      filepicker.constructWidget(element)

  $.mason();

  # OLD STUFF!
  return
  # $.colorBoxIt "#urls"

  # $(document).bind "keydown", "shift+a", ->
  #   document.location = $("li.mark-read a").attr("href")

  # $(document).bind "keydown", "shift+v", ->
  #   $.openLink true

  # $(document).bind "keydown", "v", (e)->
  #   $.openLink()


  # $(".sharing a[data-target]").live "click", ->
  #   $(this).toggle().siblings().toggle()

  # $("#updates a").live 'click', (e) ->
  #   $.ajax
  #     url: window.location.href
  #     data:
  #       page : -1
  #       ids : newUrls
  #     type: "get"
  #     dataType: "script"
  #     success: ->
  #       $("#updates").fadeOut()
  #   e.stopPropagation()
  #   false

  # $('a.bad').click () ->
  #   $(this).parents("li").fadeOut()

  # $('.editImages li').click ->
  #   $checkbox = $(this).find(':checkbox');
  #   $checkbox.attr('checked', !$checkbox.attr('checked'));

$(document).on "page:fetch", ->
  $("#page_loading").show()

$(document).on "page:change", ->
  $("#page_loading").hide()
  $(".addthis_toolbox").each ->
    window.addthis.toolbox this

# $.fn.imagesLoaded = (callback) ->
#   elems = @find("img")
#   len = elems.length
#   _this = this
#   callback.call this  unless elems.length
#   elems.bind("load", ->
#     callback.call _this  if --len <= 0
#   ).each ->
#     if @complete or @complete is `undefined`
#       src = @src
#       @src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=="
#       @src = src
#   this

(($) ->
  settings =
    unfilterMethod: "show"
    filterMethod: "hide"

  methods =
    init: (options) ->
      $.extend settings, options  if options
      methods.filterImages $(this)

    showAll: ->
      @each ->
        $(this).show()


    filterImages: (collection) ->
      collection.each ->
        img = $(this)
        prevHeight = img.attr("height")
        prevWidth = img.attr("width")
        img.removeAttr("width").removeAttr("height").css
          width: ""
          height: ""

        pic_real_width = img.width()
        pic_real_height = img.height()
        if methods.shouldBeHidden(pic_real_width, pic_real_height)
          methods.filter img
        else
          methods.unfilter img
        img.attr("height", prevHeight).attr "width", prevWidth  if settings.resetImageDimensionsAfterFilter


    shouldBeHidden: (width, height) ->
      (width < settings.minWidth) or (height < settings.minHeight) or (width > settings.maxWidth) or (height > settings.maxHeight)

    filter: (img) ->
      $(img)[settings.filterMethod]()

    unfilter: (img) ->
      $(img)[settings.unfilterMethod]()

  $.fn.filterImagesByDimension = (method) ->

    # Method calling logic
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments_, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments_
    else
      $.error "Method " + method + " does not exist on jQuery.hideImagesByWidth"

  $("form").live "ajax:aborted:required", (event, elements) ->
    elements.each ->
      $(this).parents(".control-group").addClass "error"


) jQuery
