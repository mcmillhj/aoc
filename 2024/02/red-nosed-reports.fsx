open System.IO

type Report = int list

let reports =
    File.ReadAllLines(Path.Combine(__SOURCE_DIRECTORY__, "input.txt"))
    |> List.ofSeq
    |> List.map (fun line -> line.Split(" ") |> Seq.map (int) |> Seq.toList)

let isReportDecreasing (report: Report) =
    report
    |> List.pairwise
    |> List.forall (fun reportPair -> snd reportPair < fst reportPair)

let isReportIncreasing (report: Report) =
    report
    |> List.pairwise
    |> List.forall (fun reportPair -> snd reportPair > fst reportPair)

let hasUnsafeLevelChange (report: Report) =
    report
    |> List.pairwise
    |> List.exists (fun reportPair ->
        let levelChange = abs (snd reportPair - fst reportPair) in levelChange = 0 || levelChange > 3)


let isSafeReport (report: Report) =
    (isReportDecreasing report || isReportIncreasing report)
    && not (hasUnsafeLevelChange report)

let isSafeAfterDampening (unsafeReport: Report) =
    unsafeReport
    |> List.mapi (fun index level -> index)
    |> List.exists (fun index -> isSafeReport (List.removeAt index unsafeReport))

let safeReports, unsafeReports = reports |> List.partition isSafeReport
printf "%d", safeReports.Length

let safeReportsAfterDampening = unsafeReports |> List.filter isSafeAfterDampening
printf "%d", safeReports.Length + safeReportsAfterDampening.Length
