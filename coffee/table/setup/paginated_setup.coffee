class PaginatedSetup extends Setup

  constructor: (table_configuration) ->
    @table_configuration = table_configuration
    @repeatString = "item in sorted_and_paginated_list"

  compile: (element) ->
    tbody = @setupTr(element, @repeatString)

    tds = element.find("td")
    tdString = ""
    for td in tds
      tdString += "<td>&nbsp;</td>"

    # TODO
    fillerTr = angular.element(document.createElement("tr"))
    fillerTr.attr("ng-show", @table_configuration.fill_last_page)
    fillerTr.html(tdString)
    fillerTr.attr("ng-repeat", "item in filler_array")

    tbody.append(fillerTr)

    return

  link: ($scope, $element, $attributes, $filter) ->
    tc = @table_configuration

    w = new ScopeConfigWrapper($scope, tc)

    get_sorted_and_paginated_list = (list, current_page, items_per_page, sort_context, predicate, descending, $filter) ->
      if list
        val = list
        from_page  = items_per_page * current_page - list.length
        if sort_context == "global"
          val = $filter("orderBy")(val, predicate, descending)
          val = $filter("limitTo")(val, from_page)
          val = $filter("limitTo")(val, items_per_page)
        else
          val = $filter("limitTo")(val, from_page)
          val = $filter("limitTo")(val, items_per_page)
          val = $filter("orderBy")(val, predicate, descending)

        return val
      else
        return []

    get_filler_array = (list, current_page, number_of_pages, items_per_page) ->
      items_per_page = parseInt(items_per_page)

      if current_page == number_of_pages - 1
        itemCountOnLastPage = list.length % items_per_page
        if itemCountOnLastPage != 0 || list.length == 0
          fillerLength = items_per_page - itemCountOnLastPage - 1
          x for x in [(list.length)..(list.length + fillerLength)]
        else
          []

    update_stuff = () ->

      $scope.sorted_and_paginated_list = get_sorted_and_paginated_list(
        w.get_list(),
        w.get_current_page(),
        w.get_items_per_page(),
        $scope[tc.sort_context],
        $scope.predicate,
        $scope.descending,
        $filter
      )

      nop = Math.ceil(w.get_list().length / w.get_items_per_page())

      $scope.filler_array = get_filler_array(
        w.get_list(),
        w.get_current_page(),
        nop,
        w.get_items_per_page()
      )

    $scope.$watch(tc.current_page, () ->
      update_stuff()
    )

    $scope.$watch(tc.items_per_page, () ->
      update_stuff()
    )

    $scope.$watch("#{tc.list}.length", () ->
      $scope[irk_number_of_pages] = Math.ceil($scope[tc.list].length / w.get_items_per_page())
      update_stuff()
    )

    $scope.$watch("predicate", () ->
      update_stuff()
    )

    $scope.$watch("descending", () ->
      update_stuff()
    )

