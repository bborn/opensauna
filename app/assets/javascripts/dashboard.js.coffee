@Dashboard = (json) ->
  self = @
  mapping =
    style:
      create: (options)->
        attributes =
          textColor: "#808080"
          fontFamily : "Droid Serif"
          backgroundImage: "none"
          backgroundColor: "#ffffff"
          headerBackgroundColor: "#ffffff"
          headerBackgroundImage: "none"
          headerColor : "#808080"
          itemHeadingsColor: "#808080"
          itemHeadingsFontFamily : 'Droid Serif'
          itemBorderRadius: "4px"
          itemBorderStyle: "1px solid #808080"
          itemBoxShadow: "0 0 5px rgba(0, 0, 0, 0.3)"

        json = $.extend attributes, options.data
        return ko.mapping.fromJS(json, {}, this)

  ko.mapping.fromJS(json, mapping, this)

  @fontFamilies = ()->
    if dashboard.style
      [ this.style.fontFamily(), this.style.itemHeadingsFontFamily() ]
    else
      []

  @headerTextIndent = ko.computed ()->
    if !self.style.headerBackgroundImage()? && self.style.headerBackgroundImage() != ''
      return '-9999px'
    else
      return '0px'

  @page = ko.observable 1
  @loading = ko.observable false
  @no_more_items = ko.observable false

  @nearBottomOfPage = () ->
    return $(window).scrollTop() > $(document).height() - $(window).height() - 600

  @setUpInfiniteScrolling = () ->
    $(window).scroll ()->
      if dashboard.loading()
        return

      if dashboard.nearBottomOfPage()
        return if dashboard.no_more_items()

        dashboard.loading(true)
        dashboard.page(dashboard.page() + 1)
        $.ajax({
          url: window.location.href
          data :
            page : dashboard.page()
          type: 'get'
          dataType: 'script'
          success: () ->
            dashboard.loading(false)
        })

  @save = ->
    data = {}
    data['dashboard'] = ko.mapping.toJS(@)
    params =
      type: 'PUT'
      dataType: 'json'
      beforeSend: (xhr)->
        token = $('meta[name="csrf-token"]').attr('content')
        xhr.setRequestHeader('X-CSRF-Token', token) if token
      url: "/dashboards/" + @id()
      contentType: 'application/json'
      context: this
      processData: false
      data: JSON.stringify data

    $.ajax(params).success(-> $.bootstrapGrowl "Saved!", { type: 'success' } )


  @poll = ->
    $.get "/dashboards/" + self.id() + '.js?since=true', (data) ->
      setTimeout self.poll, 5000

  return this

@Item = (json) ->
  ko.mapping.fromJS(json, {}, this)
  return this
