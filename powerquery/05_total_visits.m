let
  Source = #"02_basic_traffic",
  #"Removed columns" = Table.RemoveColumns(Source, {"Day name", "Date", "Ratio", "Poort", "Binnen geweest op", "CustomerID"}),
  #"Grouped rows" = Table.Group(#"Removed columns", {"TimeSlot30"}, {{"TotalVisits", each Table.RowCount(_), Int64.Type}}),
  #"Merged queries" = Table.NestedJoin(#"Grouped rows", {"TimeSlot30"}, #"04_possible_open_days", {"TimeSlot30"}, "04_possible_open_days", JoinKind.LeftOuter),
  #"Expanded 04_possible_open_days" = Table.ExpandTableColumn(#"Merged queries", "04_possible_open_days", {"PossibleOpenDays"}, {"PossibleOpenDays"}),
  #"Added custom" = Table.AddColumn(#"Expanded 04_possible_open_days", "AvgVisitsPerPossibleOpenDay", each if [PossibleOpenDays] = null or [PossibleOpenDays] = 0 then null
else [TotalVisits] / [PossibleOpenDays]),
  #"Sorted rows" = Table.Sort(#"Added custom", {{"TimeSlot30", Order.Ascending}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Sorted rows", {{"AvgVisitsPerPossibleOpenDay", type number}})
in
  #"Changed column type"
