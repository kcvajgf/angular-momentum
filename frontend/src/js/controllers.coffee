momentum = angular.module "Momentum.controllers", []

momentum.controller "SelectorsController", [
 '$scope', '$location', '$http',
 ($scope,   $location,   $http) ->

  if $location.search().source?
    1 # get from server
  else # sample data
    $scope.htmlData = """
      <div class="subok">This is a div with class(subok)<div class="a b c">This is a div class (a b c)<div id="fiil" class="fool feel">This is a div with id (fiil) class (fool feel)</div><button class="btn">This is a button with class (btn)</button></div><div id="x" class="d e f">This is a div with class (d e f) and id (x)<div class="y">This is a div with class (y)</div></div>
    """
  $scope.printElement = $("#selector-area")[0]

  filterClass = (classes) ->
    (c for c in classes.trim().split(/\s+/) when c != "selector-test").join ' '
  $scope.filterAttributes = (attributes) ->
    if attributes?
      for a in attributes when a.name != 'ng-bind-html-unsafe'
        name: a.name
        value: if a.name == "class" then filterClass(a.value) else a.value
  $scope.additionalClasses = (element) ->
    if $(element).hasClass("selector-test")
      "node-has-class"
    else 
      ""
]

momentum.controller "CSSController", ['$scope', ($scope) ->
  console.log "Hello CSS"
]

momentum.controller "JadeController", ['$scope', ($scope) ->
  console.log "Hello Jade"
]

momentum.controller "JQueryController", ['$scope', ($scope) ->
  console.log "Hello JQuery"
]



