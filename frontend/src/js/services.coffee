
momentum = angular.module "Momentum.services", []

momentum.factory 'toastr', [-> toastr]

momentum.factory 'CurrentUser', ['User', '$q', '$http', '$window', '$timeout', (User, $q, $http, $window, $timeout) ->
  storage = $window.localStorage
  CurrentUser = 
    signUp: (data) ->
      $http.post('/api/users', data)
      .success (response) =>
        console.log "Successfully signed up!", response
        @setData response.user
      .error (errorResponse) ->
        console.error "Didn't successfully sign up", errorResponse
        $q.reject errorResponse
    logIn: (data) ->
      $http.post('/api/login', data)
      .success (response) =>
        console.log "Successfully logged in!", response
        if response.ok
          @setData response.user
        else
          @setData null
      .error (errorResponse) ->
        console.error "Didn't successfully log in", errorResponse
        $q.reject errorResponse
    logout: ->
      $http.post('/api/logout')
      .success (response) =>
        console.log "Successfully logged out!", response
        @setData null
      .error (errorResponse) ->
        console.error "Didn't successfully log out", errorResponse
        $q.reject errorResponse
    setData: (data) ->
      if data?
        storage.setItem 'currentUser', angular.toJson data
        @user = new User(data)
      else
        storage.removeItem 'currentUser'
        @user = null
    isLoggedIn: ->
      return @user?
    user: null

  $window.onfocus = ->
    console.log "ON FOCUS!"
  $window.onblur = ->
    console.log "ON BLUR!"

  checkUser = ->
    $http.get("/api/current_user")
    .success (response) ->
      if response.user?
        CurrentUser.setData response.user
      else
        CurrentUser.setData null
    .error (errorResponse) ->
      console.error "Error retrieving user:", errorResponse
      $timeout ->
        checkUser()
      , 2000

  userData = storage.getItem 'currentUser'
  if userData?
    userData = angular.fromJson userData
    CurrentUser.setData userData
    checkUser()

  CurrentUser
]
