let
  Source = #"02_basic_traffic",
  #"Removed columns" = Table.RemoveColumns(Source, {"Poort", "Ratio", "CustomerID"})
in
  #"Removed columns"
