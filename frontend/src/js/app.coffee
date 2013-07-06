
momentum = angular.module "Momentum", [
  "Momentum.problems"
  "Momentum.register"
  "Momentum.directives"
  "Momentum.resources"
  "Momentum.services"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/home",
    templateUrl: "/html/home.html"

  $routeProvider.when "/problems",
    templateUrl: "/html/problems.html"
    controller: "ProblemsCtrl"

  $routeProvider.when "/register",
    templateUrl: "/html/register.html"
    controller: "RegisterCtrl"

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"

  $routeProvider.when "/",
    redirectTo: "/home"

  $routeProvider.when "",
    redirectTo: "/home"
  
  $routeProvider.otherwise redirectTo: "/404"
]
