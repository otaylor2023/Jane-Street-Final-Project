module Game_odds = struct
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
end

module Game_distribution = struct
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
end

module Bets = struct
  type t =
    | Home of { odds : float }
    | Away of { odds : float }
    | Tie of { odds : float }
end

module Bet_properties = struct
  type t =
    { expected_value : float
    ; variance : float
    ; variance_cost : float
    ; risk : float
    }
end

let convert_to_decimal (american_odds : int) =
  Float.div (Float.of_int american_odds) 100. +. 1.
;;

let create_game_odds ~home ~tie ~away : Game_odds.t =
  { home = convert_to_decimal home
  ; tie = convert_to_decimal tie
  ; away = convert_to_decimal away
  }
;;

let implied_odds (odd : float) = 1. /. odd *. 100.

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
  match bet_type with
  | Home { odds } -> (game_d.home *. odds) +. (-1. *. (1. -. game_d.home))
  | Tie { odds } -> (game_d.tie *. odds) +. (-1. *. (1. -. game_d.tie))
  | Away { odds } -> (game_d.away *. odds) +. (-1. *. (1. -. game_d.away))
;;

let bet_variance (bet_type : Bets.t) (game_d : Game_distribution.t) =
  let ev = bet_expected_value bet_type game_d in
  match bet_type with
  | Home { odds } ->
    (Float.pow (odds -. ev) 2.0 *. game_d.home)
    +. (Float.pow (-1. -. ev) 2.0 *. (1. -. game_d.home))
  | Tie { odds } ->
    (Float.pow (odds -. ev) 2.0 *. game_d.tie)
    +. (Float.pow (-1. -. ev) 2.0 *. (1. -. game_d.tie))
  | Away { odds } ->
    (Float.pow (odds -. ev) 2.0 *. game_d.away)
    +. (Float.pow (-1. -. ev) 2.0 *. (1. -. game_d.away))
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
    (Float.pow (1. +. w) p -. 1.) /. (p *. w)
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

let risk_of_bet odds = odds /. (1. +. odds)

let create_bet_properties
  bankroll
  (bet_type : Bets.t)
  (game_d : Game_distribution.t)
  : Bet_properties.t
  =
  let odds =
    match bet_type with
    | Home { odds } -> odds
    | Away { odds } -> odds
    | Tie { odds } -> odds
  in
  { expected_value = bet_expected_value bet_type game_d
  ; variance = bet_variance bet_type game_d
  ; variance_cost = cost_of_variance ~bankroll bet_type game_d
  ; risk = risk_of_bet odds
  }
;;

let bet_risk_score (bet_properties : Bet_properties.t) =
  (bet_properties.variance *. 100.)
  +. ((1. -. bet_properties.variance_cost) *. 200.)
  +. (bet_properties.risk *. 100.)
  -. (bet_properties.expected_value *. 100.)
;;
