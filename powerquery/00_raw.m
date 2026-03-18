let
  Source = Excel.Workbook(File.Contents(pFilePath), null, true),
  #"Navigation 1" = Source{[Item = "202501", Kind = "Sheet"]}[Data],
  #"Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"CustomerID", type text}, {"Leeftijd", Int64.Type}, {"Abonnement / addon", type text}, {"Binnen geweest op", type datetime}, {"Poort", type text}, {"Ratio", type text}}, "en-US")
in
  #"Changed column type"
