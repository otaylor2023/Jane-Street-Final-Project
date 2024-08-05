open! Core

let get_matches contents =
  let open Soup in
  parse contents
  $$ "li[data-testid=\"match\"]"
  |> to_list
  |> List.map ~f:(fun a ->
    let teams =
      a
      $$ "div[data-testid=\"team-name\"]"
      |> Soup.to_list
      |> List.map ~f:(fun a -> R.leaf_text a)
    in
    let home = List.hd_exn teams in
    let away = List.nth_exn teams 1 in
    let books =
      a
      $$ "button[data-testid=\"bet-button\"]"
      |> Soup.to_list
      |> List.concat_map ~f:(fun b ->
        b
        $$ "img"
        |> to_list
        |> List.map ~f:(fun a ->
          let name = R.attribute "alt" a in
          let book_name =
            String.sub name ~pos:0 ~len:(String.length name - 5)
          in
          if not (String.equal book_name "Fanduel")
          then String.sub book_name ~pos:0 ~len:(String.length book_name - 3)
          else book_name))
    in
    let _buttons = a $$ "button" in
    (* let book_names = a $$ "img" |> to_list |> List.map ~f:(fun a -> let
       name = R.attribute "alt" a in String.sub name ~pos:0
       ~len:(String.length name - 5)) in *)
    let bet_prices =
      a
      $$ "div[data-testid=\"odds-primary\"]"
      |> Soup.to_list
      |> List.map ~f:(fun a ->
        let odds = R.leaf_text a in
        (* let int_odds = if String.equal (String.sub odds ~pos:0 ~len:0) "-"
           then 0 - Int.of_string odds else Int.of_string odds in *)
        let int_odds = Int.of_string odds in
        Bet_interphase.convert_to_decimal int_odds |> Float.to_string)
    in
    let book_names =
      [ List.nth_exn books 0; List.nth_exn books 2; List.nth_exn books 4 ]
    in
    let prices =
      [ List.nth_exn bet_prices 0
      ; List.nth_exn bet_prices 2
      ; List.nth_exn bet_prices 4
      ]
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
    (home, away), book_names, prices)
;;

let get_match_information () =
  let contents =
    File_fetcher.fetch_exn
      (Local
         (File_path.of_string
            "/home/ubuntu/Jane-Street-Final-Project/resources"))
      ~resource:"odds"
  in
  get_matches contents
;;

let%expect_test "odds_checker" =
  (* This test uses existing files on the filesystem. *)
  let contents =
    File_fetcher.fetch_exn
      (Local
         (File_path.of_string
            "/home/ubuntu/Jane-Street-Final-Project/resources"))
      ~resource:"odds"
  in
  List.iter
    (get_matches contents)
    ~f:(fun ((home, away), book_names, prices) ->
      print_s
        [%message
          (home : string)
            (away : string)
            (book_names : string list)
            (prices : string list)]);
  [%expect
    {|
  ((home "Athletic Bilbao") (away Getafe) (book_names (BetMGM BetMGM Fanduel))
   (prices (-210 +333 +700)))
  ((home "Real Betis") (away Girona) (book_names (Bet365 Fanduel Fanduel))
   (prices (+150 +250 +175)))
  ((home "Celta Vigo") (away Alaves) (book_names (Fanduel Fanduel Bet365))
   (prices (+100 +240 +310)))
  ((home "Las Palmas") (away Sevilla) (book_names (Bet365 BetMGM Bet365))
   (prices (+187 +225 +162)))
  ((home Osasuna) (away Leganes) (book_names (Bet365 BetMGM Bet365))
   (prices (-150 +290 +475)))
  ((home Valencia) (away Barcelona) (book_names (Bet365 Bet365 BetMGM))
   (prices (+350 +280 -130)))
  ((home "Real Sociedad") (away "Rayo Vallecano")
   (book_names (Bet365 Fanduel Bet365)) (prices (-182 +280 +650)))
  ((home "Real Mallorca") (away "Real Madrid")
   (book_names (Fanduel Bet365 BetMGM)) (prices (+500 +320 -165)))
  ((home Valladolid) (away Espanyol) (book_names (Bet365 Fanduel Bet365))
   (prices (+140 +220 +220)))
  ((home Villarreal) (away "Atletico Madrid")
   (book_names (Bet365 BetMGM Fanduel)) (prices (+190 +260 +140)))
  |}]
;;
