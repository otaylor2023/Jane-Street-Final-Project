open! Core
module Game_result = League_handeling.Game_result

(* (Home * Away) * (Game Odds * Predicted Odds) *)
type t =
  ((string * string)
  * (Bet_interphase.Game_odds.t * Bet_interphase.Game_odds.t))
    list

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

let output_bets_and_information (t : t) ~bankroll ~unwanted_teams =
  let match_bets =
    filter_unwilling_matches ~unwanted_teams t |> choose_match_bets
  in
  List.iter match_bets ~f:(fun inp ->
    let ((home, away), (_, predicted)), (_, odds) = inp in
    let distribution = Bet_interphase.implied_game_distribution predicted in
    let bet_properties =
      Bet_interphase.create_bet_properties bankroll odds distribution
    in
    print_endline "";
    print_endline
      [%string
        "Home Team: %{home} vs Away Team : %{away} -> Suggested Bet: \
         %{odds#Bet_interphase.Bets} -> Bet Properties: \
         %{bet_properties#Bet_interphase.Bet_properties}"])
;;
