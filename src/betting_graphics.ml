open! Core

module Colors = struct
  let black = Graphics.rgb 000 000 000
  let white = Graphics.rgb 255 255 255
  let green = Graphics.rgb 000 255 000
  let blue = Graphics.rgb 000 000 255
  let head_color = Graphics.rgb 100 100 125
  let red = Graphics.rgb 255 000 000
  let background = Graphics.rgb 250 213 213
  let gold = Graphics.rgb 255 223 000
  let game_in_progress = Graphics.rgb 100 100 200
  let game_lost = Graphics.rgb 200 100 100
  let game_won = Graphics.rgb 100 200 100
end

(* These constants are optimized for running on a low-resolution screen. Feel
   free to increase the scaling factor to tweak! *)
module Constants = struct
  let scaling_factor = 0.75
  let play_area_height = 1000. *. scaling_factor |> Float.iround_down_exn
  let header_height = 75. *. scaling_factor |> Float.iround_down_exn
  let play_area_width = 675. *. scaling_factor |> Float.iround_down_exn
end

let only_one : bool ref = ref false

let init_exn () =
  let open Constants in
  (* Should raise if called twice *)
  if !only_one
  then failwith "Can only call init_exn once"
  else only_one := true;
  (* Creating_week_stats.create_stats (); *)
  Graphics.open_graph
    (* (Printf.sprintf " %dx%d" (play_area_height + header_height)
       play_area_width); *)
    "";
  Graphics.resize_window (play_area_height + header_height) play_area_width;
  Interface.init ()
;;

let draw_header _date _season _match_day =
  let open Constants in
  let header_color = Colors.blue in
  Graphics.set_color header_color;
  Graphics.fill_rect 0 play_area_height play_area_width header_height;
  let match_day = "1" in
  (* let full_date = Date.today ~zone:Time_zone.utc in *)
  let cur_time =
    Time_ns.now () |> Time_ns.to_date ~zone:Time_ns_unix.Zone.utc
  in
  let american_year = Date.to_string_american cur_time in
  let month = Date.month cur_time |> Month.to_int in
  let season = Int.( % ) (Date.year cur_time) 100 in
  let season =
    if month < 6
    then
      String.concat [ Int.to_string (season - 1); "/"; Int.to_string season ]
    else
      String.concat [ Int.to_string season; "/"; Int.to_string (season + 1) ]
  in
  Graphics.set_color Colors.black;
  Graphics.set_text_size 150;
  Graphics.moveto 20 (play_area_height + 25);
  Graphics.draw_string (Printf.sprintf "Date: %s" american_year);
  Graphics.moveto 200 (play_area_height + 25);
  Graphics.draw_string (Printf.sprintf "Season: %s" season);
  Graphics.moveto 380 (play_area_height + 25);
  Graphics.draw_string (Printf.sprintf "Match Day: %s" match_day)
;;

let draw_week_table (week_matches : Matchday_handeling.t) =
  List.iteri week_matches ~f:(fun idx ((home, away), _, _) ->
    let x = 20 + (idx % 2 * 230) in
    let y = 650 - (idx / 2 * 40) in
    Graphics.draw_rect x y 230 40;
    Graphics.moveto (x + 5) (y + 10);
    Graphics.set_text_size 1;
    Graphics.draw_string (Printf.sprintf "H: %s vs A: %s" home away))
;;

let draw_week_games ~game_day (week_matches : Matchday_handeling.t) =
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 50 725;
  Graphics.draw_string (Printf.sprintf "Week %d Games: " game_day);
  draw_week_table week_matches
;;

let display_fav_team (interphase : Interface.t) =
  let header_color = Colors.white in
  let x_coord = 150 in
  let y_coord = 435 in
  let width = 125 in
  let height = 30 in
  Graphics.set_color header_color;
  Graphics.fill_rect x_coord y_coord width height;
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 50 445;
  Graphics.draw_string (Printf.sprintf "Favorite Team: ");
  Graphics.moveto 155 445;
  Graphics.draw_string (Printf.sprintf "%s" interphase.current_fav_team)
;;

let display_bankroll (interphase : Interface.t) =
  let header_color = Colors.white in
  let x_coord = 150 in
  let y_coord = 390 in
  let width = 125 in
  let height = 30 in
  Graphics.set_color header_color;
  Graphics.fill_rect x_coord y_coord width height;
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 50 400;
  Graphics.draw_string (Printf.sprintf "Bankroll: ");
  Graphics.moveto 155 400;
  if interphase.current_bankroll > 0
  then Graphics.draw_string (Printf.sprintf "%d" interphase.current_bankroll)
;;

let display_risk (interphase : Interface.t) =
  let header_color = Colors.white in
  let x_coord = 150 in
  let y_coord = 345 in
  let width = 125 in
  let height = 30 in
  Graphics.set_color header_color;
  Graphics.fill_rect x_coord y_coord width height;
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 50 355;
  Graphics.draw_string (Printf.sprintf "Risk: ");
  Graphics.moveto 155 355;
  Graphics.draw_string (Printf.sprintf "%d" interphase.current_risk)
;;

let display_submit () =
  let header_color = Colors.gold in
  let x_coord = 150 in
  let y_coord = 300 in
  let width = 125 in
  let height = 30 in
  Graphics.set_color header_color;
  Graphics.fill_rect x_coord y_coord width height;
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 170 310;
  Graphics.draw_string (Printf.sprintf "SUBMIT")
;;

let get_bets (week_games : Matchday_handeling.t) bankroll fav_team risk =
  Matchday_handeling.output_bets_and_information_as_string
    week_games
    ~bankroll:(float_of_int bankroll)
    ~unwanted_teams:[ fav_team ]
    ~risk_tolerance:(float_of_int risk)
;;

let draw_bets_table bets =
  let bets =
    if List.length bets > 5 then List.sub bets ~pos:0 ~len:5 else bets
  in
  List.iteri bets ~f:(fun idx str ->
    let o1, o2 = str in
    let x = 30 in
    let y = 230 - (idx * 45) in
    Graphics.draw_rect x y 440 45;
    Graphics.moveto (x + 5) (y + 20);
    Graphics.draw_string o1;
    Graphics.moveto (x + 5) (y + 5);
    Graphics.draw_string o2)
;;

(* print_endline *)

let draw_bets (week_matches : Matchday_handeling.t) (interface : Interface.t)
  =
  Graphics.set_color Colors.red;
  Graphics.set_text_size 80;
  Graphics.moveto 50 285;
  Graphics.draw_string (Printf.sprintf "Personalized Bets: ");
  if interface.submit_clicked
  then
    interface.bets_graphic
    <- get_bets
         week_matches
         interface.current_bankroll
         interface.current_fav_team
         interface.current_risk;
  interface.submit_clicked <- false;
  draw_bets_table interface.bets_graphic
;;

let draw_play_area () =
  let open Constants in
  Graphics.set_color Colors.background;
  Graphics.fill_rect 0 0 play_area_width play_area_height
;;

let render interface =
  (* We want double-buffering. See
     https://v2.ocaml.org/releases/4.03/htmlman/libref/Graphics.html for more
     info!

     So, we set [display_mode] to false, draw to the background buffer, set
     [display_mode] to true and then synchronize. This guarantees that there
     won't be flickering! *)
  Graphics.display_mode false;
  draw_header 1 1 1;
  draw_play_area ();
  display_fav_team interface;
  display_bankroll interface;
  let match_data = Interpreting_matchdata.parse_matchday_facts () in
  draw_bets match_data interface;
  display_submit ();
  display_risk interface;
  draw_week_games ~game_day:1 match_data;
  Graphics.display_mode true;
  Graphics.synchronize ()
;;

let read_key () =
  if Graphics.key_pressed () then Some (Graphics.read_key ()) else None
;;

let every seconds ~f =
  let open Async in
  let rec loop () =
    Clock.after (Time_float.Span.of_sec seconds)
    >>= fun () ->
    f ();
    loop ()
  in
  don't_wait_for (loop ())
;;

(* let display_screen () = every 0.1 ~f:(fun () -> render ()) *)
