import iv.{type Array}

pub type IntCode {
  IntCode(prog: Array(Int), pos: Int)
}

pub type Step(a, b) {
  Continue(a)
  Stop(b)
}

pub fn from_array(a: Array(Int)) -> IntCode {
  IntCode(prog: a, pos: 0)
}

pub fn from_list(l: List(Int)) -> IntCode {
  l
  |> iv.from_list
  |> from_array
}

pub fn bin_op(ic: IntCode, op: fn(Int, Int) -> Int) -> IntCode {
  let assert Ok(ia) = iv.get(ic.prog, ic.pos + 1)
  let assert Ok(a) = iv.get(ic.prog, ia)
  let assert Ok(ib) = iv.get(ic.prog, ic.pos + 2)
  let assert Ok(b) = iv.get(ic.prog, ib)
  let assert Ok(r) = iv.get(ic.prog, ic.pos + 3)
  let assert Ok(new_prog) = iv.set(ic.prog, r, op(a, b))

  IntCode(prog: new_prog, pos: ic.pos + 4)
}

pub fn get_op(ic: IntCode) -> Int {
  let assert Ok(val) = iv.get(ic.prog, ic.pos)
  val
}

pub fn get_output(ic: IntCode) -> Int {
  let assert Ok(val) = iv.get(ic.prog, 0)
  val
}

pub fn execute(ic: IntCode, f: fn(IntCode, Int) -> Step(IntCode, a)) -> a {
  let op = get_op(ic)
  let step = f(ic, op)

  case step {
    Continue(ic) -> execute(ic, f)
    Stop(a) -> a
  }
}
