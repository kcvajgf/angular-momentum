
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

momentum.directive 'mmProblem', [->
  scope:
    problem: '=mmProblem'
    attempt: '&'
  templateUrl: "/html/problem.html"
  link: (scope, element, attrs) ->
    scope.submit = (answer) ->
      scope.attempt answer: answer
]

momentum.directive 'mmAnswerBox', [->
  scope:
    problem: '=mmAnswerBox'
    attempt: '&'
  templateUrl: "/html/answer_box.html"
  link: (scope, element, attrs) ->
    scope.submit = ->
      if scope.answer?.length
        scope.attempt answer: scope.answer
]

momentum.directive 'mmEditProblem', ['toastr', (toastr) ->
  scope:
    problem: '=mmEditProblem'
    save: '&'
  templateUrl: "/html/edit_problem.html"
  link: (scope, element, attrs) ->
    scope._save = ->
      scope.save problem: scope.problem
    scope.attempt = (answer) ->
      if answer == scope.problem.answer
        toastr.success "Congratulations! Your answer for problem #{scope.problem.index} is correct!"
      else
        toastr.error "Sorry, your answer for problem #{scope.problem.index} is incorrect..."
    scope.$watch 'problem.has_answered', (has_answered) ->
      if has_answered
        scope.problem.has_answered = false
]
