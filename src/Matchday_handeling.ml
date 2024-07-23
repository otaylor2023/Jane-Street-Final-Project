open! Core

module Matchday = struct
  type t =
    (Bet_interphase.Game_odds.t * Bet_interphase.Game_distribution.t) list
end
