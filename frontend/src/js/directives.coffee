
momentum = angular.module "Momentum.directives", []

momentum.directive 'mmTabs', [->
  transclude: true
  replace: true
  scope: {}
  template: """
    <div class="tabbable">
      <ul class="nav nav-tabs">
        <li ng-repeat="tab in tabs" ng-class="{active: tab.selected}">
          <a ng-click="select(tab)">{{tab.title}}</a>
        </li>
      </ul>
      <div class="tab-content" ng-transclude></div>
    </div>
  """
  controller: ['$scope', ($scope) ->
    $scope.tabs = []

    $scope.select = (tab) ->
      t.selected = false for t in $scope.tabs
      tab.selected = true

    @register = (tab) ->
      $scope.select(tab) if $scope.tabs.length == 0
      $scope.tabs.push tab

    null
  ]
]

momentum.directive 'mmTab', [->
  require: '^mmTabs'
  transclude: true
  replace: true
  scope:
    title: '@mmTab'
  template: """
    <div class="tab-pane" ng-class="{active: selected}" ng-transclude></div>
  """
  link: (scope, element, attrs, tabsCtrl) ->
    tabsCtrl.register scope
]

momentum.directive 'mmSelector', ['$parse', ($parse) ->
  link: (scope, element, attrs) ->
    doAction   = if attrs.doAction   then $parse(attrs.doAction)
    undoAction = if attrs.undoAction then $parse(attrs.undoAction)
    error =      if attrs.error      then $parse(attrs.error)

    oldSelected = null
    attrs.$observe 'mmSelector', (newSelector) ->
      try
        newSelected = element.find(newSelector)
        error.assign scope, null
      catch er
        error.assign scope, er
        return

      if oldSelected?
        if undoAction?
          oldSelected.each (index, elt) ->
            undoAction scope, element: elt
        if attrs.addClass
          oldSelected.removeClass attrs.addClass

      if newSelected?
        if doAction?
          newSelected.each (index, elt) ->
            doAction   scope, element: elt
        if attrs.addClass
          newSelected.addClass attrs.addClass

      oldSelected = newSelected
]
