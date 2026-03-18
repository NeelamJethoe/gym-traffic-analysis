let
  Source = #"00_raw",
  #"Sorted rows" = Table.Sort(Source, {{"CustomerID", Order.Ascending}, {"Binnen geweest op", Order.Ascending}}),
  #"Added index" = Table.AddIndexColumn(#"Sorted rows", "Index", 0, 1, Int64.Type),
  #"Merged queries" = Table.NestedJoin(#"Added index", {"Index"}, prev, {"Index"}, "prev", JoinKind.LeftOuter),
  #"Expanded prev" = Table.ExpandTableColumn(#"Merged queries", "prev", {"CustomerID", "Binnen geweest op"}, {"CustomerID.1", "Binnen geweest op.1"}),
  #"Added custom" = Table.AddColumn(#"Expanded prev", "DiffMinutes", each if [Binnen geweest op.1] = null then null
else Duration.TotalMinutes([Binnen geweest op] - [Binnen geweest op.1])),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "IsDuplicate30", each if [Binnen geweest op.1] = null then false
else if [CustomerID] = [CustomerID.1] and [DiffMinutes] >= 0 and [DiffMinutes] <= 30 then true
else false),
   #"Filtered rows" = Table.SelectRows(#"Added custom 1", each [IsDuplicate30] = false),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Index", "CustomerID.1", "Binnen geweest op.1", "DiffMinutes"})
in
  #"Removed columns"
