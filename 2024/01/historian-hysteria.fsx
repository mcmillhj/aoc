open System.IO

let input =
    File.ReadAllLines(Path.Combine(__SOURCE_DIRECTORY__, "input.txt")) |> List.ofSeq

let parse (lines: string list) =
    lines
    |> List.map (fun line -> line.Split("   ") |> Seq.map (int) |> Seq.toList)
    |> List.transpose
    |> List.map List.sort

let [ left; right: int list ] = parse input

let distance_sum =
    List.zip left right |> List.map (fun (a, b) -> abs (a - b)) |> List.sum

let frequencies = right |> List.countBy id |> Map.ofList

let similarity_score =
    [ for e in left -> e * (frequencies |> Map.tryFind e |> Option.defaultValue 0) ]
    |> List.sum

printf "%s", distance_sum
printf "%s", similarity_score
