let
  Source = Excel.Workbook(File.Contents(pFilePath), null, true),
  #"Navigation 1" = Source{[Item = "202501", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true]),
  #"Converted Binnen safely" = Table.TransformColumns(
      #"Promoted headers",
      {{"Binnen geweest op", each try DateTime.From(_) otherwise null, type nullable datetime}}
  ),
  #"Filtered valid datetimes" = Table.SelectRows(#"Converted Binnen safely", each [Binnen geweest op] <> null)
in
  #"Filtered valid datetimes"
