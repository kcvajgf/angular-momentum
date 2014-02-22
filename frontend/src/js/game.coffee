
momentum = angular.module "Momentum.game", []

momentum.controller 'GameCtrl', [
 '$scope', 'toastr', '$location', 'CurrentUser',
 ($scope,   toastr,   $location,   CurrentUser) ->
  unless CurrentUser.name and CurrentUser.nickname
    $location.path "/name"

]
