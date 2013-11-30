
momentum = angular.module "Momentum.game", []

momentum.controller 'GameCtrl', [
 '$scope', 'toastr', '$location',
 ($scope,   toastr,   $location) ->
  console.log "HUY"
]
