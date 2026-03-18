let
  Source = #"01_dedup_30min",
  #"Removed columns" = Table.RemoveColumns(Source, {"Leeftijd", "Abonnement / addon", "IsDuplicate30"}),
  #"Inserted date" = Table.AddColumn(#"Removed columns", "Date", each DateTime.Date([Binnen geweest op]), type nullable date),
  #"Inserted day of week" = Table.AddColumn(#"Inserted date", "Day of week", each Date.DayOfWeek([Binnen geweest op]), type nullable number),
  #"Removed columns 1" = Table.RemoveColumns(#"Inserted day of week", {"Day of week"}),
  #"Inserted day name" = Table.AddColumn(#"Removed columns 1", "Day name", each Date.DayOfWeekName([Binnen geweest op]), type nullable text),
  #"Added custom 1" = Table.AddColumn(#"Inserted day name", "Custom", each let
    SlotStart = #time(
        Time.Hour([Binnen geweest op]),
        if Time.Minute([Binnen geweest op]) < 30 then 0 else 30,
        0
    ),
    SlotEnd = SlotStart + #duration(0, 0, 30, 0)
in
    Time.ToText(SlotStart, "HH:mm") & "-" & Time.ToText(SlotEnd, "HH:mm")),
  #"Renamed columns" = Table.RenameColumns(#"Added custom 1", {{"Custom", "TimeSlot30"}})
in
  #"Renamed columns"
