
momentum = angular.module "Momentum.threads", []

momentum.controller 'ThreadsCtrl', [
 '$scope', 'toastr', '$location', 'angularFire', 'firebaseThreadsURL', 'firebaseUsersURL', 'CurrentUser',
 ($scope,   toastr,   $location,   angularFire,   firebaseThreadsURL,   firebaseUsersURL,   CurrentUser) ->
  $scope.loading = true
  console.log "HEY"
  promise = angularFire firebaseThreadsURL, $scope, 'threads', []
  userPromise = null
  $scope.$watch (-> CurrentUser.user), (user) ->
    if user
      userPromise = angularFire "#{firebaseUsersURL}/user_#{user.id}", $scope, 'userData', {}
      userPromise.then ->
        console.log "HOY", $scope.userData
  promise.then ->
    $scope.loading = false
    console.log "we have threads", $scope.threads?.length
  $scope.hasRead = (thread) ->
    console.log thread
    if $scope.userData?
      console.log "hasRead", $scope.userData["thread_#{thread.id}"], thread.last_message
    else
      console.log "hasRead nO"
    $scope.userData? and $scope.userData["thread_#{thread.id}"] >= thread.last_message
  $scope.names = (thread) ->
    console.log "messages", thread.messages
    allNames = []
    allNameSet = {}
    for msg in thread.messages
      if msg.author not of allNameSet
        allNameSet[msg.author] = msg
        allNames.push msg.author
    console.log "names = ", allNames
    allNames
]

momentum.controller 'ThreadCtrl', [
 '$scope', 'toastr', '$location', 'angularFire', 'firebaseThreadsURL', 'firebaseUsersURL', '$routeParams', 'CurrentUser', 'replyFilter'
 ($scope,   toastr,   $location,   angularFire,   firebaseThreadsURL,   firebaseUsersURL,   $routeParams,   CurrentUser,   replyFilter) ->
  $scope.CurrentUser = CurrentUser
  $scope.loading = true
  console.log "HEY"
  promise = angularFire "#{firebaseThreadsURL}/#{$routeParams.id}", $scope, 'thread', {}
  userPromise = null
  $scope.$watch (-> CurrentUser.user), (user) ->
    if user
      console.log "reading", "#{firebaseUsersURL}/user_#{user.id}"
      userPromise = angularFire "#{firebaseUsersURL}/user_#{user.id}", $scope, 'userData', {}
      userPromise.then ->
        oldRead = $scope.userData?["thread_#{$scope.thread.id}"]
        unless oldRead?
          oldRead = new Date(0)
        setTimeout ->
          today = new Date()
          console.log "hoy got user", $scope.userData, user.id, "reading", $scope.thread, today
          $scope.userData?["thread_#{$scope.thread.id}"] = today
        , 10
        promise.then ->
          $scope.scrollMessage = null
          for message in $scope.thread.messages
            if oldRead < message.created
              $scope.scrollMessage = message
              break

  promise.then ->
    $scope.loading = false
    console.log "we have thread", $scope.thread

  
  $scope.modify = (message, newMessage) ->
    promise.then ->
      today = new Date()
      $scope.thread.last_updated = today
      message.body = newMessage.body
      message.last_updated = today
      newMessage.body = ''
  $scope.reply = (newMessage) ->
      today = new Date()
      $scope.thread.last_updated = today
      $scope.thread.last_message = today
      $scope.thread.last_message_author = CurrentUser.user.email
      $scope.thread.messages.push
        original: false
        author: $scope.CurrentUser.user.email
        body: newMessage.body
        subject: replyFilter $scope.thread.subject
        created: today
        last_updated: today
        id: $scope.thread.messages.length
      newMessage.body = ''
]

momentum.controller 'NewThreadCtrl', [
 '$scope', 'toastr', '$location', 'angularFire', 'firebaseThreadsURL', 'firebaseUsersURL', 'CurrentUser'
 ($scope,   toastr,   $location,   angularFire,   firebaseThreadsURL,   firebaseUsersURL,   CurrentUser) ->
  $scope.CurrentUser = CurrentUser
  $scope.loading = false
  console.log "HEYx"
  promise = angularFire firebaseThreadsURL, $scope, 'threads', []
  userPromise = null
  $scope.$watch (-> CurrentUser.user), (user) ->
    if user
      userPromise = angularFire "#{firebaseUsersURL}/user_#{user.id}", $scope, 'userData', {}
  $scope.message =
    original: true
    id: 0
  $scope.$watch 'CurrentUser.user.email', (email) ->
    $scope.message.author = email
    $scope.thread.author = email
  $scope.thread = 
    messages: [
      $scope.message
    ]
  $scope.showForm = true
  $scope.$watch 'message.subject', (subject) ->
    $scope.thread.subject = subject
  $scope.save = ->
    today = new Date()
    $scope.message.created = today
    $scope.message.last_updated = today
    promise.then ->
      newId = $scope.threads.length
      $scope.threads.push 
        subject: $scope.thread.subject
        author: CurrentUser.user.email
        last_message_author: CurrentUser.user.email
        id: newId
        last_updated: today
        last_message: today
        created: today
        messages: [$scope.message]
      $scope.userData?["thread_#{newId}"] = today
      $location.path "/threads/#{newId}"
]
