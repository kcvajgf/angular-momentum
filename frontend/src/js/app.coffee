
momentum = angular.module "Momentum", [
  "Momentum.problems"
  "Momentum.directives"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/home",
    templateUrl: "/html/home.html"

  $routeProvider.when "/problems",
    templateUrl: "/html/problems.html"
    controller: "ProblemsCtrl"

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"

  $routeProvider.when "/",
    redirectTo: "/home"

  $routeProvider.when "",
    redirectTo: "/home"
  
  $routeProvider.otherwise redirectTo: "/404"
]
