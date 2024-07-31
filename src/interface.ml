open! Core

type t =
  { mutable current_bankroll : int
  ; mutable current_fav_team : string
  ; mutable current_risk : int
  ; mutable risk_clicked : bool
  ; mutable bankroll_clicked : bool
  ; mutable fav_team_clicked : bool
  ; mutable submit_clicked : bool
  ; mutable bets_graphic : (string * string) list
  }
[@@deriving sexp_of]

let init () =
  { current_bankroll = 0
  ; current_fav_team = ""
  ; current_risk = 0
  ; risk_clicked = false
  ; bankroll_clicked = false
  ; fav_team_clicked = false
  ; submit_clicked = false
  ; bets_graphic = []
  }
;;

let handle_click (t : t) (pos : int * int) =
  let x_pos, y_pos = pos in
  (* Calculate: 482 575 100 25 *)
  if (x_pos > 150 && x_pos < 275) && y_pos > 390 && y_pos < 420
  then (
    t.risk_clicked <- false;
    t.fav_team_clicked <- false;
    t.submit_clicked <- false;
    t.bankroll_clicked <- true)
  else if (x_pos > 150 && x_pos < 275) && y_pos > 435 && y_pos < 475
  then (
    t.fav_team_clicked <- true;
    t.risk_clicked <- false;
    t.submit_clicked <- false;
    t.bankroll_clicked <- false)
  else if (x_pos > 150 && x_pos < 275) && y_pos > 345 && y_pos < 475
  then (
    t.fav_team_clicked <- false;
    t.risk_clicked <- true;
    t.submit_clicked <- false;
    t.bankroll_clicked <- false)
  else if (x_pos > 150 && x_pos < 275) && y_pos > 300 && y_pos < 330
  then (
    t.fav_team_clicked <- false;
    t.risk_clicked <- false;
    t.submit_clicked <- true;
    t.bankroll_clicked <- false)
  else (
    t.fav_team_clicked <- false;
    t.risk_clicked <- false;
    t.submit_clicked <- false;
    t.bankroll_clicked <- false)
;;
