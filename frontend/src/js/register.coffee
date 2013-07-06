
momentum = angular.module "Momentum.register", []

momentum.controller 'AuthCtrl', ['$scope', 'CurrentUser', '$location', ($scope, CurrentUser, $location) ->
  $scope.CurrentUser = CurrentUser
  $scope.logOut = ->
    return if $scope.processingAuth
    $scope.processingAuth = true
    CurrentUser.logout().then (response) ->
      console.log "Success logout", response
      $scope.processingAuth = false

      $location.path '/'
    , (error) ->
      console.error "Error", error
      $scope.processingAuth = false
]
momentum.controller 'RegisterCtrl', ['$scope', 'User', 'CurrentUser', '$location', ($scope, User, CurrentUser, $location) ->
  $scope.redirectNext = ->
    next = $location.search().next or '/'
    nextSearch = $location.search().nextSearch or ''
    nextHash = $location.search().nextHash or ''
    $location.path next
    $location.search nextSearch
    $location.hash nextHash
  $scope.signUp = ->
    return if $scope.processing
    $scope.processing = true
    CurrentUser.signUp(
      username: $scope.signUp.username
      email: $scope.signUp.email
      password: $scope.signUp.password
    ).then (result) ->
      console.log "Success signup", result
      $scope.processing = false
      $scope.redirectNext()
    , (error) ->
      console.error "Error", error
      $scope.processing = false
  $scope.login = ->
    return if $scope.processing
    $scope.processing = true
    CurrentUser.logIn(
      username: $scope.login.username
      password: $scope.login.password
    ).then (response) ->
      console.log "Success login", response
      $scope.processing = false
      $scope.redirectNext()
    , (error) ->
      console.log "Error", error
      $scope.processing = false

]
