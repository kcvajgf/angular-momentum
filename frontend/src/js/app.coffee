
momentum = angular.module "Momentum", [
  "Momentum.controllers"
  "Momentum.directives"
  "Momentum.filters"
  "Momentum.test"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/home",
    templateUrl: "/html/messages.html"
    controller: 'MessagesController'

  $routeProvider.when "/message",
    templateUrl: "/html/message.html"
    controller: 'MessageController'
  
  $routeProvider.when "/404",
    templateUrl: "/html/404.html"

  $routeProvider.when "/",
    redirectTo: "/home"

  $routeProvider.when "/test",
    templateUrl: "/html/test.html"
    controller: "TestCtrl"

  $routeProvider.when "",
    redirectTo: "/home"
  
  $routeProvider.otherwise redirectTo: "/404"
]
