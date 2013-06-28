momentum = angular.module "Momentum.controllers", []

momentum.controller "SelectorsController", [
 '$scope', '$location', '$http',
 ($scope,   $location,   $http) ->
  $scope.htmlData = """
    <form class="subok">This is a form with class (subok)<div class="a b c">This is a div class (a b c)<div id="fiil" class="fool feel">This is a div with id (fiil) class (fool feel)</div><button class="btn">This is a button with class (btn)</button><input type="text" placeholder="This is an input"></input></div><div id="x" class="c d e">This is a div with class (c d e) and id (x)<div class="y">This is a div with class (y). <em>This is emphasized text.</em></div></div><button id="submit" class="btn btn-success">This is a button with id (submit) and class (btn btn-success)</button></form>
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

momentum.controller "JadeController", [
 '$scope', '$http',
 ($scope,   $http) ->
  console.log "Hello Jade"
  $scope.compile = ->
    $scope.error = null
    $http.post('/api/compilejade',
      data: $scope.jadeData
    ).success (response) ->
      console.log "Success!"
      $scope.htmlData = response
    .error (response) ->
      console.log "Error!"
      $scope.error = response
]

momentum.controller "JQueryController", ['$scope', ($scope) ->
  console.log "Hello JQuery"
]



