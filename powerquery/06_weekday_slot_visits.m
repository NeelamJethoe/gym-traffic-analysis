let
  Source = #"02_basic_traffic",
  #"Grouped rows" = Table.Group(Source, {"Day name", "TimeSlot30"}, {{"Visits", each Table.RowCount(_), Int64.Type}}),
  #"Merged queries" = Table.NestedJoin(#"Grouped rows", {"Day name", "TimeSlot30"}, #"07_weekday_slot_possible_open_days", {"Day name", "TimeSlot30"}, "07_weekday_slot_possible_open_days", JoinKind.LeftOuter),
  #"Expanded 07_weekday_slot_possible_open_days" = Table.ExpandTableColumn(#"Merged queries", "07_weekday_slot_possible_open_days", {"PossibleOpenDays"}, {"PossibleOpenDays"}),
  #"Added custom" = Table.AddColumn(#"Expanded 07_weekday_slot_possible_open_days", "AvgVisitorsPerOpenSlot", each if [PossibleOpenDays] = null or [PossibleOpenDays] = 0 then null else [Visits] / [PossibleOpenDays], type number),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "DayOrder", each if [Day name] = "Monday" then 1
else if [Day name] = "Tuesday" then 2
else if [Day name] = "Wednesday" then 3
else if [Day name] = "Thursday" then 4
else if [Day name] = "Friday" then 5
else if [Day name] = "Saturday" then 6
else if [Day name] = "Sunday" then 7
else null, Int64.Type),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "DayShort", each if [Day name] = "Monday" then "Mon"
else if [Day name] = "Tuesday" then "Tue"
else if [Day name] = "Wednesday" then "Wed"
else if [Day name] = "Thursday" then "Thu"
else if [Day name] = "Friday" then "Fri"
else if [Day name] = "Saturday" then "Sat"
else if [Day name] = "Sunday" then "Sun"
else null, type text),
  #"Sorted rows" = Table.Sort(#"Added custom 2", {{"TimeSlot30", Order.Ascending}, {"DayOrder", Order.Ascending}})
in
  #"Sorted rows"
