let
    Source = #"00_raw",
    #"Sorted rows" = Table.Sort(Source, {{"CustomerID", Order.Ascending}, {"Binnen geweest op", Order.Ascending}}),
    #"Added index" = Table.AddIndexColumn(#"Sorted rows", "Index", 1, 1, Int64.Type),
    #"Choose columns" = Table.SelectColumns(#"Added index", {"Index", "CustomerID", "Binnen geweest op"})
in
    #"Choose columns"
