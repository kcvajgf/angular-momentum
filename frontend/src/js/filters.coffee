
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

momentum.filter 'timeElapsed', [->
  (diff, a, b) ->
    if diff < 0
      return "negative time"
    if diff == 0
      return "0 seconds"
    diff /= 1000
    secs = diff % 60 >> 0
    diff /= 60
    mins = diff % 60 >> 0
    diff /= 60
    hours = diff % 24 >> 0
    diff /= 24
    ts = []
    if diff > 1
      ts.push "#{diff} days"
    if diff == 1
      ts.push "#{diff} day"
    if hours > 1
      ts.push "#{hours} hours"
    if hours == 1
      ts.push "#{hours} hour"
    if mins > 1
      ts.push "#{mins} minutes"
    if mins == 1
      ts.push "#{mins} minute"
    if secs > 1
      ts.push "#{secs} seconds"
    if secs == 1
      ts.push "#{secs} second"
    return ts.join ', '
]