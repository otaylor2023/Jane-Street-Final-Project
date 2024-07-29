import pandas as pd

initial_matchday = pd.read_excel("small_test.xlsx")
updated_matchday = pd.read_excel("small_test.xlsx")


team_map = {0: 'Alaves', 1: 'Almeria', 2: 'Ath Bilbao', 3: 'Atl. Madrid', 4: 'Barcelona', 5: 'Betis', 6: 'Cadiz CF', 7: 'Celta Vigo', 8: 'Cordoba', 9: 'Dep. La Coruna', 10: 'Eibar', 11: 'Elche', 12: 'Espanyol', 13: 'Getafe', 14: 'Gijon', 15: 'Girona', 16: 'Granada CF', 17: 'Huesca', 18: 'Las Palmas', 19: 'Leganes', 20: 'Levante', 21: 'Malaga', 22: 'Mallorca', 23: 'Osasuna', 24: 'Rayo Vallecano', 25: 'Real Madrid', 26: 'Real Sociedad', 27: 'Sevilla', 28: 'Valencia', 29: 'Valladolid', 30: 'Villarreal'}
# if pd.Dataframe.eq initial_matchday updated_matchday:
#     # run( python3 model_connection.py updated_matchday.xlsx 2>/dev/null)
#     one = 1
predictions = pd.read_excel("week_predictions.xlsx")

for index, row in updated_matchday.iterrows():
    # print((team_map[row["HomeTeam"]], team_map[row["AwayTeam"]]))
    # print((row["OP1"],row["OPX"],row["OP2"]))
    # print(predictions[0][index])
    # print(predictions[1][index])
    # print(predictions[2][index])
    # print((predictions[index][0],predictions[index][1],predictions[index][2]))
    print(",".join([team_map[row["HomeTeam"]], team_map[row["AwayTeam"]],row["OP1"],row["OPX"],row["OP2"], predictions[0][index] , predictions[1][index],predictions[2][index]]))



# ( ("Grenada CF", "Dep. La Coruna")
#     , ( { Bet_interphase.Game_odds.home = 2.14; tie = 3.33; away = 3.95 }
#       , { Bet_interphase.Game_odds.home = 2.14; tie = 3.33; away = 3.95 } ) )