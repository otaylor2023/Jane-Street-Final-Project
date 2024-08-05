open! Core

let get_stats contents =
  let open Soup in
  parse contents
  $$ "div[class=\"ui-table__row  \"]"
  |> to_list
  |> List.map ~f:(fun a ->
    let team_name =
      a $ "a[class=\"tableCellParticipant__name\"]" |> R.leaf_text
    in
    let team_stats =
      a
      $$ "span[class=\" table__cell table__cell--value   \"]"
      |> Soup.to_list
      |> List.map ~f:(fun a -> R.leaf_text a |> Int.of_string)
    in
    team_name, team_stats)
;;

let create_team_stats () : League_handeling.League.t =
  let home =
    File_fetcher.fetch_exn
      (Local
         (File_path.of_string
            "/home/ubuntu/Jane-Street-Final-Project/resources"))
      ~resource:"stats_home"
  in
  let away =
    File_fetcher.fetch_exn
      (Local
         (File_path.of_string
            "/home/ubuntu/Jane-Street-Final-Project/resources"))
      ~resource:"stats_away"
  in
  let home_stats = get_stats home in
  let away_stats = get_stats away in
  let teams = List.map home_stats ~f:(fun (t, _) -> t) in
  let league = League_handeling.League.of_teams teams in
  League_handeling.League.assign_stats league home_stats away_stats;
  league
;;

let%expect_test "update_league" =
  (* This test uses existing files on the filesystem. *)
  let league = create_team_stats () in
  print_s [%message (league : League_handeling.League.t)];
  [%expect
    {|
  /wiki/Carnivore
  /wiki/Domestication_of_the_cat
  /wiki/Mammal
  /wiki/Species
  |}]
;;

let%expect_test "get_matches" =
  (* This test uses existing files on the filesystem. *)
  let contents =
    File_fetcher.fetch_exn
      (Local (File_path.of_string "../resources"))
      ~resource:"stats_away"
  in
  List.iter (get_stats contents) ~f:(fun (team_name, team_stats) ->
    print_s [%message (team_name : string) (team_stats : int list)]);
  [%expect
    {|
  ((team_name "Real Sociedad") (team_stats (0 0 0 0)))
  ((team_name "Las Palmas") (team_stats (0 0 0 0)))
  ((team_name Alaves) (team_stats (0 0 0 0)))
  ((team_name "Celta Vigo") (team_stats (0 0 0 0)))
  ((team_name "Rayo Vallecano") (team_stats (0 0 0 0)))
  ((team_name "Real Madrid") (team_stats (0 0 0 0)))
  ((team_name Villarreal) (team_stats (0 0 0 0)))
  ((team_name Barcelona) (team_stats (0 0 0 0)))
  ((team_name "Atl. Madrid") (team_stats (0 0 0 0)))
  ((team_name Sevilla) (team_stats (0 0 0 0)))
  ((team_name Mallorca) (team_stats (0 0 0 0)))
  ((team_name Valencia) (team_stats (0 0 0 0)))
  ((team_name "Ath Bilbao") (team_stats (0 0 0 0)))
  ((team_name Espanyol) (team_stats (0 0 0 0)))
  ((team_name Betis) (team_stats (0 0 0 0)))
  ((team_name Getafe) (team_stats (0 0 0 0)))
  ((team_name Valladolid) (team_stats (0 0 0 0)))
  ((team_name Osasuna) (team_stats (0 0 0 0)))
  ((team_name Girona) (team_stats (0 0 0 0)))
  ((team_name Leganes) (team_stats (0 0 0 0)))
  |}]
;;
