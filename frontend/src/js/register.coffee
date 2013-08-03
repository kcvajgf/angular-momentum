
momentum = angular.module "Momentum.register", []

momentum.factory 'handleError', ['toastr', (toastr) ->
  (error, defaultMessage = "Please try again later.") ->
    switch error.code
      when "EMAIL_TAKEN"
        toastr.error "Email already taken."
      when "INVALID_EMAIL"
        toastr.error "Invalid email."
      when "INVALID_PASSWORD"
        toastr.error "Invalid password."
      when "INVALID_USER"
        toastr.error "User doesn't exist."
      when "USER_DENIED", "UNKNOWN_ERROR", "AUTHENTICATION_DISABLED", "INVALID_FIREBASE", "INVALID_ORIGIN"
        toastr.info defaultMessage
      else toastr.info defaultMessage
]
momentum.controller 'AuthCtrl', [
 '$scope', 'CurrentUser', '$location', 'toastr', 'handleError',
 ($scope,   CurrentUser,   $location,   toastr,   handleError) ->
  $scope.CurrentUser = CurrentUser
  $scope.logOut = ->
    return if $scope.processingAuth
    $scope.processingAuth = true
    CurrentUser.logout().then (response) ->
      console.log "Success logout", response
      toastr.success "Successfully logged out!"
      $scope.processingAuth = false
      $location.path '/'
    , (error) ->
      handleError error, "Log out failed. Please try again later."
      console.error "Error", error
      
      $scope.processingAuth = false
]
momentum.controller 'RegisterCtrl', [
 '$scope', 'CurrentUser', '$location', 'toastr', 'handleError',
 ($scope,   CurrentUser,   $location,   toastr,   handleError) ->
  $scope.redirectNext = ->
    next = $location.search().next or '/'
    nextSearch = angular.fromJson $location.search().nextSearch or {}
    nextHash = $location.search().nextHash or ''
    $location.path next
    $location.search nextSearch
    $location.hash nextHash
  $scope.signUp = ->
    console.log "Hey S"
    return if $scope.processing
    $scope.processing = true
    CurrentUser.signUp(
      email: $scope.signUp.email
      password: $scope.signUp.password
    ).then (result) ->
      console.log "Success signup", result
      toastr.success "Thanks for signing up!"
      $scope.processing = false
      $scope.signUp.email = $scope.signUp.password = ''
      $scope.login.email = $scope.login.password = ''
      $scope.redirectNext()
    , (error) ->
      handleError error, "Sign up failed. Please try again later."
      console.error "Error", error
      $scope.processing = false
  $scope.login = ->
    console.log "Hey L"
    return if $scope.processing
    $scope.processing = true
    CurrentUser.logIn(
      email: $scope.login.email
      password: $scope.login.password
    ).then (response) ->
      console.log "Success login", response
      toastr.success "Successfully logged in!"
      $scope.processing = false
      $scope.signUp.email = $scope.signUp.password = ''
      $scope.login.email = $scope.login.password = ''
      $scope.redirectNext()
    , (error) ->
      handleError error, "Login failed. Please try again later."
      $scope.processing = false
  $scope.loginOrSignup = (type) ->
    console.log "hey", $scope.login
    switch type
      when "login"
        $scope.login()
      when "signup"
        $scope.signUp.email = $scope.login.email
        $scope.signUp.password = $scope.login.password
        $scope.signUp()

]
