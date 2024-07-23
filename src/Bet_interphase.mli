module Bet_interphase : sig
  module Game_odds : sig
    type t =
      { home : float
      ; tie : float
      ; away : float
      }
  end

  module Game_distribution : sig
    type t =
      { home : float
      ; tie : float
      ; away : float
      }
  end

  module Bets : sig
    type t =
      | Home of { odds : float }
      | Tie of { odds : float }
      | Away of { odds : float }
  end

  module Bet_properties : sig
    type t =
      { expected_value : float
      ; variance : float
      ; variance_cost : float
      ; risk : float
      }
  end

  val create_game_odds : home:int -> tie:int -> away:int -> Game_odds.t
  val implied_game_distribution : Game_odds.t -> Game_distribution.t
  val bet_expected_value : Bets.t -> Game_distribution.t -> float
  val bet_variance : Bets.t -> Game_distribution.t -> float

  val create_bet_properties
    :  float
    -> Bets.t
    -> Game_distribution.t
    -> Bet_properties.t
end
