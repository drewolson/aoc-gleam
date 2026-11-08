import gleam/list

pub type Queue(a)

@external(erlang, "pqueue2", "new")
pub fn new() -> Queue(a)

@external(erlang, "pqueue2", "in")
fn ffi_in(value: a, priority: Int, queue: Queue(a)) -> Queue(a)

pub fn push(queue: Queue(a), priority: Int, value: a) -> Queue(a) {
  ffi_in(value, priority, queue)
}

/// Pops the lowest-priority item, returning `#(priority, value, rest)`.
@external(erlang, "pq_ffi", "pop")
pub fn pop(queue: Queue(a)) -> Result(#(Int, a, Queue(a)), Nil)

@external(erlang, "pqueue2", "is_empty")
pub fn is_empty(queue: Queue(a)) -> Bool

@external(erlang, "pqueue2", "len")
pub fn size(queue: Queue(a)) -> Int

pub fn from_list(items: List(#(Int, a))) -> Queue(a) {
  list.fold(items, new(), fn(q, item) { push(q, item.0, item.1) })
}
