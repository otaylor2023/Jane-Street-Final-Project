import tensorflow as tf
from tensorflow.keras.models import load_model
import pandas as pd
import numpy as np
import sys
import csv

def closing_heuristics(op1, opx, op2):

    if op2 > opx > op1:
        return (op1*(0.97), opx, op2)
    if opx > op2 > op1:
        return (op1, opx*(0.97), op2)
    if opx > op1 > op2:
        return (op1, opx, op2*(0.97))
    if op1 > opx > op2:
        return (op1*(0.97), opx, op2)
    return (op1, opx, op2)


filename = "/home/ubuntu/Jane-Street-Final-Project/data_files/week_data.csv"

# Should be called from main directory
# Should be data_files/small_test.xlsx
team_name_to_idx = {'Alaves': 0, 'Almeria': 1, 'Ath Bilbao': 2, 'Atl. Madrid': 3, 'Barcelona': 4, 'Betis': 5, 'Cadiz CF': 6, 'Celta Vigo': 7, 'Cordoba': 8, 'Dep. La Coruna': 9, 'Eibar': 10, 'Elche': 11, 'Espanyol': 12, 'Getafe': 13, 'Gijon': 14, 'Girona': 15, 'Granada CF': 16, 'Huesca': 17, 'Las Palmas': 18, 'Leganes': 19, 'Levante': 20, 'Malaga': 21, 'Mallorca': 22, 'Osasuna': 23, 'Rayo Vallecano': 24, 'Real Madrid': 25, 'Real Sociedad': 26, 'Sevilla': 27, 'Valencia': 28, 'Valladolid': 29, 'Villarreal': 30}
team_idx_to_name = {0: 'Alaves', 1: 'Almeria', 2: 'Ath Bilbao', 3: 'Atl. Madrid', 4: 'Barcelona', 5: 'Betis', 6: 'Cadiz CF', 7: 'Celta Vigo', 8: 'Cordoba', 9: 'Dep. La Coruna', 10: 'Eibar', 11: 'Elche', 12: 'Espanyol', 13: 'Getafe', 14: 'Gijon', 15: 'Girona', 16: 'Granada CF', 17: 'Huesca', 18: 'Las Palmas', 19: 'Leganes', 20: 'Levante', 21: 'Malaga', 22: 'Mallorca', 23: 'Osasuna', 24: 'Rayo Vallecano', 25: 'Real Madrid', 26: 'Real Sociedad', 27: 'Sevilla', 28: 'Valencia', 29: 'Valladolid', 30: 'Villarreal'}

dataset = pd.read_csv(filename)

#dataset = pd.read_excel(filename)

dataset['HomeTeam'] = dataset['HomeTeam'].map(team_name_to_idx)
dataset['AwayTeam'] = dataset['AwayTeam'].map(team_name_to_idx)

print(dataset)
dataset.describe().transpose()[['mean', 'std']]
books = dataset.iloc[:,-3:]

dataset = dataset.drop(['book1', 'book2', 'bookX'], axis=1)

predictor_model = load_model('models/model_1.tf')

match_predictions = []
for index, row in dataset.iterrows():
    result = predictor_model.predict(np.array([row]), verbose = 0)
    result = closing_heuristics(result[0][0], result[0][1],result[0][2])
    match_predictions.append([team_idx_to_name[dataset["HomeTeam"][index]],team_idx_to_name[dataset["AwayTeam"][index]], dataset["OP1"][index],dataset["OPX"][index],dataset["OP2"][index], result[0], result[1],result[2], books["book1"][index],books["bookX"][index],books["book2"][index] ])
    # week_predictions.append(dataset["HomeTeam"][index] + result[0])
# print(week_predictions)
# predictions = pd.DataFrame(week_predictions)
# predictions.to_excel("week_predictions.xlsx")
with open('data_files/matchday_data.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(match_predictions)