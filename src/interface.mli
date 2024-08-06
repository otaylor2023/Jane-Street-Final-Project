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

val sexp_of_t : t -> Sexplib0.Sexp.t
val init : unit -> t
val handle_click : t -> int * int -> unit
