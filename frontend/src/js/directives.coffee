
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
    doAction      = if attrs.doAction      then $parse(attrs.doAction)
    undoAction    = if attrs.undoAction    then $parse(attrs.undoAction)
    error         = if attrs.error         then $parse(attrs.error)
    selectedCount = if attrs.selectedCount then $parse(attrs.selectedCount)

    oldSelected = null
    attrs.$observe 'mmSelector', (newSelector) ->
      try
        newSelected = element.find(newSelector)
        error.assign scope, null
      catch er
        error.assign scope, er
        return

      if oldSelected?
        if attrs.addClass
          oldSelected.removeClass attrs.addClass
        if undoAction?
          oldSelected.each (index, elt) ->
            undoAction scope, element: elt

      if newSelected?
        if doAction?
          newSelected.each (index, elt) ->
            doAction   scope, element: elt
        if attrs.addClass
          newSelected.addClass attrs.addClass
        selectedCount?.assign scope, newSelected.length
      else
        selectedCount?.assign scope, 0

      oldSelected = newSelected
]

momentum.directive 'mmCompileHtml', ['$compile', ($compile) ->
  (scope, element, attrs) ->
    scope.$watch attrs.mmCompileHtml, (value) ->
      element.html value
      $compile(element.contents()) scope
]

momentum.directive 'mmPrintHtml', [->
  scope:
    element: '=mmPrintHtml'
    additionalClasses: '&'
    filterAttributes: '&'
  templateUrl: '/html/printhtml.html'
  link: (scope, element, attrs) ->
    scope.$watch 'element.childNodes', (childNodes) ->
      scope.childNodes = childNodes

    scope.$watch 'element.attributes', (attributes) ->
      if attributes?
        scope.attributes = scope.filterAttributes attributes: attributes
        scope.attributes = (a for a in (scope.attributes ? attributes))
      else
        scope.attributes = null

    voids = "AREA BASE BR COL EMBED HR IMG INPUT KEYGEN LINK MENUITEM META PARAM SOURCE TRACK WBR".split /\s+/
    voidSet = {}
    for v in voids
      voidSet[v] = true
    scope.isVoid = (element) -> element of voidSet
]

momentum.directive 'mmPrintJade', [->
  scope:
    element: '=mmPrintJade'
    additionalClasses: '&'
    filterAttributes: '&'
  templateUrl: '/html/printjade.html'
  link: (scope, element, attrs) ->
    scope.$watch 'element.childNodes', (childNodes) ->
      scope.childNodes = childNodes

    scope.$watch 'element.attributes', (attributes) ->
      if attributes?
        scope.attributes = scope.filterAttributes attributes: attributes
        scope.attributes = (a for a in (scope.attributes ? attributes))
      else
        scope.attributes = null
      # filter class and id
      scope.selAttributes = []
      scope.genAttributes = []
      if scope.attributes?
        for a in scope.attributes
          if a.name == 'id'
            scope.selAttributes.push a
          else if a.name == 'class'
            # only handles simple 'class' values, so beware
            for c in a.value.trim().split(/\s+/)
              scope.selAttributes.push
                name: 'class'
                value: c
          else
            scope.genAttributes.push a

      null # return null at the end, instead of a list created by the for loop above
]

momentum.directive 'mmPrintJadeContents', [->
  scope:
    element: '=mmPrintJadeContents'
    additionalClasses: '&'
    filterAttributes: '&'
  templateUrl: '/html/printjadecontents.html'
  link: (scope, element, attrs) ->
    scope.$watch 'element.childNodes', (childNodes) ->
      scope.childNodes = childNodes

    scope.$watch 'element.attributes', (attributes) ->
      if attributes?
        scope.attributes = scope.filterAttributes attributes: attributes
        scope.attributes = (a for a in (scope.attributes ? attributes))
      else
        scope.attributes = null
      # filter class and id
      scope.selAttributes = []
      scope.genAttributes = []
      if scope.attributes?
        for a in scope.attributes
          if a.name == 'id'
            scope.selAttributes.push a
          else if a.name == 'class'
            # only handles simple 'class' values, so beware
            for c in a.value.trim().split(/\s+/)
              scope.selAttributes.push
                name: 'class'
                value: c
          else
            scope.genAttributes.push a

      null # return null at the end, instead of a list created by the for loop above
]
