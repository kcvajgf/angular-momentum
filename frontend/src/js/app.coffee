
momentum = angular.module "Momentum", [
  "Momentum.directives"
  "Momentum.services"
  "Momentum.filters"
  "Momentum.game"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"
    controller: "NotFoundCtrl"

  $routeProvider.when "/about",
    templateUrl: "/html/about.html"

  $routeProvider.when "/",
    templateUrl: "/html/game.html"
    controller: "GameCtrl"
    
  $routeProvider.when "/home",
    redirectTo: "/"

  $routeProvider.when "",
    redirectTo: "/"
  
  $routeProvider.otherwise redirectTo: "/404"
]

momentum.controller "NotFoundCtrl", ['$location', ($location) ->
  $location.search {}
  $location.hash ''
]

momentum.controller 'GlobalCtrl', [
 '$scope', 'toastr', '$location', 
 ($scope,   toastr,   $location) ->
  console.log "HUY GLOBAL"
]
