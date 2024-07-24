open! Core

module Game_result : sig
  type t =
    | Home
    | Tie
    | Away
  [@@deriving sexp, equal]

  val to_string : t -> string
end

module Team : sig
  type t =
    { home_wins : int
    ; home_ties : int
    ; home_loss : int
    ; away_wins : int
    ; away_ties : int
    ; away_loss : int
    }

  val matches_played : t -> int
end

module League : sig
  type t = Team.t String.Table.t

  val of_teams : string list -> t
  val get_team_record : t -> bool -> string -> int * int * int

  val update_after_matchday
    :  t
    -> (string * string * Game_result.t) list
    -> unit
end
