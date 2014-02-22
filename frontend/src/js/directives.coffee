
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

