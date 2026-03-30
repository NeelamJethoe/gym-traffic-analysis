let
    Source = #"03_dates",

    #"Kept columns" = Table.SelectColumns(Source, {"Date", "Day name"}),

    #"Removed duplicates" = Table.Distinct(#"Kept columns", {"Date", "Day name"}),

    #"Added OpenTime" = Table.AddColumn(#"Removed duplicates", "OpenTime", each 
        if [Day name] = "Friday" then #time(7,0,0)
        else if [Day name] = "Saturday" then #time(7,30,0)
        else if [Day name] = "Sunday" then #time(8,30,0)
        else #time(7,0,0),
        type time
    ),

    #"Added CloseTime" = Table.AddColumn(#"Added OpenTime", "CloseTime", each 
        if [Day name] = "Friday" then #time(21,30,0)
        else if [Day name] = "Saturday" then #time(18,0,0)
        else if [Day name] = "Sunday" then #time(18,0,0)
        else #time(22,30,0),
        type time
    ),

    #"Added SlotList" = Table.AddColumn(#"Added CloseTime", "SlotList", each let
        openT = [OpenTime],
        closeT = [CloseTime]
    in
        List.Generate(
            () => openT,
            each _ < closeT,
            each _ + #duration(0,0,30,0)
        )
    ),

    #"Expanded SlotList" = Table.ExpandListColumn(#"Added SlotList", "SlotList"),

    #"Added TimeSlot30" = Table.AddColumn(#"Expanded SlotList", "TimeSlot30", each 
        Time.ToText([SlotList], "HH:mm") & "-" & 
        Time.ToText([SlotList] + #duration(0,0,30,0), "HH:mm"),
        type text
    ),

    #"Removed columns" = Table.RemoveColumns(#"Added TimeSlot30", {"Date", "Day name", "OpenTime", "CloseTime", "SlotList"}),

    #"Grouped rows" = Table.Group(#"Removed columns", {"TimeSlot30"}, {{"PossibleOpenDays", each Table.RowCount(_), Int64.Type}}),

    #"Sorted rows" = Table.Sort(#"Grouped rows", {{"TimeSlot30", Order.Ascending}})
in
    #"Sorted rows"
