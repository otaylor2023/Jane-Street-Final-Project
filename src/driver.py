from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.expected_conditions import presence_of_element_located
import time

service = webdriver.FirefoxService(executable_path='/snap/firefox/current/usr/lib/firefox/geckodriver')
options = webdriver.FirefoxOptions()
options.add_argument('--headless')
options.binary_location = '/snap/firefox/current/usr/lib/firefox/firefox'

with webdriver.Firefox(service=service, options=options) as driver:

    driver.get("https://www.oddschecker.com/us/soccer/spain/la-liga-primera")
    print("start")
    time.sleep(15)
    print("end")
    contents = driver.page_source
    with open("resources/odds", "w") as file:
        file.write(contents)


    driver.get("https://www.flashscore.com/standings/bJrC4h3n/SbZJTabs/#/SbZJTabs/table/home")
    print("start")
    time.sleep(15)
    print("end")
    home_contents = driver.page_source
    with open("resources/stats_home_past", "w") as file:
        file.write(home_contents)


    driver.get("https://www.flashscore.com/standings/bJrC4h3n/SbZJTabs/#/SbZJTabs/table/away")
    print("start")
    time.sleep(15)
    print("end")
    away_contents = driver.page_source
    with open("resources/stats_away_past", "w") as file:
        file.write(away_contents)



