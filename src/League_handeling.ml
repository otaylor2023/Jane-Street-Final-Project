open! Core

module Game_result = struct
  type t =
    | Home
    | Tie
    | Away
end

module Teams = struct
  type t =
    { home_wins : int
    ; home_ties : int
    ; home_loss : int
    ; away_wins : int
    ; away_ties : int
    ; away_loss : int
    }

  let initialize_team =
    { home_wins = 0
    ; home_ties = 0
    ; home_loss = 0
    ; away_wins = 0
    ; away_ties = 0
    ; away_loss = 0
    }
  ;;

  let matches_played (t : t) =
    t.home_wins
    + t.home_ties
    + t.home_loss
    + t.away_wins
    + t.away_ties
    + t.away_loss
  ;;
end

module League = struct
  type t = Teams.t String.Table.t

  let of_teams team_mapping : t =
    let team_mapping =
      List.map team_mapping ~f:(fun team_name ->
        team_name, Teams.initialize_team)
    in
    Hashtbl.of_alist_exn (module String) team_mapping
  ;;

  let get_team_record (t : t) is_home team_name =
    let team_record = Hashtbl.find_exn t team_name in
    match is_home with
    | true ->
      team_record.home_wins, team_record.home_ties, team_record.home_loss
    | false ->
      team_record.away_wins, team_record.away_ties, team_record.away_loss
  ;;

  let update_after_game (t : t) home_team away_team (result : Game_result.t) =
    let home_record = Hashtbl.find_exn t home_team in
    let away_record = Hashtbl.find_exn t away_team in
    match result with
    | Home ->
      Hashtbl.set
        t
        ~key:home_team
        ~data:{ home_record with home_wins = home_record.home_wins + 1 };
      Hashtbl.set
        t
        ~key:away_team
        ~data:{ away_record with away_loss = away_record.away_loss + 1 }
    | Tie ->
      Hashtbl.set
        t
        ~key:home_team
        ~data:{ home_record with home_ties = home_record.home_ties + 1 };
      Hashtbl.set
        t
        ~key:away_team
        ~data:{ away_record with away_ties = away_record.away_ties + 1 }
    | Away ->
      Hashtbl.set
        t
        ~key:home_team
        ~data:{ home_record with home_loss = home_record.home_loss + 1 };
      Hashtbl.set
        t
        ~key:away_team
        ~data:{ away_record with away_wins = away_record.away_wins + 1 }
  ;;

  let update_after_matchday (t : t) game_result_list =
    List.iter game_result_list ~f:(fun (home, away, result) ->
      update_after_game t home away result)
  ;;
end
