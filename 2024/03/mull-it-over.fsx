open System.IO
open System.Text.RegularExpressions

type Instruction =
    | Mul of int * int
    | Do
    | Dont

let parseInstructions (instruction: string) =
    let r = Regex("mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)")
    let matches = r.Matches(instruction)

    let parseMatch (m: Match) =
        match m.Value with
        | "do()" -> Do
        | "don't()" -> Dont
        | _ -> Mul(int m.Groups.[1].Value, int m.Groups.[2].Value)

    matches |> Seq.map parseMatch |> Seq.toList

let instructions =
    File.ReadAllText(Path.Combine(__SOURCE_DIRECTORY__, "input.txt"))
    |> parseInstructions


type State = { Acc: int; Enabled: bool }

let multiply state instruction =
    match instruction with
    | Do -> { state with Enabled = true }
    | Dont -> { state with Enabled = false }
    | Mul(a, b) ->
        if state.Enabled then
            { state with Acc = state.Acc + a * b }
        else
            state

let result = List.fold multiply { Acc = 0; Enabled = true } instructions
printf "%d\n", result
