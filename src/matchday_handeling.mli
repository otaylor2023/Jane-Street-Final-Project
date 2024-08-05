open! Core

(* (Home * Away) * (Game Odds * Predicted Odds) *)
type t =
  ((string * string)
  * (Bet_interphase.Game_odds.t * Bet_interphase.Game_odds.t)
  * Bet_interphase.Game_odds_books.t)
    list

val output_bets_and_information
  :  t
  -> bankroll:float
  -> unwanted_teams:string list
  -> risk_tolerance:float
  -> unit

val output_bets_and_information_as_string
  :  t
  -> bankroll:float
  -> unwanted_teams:string list
  -> risk_tolerance:float
  -> (string * string) list

val of_csv_exn : string list list -> t
