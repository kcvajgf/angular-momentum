
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

momentum.factory 'Words', [
 '$http', '$q', '$timeout',
 ($http,   $q,   $timeout) ->


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
    letters
    digits
    allSymbols
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

  sUnion = (curr, strs...) ->
    for str in strs
      for letter in str
        curr += letter unless letter in curr
    curr

  sIntersection = (curr, strs...) ->
    for str in strs
      bago = ''
      for letter in str
        bago += letter if letter in curr
      curr = bago
    curr

  textLevelBanks = {}
  lessonLevelBanks = {}
  levelBanks = {}
  for letters, index in textLevels
    bank = {}
    bank[letter] = index for letter in sUnion textLevels[..index]...
    textLevelBanks[index] = bank
  for letters, index in lessonLevels
    bank = {}
    bank[letter] = index for letter in sUnion lessonLevels[..index]...
    lessonLevelBanks[index] = bank
  for letters, index in textLevels
    levelBanks[index] = {}
    for letters, lIndex in lessonLevels
      bank = {}
      bank[letter] = index for letter in sIntersection sUnion(textLevels[..index]...), sUnion(lessonLevels[..lIndex]...)
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
  lowerTextObj = $q.defer()
  textLevelSplitsObj = $q.defer()
  originalCasesObj = $q.defer()
  wordsObj = $q.defer()
  bigramsObj = $q.defer()
  trigramsObj = $q.defer()
  quadgramsObj = $q.defer()


  # TODO use masc_total_2
  $http.get("/assets/masc_total_2_bak.txt").success (text, status, header, config) ->
    textObj.resolve textWrapper + text + textWrapper

  textObj.promise.then (text) ->
    $timeout ->
      lowerTextObj.resolve text.toLowerCase()

  textObj.promise.then (text) ->
    $timeout ->
      textLevelSplits = {}
      $q.all(
        for letters, level in textLevels # TODO asynchronously split work
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
        textLevelSplitsObj.resolve textLevelSplits

  textLevelSplitsObj.promise.then (textLevelSplits) ->
    $timeout ->
      originalCases = {}
      for level, words of textLevelSplits
        for word in words
          nword = word.toLowerCase()
          originalCases[nword] ?= []
          originalCases[nword].push word
      originalCasesObj.resolve originalCases

  goodInBank = (bank, words...) ->
    for word in words
      for letter in word
        return false if letter not of bank
    true

  textLevelSplitsObj.promise.then (textLevelSplits) ->
    $timeout ->
      words = {}
      # TODO split asynchronously
      for letters, lesson in lessonLevels
        words[lesson] = {}
        textBank = lessonLevelBanks[lesson]
        for letters, level in textLevels
          words[lesson][level] = []
          for word in textLevelSplits[level]
            words[lesson][level].push word if goodInBank textBank, word

      wordsObj.resolve words

  chainDict = (obj, first, words..., last) ->
    for word in words
      obj[first] ?= {}
      first = word
    obj[first] ?= []
    obj[first].push last

  chainGet = (obj, keys...) ->
    obj = obj[key] for key in keys
    obj

  for grams, gIndex in [bigramsObj, trigramsObj, quadgramsObj]
    do (grams, gIndex) ->
      textLevelSplitsObj.promise.then (textLevelSplits) ->
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
                chainDict gramMap[lesson][level], splits[index-gIndex-1..index]... if goodInBank textBank, splits[index-gIndex-1..index]...
          grams.resolve gramMap
          if gIndex == 2
            window.foou = gramMap

  randomChoice = (arr) ->
    arr[(Math.random() * arr.length) | 0]
  data = 
    textLevel: textLevels.length-1
    textLevelMax: textLevels.length-1
    lessonLevel: 0
    lessonLevelMax: lessonLevels.length-1
    lessonDelta: 100
    textDelta: 400

  _data = {}
  wordsObj.promise.then (words) -> _data.words = words
  bigramsObj.promise.then (bigrams) -> _data.bigrams = bigrams
  trigramsObj.promise.then (trigrams) -> _data.trigrams = trigrams
  quadgramsObj.promise.then (quadgrams) -> _data.quadgrams = quadgrams
  words = []
  wordCount = 0
  nextWord: ->
    words.unshift() if words.length > 4
    lesson = data.lessonLevel
    level = data.textLevel
    chance = Math.random()
    switch
      when chance < 0.01 and words.length >= 3 and (get = chainGet _data.quadgrams[lesson][level], words[words.length-3..])
        newWord = randomChoice get
      when chance < 0.1 and words.length >= 2 and (get = chainGet _data.trigrams[lesson][level], words[words.length-2..])
        newWord = randomChoice get
      when chance < 0.4 and words.length >= 1 and (get = chainGet _data.bigrams[lesson][level], words[words.length-1..])
        newWord = randomChoice get
      when (get = chainGet _data.words[lesson][level])
        newWord = randomChoice get

    unless newWord? then newWord = 'foo'
    words.push newWord

    wordCount++
    data.lessonLevel++ if wordCount % data.lessonDelta == 0
    data.textLevel++ if wordCount % data.textDelta == 0

    newWord

  data: data
  textPromise: textObj.promise
  lowerTextPromise: lowerTextObj.promise
  textLevelSplitsPromise: textLevelSplitsObj.promise
  originalCasesPromise: originalCasesObj.promise
  words: wordsObj.promise
  bigrams: bigramsObj.promise
  trigrams: trigramsObj.promise
  quadgrams: quadgramsObj.promise
  promise: $q.all [
    textObj.promise
    lowerTextObj.promise
    textLevelSplitsObj.promise
    originalCasesObj.promise
    wordsObj.promise
    bigramsObj.promise
    trigramsObj.promise
    quadgramsObj.promise
  ]
]

