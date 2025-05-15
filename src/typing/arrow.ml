let global_local : string -> local_ int * int = fun _ -> exclave_ (6, 28)
let global_global : string -> int * int = fun _ -> (6, 28)
let local_global : local_ string -> int * int = fun _ -> (6, 28)
let local_local : local_ string -> local_ int * int = fun _ -> exclave_ (6, 28)
