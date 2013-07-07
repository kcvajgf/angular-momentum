
momentum = angular.module "Momentum.problems", []

momentum.controller 'ProblemOneCtrl', [
 '$scope', 'Problem', '$http', 'toastr', '$routeParams', '$location',
 ($scope,   Problem,   $http,   toastr,   $routeParams,   $location) ->
  $scope.currentIndex = parseInt $routeParams.index
  $scope.showInactive = $location.search().showinactive
  width = 10

  loadStuff = ->
    if not $scope.loadingProblem  
      $scope.loadingProblem = true
      $scope.currentProblem = Problem.get(index: $scope.currentIndex, ->
        $scope.loadingProblem = false)
      
    if not $scope.loadingProblems
      $scope.loadingProblems = true
      $http.get("/api/problems/info/"
        params:
          from: $scope.currentIndex - width
          to: $scope.currentIndex + width
      ).success (response) ->
        $scope.problems = response
        $scope.problemMap = {}
        for problem in $scope.problems
          $scope.problemMap[problem.index] = problem
        $scope.loadingProblems = false
      .error (errorResponse) ->
        console.error "Some error", errorResponse

      $http.get("/api/problems/upcoming/")
      .success (response) ->
        $scope.upcomingProblems = response
      .error (errorResponse) ->
        console.error "Some error", errorResponse

  loadStuff()

  $scope.$watch (->
    if $scope.upcomingProblems?
      for problem in $scope.upcomingProblems
        if problem.release <= problem.now
          loadStuff()
          break
    null
  )

  $scope.$watch 'showInactive', (showInactive) ->
    if showInactive
      $location.search 'showinactive', true
    else
      $location.search 'showinactive', null

  $scope.setProblem = (problem) ->
    $location.path "/problems/#{problem.index}"

  $scope.problemFilter = (problem) ->
    problem.active or $scope.showInactive

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

momentum.controller 'ScoreboardCtrl', [
 '$scope', 'Problem', '$http', 'toastr', '$routeParams', '$location',
 ($scope,   Problem,   $http,   toastr,   $routeParams,   $location) ->
  $scope.currentIndex = parseInt $routeParams.index
  $scope.showInactive = $location.search().showinactive
  width = 10

  loadStuff = ->
    if not $scope.loadingProblem  
      $scope.loadingProblem = true
      $http.get("/api/problems/#{$scope.currentIndex}/solvers")
      .success (response) ->
        $scope.solvers = response
        for solver in $scope.solvers
          solver.created_at = new Date solver.created_at
        $scope.loadingProblem = false
      .error (errorResponse) ->
        console.error "Some error", errorResponse
        $scope.loadingProblem = false
      
    if not $scope.loadingProblems
      $scope.loadingProblems = true
      $http.get("/api/problems/info/"
        params:
          from: $scope.currentIndex - width
          to: $scope.currentIndex + width
      ).success (response) ->
        $scope.problems = response
        $scope.problemMap = {}
        for problem in $scope.problems
          $scope.problemMap[problem.index] = problem
        $scope.loadingProblems = false
      .error (errorResponse) ->
        console.error "Some error", errorResponse

      $http.get("/api/problems/upcoming/")
      .success (response) ->
        $scope.upcomingProblems = response
      .error (errorResponse) ->
        console.error "Some error", errorResponse

  loadStuff()

  $scope.$watch (->
    if $scope.upcomingProblems?
      for problem in $scope.upcomingProblems
        if problem.release <= problem.now
          loadStuff()
          break
    null
  )
  $scope.setProblem = (problem) ->
    $location.path "/problems/#{problem.index}/scoreboard/"
]

momentum.controller 'ProblemsCtrl', [
 '$scope', 'Problem', '$http', 'toastr', '$routeParams', '$location',
 ($scope,   Problem,   $http,   toastr,   $routeParams,   $location) ->

  $scope.currentIndex = $routeParams.index
  $scope.showInactive = $location.search().showinactive

  loadStuff = ->
    return if $scope.loadingProblems

    $scope.loadingProblems = true
    $http.get("/api/problems/info/").success (response) ->
      $scope.problems = response
      $scope.problemMap = {}
      for problem in $scope.problems
        $scope.problemMap[problem.index] = problem
      $scope.loadingProblems = false
    .error (errorResponse) ->
      console.error "Some error", errorResponse

    $http.get("/api/problems/upcoming/")
    .success (response) ->
      $scope.upcomingProblems = response
    .error (errorResponse) ->
      console.error "Some error", errorResponse

  loadStuff()

  $scope.$watch (->
    if $scope.upcomingProblems?
      for problem in $scope.upcomingProblems
        if problem.release <= problem.now
          loadStuff()
          break
    null
  )

  $scope.$watch 'showInactive', (showInactive) ->
    if showInactive
      $location.search 'showinactive', true
    else
      $location.search 'showinactive', null

  $scope.setProblem = (problem) ->
    $location.path "/problems/#{problem.index}"

  $scope.problemFilter = (problem) ->
    problem.active or $scope.showInactive

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

momentum.controller 'AllProblemsCtrl', [
 '$scope', 'Problem', '$http', 'toastr', '$routeParams', '$location',
 ($scope,   Problem,   $http,   toastr,   $routeParams,   $location) ->

  $scope.currentIndex = $routeParams.index
  $scope.showInactive = $location.search().showinactive

  loadStuff = ->
    return if $scope.loadingProblems

    $scope.loadingProblems = true
    $scope.problems = Problem.query ->
      $scope.problemMap = {}
      for problem in $scope.problems
        $scope.problemMap[problem.index] = problem
      $scope.loadingProblems = false
    , (errorResponse) ->
      console.error "Some error", errorResponse

    $http.get("/api/problems/upcoming/")
    .success (response) ->
      $scope.upcomingProblems = response
    .error (errorResponse) ->
      console.error "Some error", errorResponse

  loadStuff()

  $scope.$watch (->
    if $scope.upcomingProblems?
      for problem in $scope.upcomingProblems
        if problem.release <= problem.now
          loadStuff()
          break
    null
  )

  $scope.$watch 'showInactive', (showInactive) ->
    if showInactive
      $location.search 'showinactive', true
    else
      $location.search 'showinactive', null

  $scope.setProblem = (problem) ->
    $location.path "/problems/#{problem.index}"

  $scope.problemFilter = (problem) ->
    problem.active or $scope.showInactive

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
 '$scope', 'Problem', '$routeParams', '$location', 'CurrentUser', '$q',
 ($scope,   Problem,   $routeParams,   $location,   CurrentUser,   $q) ->
  unless CurrentUser.user?.is_admin
    $location.path '/404'
    $location.search null
    $location.hash null
  $scope.problem = index: $routeParams.index
  Problem.get index: $routeParams.index, (problem) ->
    $scope.problem = problem
  $scope.save = (problem) ->
    d = $q.defer()
    problem.$update (response) ->
      console.log $scope.problem
      d.resolve response
    , (errorResponse) ->
      d.reject errorResponse
    d.promise
]

momentum.controller 'NewProblemCtrl', [
 '$scope', 'Problem', '$http', '$location', 'CurrentUser', '$q',
 ($scope,   Problem,   $http,   $location,   CurrentUser,   $q) ->
  unless CurrentUser.user?.is_admin
    $location.path '/404'
    $location.search null
    $location.hash null
  $scope.problem = {}
  $scope.save = (problem) ->
    d = $q.defer()
    $http.post('/api/problems'
      $scope.problem
    ).success (response) ->
      console.log $scope.problem, $scope.problem.id
      d.resolve response
      $location.path "/problems/edit/#{$scope.problem.index}"
      $location.search null
      $location.hash null
    .error (errorResponse) ->
      d.reject errorResponse
    d.promise
]
