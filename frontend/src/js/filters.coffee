
momentum = angular.module "Momentum.filters", []

momentum.filter 'timeFrom', [->
  (dateTo, dateFrom) ->
    to = new Date dateTo
    from = new Date dateFrom
    diff = to - from
    p2 = (x) ->
      x = str(x)
      return "00" if x.length == 0
      return "0" + x if x.length == 1
      return x
    if diff <= 0
      'Released now!'
    else if diff <= 1000*60
      "#{diff / 1000 >> 0} seconds remaining"
    else if diff <= 1000*60*60*48
      "#{p2(diff / (1000*60*60) >> 0)}:#{p2((diff / (1000*60) >> 0) % 60)}:#{p2((diff / 1000 >> 0) % 60)} remaining"
    else
      "#{diff / (1000*60*60*24) >> 0} days, #{(diff / (1000*60*60) >> 0) % 24} hours remaining"
]
