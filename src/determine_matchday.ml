open! Core

let file_name =
  "/home/ubuntu/Jane-Street-Final-Project/data_files/week_data.csv"
;;

let get_matchday () =
  let information = Csv.load file_name in
  let min_matches =
    List.map (List.sub information ~pos:1 ~len:10) ~f:(fun match_info ->
      Int.of_string (List.nth_exn match_info 6))
    |> List.min_elt ~compare:Int.compare
  in
  match min_matches with Some matches -> matches + 1 | None -> 0
;;
