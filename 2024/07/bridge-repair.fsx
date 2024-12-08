open System.IO

type Equation = int64 * (int64 list)

type Operator =
    | Sub
    | Div
    | Trunc

let parseEquation (line: string) : Equation =
    let [| result; operandStr |] = line.Split(": ")
    let operands = operandStr.Split(" ") |> Seq.map int64 |> Seq.toList

    (int64 result, operands)


let equations =
    File.ReadAllLines(Path.Combine(__SOURCE_DIRECTORY__, "input.txt"))
    |> List.ofSeq
    |> List.map parseEquation

let divides (a: int64, b: int64) = (b % a) = 0

let numberOfDigits (n: int64) : int = (log10 (float n) |> int) + 1

let isCalibrationValid (e: Equation, operators: Operator list) =
    let rec aux (target: int64, operands: int64 list) : bool =
        match operands with
        | [] -> false
        | [ o ] -> o = target
        | o :: os ->
            operators
            |> List.exists (fun op ->
                match op with
                // subtract the current operand from the target and recurse
                | Sub -> aux (target - o, os)
                // if target is divisible by the current operand, divide the target by the current operand and recurse
                // otherwise, prune this branch
                | Div -> divides (o, target) && aux (target / o, os)
                // if target ends with the current operand (string operation), drop the current operand from the end of the target string and recurse
                // otherwise, prune this branch
                | Trunc ->
                    let operandDigits = numberOfDigits o
                    let truncationPlace = pown 10L operandDigits

                    if target % truncationPlace <> o then
                        false
                    else
                        aux (target / truncationPlace, os))

    // process operands from right to left
    aux (fst e, List.rev (snd e))

let part1 =
    equations
    |> List.filter (fun e -> isCalibrationValid (e, [ Sub; Div ]))
    |> List.sumBy fst

let part2 =
    equations
    |> List.filter (fun e -> isCalibrationValid (e, [ Sub; Div; Trunc ]))
    |> List.sumBy fst

System.Console.WriteLine(part1)
System.Console.WriteLine(part2)
