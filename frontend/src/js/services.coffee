
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
    for c in letters
      textLevel[c] = level
  lessonLevel = {}
  for letters, level in lessonLevels
    for c in letters
      lessonLevel[c] = level
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


  $http.get("/assets/masc_total_2_bak.txt").success (text, status, header, config) ->
    textObj.resolve textWrapper + text + textWrapper

  textObj.promise.then (text) ->
    $timeout ->
      lowerTextObj.resolve text.toLowerCase()

  textObj.promise.then (text) ->
    $timeout ->
      textLevelSplits = {}
      textBank = {}
      for letters, level in textLevels # TODO asynchronously split work
        levelSplit = []
        for letter in letters
          textBank[letter] = 1
        accWord = ''
        for c in text
          if c of textBank
            accWord += c
          else if accWord
            levelSplit.push accWord
        textLevelSplits[level] = levelSplit

      textLevelSplitsObj.resolve textLevelSplits

  textLevelSplitsObj.promise.then (textLevelSplits) ->
    $timeout ->
      originalCases = {}
      for level, words of textLevelSplits
        for word in words
          nword = word.toLowerCase()
          originalCases[nword] = [] if nword not of originalCases
          originalCases[nword].push word
      originalCasesObj.resolve originalCases

  # collect unigrams
  # collect bigrams
  # collect trigrams
  # collect quadgrams
  # filter by lessonLevel:
    # unigrams
    # bigrams
    # trigrams
    # quadgrams


  textPromise: textObj.promise
  lowerTextPromise: lowerTextObj.promise
  textLevelSplitsPromise: textLevelSplitsObj.promise
  originalCasesPromise: originalCasesObj.promise
  tokens:1
  unigrams:1 
  bigrams:1
  trigrams: 1
  promise: $q.all [
    textObj.promise
    lowerTextObj.promise
    textLevelSplitsObj.promise
    originalCasesObj.promise
  ]
]
