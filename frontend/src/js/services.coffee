
momentum = angular.module "Momentum.services", []

momentum.factory 'toastr', [-> 
  toastr.options.positionClass = 'toast-top-center'
  toastr
]

momentum.factory 'CurrentUser', [
 '$q', '$http', '$window', '$timeout', '$rootScope', '$location',
 ($q,   $http,   $window,   $timeout,   $rootScope,   $location) ->
  {}
]

momentum.service 'util', [
  class
    sUnion: (curr, strs...) ->
      for str in strs
        for letter in str
          curr += letter unless letter in curr
      curr

    sIntersection: (curr, strs...) ->
      for str in strs
        bago = ''
        for letter in str
          bago += letter if letter in curr
        curr = bago
      curr

    addSet: (st, val) ->
      if val of st
        st[val]++
      else
        st[val] = 1

    goodInBank: (bank, words...) ->
      for word in words
        for letter in word
          return false if letter not of bank
      true

    chainDict: (obj, first, words..., last) ->
      oobj = {}
      ofirst = first
      for word in words
        obj = obj[first] ?= {}
        first = word
      obj[first] ?= {}
      @addSet obj[first], last  

    chainGet: (obj, keys...) ->
      obj = obj[key] for key in keys
      obj
]
momentum.factory 'Words', [
 '$http', '$q', '$timeout', 'util',
 ($http,   $q,   $timeout,   util) ->


  sample = "The quick brown fox jumps over the lazy dog."
  textWrapper = sample + sample + sample
  lowers = "abcdefghijklmnopqrstuvwxyz"
  uppers = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  digits = "0123456789"
  puncts = ";,:.?!"
  spacelikes = """/-+_@"""
  wrapSymbols = """'"()[]{}<>`"""
  symbols = "=$%^&#*~|\\"
  spaces = """ \t\n"""
  allSymbols = puncts + spacelikes + wrapSymbols + symbols
  letters = lowers + uppers
  alphanumerics = letters + digits
  textLevels = [
    lowers + uppers + digits + allSymbols
  ]
  wraps = [
    "''"
    '""'
    "()"
    "[]"
    "{}"
    "<>"
    "``"
  ]
  lessonLevels = [
    '''asdf jkl;'''
    '''ASDFJKL'''
    '''rtyu'''
    '''RTYU\t'''
    '''cvb'''
    '''CVB'''
    '''nm,:'''
    '''NM\n'''
    '''wxo.'''
    '''WXO'''
    '''qzp'"'''
    '''QZP'''
    '''/?<>'''
    '''-=_+[]'''
    '''4567'''
    '''$%^&'''
    '''38'''
    '''#*{}'''
    '''290'''
    '''@()'''
    '''1!'''
    '''`~\|'''
  ]
  textLevel = {}
  for letters, level in textLevels
    textLevel[c] = level for c in letters
  lessonLevel = {}
  for letters, level in lessonLevels
    lessonLevel[c] = level for c in letters

  textLevelBanks = {}
  lessonLevelBanks = {}
  levelBanks = {}
  for letters, index in textLevels
    bank = {}
    bank[letter] = index for letter in util.sUnion textLevels[..index]...
    textLevelBanks[index] = bank
  for letters, index in lessonLevels
    bank = {}
    bank[letter] = index for letter in util.sUnion lessonLevels[..index]...
    lessonLevelBanks[index] = bank
  for letters, index in textLevels
    levelBanks[index] = {}
    for letters, lIndex in lessonLevels
      bank = {}
      bank[letter] = index for letter in util.sIntersection util.sUnion(textLevels[..index]...), util.sUnion(lessonLevels[..lIndex]...)
      levelBanks[index][lIndex] = bank

  opens = ""
  closes = ""
  pairs = {}
  for pair in wraps
    opens += pair[0]
    closes += pair[1]
    pairs[pair[0]] = pair[1]
    pairs[pair[1]] = pair[0]

  textObj = $q.defer()
  cornObj = $q.defer()
  lowerTextObj = $q.defer()
  textLevelSplitsObj = $q.defer()
  originalCasesObj = $q.defer()
  wordsObj = $q.defer()
  bigramsObj = $q.defer()
  trigramsObj = $q.defer()
  quadgramsObj = $q.defer()


  loadWords = ->
    # TODO use masc_total_2
    $http.get("/assets/masc_total_2_300.txt").success (text, status, header, config) ->
      console.log "RESOLVE lll"
      textObj.resolve textWrapper + text + textWrapper
      console.log "RESOLVE lll"

    $http.get("/assets/corncob_lowercase.txt").success (text, status, header, config) ->
      console.log "RESOLVE corn"
      cornObj.resolve text
      console.log "RESOLVE corn"

    textObj.promise.then (text) ->
      $timeout ->
        console.log "RESOLVE lower"
        lowerTextObj.resolve text.toLowerCase()
        console.log "RESOLVE lower"

    textObj.promise.then (text) ->
      $timeout ->
        textLevelSplits = {}
        $q.all(
          for letters, level in textLevels
            obj = $q.defer()
            do (level, obj) ->
              $timeout ->
                levelSplit = []
                textBank = textLevelBanks[level]
                accWord = ''
                for c in text
                  if c of textBank
                    accWord += c
                  else 
                    levelSplit.push accWord if accWord
                    accWord = ''
                levelSplit.push accWord if accWord
                textLevelSplits[level] = levelSplit
                obj.resolve()
            obj.promise
        ).then ->
          console.log "RESOLVE tp"
          textLevelSplitsObj.resolve textLevelSplits
          console.log "RESOLVE tp"

    textLevelSplitsObj.promise.then (textLevelSplits) ->
      $timeout ->
        originalCases = {}
        for level, words of textLevelSplits
          for word in words
            nword = word.toLowerCase()
            originalCases[nword] ?= {}
            util.addSet originalCases[nword], word
        console.log "RESOLVE orgc", originalCases
        originalCasesObj.resolve originalCases
        console.log "RESOLVE orgc"

    textLevelSplitsObj.promise.then (textLevelSplits) ->
      $timeout ->
        words = {}
        # TODO loop asynchronously
        for letters, lesson in lessonLevels
          words[lesson] = {}
          textBank = lessonLevelBanks[lesson]
          for letters, level in textLevels
            words[lesson][level] = {}
            for word in textLevelSplits[level]
              util.addSet words[lesson][level], word if util.goodInBank textBank, word
        
        cornObj.promise.then (corn) ->
          cornSplit = corn.trim().split /\s+/g
          # TODO loop asynchronously
          for letters, lesson in lessonLevels
            textBank = lessonLevelBanks[lesson]
            for letters, level in textLevels
              for word in cornSplit
                util.addSet words[lesson][level], word if util.goodInBank textBank, word

          console.log "RESOLVE wdas"
          wordsObj.resolve words
          console.log "RESOLVE wdas"

    for grams, gIndex in [bigramsObj, trigramsObj, quadgramsObj]
      do (grams, gIndex) ->
        textLevelSplitsObj.promise.then (textLevelSplits) ->
          console.log "DITO", gIndex, textLevelSplits
          $timeout ->
            gramMap = {}
            for letters, lesson in lessonLevels # TODO split asynchronously
              gramMap[lesson] = {}
              textBank = lessonLevelBanks[lesson]
              for letters, level in textLevels 
                gramMap[lesson][level] = {}
                splits = textLevelSplits[level]
                for word, index in splits
                  continue if index <= gIndex
                  util.chainDict gramMap[lesson][level], splits[index-gIndex-1..index]... if util.goodInBank textBank, splits[index-gIndex-1..index]...
            console.log "RESOLVE", gIndex
            grams.resolve gramMap
            console.log "RESOLVE", gIndex

  randomChoice = (arr) ->
    arr = _.keys arr
    arr[(Math.random() * arr.length) | 0]


  data = 
    textLevel: textLevels.length-1
    textLevelMax: textLevels.length-1
    lessonLevel: 0
    lessonLevelMax: lessonLevels.length-1
    lessonDelta: 30#100
    textDelta: 400

  _data = {}
  wordsObj.promise.then (words) -> _data.words = words
  bigramsObj.promise.then (bigrams) -> _data.bigrams = bigrams
  trigramsObj.promise.then (trigrams) -> _data.trigrams = trigrams
  quadgramsObj.promise.then (quadgrams) -> _data.quadgrams = quadgrams
  words = []
  wordCount = 0

  console.log "HEREX"
  nextWord: ->
    #console.log "nextWord"
    lesson = data.lessonLevel
    level = data.textLevel
    chance = Math.random()
    switch
      when chance < 0.008 and words.length >= 3 and (get = util.chainGet _data.quadgrams[lesson][level], words[words.length-3..])
        newWord = randomChoice get
      when chance < 0.05 and words.length >= 2 and (get = util.chainGet _data.trigrams[lesson][level], words[words.length-2..])
        newWord = randomChoice get
      when chance < 0.3 and words.length >= 1 and (get = util.chainGet _data.bigrams[lesson][level], words[words.length-1..])
        newWord = randomChoice get
      when (get = util.chainGet _data.words[lesson][level])
        newWord = randomChoice get

    unless newWord? then newWord = 'foo'

    if Math.random() < 0.1 and util.goodInBank lessonLevelBanks[lesson], newWord[0].toUpperCase()
      newWord = newWord[0].toUpperCase() + newWord[1..]

    words.unshift() if words.length > 4
    words.push newWord

    wordCount++
    data.lessonLevel++ if data.lessonLevel < data.lessonLevelMax and wordCount % data.lessonDelta == 0
    data.textLevel++ if data.textLevel < data.textLevelMax and wordCount % data.textDelta == 0

    #console.log "got word", newWord
    newWord

  data: data
  textPromise: textObj.promise
  lowerTextPromise: lowerTextObj.promise
  textLevelSplitsPromise: textLevelSplitsObj.promise
  cornPromise: cornObj.promise
  originalCasesPromise: originalCasesObj.promise
  words: wordsObj.promise
  bigrams: bigramsObj.promise
  trigrams: trigramsObj.promise
  quadgrams: quadgramsObj.promise
  loadWords: loadWords
  promise: $q.all [
    textObj.promise
    lowerTextObj.promise
    textLevelSplitsObj.promise
    cornObj.promise
    #originalCasesObj.promise
    wordsObj.promise
    bigramsObj.promise
    trigramsObj.promise
    quadgramsObj.promise
  ]
]

momentum.filter 'opacity', [->
  (index, last) ->
    if index == last
      0.25
    else if index == last-1
      0.5
    else if index == last-2
      0.75
    else if index == 0
      0.4
    else if index == 1
      0.8
    else
      1

]

momentum.filter "bound", [->
  (number, left, right) ->
    Math.max left, Math.min right, number
]
###

TODO moving gradient progress bar
TODO google charts if may internet
  WPM over time
  accuracy (words) over time
  accuracy (letters) over time
symbols random
capitalization random
probability adjustments

hands

restart game

loading messages

keyboard highlighting present letters so far! (lesson ID in char obj)
###
