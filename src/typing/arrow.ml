let global_to_local : string -> local_ int * int = fun _ -> exclave_ (6, 28)
let global_to_global : string -> int * int = fun _ -> (6, 28)
let local_to_global : local_ string -> int * int = fun _ -> (6, 28)
let local_to_local : local_ string -> local_ int * int = fun _ -> exclave_ (6, 28)
