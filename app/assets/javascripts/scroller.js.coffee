@Scroller = (page) ->
  self = @
  @page = ko.observable 1
  @loading = ko.observable false
  @no_more_items = ko.observable false

  @nearBottomOfPage = () ->
    return $(window).scrollTop() > $(document).height() - $(window).height() - 600

  @setUpInfiniteScrolling = () ->
    $(window).scroll ()->
      if self.loading()
        return false

      if self.nearBottomOfPage()
        return if self.no_more_items()
        self.loading(true)
        self.page(self.page() + 1)

        $.ajax({
          url: window.location.href
          data :
            page : self.page()
          type: 'get'
          dataType: 'script'
          success: () ->
            self.loading(false)
        })

  return this

