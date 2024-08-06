open! Core

(* This is the core logic that actually runs the game. We have implemented
   all of this for you, but feel free to read this file as a reference. *)
let game_over = ref false

let every seconds ~f ~stop =
  let open Async in
  let rec loop () =
    if !stop
    then return ()
    else
      Clock.after (Time_float.Span.of_sec seconds)
      >>= fun () ->
      f ();
      loop ()
  in
  don't_wait_for (loop ())
;;

let handle_keys (interface : Interface.t) =
  every ~stop:game_over 0.001 ~f:(fun () ->
    match Betting_graphics.read_key () with
    | Some key ->
      if interface.bankroll_clicked
      then
        if Char.is_digit key && interface.current_bankroll < 100000000000001
        then
          interface.current_bankroll
          <- Int.of_string
               (String.concat
                  [ Int.to_string interface.current_bankroll
                  ; String.of_char key
                  ])
        else if Char.to_int key = 8 && interface.current_bankroll > 0
        then
          if interface.current_bankroll > 10
          then
            interface.current_bankroll
            <- Int.of_string
                 (String.sub
                    (Int.to_string interface.current_bankroll)
                    ~pos:0
                    ~len:
                      (String.length
                         (Int.to_string interface.current_bankroll)
                       - 1))
          else interface.current_bankroll <- 0;
      if interface.risk_clicked
      then
        if Char.is_digit key
           && String.length (Int.to_string interface.current_risk) < 2
        then interface.current_risk <- Int.of_string (String.of_char key);
      if interface.fav_team_clicked
      then
        if Char.is_alpha key && String.length interface.current_fav_team < 20
        then
          interface.current_fav_team
          <- String.concat [ interface.current_fav_team; String.of_char key ]
        else if Char.to_int key = 8
                && not (String.equal interface.current_fav_team "")
        then
          interface.current_fav_team
          <- String.sub
               interface.current_fav_team
               ~pos:0
               ~len:(String.length interface.current_fav_team - 1)
        else if Char.to_int key = 32
        then
          interface.current_fav_team
          <- String.concat [ interface.current_fav_team; " " ]
    | None -> ())
;;

let handle_clicks (interface : Interface.t) =
  every ~stop:game_over 0.001 ~f:(fun () ->
    if Graphics.button_down ()
    then Interface.handle_click interface (Graphics.mouse_pos ()))
;;

let handle_steps (interface : Interface.t) =
  every ~stop:game_over 0.1 ~f:(fun () -> Betting_graphics.render interface)
;;

let run () =
  let interface = Betting_graphics.init_exn () in
  Betting_graphics.render interface;
  handle_keys interface;
  handle_clicks interface;
  handle_steps interface
;;
