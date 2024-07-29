import tensorflow as tf
from tensorflow.keras.models import load_model
import pandas as pd
import numpy as np
import sys
import csv




# Should be called from main directory
# Should be data_files/small_test.xlsx
filename = sys.argv[1]
team_map = {0: 'Alaves', 1: 'Almeria', 2: 'Ath Bilbao', 3: 'Atl. Madrid', 4: 'Barcelona', 5: 'Betis', 6: 'Cadiz CF', 7: 'Celta Vigo', 8: 'Cordoba', 9: 'Dep. La Coruna', 10: 'Eibar', 11: 'Elche', 12: 'Espanyol', 13: 'Getafe', 14: 'Gijon', 15: 'Girona', 16: 'Granada CF', 17: 'Huesca', 18: 'Las Palmas', 19: 'Leganes', 20: 'Levante', 21: 'Malaga', 22: 'Mallorca', 23: 'Osasuna', 24: 'Rayo Vallecano', 25: 'Real Madrid', 26: 'Real Sociedad', 27: 'Sevilla', 28: 'Valencia', 29: 'Valladolid', 30: 'Villarreal'}

dataset = pd.read_excel(filename)

del dataset["Unnamed: 0"]
dataset.describe().transpose()[['mean', 'std']]
predictor_model = load_model('models/model_1.tf')

match_predictions = []
for index, row in dataset.iterrows():
    result = predictor_model.predict(np.array([row]), verbose = 0)
    match_predictions.append([team_map[dataset["HomeTeam"][index]],team_map[dataset["AwayTeam"][index]], dataset["OP1"][index],dataset["OPX"][index],dataset["OP2"][index], result[0][0], result[0][1],result[0][2]])
    # week_predictions.append(dataset["HomeTeam"][index] + result[0])
# print(week_predictions)
# predictions = pd.DataFrame(week_predictions)
# predictions.to_excel("week_predictions.xlsx")
with open('data_files/matchday_data.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(match_predictions)