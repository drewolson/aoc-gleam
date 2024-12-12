import aoc/util/li
import aoc/util/parser.{type Parser}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import party

type Rule =
  #(Int, Int)

type Update =
  List(Int)

type Reqs =
  Dict(Int, Set(Int))

fn rule_p() -> Parser(Rule) {
  use a <- party.do(parser.int())
  use <- party.drop(party.string("|"))
  use b <- party.map(parser.int())
  #(a, b)
}

fn rules_p() -> Parser(List(Rule)) {
  party.sep1(rule_p(), party.string("\n"))
}

fn update_p() -> Parser(Update) {
  party.sep1(parser.int(), party.string(","))
}

fn updates_p() -> Parser(List(Update)) {
  party.sep1(update_p(), party.string("\n"))
}

fn input_p() -> Parser(#(List(Rule), List(Update))) {
  use rules <- party.do(rules_p())
  use <- party.drop(party.string("\n\n"))
  use updates <- party.map(updates_p())
  #(rules, updates)
}

fn build_reqs(rules: List(Rule)) -> Reqs {
  list.fold(rules, dict.new(), fn(reqs, rule) {
    let #(a, b) = rule
    dict.upsert(reqs, b, fn(opt) {
      case opt {
        None -> set.new() |> set.insert(a)
        Some(s) -> set.insert(s, a)
      }
    })
  })
}

fn valid(reqs: Reqs, update: Update) -> Bool {
  let #(_, missing) =
    list.fold(update, #(set.new(), set.new()), fn(acc, i) {
      let #(seen, missing) = acc
      let req = reqs |> dict.get(i) |> result.unwrap(set.new())
      #(set.insert(seen, i), req |> set.difference(seen) |> set.union(missing))
    })
  update |> set.from_list |> set.intersection(missing) |> set.is_empty
}

fn find_middle(update: Update) -> Int {
  let n = list.length(update) / 2

  update
  |> list.drop(n)
  |> list.first
  |> result.unwrap(0)
}

fn reorder(
  update: Update,
  reqs: Reqs,
  all: Set(Int),
  seen: Set(Int),
  acc: Update,
) -> Update {
  case list.is_empty(update) {
    True -> acc
    False -> {
      let #(next, rest) =
        list.partition(update, fn(n) {
          reqs
          |> dict.get(n)
          |> result.unwrap(set.new())
          |> set.intersection(all)
          |> set.difference(seen)
          |> set.is_empty
        })

      reorder(
        rest,
        reqs,
        all,
        next |> set.from_list |> set.union(seen),
        list.append(next, acc),
      )
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(rules, updates) = parser.go(input, input_p())
  let reqs = build_reqs(rules)

  updates
  |> list.filter(valid(reqs, _))
  |> list.map(find_middle)
  |> li.sum
}

pub fn part2(input: String) -> Int {
  let #(rules, updates) = parser.go(input, input_p())
  let reqs = build_reqs(rules)

  updates
  |> list.filter(fn(u) { !valid(reqs, u) })
  |> list.map(fn(u) {
    u |> reorder(reqs, set.from_list(u), set.new(), []) |> find_middle
  })
  |> li.sum
}
