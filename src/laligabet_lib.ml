open! Core
open Async
module Interactive = Interactive
module Run = Run
module Creating_week_stats = Creating_week_stats

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

let command_compute_stats =
  Command.async
    ~summary:"STATS"
    (let%map_open.Command () = return () in
     fun () -> Creating_week_stats.create_stats ())
;;

(* let command_render_graphics = Command.async ~summary:"Graphics"
   (let%map_open.Command () = return () in fun () ->
   Snake_graphics.display_screen (); Deferred.never ()) ;; *)
