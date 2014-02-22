
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

  $routeProvider.when "/name",
    templateUrl: "/html/name.html"

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
 '$scope', 'toastr', '$location', 'CurrentUser', '$log', 'Words',
 ($scope,   toastr,   $location,   CurrentUser,   $log,   Words) ->

  $scope.CurrentUser = CurrentUser

  $scope.submitName = ->
    if CurrentUser.name and CurrentUser.nickname
      toastr.success "Hello, #{CurrentUser.nickname}!"
      $location.path "/"
    else
      toastr.error "You must enter a name and a nickname!!!!"

  $scope.gameId = 0
  $scope.startGame = ->
    currGameId = ++$scope.gameId
    $location.path "/"
    $log.log "STARTING!"
    $scope.loadingGame = true
    $scope.loadingMessage = "Loading data from text file"
    Words.promise.then (data) ->
      return if currGameId != $scope.gameId
      $scope.loadingGame = false
      $scope.loadingMessage = ""
      toastr.success "Game started!"


  $scope.startGame()

  index = 5
  $scope.fuul = ->
    $scope.words.shift()
    $scope.words.push ["#{index++} aaa hoy"]

  $scope.words = [
    ["1 the quick"]
    ["2 brown fox"]
    ["3 jumps over"]
    ["4 the lazy dog."]
  ]
]
