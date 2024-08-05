open! Core
open Async

let create_stats () =
  let file =
    "/home/ubuntu/Jane-Street-Final-Project/data_files/week_data.csv"
  in
  let matches = Odds_checker_scraping.get_match_information () in
  let league = Flash_score_scraping.create_team_stats () in
  let csv_header =
    [ [ "HomeWins"
      ; "HomeTie"
      ; "HomeLoss"
      ; "AwayWins"
      ; "AwayTie"
      ; "AwayLoss"
      ; "Games"
      ; "HomeTeam"
      ; "AwayTeam"
      ; "OP1"
      ; "OPX"
      ; "OP2"
      ; "book1"
      ; "bookX"
      ; "book2"
      ]
    ]
  in
  let csv_info =
    List.map matches ~f:(fun ((home, away), books, prices) ->
      let home =
        if String.equal home "Athletic Bilbao" then "Ath Bilbao" else home
      in
      let home =
        if String.equal home "Atletico Madrid" then "Atl. Madrid" else home
      in
      let home = if String.equal home "Real Betis" then "Betis" else home in
      let home =
        if String.equal home "Real Mallorca" then "Mallorca" else home
      in
      let away =
        if String.equal away "Athletic Bilbao" then "Ath Bilbao" else away
      in
      let away =
        if String.equal away "Atletico Madrid" then "Atl. Madrid" else away
      in
      let away = if String.equal away "Real Betis" then "Betis" else away in
      let away =
        if String.equal away "Real Mallorca" then "Mallorca" else away
      in
      let away =
        if String.equal (String.sub away ~pos:0 ~len:1) " "
        then String.sub away ~pos:1 ~len:(String.length away - 1)
        else away
      in
      let home =
        if String.equal (String.sub home ~pos:0 ~len:1) " "
        then String.sub away ~pos:1 ~len:(String.length home - 1)
        else home
      in
      let home_stats = Hashtbl.find_exn league home in
      let away_stats = Hashtbl.find_exn league away in
      [ Int.to_string home_stats.home_wins
      ; Int.to_string home_stats.home_ties
      ; Int.to_string home_stats.home_loss
      ; Int.to_string away_stats.away_wins
      ; Int.to_string away_stats.away_ties
      ; Int.to_string away_stats.away_loss
      ; Int.to_string (League_handeling.Team.matches_played home_stats)
      ; home
      ; away
      ]
      @ prices
      @ books)
  in
  Csv.save file (csv_header @ csv_info);
  return ()
;;

(* let%expect_test "odds_checker" = (* This test uses existing files on the
   filesystem. *) create_stats (); [%expect {|

   |}] ;; *)
