
momentum = angular.module "Momentum", [
  "Momentum.problems"
  "Momentum.register"
  "Momentum.directives"
  "Momentum.resources"
  "Momentum.services"
  "Momentum.filters"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/home",
    templateUrl: "/html/home.html"

  $routeProvider.when "/problems",
    templateUrl: "/html/problems.html"
    controller: "ProblemsCtrl"
    reloadOnSearch: false
    
  $routeProvider.when "/problems/all",
    templateUrl: "/html/all_problems.html"
    controller: "AllProblemsCtrl"
    reloadOnSearch: false

  $routeProvider.when "/problems/new",
    templateUrl: "/html/admin_new_problem.html"
    controller: "NewProblemCtrl"

  $routeProvider.when "/problems/:index/scoreboard",
    templateUrl: "/html/problem_scoreboard.html"
    controller: "ScoreboardCtrl"

  $routeProvider.when "/problems/:index/forum",
    templateUrl: "/html/problem_forum.html"
    controller: "ForumCtrl"

  $routeProvider.when "/problems/:index/edit",
    templateUrl: "/html/admin_problem.html"
    controller: "EditProblemCtrl"

  $routeProvider.when "/problems/:index",
    templateUrl: "/html/problem_one.html"
    controller: "ProblemOneCtrl"
    reloadOnSearch: false

  $routeProvider.when "/register",
    templateUrl: "/html/register.html"
    controller: "RegisterCtrl"

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"
    controller: "NotFoundCtrl"

  $routeProvider.when "/",
    redirectTo: "/home"

  $routeProvider.when "",
    redirectTo: "/home"
  
  $routeProvider.otherwise redirectTo: "/404"
]

momentum.controller "NotFoundCtrl", ['$location', ($location) ->
  $location.search {}
  $location.hash ''
]
