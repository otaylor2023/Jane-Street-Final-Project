open! Core

module Game_odds : sig
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
  [@@deriving sexp, equal]
end

module Game_odds_books : sig
  type t =
    { home_book : string
    ; tie_book : string
    ; away_book : string
    }
  [@@deriving sexp, equal]
end

module Game_distribution : sig
  type t =
    { home : float
    ; tie : float
    ; away : float
    }
  [@@deriving sexp, equal]
end

module Bets : sig
  type t =
    | Home of
        { odds : float
        ; book : string
        }
    | Tie of
        { odds : float
        ; book : string
        }
    | Away of
        { odds : float
        ; book : string
        }
  [@@deriving sexp, equal]

  val to_string : t -> string
end

module Bet_properties : sig
  type t =
    { expected_value : float
    ; variance : float
    ; variance_cost : float
    ; risk : float
    ; odds : float
    ; book : string
    }
  [@@deriving sexp, equal]

  val to_string : t -> string
end

val create_game_odds : home:int -> tie:int -> away:int -> Game_odds.t
val convert_to_decimal : int -> float
val implied_game_distribution : Game_odds.t -> Game_distribution.t
val bet_expected_value : Bets.t -> Game_distribution.t -> float
val bet_variance : Bets.t -> Game_distribution.t -> float

val create_bet_properties
  :  float
  -> Bets.t
  -> Game_distribution.t
  -> Bet_properties.t

val decide_bet_amount
  :  bankroll:float
  -> risk_tolerance:float
  -> match_bet:Bet_properties.t
  -> float option
