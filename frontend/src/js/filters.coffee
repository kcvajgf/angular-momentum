
momentum = angular.module "Momentum.filters", []

momentum.filter 'htmlEscape', [->
  (str) -> _.escape str
]