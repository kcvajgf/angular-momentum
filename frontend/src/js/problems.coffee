
momentum = angular.module "Momentum.problems", []

momentum.controller 'ProblemsCtrl', [
 '$scope', 'Problem', '$http', 'toastr',
 ($scope,   Problem,   $http,   toastr) ->
  $scope.problems = Problem.query()
  $scope.attempt = (problem, answer) ->
    $scope.submitting = true
    $http.post "/api/problems/#{problem.index}/answer",
      answer: answer
    .success (response) ->
      console.log 'Success', response
      if response.correct
        toastr.success "Congratulations! Your answer for problem #{problem.index} is correct!"
        problem.answer = response.answer
        problem.has_answered = true
      else
        toastr.error "Sorry, your answer for problem #{problem.index} is incorrect..."
      $scope.submitting = false
    .error (errorResponse) ->
      console.error 'Error', errorResponse
      toastr.info "Sorry, an error occurred while submitting form problem #{problem.index}. Please try again later."
      $scope.submitting = false
]

momentum.controller 'EditProblemCtrl', [
 '$scope', 'Problem', '$routeParams', '$location', 'CurrentUser',
 ($scope,   Problem,   $routeParams,   $location,   CurrentUser) ->
  unless CurrentUser.user?.is_admin
    $location.path '/404'
    $location.search null
    $location.hash null
  $scope.problem = Problem.get(index: $routeParams.index)
]