open! Core
open Async
module Interactive = Interactive

let command_play =
  Command.async
    ~summary:"Play"
    (let%map_open.Command () = return () in
     fun () -> Interactive.run ())
;;

let command_matchday_example =
  Command.async
    ~summary:"MATCHDAY"
    (let%map_open.Command () = return () in
     fun () -> Interactive.run_example ())
;;

let command_matchday_test =
  Command.async
    ~summary:"MATCHDAY"
    (let%map_open.Command () = return () in
     fun () -> Interactive.run_matchday ())
;;
