open! Core
module Game_result = League_handeling.Game_result

(* (Home * Away) * (Game Odds * Predicted Odds) *)
type t =
  ((string * string)
  * (Bet_interphase.Game_odds.t * Bet_interphase.Game_odds.t))
    list


let of_csv_exn (matches_info: string list list) : t=
  List.map matches_info ~f:(fun match_inf -> 
    
  let home = List.nth_exn match_inf 0 in
  let away = List.nth_exn match_inf 1 in
  let op1 =  List.nth_exn match_inf 2 in
  let opx =  List.nth_exn match_inf 3 in
  let op2 =  List.nth_exn match_inf 4 in
  let cp1 =  List.nth_exn match_inf 5 in
  let cpx =  List.nth_exn match_inf 6 in
  let cp2 =  List.nth_exn match_inf 7 in

  let open_odds = {Bet_interphase.Game_odds.home = (Float.of_string op1); tie = (Float.of_string opx); away = (Float.of_string op2)} in
  let closing_odds = {Bet_interphase.Game_odds.home = (Float.of_string cp1); tie = (Float.of_string cpx); away = (Float.of_string cp2)} in

  ((home,away), (open_odds, closing_odds))
  )
;;

let filter_unwilling_matches ~unwanted_teams (t : t) : t =
  List.filter t ~f:(fun ((home, away), _) ->
    (not (List.mem unwanted_teams home ~equal:String.equal))
    && not (List.mem unwanted_teams away ~equal:String.equal))
;;

let choose_match_bets (t : t) =
  List.filter_map t ~f:(fun inp ->
    let _, (real, pred) = inp in
    let home_diff = real.home -. pred.home in
    let tie_diff = real.tie -. pred.tie in
    let away_diff = real.away -. pred.away in
    let best_val = Float.max (Float.max home_diff tie_diff) away_diff in
    if Float.( > ) best_val 0.2
    then
      if Float.( = ) home_diff best_val
      then
        Some
          ( inp
          , (Game_result.Home, Bet_interphase.Bets.Home { odds = real.home })
          )
      else if Float.( = ) tie_diff best_val
      then
        Some
          ( inp
          , (Game_result.Tie, Bet_interphase.Bets.Tie { odds = real.tie }) )
      else
        Some
          ( inp
          , (Game_result.Away, Bet_interphase.Bets.Away { odds = real.away })
          )
    else None)
;;

let output_bets_and_information
  (t : t)
  ~bankroll
  ~unwanted_teams
  ~risk_tolerance
  =
  let match_bets =
    filter_unwilling_matches ~unwanted_teams t |> choose_match_bets
  in
  List.iter match_bets ~f:(fun inp ->
    let ((home, away), (_, predicted)), (_, odds) = inp in
    let distribution = Bet_interphase.implied_game_distribution predicted in
    let match_bet =
      Bet_interphase.create_bet_properties bankroll odds distribution
    in
    let bet_amount =
      Bet_interphase.decide_bet_amount ~bankroll ~risk_tolerance ~match_bet
    in
    match bet_amount with
    | Some bet ->
      print_endline "";
      print_endline
        [%string
          "Home Team: %{home} vs Away Team : %{away} -> Suggested Bet: \
           %{odds#Bet_interphase.Bets} -> Bet Properties: \
           %{match_bet#Bet_interphase.Bet_properties} -> Bet Amount: \
           %{bet#Float}"]
    | None -> ())
;;

let output_bets_and_information_as_string
  (t : t)
  ~bankroll
  ~unwanted_teams
  ~risk_tolerance
  =
  let match_bets =
    filter_unwilling_matches ~unwanted_teams t |> choose_match_bets
  in
  List.filter_map match_bets ~f:(fun inp ->
    let ((home, away), (_, predicted)), (_, odds) = inp in
    let distribution = Bet_interphase.implied_game_distribution predicted in
    let match_bet =
      Bet_interphase.create_bet_properties bankroll odds distribution
    in
    let bet_amount =
      Bet_interphase.decide_bet_amount ~bankroll ~risk_tolerance ~match_bet
    in
    match bet_amount with
    | Some bet ->
        Some 
           ([%string
           "H: %{home} vs A: %{away} -> Suggested Bet: \
            %{odds#Bet_interphase.Bets}"],Printf.sprintf "EV:%.2f, Variance:%.2f, Risk:%.2f -> Bet Amount:%.2f" match_bet.expected_value match_bet.variance match_bet.risk bet)

    | None -> None)
;;

(* let create_matchday_data () = 
  
;; *)
