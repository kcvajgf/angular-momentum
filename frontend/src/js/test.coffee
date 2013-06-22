
momentum = angular.module "Momentum.test", []

momentum.controller 'TestCtrl', ['$scope', ($scope) ->
  $scope.printOut = (element, select) ->
    if select
      console.log "Element", element.outerHTML, "selected"
    else
      console.log "Element", element.outerHTML, "deselected"
  $scope.printElement = $("#subok2")[0]
  filterClass = (classes) ->
    (c for c in classes.trim().split(/\s+/) when c != "selector-test").join ' '
  $scope.filterAttributes = (attributes) ->
    if attributes?
      for a in attributes
        name: a.name
        value: if a.name == "class" then filterClass(a.value) else a.value

]