
momentum = angular.module "Momentum.test", []

momentum.controller 'TestCtrl', ['$scope', ($scope) ->
  $scope.printOut = (element, select) ->
    if select
      console.log "Element", element.outerHTML, "selected"
    else
      console.log "Element", element.outerHTML, "deselected"
]