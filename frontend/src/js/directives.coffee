
momentum = angular.module "Momentum.directives", []


momentum.directive 'mmCompile', ['$compile', ($compile) ->
  (scope, element, attrs) ->
    attrs.$observe 'mmCompile', (value) ->
      console.log "compiling", value
      element.html value
      $compile(element.contents()) scope
]

momentum.directive 'mmScrollWhen', ['$parse', ($parse) ->
  scope: false
  link: (scope, element, attrs) ->
    doneScroll = $parse attrs.doneScroll
    scope.$watch attrs.mmScrollWhen, (scrollNow) ->
      console.log "check scroll", scrollNow, scope.scrollToMessage, scope.message
      if scrollNow
        console.log "SCROLLING!", attrs.mmScrollWhen, attrs.doneScroll, $(element).offset()
        # scrollto element
        #scrollTo $(element).offset().left, $(element).offset().top
        #$(window).scrollTop($(element).offset().top)
        $(element)[0].scrollIntoView(true)
        doneScroll()
]

momentum.directive 'mmRender', [->
  scope:
    mmRender: '@'
  templateUrl: "/html/render_thread.html"
]
momentum.directive 'mmThread', [->
  scope:
    thread: '=mmThread'
    user: '=user'
    reply: '&reply'
    modify: '&modify'
    scrollToMessage: '=?'
  templateUrl: "/html/display_thread.html"
  link: (scope, element, attrs) ->
    scope.clearScroll = ->
      console.log "clearing scroll"
      scope.scrollToMessage = {}
    scope.editing = null
    scope.newMessage = {}
    scope.newMessage2 = {}
    scope.toggleEditing = (newEditing) ->
      if scope.editing? and newEditing == scope.editing
        scope.editing = null
      else
        scope.editing = newEditing
    scope.$watch 'editing', (editing) ->
      if editing?
        for message in scope.thread.messages
          if message.id == editing
            scope.newMessage2.body = message.body
    scope._reply = ->
      scope.reply? newMessage: scope.newMessage
    scope._modify = (message) ->
      scope.modify?(
        message: message
        newMessage: scope.newMessage2
      )
      scope.editing = null
]

