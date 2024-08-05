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


print("start")
counter = 0
while True:
    counter += 1 
    with webdriver.Firefox(service=service, options=options) as driver:
        print("before")
        driver.get("https://www.kayak.com/flights/SFO-NYC/2024-09-21-flexible-3days?sort=bestflight_a&attempt=1&lastms=1722882303064")
        print("after")
        contents = driver.page_source
        if not contents:
            break
        
print(counter)