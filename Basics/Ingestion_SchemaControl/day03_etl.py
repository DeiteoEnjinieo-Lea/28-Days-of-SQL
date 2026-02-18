# Day 3: Python: Scraping web tables
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd

# 1. Setup Chrome options (Optional: add '--headless' to run without a window opening)
options = webdriver.ChromeOptions()

# 2. Initialize Driver (Automatically handles chromedriver)
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

try:
    # 3. Navigate to the page
    url = "https://example-site-with-table.com"
    driver.get(url)
    
    # 4. Get the HTML of the page after it loads
    html_content = driver.page_source
    
    # read_html returns a list of all tables found on the page.
    all_tables = pd.read_html(html_content)
    
    # Grab the first table found
    df = all_tables[0]
    print(df.head())

finally:
    # 6. Always close the browser
    driver.quit()

# Using BeautifulSoup - Rough Draft
from bs4 import BeautifulSoup

html_doc = "https://example-site-with-table.com"
soup = BeautifulSoup(html_doc,'html.parser')
html_content = soup.prettify()

all_tables = pd.read_html(html_content)

# Grab the first table found
df = all_tables[0]
print(df.head())

# Submitted to AI for corrections -- BeautifulSoup must be used with requests lib 
# Webscraping script updated

import requests
import pandas as pd
from bs4 import BeautifulSoup

# 1. Use the requests library to fetch the page
url = "https://example-site-with-table.com"
response = requests.get(url)

# always verify its success, 200 is success
if response.status_code == 200:
    print(f"Success! Status Code: {response.status_code}")

# 2. Pass the text from that response into BeautifulSoup
soup = BeautifulSoup(response.text, 'html.parser')

# 3. Use Pandas to find and read the tables in the HTML
# Note: pd.read_html can take the raw string directly, enforce dtype with str
all_tables = pd.read_html(str(soup))

# if no changes are need, can cast it directly
# This is often faster and avoids the object-to-string conversion
# all_tables = pd.read_html(response.text)

# 4. Grab the first table found
df = all_tables[0]
print(df.head())
