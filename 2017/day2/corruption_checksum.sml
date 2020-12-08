(* --- Day 2: Corruption Checksum --- *)

(* --- Part One --- *)

(* As you walk through the door, a glowing humanoid shape yells in your direction. "You there! Your state appears to be idle. Come help us repair the corruption in this spreadsheet - if we take another millisecond, we'll have to display an hourglass cursor!" *)

(* The spreadsheet consists of rows of apparently-random numbers. To make sure the recovery process is on the right track, they need you to calculate the spreadsheet's checksum. For each row, determine the difference between the largest value and the smallest value; the checksum is the sum of all of these differences. *)

(* For example, given the following spreadsheet: *)

(* 5 1 9 5 *)
(* 7 5 3 *)
(* 2 4 6 8 *)
(* The first row's largest and smallest values are 9 and 1, and their difference is 8. *)
(* The second row's largest and smallest values are 7 and 3, and their difference is 4. *)
(* The third row's difference is 6. *)
(* In this example, the spreadsheet's checksum would be 8 + 4 + 6 = 18. *)

(* What is the checksum for the spreadsheet in your puzzle input? *)

fun checksum input = let
    fun max_diff xs = let
        val int_min = (~ (ceil(Math.pow(2.0, 31.0))))
        val int_max = (floor(Math.pow(2.0, 31.0) - 1.0))

        fun max_diff' [] min max = (max - min)
          | max_diff' (x::xs) min max = max_diff' xs (if x < min then x else min) (if x > max then x else max)
    in
        max_diff' xs int_max int_min
    end

    fun checksum' [] acc = acc
      | checksum' (x::xs) acc = checksum' xs acc + (max_diff x)
in
    checksum' input
end

(* --- Part Two --- *)

(* "Great work; looks like we're on the right track after all. Here's a star for your effort." However, the program seems a little worried. Can programs be worried? *)

(* "Based on what we're seeing, it looks like all the User wanted is some information about the evenly divisible values in the spreadsheet. Unfortunately, none of us are equipped for that kind of calculation - most of us specialize in bitwise operations." *)

(* It sounds like the goal is to find the only two numbers in each row where one evenly divides the other - that is, where the result of the division operation is a whole number. They would like you to find those numbers on each line, divide them, and add up each line's result. *)

(* For example, given the following spreadsheet: *)

(* 5 9 2 8 *)
(* 9 4 7 3 *)
(* 3 8 6 5 *)
(* In the first row, the only two numbers that evenly divide are 8 and 2; the result of this division is 4. *)
(* In the second row, the two numbers are 9 and 3; the result is 3. *)
(* In the third row, the result is 2. *)
(* In this example, the sum of the results would be 4 + 3 + 2 = 9. *)

(* What is the sum of each row's result in your puzzle input? *)

fun checksum2 input = let
    val sum = foldl (op +) 0;

    fun checksum2' [] = 0
      | checksum2' (x::xs) = case List.find (fn e => (x mod e) = 0) xs
                              of
                                 (SOME e) => x div e
                               | NONE => checksum2' (xs @ [x])
in
    sum (List.map checksum2' input)
end

val spreadsheet = [
    [1208, 412, 743, 57, 1097, 53, 71, 1029, 719, 133, 258, 69, 1104, 373, 367, 365],
    [4011, 4316, 1755, 4992, 228, 240, 3333, 208, 247, 3319, 4555, 717, 1483, 4608, 1387, 3542],
    [675, 134, 106, 115, 204, 437, 1035, 1142, 195, 1115, 569, 140, 1133, 190, 701, 1016],
    [4455, 2184, 5109, 221, 3794, 246, 5214, 4572, 3571, 3395, 2054, 5050, 216, 878, 237, 3880],
    [4185, 5959, 292, 2293, 118, 5603, 2167, 5436, 3079, 167, 243, 256, 5382, 207, 5258, 4234],
    [94, 402, 126, 1293, 801, 1604, 1481, 1292, 1428, 1051, 345, 1510, 1417, 684, 133, 119],
    [120, 1921, 115, 3188, 82, 334, 366, 3467, 103, 863, 3060, 2123, 3429, 1974, 557, 3090],
    [53, 446, 994, 71, 872, 898, 89, 982, 957, 789, 1040, 100, 133, 82, 84, 791],
    [2297, 733, 575, 2896, 1470, 169, 2925, 1901, 195, 2757, 1627, 1216, 148, 3037, 392, 221],
    [1343, 483, 67, 1655, 57, 71, 1562, 447, 58, 1561, 889, 1741, 1338, 88, 1363, 560],
    [2387, 3991, 3394, 6300, 2281, 6976, 234, 204, 6244, 854, 1564, 210, 195, 7007, 3773, 3623],
    [1523, 77, 1236, 1277, 112, 171, 70, 1198, 86, 1664, 1767, 75, 315, 143, 1450, 1610],
    [168, 2683, 1480, 200, 1666, 1999, 3418, 2177, 156, 430, 2959, 3264, 2989, 136, 110, 3526],
    [8702, 6973, 203, 4401, 8135, 7752, 1704, 8890, 182, 9315, 255, 229, 6539, 647, 6431, 6178],
    [2290, 157, 2759, 3771, 4112, 2063, 153, 3538, 3740, 130, 3474, 1013, 180, 2164, 170, 189],
    [525, 1263, 146, 954, 188, 232, 1019, 918, 268, 172, 1196, 1091, 1128, 234, 650, 420]
];

val part1_answer = checksum spreadsheet;
val part2_answer = checksum2 spreadsheet;
