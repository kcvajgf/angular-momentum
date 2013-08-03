
momentum = angular.module "Momentum", [
  "Momentum.threads"
  "Momentum.register"
  "Momentum.directives"
  "Momentum.resources"
  "Momentum.services"
  "Momentum.filters"
  'firebase'
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/threads",
    templateUrl: "/html/threads.html"
    controller: "ThreadsCtrl"

  $routeProvider.when "/threads/new",
    templateUrl: "/html/new_thread.html"
    controller: "NewThreadCtrl"
    reloadOnSearch: false

  $routeProvider.when "/threads/:id",
    templateUrl: "/html/thread.html"
    controller: "ThreadCtrl"
    reloadOnSearch: false

  $routeProvider.when "/register",
    templateUrl: "/html/register.html"
    controller: "RegisterCtrl"

  $routeProvider.when "/account",
    templateUrl: "/html/account.html"

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"
    controller: "NotFoundCtrl"

  $routeProvider.when "/home",
    redirectTo: "/threads"

  $routeProvider.when "/",
    redirectTo: "/threads"

  $routeProvider.when "",
    redirectTo: "/threads"
  
  $routeProvider.otherwise redirectTo: "/404"
]

momentum.controller "NotFoundCtrl", ['$location', ($location) ->
  $location.search {}
  $location.hash ''
]
