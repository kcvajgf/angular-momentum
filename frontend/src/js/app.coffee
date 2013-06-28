
momentum = angular.module "Momentum", [
  "Momentum.controllers"
  "Momentum.directives"
  "Momentum.filters"
  "Momentum.test"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/home",
    redirectTo: "/selectors"

  $routeProvider.when "/selectors",
    templateUrl: "/html/selectors.html"
    controller: "SelectorsController"
    
  $routeProvider.when "/styl",
    templateUrl: "/html/css.html"
    controller: "CSSController"
    
  $routeProvider.when "/jade",
    templateUrl: "/html/jade.html"
    controller: "JadeController"
    
  $routeProvider.when "/jquery",
    templateUrl: "/html/jquery.html"
    controller: "JQueryController"

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"

  $routeProvider.when "/",
    redirectTo: "/home"

  $routeProvider.when "",
    redirectTo: "/home"
  
  $routeProvider.otherwise redirectTo: "/404"
]
