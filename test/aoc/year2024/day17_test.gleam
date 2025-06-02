import aoc/year2024/day17

const input = "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"

const input1 = "Register A: 10
Register B: 0
Register C: 0

Program: 5,0,5,1,5,4
"

const input2 = "Register A: 2024
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"

const input3 = "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"

pub fn part1_test() {
  assert day17.part1(input) == "4,6,3,5,6,3,5,2,1,0"

  assert day17.part1(input1) == "0,1,2"

  assert day17.part1(input2) == "4,2,5,6,7,7,7,7,3,1,0"
}

pub fn part2_test() {
  assert day17.part2(input3) == 117_440
}
