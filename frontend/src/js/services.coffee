
momentum = angular.module "Momentum.services", []

momentum.factory 'toastr', [-> 
  toastr.options.positionClass = 'toast-top-center'
  toastr
]

momentum.value 'firebaseURL', 'https://unrealtime-forum.firebaseio.com'

momentum.factory 'firebaseRoot', (firebaseURL) ->
  new Firebase firebaseURL

momentum.factory 'firebaseAuth', (firebaseRoot, $timeout) ->
  listeners = []
  currentUser = null
  currentError = null
  auth = new FirebaseSimpleLogin firebaseRoot, (error, user) ->
    currentUser = user
    currentError = error
    console.log "User change!", error, user, listeners
    for listener in listeners
      listener error, user

  auth.addListener = (listener) ->
    listeners.push listener
    listener currentUser, currentError
  auth

momentum.factory 'CurrentUser', [
 '$q', '$http', '$window', '$timeout', 'firebaseAuth', '$rootScope', '$location'
 ($q,   $http,   $window,   $timeout,   firebaseAuth,   $rootScope,   $location) ->
  safeApply = (f) ->
    if $rootScope.$$phase == '$apply' or $rootScope.$$phase = '$digest'
      console.log "not applying!"
      f()
    else
      console.log "applying!"
      $rootScope.$apply f

  deferreds = []
  firebaseAuth.addListener (error, user) ->
    f = ->
      for deferred in deferreds
        if error
          deferred.reject error
        else
          deferred.resolve user
    if $rootScope.$$phase == '$apply' or $rootScope.$$phase == '$digest'
      f()
    else
      $rootScope.$apply f
    deferreds = []

  CurrentUser = 
    signUp: (data) ->
      console.log "signup!!", data
      d = $q.defer()
      firebaseAuth.createUser data.email, data.password, (error, user) =>
        $rootScope.$apply =>
          if error
            console.error "Didn't successfully sign up", error
            d.reject error
          else if user
            console.log "Successfully signed up!", user
            d.resolve @setData user
          else
            console.log "Successfully signed up but no user?!"
            d.reject null
      d.promise
    logIn: (data) ->
      d = $q.defer()
      deferreds.push d
      firebaseAuth.login 'password',
        email: data.email
        password: data.password
        rememberMe: false # TODO
      d.promise.then (user) =>
        if user
          console.log "Successfully logged in!", user
          d.resolve @setData user
        else
          console.log "Successfully logged in but no user?!"
          d.reject user
      , (error) =>
        console.error "Didn't successfully log in", error
        d.reject error
      d.promise
    logout: ->
      d = $q.defer()
      deferreds.push d
      firebaseAuth.logout()
      d.promise.then (user) =>
        if user
          console.log "Successfully logged out but user?!"
          d.reject user
        else
          console.log "Successfully logged out!", user
          d.resolve @setData user
      , (error) =>
        console.error "Didn't successfully log in", error
        d.reject error
      d.promise
    setData: (data) ->
      @user = data
    isLoggedIn: ->
      return @user?
    user: null

  firebaseAuth.addListener (error, user) ->
    console.log "HEY HEY HEY"
    f = ->
      if error
        console.error "Error retrieving user...", error
      else 
        console.log "Got user!", user
        CurrentUser.setData user

    if $rootScope.$$phase == '$apply' or $rootScope.$$phase == '$digest'
      f()
    else
      $rootScope.$apply f

  $window.onfocus = ->
    console.log "ON FOCUS!"
  $window.onblur = ->
    console.log "ON BLUR!"

  CurrentUser
]
