
momentum = angular.module "Momentum.register", []

momentum.controller 'RegisterCtrl', ['$scope', 'User', ($scope, User) ->
  $scope.signUp = ->
    return if $scope.processing
    $scope.processing = true
    User.save
      username: $scope.signUp.username
      email: $scope.signUp.email
      password: $scope.signUp.password
    , (result) ->
      console.log "Done"
      $scope.processing = false
    , (error) ->
      console.error "Error", error
      $scope.processing = false
  $scope.login = ->
    return if $scope.processing
    console.log $scope.login.username
    console.log $scope.login.password

]
