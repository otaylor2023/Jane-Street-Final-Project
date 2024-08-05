---
title: La Liga Sports Forecasting 
---

In this project, we implemented forcasting techniques, OCaml Graphics, and scraping techniques to create a tool for sportsbetting on Laliga matches.

# Project Overview

Our goal was to create an interactive tool that could help make sports betting profitable. It intakes a users bankroll, risk tolerance, and favorite team, and makes personalized suggestions. 

We target our betting to the Spain First Division Football League -> La Liga. Our approach was to predict the closing odds and use it as the fair value. Using the closing odds, we could decide to buy at the current odds by calculating its expected value, variance, and risk. The approach was decided on under the consideration that sports books are increadibly accurate at predicting the lines and probabilities. Instead of competiting against their models, we opted to use the provided odds to make decisions. 

# Data Analytics And Processing

# Web Scraping

In order to make a functioning tool, we needed to be able to get current odds accross many books, updated league statistics, and upcoming matches. 

We decided to scrape from OddsChecker.com to find the best odds for every game across many sites. Not only did this get us the odds, but this also gave us all of the upcoming games at the same time. We also found that OddsChecker showed discrepancies on the data it held and showed. Some odds they presented were less profitable and certain books were hidden, most likely in an attempt to take a cut from its users.

For match and updated league statistics, we scraped from Flash Score which keeps home, away, and overall statistics for the current season.

# Output

We created a OCaml Gui that displays the upcoming matches, season, date, and matchday. It takes in the users input of Favorite Team, Risk Tolerance, and Bankroll. We decided that it is not a good idea to bet for/against your favorite team, so it removes the match with your team from consideration. We used the risk tolerance to decide which games to suggest by applying a risk score to every bet, and only showing bets where the risk is <= the bet's risk. 



=======
We target our betting to the Spain First Division Football League -> La Liga. Our approach was to predict the closing odds and use it as the fair value. Using the closing odds, we could decide to buy at the current odds by calculating its expected value, variance, and risk. The approach was decided upon under the consideration that sports books are increadibly accurate at predicting the lines and probabilities, so instead of competiting against their models, we used the provided odds to make decisions. 
