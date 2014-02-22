
momentum = angular.module "Momentum", [
  "Momentum.directives"
  "Momentum.services"
  "Momentum.filters"
  "Momentum.game"
]

momentum.config ["$routeProvider", ($routeProvider) ->

  $routeProvider.when "/404",
    templateUrl: "/html/404.html"
    controller: "NotFoundCtrl"

  $routeProvider.when "/about",
    templateUrl: "/html/about.html"

  $routeProvider.when "/",
    templateUrl: "/html/game.html"
    controller: "GameCtrl"

  $routeProvider.when "/name",
    templateUrl: "/html/name.html"

  $routeProvider.when "/home",
    redirectTo: "/"

  $routeProvider.when "",
    redirectTo: "/"
  
  $routeProvider.otherwise redirectTo: "/404"
]

momentum.controller "NotFoundCtrl", ['$location', ($location) ->
  $location.search {}
  $location.hash ''
]

momentum.factory 'Undoable', [->
  unshift: (arr, value) ->
    s = -> arr.unshift value
    s.undo = -> arr.shift()
    s
  shift: (arr) ->
    oldValue = null
    s = -> oldValue = arr.shift()
    s.undo = -> arr.unshift oldValue
    s
  push: (arr, value) ->
    s = -> arr.push value
    s.undo = -> arr.pop()
    s
  pop: (arr) ->
    oldValue = null
    s = -> oldValue = arr.pop()
    s.undo = -> arr.push oldValue
    s
  set: (obj, index, value) ->
    oldValue = obj[index]
    s = -> obj[index] = value
    s.undo = -> obj[index] = oldValue
    s
  inc: (obj, index) -> @set obj, index, obj[index]+1
  dec: (obj, index) -> @set obj, index, obj[index]-1
]


momentum.factory 'Machine', [->
  (undoLimit = -1) ->
    pastActions = []

    doAction: (action) ->
      @startActionSequence()
      @act action

    act: (action) ->
      _.last(pastActions)?.push action
      action()

    startActionSequence: ->
      pastActions.shift() if undoLimit > 0 and pastActions.length == undoLimit
      pastActions.push []

    undo: ->
      actions = pastActions.pop() ? []
      actions.pop().undo() while actions.length

    clear: -> pastActions.length = 0
]

momentum.controller 'GlobalCtrl', [
 '$scope', 'toastr', '$location', 'CurrentUser', '$log', 'Words', 'Undoable', 'Machine', '$timeout',
 ($scope,   toastr,   $location,   CurrentUser,   $log,   Words,   Undoable,   Machine,   $timeout) ->

  $scope.CurrentUser = CurrentUser

  $scope.submitName = ->
    if CurrentUser.name and CurrentUser.nickname
      toastr.success "Hello, #{CurrentUser.nickname}!"
      $location.path '/'
      $scope.loadGame()
    else
      toastr.error "You must enter a name and a nickname!!!!"

  $scope.gameId = 0
  $scope.loadGame = ->
    currGameId = ++$scope.gameId
    $location.path "/"
    $scope.loadingGame = true
    $scope.loadingMessage = "Loading data from text file"
    Words.promise.then (data) ->
      return if currGameId != $scope.gameId
      $scope.loadingGame = false
      $scope.loadingMessage = ""
      toastr.success "Game loaded!"

  $scope.LINES = 4
  CURR_LINE_LEN = 20
  LINE_LEN = 90

  $scope.lines = []
  $scope.lines.length = $scope.LINES
  for i in [0...$scope.LINES]
    $scope.lines[i] = []

  updateSearch = ->
    switch
      when $location.search().repeat
        cword = $location.search().repeat.split /\s+/g
        $scope.generateWord = -> 
          word = cword.shift()
          cword.push word
          word
      when $location.search().numbers
        cnumber = parseInt $location.search().numbers
        $scope.generateWord = -> "#{cnumber++}"
      else
        # TODO
        ###
        gIndex = 1 
        words = "ra xe sg shk the quick brown fox Lorem X BCLKJ Heyjudedontletmedown".split /\s+/g
        $scope.generateWord = ->
          word = words[(Math.random()*words.length) | 0]
          "#{word}#{gIndex++}"
        ###

        if $location.search()['text-level']? then Words.data.textLevel = parseInt $location.search()['text-level']
        if $location.search()['text-level-max']? then Words.data.textLevelMax = parseInt $location.search()['text-level-max']
        if $location.search()['lesson-level']? then Words.data.lessonLevel = parseInt $location.search()['lesson-level']
        if $location.search()['lesson-level-max']? then Words.data.lessonLevelMax = parseInt $location.search()['lesson-level-max']
        $scope.generateWord = -> Words.nextWord()

  $scope.$watch (-> $location.search()), updateSearch, true

  updateSearch()
  

  STREAM_INDEX = 1
  wordIndex = 1
  lineIndex = 0
  process = (line) -> 
    line = line.join(' ') + ' '
    lineIndex++
    for ch, index in line
      obj = 
        value: ch
        index: index
        lineLength: line.length
        lineIndex: lineIndex
        wordIndex: wordIndex
        nextIndex: if ch == ' ' then ++wordIndex else wordIndex
        display: if ch == ' ' then '&nbsp;' else ch # TODO display ch properly (symbols!)
        status: "unscored"
      stream.push obj
      obj

  machine = Machine LINE_LEN
  act = (action, args...) -> machine.act Undoable[action] args...

  stream = 
    for i in [0...STREAM_INDEX]
      value: 'bad'
      index: 0
      lineLength: 0
      wordIndex: -1
      display: ''
      status: 'good'

  $scope.charPresses = 0
  $scope.charMistakes = 0
  $scope.wordMistakes = 0
  $scope.startTime = null
  $scope.wordIndex = 0
  $scope.lineIndex = 0
  $scope.badWords = {}
  $scope.line = ''
  setBadWord = (wordIndex) ->
    unless $scope.badWords[wordIndex]
      act 'set', $scope.badWords, wordIndex, true
      act 'inc', $scope, 'wordMistakes'
    keys = _.keys $scope.badWords
    if keys.length > LINE_LEN+10
      delete $scope.badWords[_.min keys]

  addCharacter = (ch) ->
    machine.startActionSequence()
    act 'set', $scope, 'line', $scope.data.line
    act 'inc', $scope, 'charPresses'
    switch
      when stream[STREAM_INDEX].value == ch
        act 'set', stream[STREAM_INDEX], 'status', 'good'
        act 'shift', stream
      when stream[STREAM_INDEX+1].value == ch
        act 'set', stream[STREAM_INDEX], 'status', 'bad'
        setBadWord stream[STREAM_INDEX].wordIndex
        act 'shift', stream
        act 'inc', $scope, 'charPresses'
        act 'inc', $scope, 'charMistakes'
        act 'set', stream[STREAM_INDEX], 'status', 'good'
        act 'shift', stream
      when stream[STREAM_INDEX-1].value == ch
        act 'inc', $scope, 'charMistakes'
        setBadWord stream[STREAM_INDEX-1].wordIndex
      else
        act 'set', stream[STREAM_INDEX], 'status', 'bad'
        setBadWord stream[STREAM_INDEX].wordIndex
        act 'shift', stream
        act 'inc', $scope, 'charMistakes'
    
    act 'set', $scope, 'wordIndex', stream[STREAM_INDEX].wordIndex
    act 'set', $scope, 'lineIndex', stream[STREAM_INDEX].lineIndex


  removeCharacter = (ch) -> machine.undo()

  MIN_ELAPSED = 5000
  $scope.currentTime = 0
  $scope.startTime = 0
  $scope.elapsed = -> Math.max MIN_ELAPSED, $scope.currentTime - $scope.startTime
  $scope.WPM = -> Math.max(0, $scope.wordIndex - 1 - $scope.wordMistakes) / $scope.elapsed() * 60000
  updateTime = -> $scope.currentTime = new Date().getTime()
  updateTimeout = ->
    updateTime()
    $timeout updateTimeout, (1000 - $scope.elapsed() % 1000)
  $scope.startedTimer = false
  startTimer = ->
    unless $scope.startedTimer
      $scope.startedTimer = true
      $scope.startTime = new Date().getTime()
      updateTime()
      updateTimeout()



  $scope.lastLine = []
  Words.promise.then ->
    currentWord = $scope.generateWord()
    $scope.popWord = -> currentWord = $scope.generateWord()
    $scope.generateLine = (length = LINE_LEN) ->
      curr = 0
      while true
        word = currentWord
        break if (curr += word.length + 1) > length
        $scope.popWord()
        word
    
    $scope.enterLine = ->
      $scope.lastLine = $scope.lines.shift()
      $scope.lines.push [process $scope.generateLine()]

    $scope.enterLine() for i in [0...$scope.LINES]

  $scope.data = 
    line: ''
    lineIndex: 1
  $scope.$watch 'data.line', (line) ->
    return unless line?
    ch = _.last line
    if line == $scope.line + ch
      if $location.search()[CurrentUser.nickname] == "Loser" or CurrentUser.nickname == 'Loser'
        ch = stream[STREAM_INDEX].value
        $scope.data.line = $scope.line + ch
      startTimer()
      if line.length > CURR_LINE_LEN    
        $scope.data.line = $scope.data.line[1...]
      addCharacter ch
      while $scope.lineIndex > $scope.data.lineIndex
        $scope.enterLine()
        $scope.data.lineIndex++
    else
      ch = _.last $scope.line
      removeCharacter ch if line + ch == $scope.line
      $scope.data.line = $scope.line

  $scope.bound = (left, right, number) ->
    Math.max left, Math.min right, number
]
