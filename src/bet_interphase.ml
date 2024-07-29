open! Core

module Game_odds = struct
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
  [@@deriving sexp, equal]
end

module Game_distribution = struct
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
  [@@deriving sexp, equal]
end

module Bets = struct
  type t =
    | Home of { odds : float }
    | Tie of { odds : float }
    | Away of { odds : float }
  [@@deriving sexp, equal]

  let to_string t = sexp_of_t t |> Sexp.to_string
end

module Bet_properties = struct
  type t =
    { expected_value : float
    ; variance : float
    ; variance_cost : float
    ; risk : float
    ; odds : float
    }
  [@@deriving sexp, equal]

  let to_string t = sexp_of_t t |> Sexp.to_string
end

let convert_to_decimal (american_odds : int) =
  if american_odds > 0
  then Float.( / ) (Float.of_int american_odds) 100. +. 1.
  else Float.( / ) 100. (Float.of_int american_odds) +. 1.
;;

let create_game_odds ~home ~tie ~away : Game_odds.t =
  { home = convert_to_decimal home
  ; tie = convert_to_decimal tie
  ; away = convert_to_decimal away
  }
;;

let implied_odds (odd : float) = 1. /. odd

let get_odds (bet_type : Bets.t) =
  match bet_type with
  | Home { odds } -> odds
  | Away { odds } -> odds
  | Tie { odds } -> odds
;;

let get_probability (bet_type : Bets.t) (game_d : Game_distribution.t) =
  match bet_type with
  | Home _ -> game_d.home
  | Away _ -> game_d.away
  | Tie _ -> game_d.tie
;;

let implied_game_distribution (game : Game_odds.t) : Game_distribution.t =
  { home = implied_odds game.home
  ; tie = implied_odds game.tie
  ; away = implied_odds game.away
  }
;;

let bet_expected_value (bet_type : Bets.t) (game_d : Game_distribution.t) =
  let p = get_probability bet_type game_d in
  match bet_type with
  | Home { odds } | Tie { odds } | Away { odds } ->
    (p *. (odds -. 1.)) +. (-1. *. (1. -. p))
;;

let bet_variance (bet_type : Bets.t) (game_d : Game_distribution.t) =
  let ev = bet_expected_value bet_type game_d in
  let p = get_probability bet_type game_d in
  match bet_type with
  | Home { odds } | Tie { odds } | Away { odds } ->
    (Float.( ** ) (odds -. 1. -. ev) 2.0 *. p)
    +. (Float.( ** ) (-1. -. ev) 2.0 *. (1. -. p))
;;

let swap_equivalent
  ~bankroll
  (bet_type : Bets.t)
  (game_d : Game_distribution.t)
  =
  let p = get_probability bet_type game_d in
  match bet_type with
  | Home { odds } | Tie { odds } | Away { odds } ->
    let w = (1. -. odds) /. bankroll in
    (Float.( ** ) (1. +. w) p -. 1.) /. (p *. w)
;;

let cost_of_variance
  ~bankroll
  (bet_type : Bets.t)
  (game_d : Game_distribution.t)
  =
  let s = swap_equivalent ~bankroll bet_type game_d in
  let ev = bet_expected_value bet_type game_d in
  ev *. (1. -. s)
;;

(* VERY SUBJECT TO CHANGE NEED TO FIGUERE THIS OUT *)
let bet_risk_score (bet_type : Bets.t) (game_d : Game_distribution.t) =
  let variance = bet_variance bet_type game_d in
  let ev = bet_expected_value bet_type game_d in
  let odds = get_odds bet_type in
  Float.sqrt
    (Float.( / ) (variance *. 15.) (Float.( ** ) (1. +. ev) 5.) *. odds)
  -. 1.
;;

let create_bet_properties
  bankroll
  (bet_type : Bets.t)
  (game_d : Game_distribution.t)
  : Bet_properties.t
  =
  { expected_value = bet_expected_value bet_type game_d
  ; variance = bet_variance bet_type game_d
  ; variance_cost = cost_of_variance ~bankroll bet_type game_d
  ; risk = bet_risk_score bet_type game_d
  ; odds = get_odds bet_type
  }
;;

let willing_to_bet risk_tolerance (match_bet : Bet_properties.t) =
  Float.( > ) (risk_tolerance *. 1.5) match_bet.risk
;;

let decide_bet_amount
  ~bankroll
  ~risk_tolerance
  ~(match_bet : Bet_properties.t)
  =
  if willing_to_bet risk_tolerance match_bet
  then (
    let unit = Float.( / ) bankroll 66.6 in
    let desired_return =
      (2. *. unit) +. (Float.( / ) bankroll 1000. *. risk_tolerance)
    in
    Some ((desired_return -. (match_bet.risk /. 2000.)) /. match_bet.odds))
  else None
;;
