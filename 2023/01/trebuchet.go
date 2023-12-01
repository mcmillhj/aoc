package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"unicode"
)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	calibrations := make([]int, 0)
	for scanner.Scan() {
		// read a line from the input file
		line := scanner.Text()

		// search from both directions until a number is found
		// bounds have to overlap fully to cover the case where the only
		// number in the line is in the first or last half of the string
		first, last := -1, -1
		for head, tail := 0, len(line)-1; head <= len(line)-1 && tail >= 0; head, tail = head+1, tail-1 {
			// stop looping if we have already found both numbers
			if first != -1 && last != -1 {
				break
			}

			// search from the start of the line until a number is found
			if first == -1 {
				if calibration := scan(line, head, FORWARD); calibration != -1 {
					first = calibration
				}
			}

			// search from the end of the line until a number is found
			if last == -1 {
				if calibration := scan(line, tail, REVERSE); calibration != -1 {
					last = calibration
				}
			}
		}

		// collect all of the calibration readinds
		calibrations = append(calibrations, first*10+last)
	}

	fmt.Println(sum(calibrations...))
}

type Direction int

const (
	FORWARD Direction = iota
	REVERSE
)

func scan(s string, index int, direction Direction) int {
	switch {
	case unicode.IsDigit(rune(s[index])):
		return int(s[index]) - '0'
	case match(s, index, "one", direction):
		return 1
	case match(s, index, "two", direction):
		return 2
	case match(s, index, "three", direction):
		return 3
	case match(s, index, "four", direction):
		return 4
	case match(s, index, "five", direction):
		return 5
	case match(s, index, "six", direction):
		return 6
	case match(s, index, "seven", direction):
		return 7
	case match(s, index, "eight", direction):
		return 8
	case match(s, index, "nine", direction):
		return 9
	default:
		return -1
	}
}

func match(s string, index int, word string, direction Direction) bool {
	var wordLength = len(word)

	switch direction {
	case FORWARD:
		return index+wordLength <= len(s) && s[index:index+wordLength] == word
	case REVERSE:
		return index-wordLength+1 >= 0 && s[index-wordLength+1:index+1] == word
	default:
		return false
	}
}

func sum(values ...int) int {
	sum := 0

	for _, v := range values {
		sum += v
	}

	return sum
}
