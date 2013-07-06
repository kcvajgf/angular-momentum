
momentum = angular.module "Momentum.resources", ['ngResource']

momentum.factory 'User', ['$resource', ($resource) ->
  $resource '/api/users/:id', 
    id: '@id'
  ,
    update:
      method: 'PUT'
]
