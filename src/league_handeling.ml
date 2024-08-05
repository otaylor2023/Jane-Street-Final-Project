open! Core

module Game_result = struct
  type t =
    | Home
    | Tie
    | Away
  [@@deriving sexp, equal]

  let to_string t = sexp_of_t t |> Sexp.to_string
end

module Team = struct
  type t =
    { home_wins : int
    ; home_ties : int
    ; home_loss : int
    ; away_wins : int
    ; away_ties : int
    ; away_loss : int
    }
  [@@deriving sexp]

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
  type t = Team.t String.Table.t [@@deriving sexp]

  let of_teams team_mapping : t =
    let team_mapping =
      List.map team_mapping ~f:(fun team_name ->
        team_name, Team.initialize_team)
    in
    Hashtbl.of_alist_exn (module String) team_mapping
  ;;

  let assign_home_stats (t : t) team_name stats =
    let h_w = List.nth_exn stats 1 in
    let h_d = List.nth_exn stats 2 in
    let h_l = List.nth_exn stats 3 in
    let team_stats = Hashtbl.find_exn t team_name in
    Hashtbl.set
      t
      ~key:team_name
      ~data:
        { team_stats with home_wins = h_w; home_ties = h_d; home_loss = h_l }
  ;;

  let assign_away_stats (t : t) team_name stats =
    let a_w = List.nth_exn stats 1 in
    let a_d = List.nth_exn stats 2 in
    let a_l = List.nth_exn stats 3 in
    let team_stats = Hashtbl.find_exn t team_name in
    Hashtbl.set
      t
      ~key:team_name
      ~data:
        { team_stats with away_wins = a_w; away_ties = a_d; away_loss = a_l }
  ;;

  let assign_stats t home_stats away_stats =
    List.iter home_stats ~f:(fun (team, stats) ->
      assign_home_stats t team stats);
    List.iter away_stats ~f:(fun (team, stats) ->
      assign_away_stats t team stats)
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
