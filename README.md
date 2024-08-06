---
title: La Liga Sports Forecasting 
---
# La Liga Sports Betting & Forecasting

In this project, we implemented forcasting techniques, OCaml Graphics, and scraping techniques to create a tool for sportsbetting on Laliga matches.

## Project Overview

Our goal was to create an interactive tool that could help make sports betting profitable. It intakes a users bankroll, risk tolerance, and favorite team, and makes personalized suggestions. 

We target our betting to the Spain First Division Football League -> La Liga. Our approach was to predict the closing odds and use it as the fair value. Using the closing odds, we could decide to buy at the current odds by calculating its expected value, variance, and risk. The approach was decided on under the consideration that sports books are increadibly accurate at predicting the lines and probabilities. Instead of competiting against their models, we opted to use the provided odds to make decisions. 

### Data Analytics And Processing

### Web Scraping

In order to make a functioning tool, we needed to be able to get current odds accross many books, updated league statistics, and upcoming matches. 

We decided to scrape from OddsChecker.com to find the best odds for every game across many sites. Not only did this get us the odds, but this also gave us all of the upcoming games at the same time. We also found that OddsChecker showed discrepancies on the data it held and showed. Some odds they presented were less profitable and certain books were hidden, most likely in an attempt to take a cut from its users.

For match and updated league statistics, we scraped from Flash Score which keeps home, away, and overall statistics for the current season.

## Output

We created a OCaml Gui that displays the upcoming matches, season, date, and matchday. It takes in the users input of Favorite Team, Risk Tolerance, and Bankroll. We decided that it is not a good idea to bet for/against your favorite team, so it removes the match with your team from consideration. We used the risk tolerance to decide which games to suggest by applying a risk score to every bet, and only showing bets where the risk is <= the bet's risk. We used the bankroll to decide the amount to bet. We decided what percentage of our bankroll we should bet based on it's expected value and risk and multiply it by the bankroll to ouptut the bet amount.


## Installation Instructions/ Getting Started

The entirety of the project is included in within the repo. All of the dependacies and packages can be installed with ```opam install .```

In order to obtain the updated versions of the league statistics, sportsbook odds, and use model for new predictions, call ```bin/run```.

Once the statistics and odds are updated, simply running ```dune exec bin/render_game.exe``` will open the GUI and display the functioning product.


### Working with the GUI

The GUI is interactive with text boxes and a button. To write text, simply click into the text boxes to type. 

The favorite team box is meant to prevent the user from betting on matches including their team. We decided that betting for or against a team you support creates biasas and unprofitable betting.

The bankroll is limited to 1,000,000,000,000,000 due to its unpracticality and space.

The risk tolerance is taken on a scale from 0-9 and can be changed by typing a new number over it.

### Warning

The goal of this project was to learn and develop skill in ML forcasting, data-analytics, web-scraping, and much more through an enjoyable practical project. This is still only a tool, and there are never garuntees in gambling. 