open! Core

let file_name =
  "/home/ubuntu/Jane-Street-Final-Project/data_files/matchday_data.csv"
;;

let parse_matchday_facts () =
  let information = Csv.load file_name in
  Matchday_handeling.of_csv_exn information
;;
