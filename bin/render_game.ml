open! Core
open! Laligabet_lib

let () =
  Graphics.open_graph (Printf.sprintf "");
  Run.run ();
  Core.never_returns (Async.Scheduler.go ())
;;
