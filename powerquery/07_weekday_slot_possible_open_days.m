let
  Source = #"03_dates",
  #"Removed columns" = Table.RemoveColumns(Source, {"TimeSlot30", "Binnen geweest op"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"Date", "Day name"}),
  #"Added custom" = Table.AddColumn(#"Removed duplicates", "OpenTime", each if [Day name] = "Friday" then #time(7,0,0)
else if [Day name] = "Saturday" then #time(7,30,0)
else if [Day name] = "Sunday" then #time(8,30,0)
else #time(7,0,0)),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "CloseTime", each if [Day name] = "Friday" then #time(21,30,0)
else if [Day name] = "Saturday" then #time(18,0,0)
else if [Day name] = "Sunday" then #time(18,0,0)
else #time(22,30,0)),
  #"Added custom 2" = Table.AddColumn(#"Added custom 1", "SlotList", each let
    openT = [OpenTime],
    closeT = [CloseTime]
in
    List.Generate(
        () => openT,
        each _ < closeT,
        each _ + #duration(0,0,30,0)
    )),
  #"Expanded SlotList" = Table.ExpandListColumn(#"Added custom 2", "SlotList"),
  #"Added custom 3" = Table.AddColumn(#"Expanded SlotList", "TimeSlot30", each Time.ToText([SlotList], "HH:mm") & "-" & Time.ToText([SlotList] + #duration(0,0,30,0), "HH:mm")),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom 3", {"Date", "OpenTime", "CloseTime", "SlotList"}),
  #"Grouped rows" = Table.Group(#"Removed columns 1", {"Day name", "TimeSlot30"}, {{"PossibleOpenDays", each Table.RowCount(_), Int64.Type}}),
  #"Added custom 4" = Table.AddColumn(#"Grouped rows", "DayShort", each if [Day name] = "Monday" then "Mon"
else if [Day name] = "Tuesday" then "Tue"
else if [Day name] = "Wednesday" then "Wed"
else if [Day name] = "Thursday" then "Thu"
else if [Day name] = "Friday" then "Fri"
else if [Day name] = "Saturday" then "Sat"
else if [Day name] = "Sunday" then "Sun"
else null)
in
  #"Added custom 4"
