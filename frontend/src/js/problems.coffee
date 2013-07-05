
momentum = angular.module "Momentum.problems", []

momentum.controller 'ProblemsCtrl', ['$scope', ($scope) ->
  $scope.problems = [
      index: 1
      title: 'First dummy problem'
      html: '<div>What is 1 + 1?</div>'
    ,
      index: 2
      title: 'Second dummy problem'
      html: '<div>What is 2 * 2?</div>'
    ,
      index: 3
      title: 'Third dummy problem'
      html: "<div>What is avogadro's number modulo 100?</div>"
  ]
  $scope.attempt = (problem, answer) ->
    alert "Attempting problem #{problem.index} with answer '#{answer}'"
]
