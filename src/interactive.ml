open! Core
open Async

let example =
  [ ( ("Grenada CF", "Dep. La Coruna")
    , ( { Bet_interphase.Game_odds.home = 2.14; tie = 3.33; away = 3.95 }
      , { Bet_interphase.Game_odds.home = 2.14; tie = 3.33; away = 3.95 } ) )
  ; ( ("Sevilla", "Valencia")
    , ( { Bet_interphase.Game_odds.home = 2.16; tie = 3.55; away = 3.63 }
      , { Bet_interphase.Game_odds.home = 2.29; tie = 3.46; away = 3.40 } ) )
  ; ( ("Almeria", "Espanyol")
    , ( { Bet_interphase.Game_odds.home = 2.56; tie = 3.29; away = 3.07 }
      , { Bet_interphase.Game_odds.home = 3.19; tie = 3.26; away = 2.50 } ) )
  ; ( ("Malaga", "Ath Bilbao")
    , ( { Bet_interphase.Game_odds.home = 3.02; tie = 3.40; away = 2.53 }
      , { Bet_interphase.Game_odds.home = 3.14; tie = 3.23; away = 2.56 } ) )
  ; ( ("Celta Vigo", "Getafe")
    , ( { Bet_interphase.Game_odds.home = 2.01; tie = 3.53; away = 4.18 }
      , { Bet_interphase.Game_odds.home = 1.68; tie = 3.88; away = 5.90 } ) )
  ; ( ("Levante", "Sociedad")
    , ( { Bet_interphase.Game_odds.home = 3.34; tie = 3.32; away = 2.38 }
      , { Bet_interphase.Game_odds.home = 5.14; tie = 3.46; away = 1.86 } ) )
  ; ( ("Eibar", "Real Sociedad")
    , ( { Bet_interphase.Game_odds.home = 3.53; tie = 3.44; away = 2.24 }
      , { Bet_interphase.Game_odds.home = 3.08; tie = 3.16; away = 2.65 } ) )
  ; ( ("Barcelona", "Elche")
    , ( { Bet_interphase.Game_odds.home = 1.14; tie = 10.32; away = 23.12 }
      , { Bet_interphase.Game_odds.home = 1.11; tie = 12.80; away = 24.00 }
      ) )
  ; ( ("Rayo Vallecano", "Atl. Madrid")
    , ( { Bet_interphase.Game_odds.home = 7.05; tie = 4.41; away = 1.53 }
      , { Bet_interphase.Game_odds.home = 5.66; tie = 3.61; away = 1.76 } ) )
  ; ( ("Real Madrid", "Cordoba")
    , ( { Bet_interphase.Game_odds.home = 1.10; tie = 13.20; away = 28.50 }
      , { Bet_interphase.Game_odds.home = 1.06; tie = 18.01; away = 39.31 }
      ) )
  ]
;;

let run () =
  let%bind home_odds =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter home odds"
  in
  let%bind tie_odds =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter tie odds"
  in
  let%bind away_odds =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter away odds"
  in
  let%bind home_pred =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter estimated home odds"
  in
  let%bind tie_pred =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter estimated tie odds"
  in
  let%bind away_pred =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter estimated away odds"
  in
  let game_odds =
    Bet_interphase.create_game_odds
      ~home:(int_of_string home_odds)
      ~tie:(int_of_string tie_odds)
      ~away:(int_of_string away_odds)
  in
  let predicted_odds =
    Bet_interphase.create_game_odds
      ~home:(int_of_string home_pred)
      ~tie:(int_of_string tie_pred)
      ~away:(int_of_string away_pred)
  in
  let game_distribution =
    Bet_interphase.implied_game_distribution predicted_odds
  in
  let all_bets =
    [ Bet_interphase.Bets.Home { odds = game_odds.home }
    ; Bet_interphase.Bets.Tie { odds = game_odds.tie }
    ; Bet_interphase.Bets.Away { odds = game_odds.away }
    ]
  in
  List.iter all_bets ~f:(fun bet ->
    let variance = Bet_interphase.bet_variance bet game_distribution in
    let ev = Bet_interphase.bet_expected_value bet game_distribution in
    print_s
      [%message
        (bet : Bet_interphase.Bets.t) (variance : float) (ev : float)];
    print_endline "");
  return ()
;;

let run_example () =
  let%bind bankroll =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter bankroll"
  in
  let%bind unwanted_team1 =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter your first unwanted team"
  in
  let%bind unwanted_team2 =
    Async_interactive.ask_dispatch_gen
      ~f:(fun input -> Ok input)
      "Enter your second unwanted team"
  in
  Matchday_handeling.output_bets_and_information
    example
    ~bankroll:(float_of_string bankroll)
    ~unwanted_teams:[ unwanted_team1; unwanted_team2 ];
  return ()
;;
