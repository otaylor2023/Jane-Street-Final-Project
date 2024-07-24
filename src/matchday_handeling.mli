open! Core

(* (Home * Away) * (Game Odds * Predicted Odds) *)
type t =
  ((string * string)
  * (Bet_interphase.Game_odds.t * Bet_interphase.Game_odds.t))
    list

val output_bets_and_information
  :  t
  -> bankroll:float
  -> unwanted_teams:string list
  -> unit
