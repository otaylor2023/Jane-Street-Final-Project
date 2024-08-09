// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

console.log("running")

window.onload = function () {
    if (location.href.includes("lang=en")) {
        handle_data_page()
    } else if (location.href.includes("results")) {
        var scrollInterval = setInterval(function () {
            document.documentElement.scrollTop = document.documentElement.scrollHeight;
        }, 800);
        setTimeout(() => handle_season_map(), 2500)

    } else {
        setTimeout(() => handle_game_page(), 1000)
    }
}

// chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
//     var requestName = Object.keys(request)[0];
//     switch (requestName) {
//         // case "download_json":
//         //     download_json(request[requestName]);
//         //     break;
//     };
// });

function openTab(link) {
    chrome.runtime.sendMessage({ open_tab: link });
}

function send_odds_data(odds_data) {
    chrome.runtime.sendMessage({ send_odds_data: odds_data });
}

// function season_page_loaded() {
//     console.log("page loaded")
//     chrome.runtime.sendMessage({ season_page_loaded: "" });
// }

function send_season_page_map(season_map) {
    console.log("sending map")
    chrome.runtime.sendMessage({
        send_season_page_map: {
            page_map: season_map,
            page_url: location.href
        }
    });
}


class Game_object {
    constructor() {
        this.id = -1
        this.url = ""
        this.home_team = ""
        this.home_goals = -1
        this.away_goals = -1
        this.away_team = ""
        this.result = ""
        this.date = ""
        this.season = ""
    }
}

var childrenMatches = function (elem, selector) {
    return Array.prototype.filter.call(elem.children, function (child) {
        return child.matches(selector);
    });
};




function handle_season_map() {
    // const scrollingElement = (document.scrollingElement || document.body);
    // scrollingElement.scrollTop = scrollingElement.scrollHeight;
    // window.scrollTo({ left: 0, top: document.body.scrollHeight, behavior: "smooth" });

    season_map = get_season_page_map();
    if (!season_map) {
        season_map = get_season_page_map();
    }
    send_season_page_map(season_map);
}

function get_season_page_map() {
    // get a's whos hrefs include "football/spain"
    // get last part as id
    // get team names
    // get home score and away score
    // get link
    // do for all
    // put in dict
    // then go into logic with getting data

    event_rows = document.querySelectorAll(".eventRow")
    console.log(event_rows)
    console.log(event_rows.length)
    date = ""

    doc_title = document.title
    split_list = doc_title.split(" ")
    season = split_list[1]
    if (!"0123456789".includes(season.substring(0, 1))) {
        season = split_list[2]
    }
    season_map = {}
    for (i = 0; i < event_rows.length; i++) {
        row = event_rows[i];
        game = new Game_object();
        game.season = season
        divs = childrenMatches(row, "div")
        console.log("length")
        console.log(divs)
        if (divs.length > 1) {
            console.log("date row")
            date = divs[divs.length - 2].querySelector("div").innerText
            console.log(date)
        }
        game.date = date;
        console.log("target div");

        target_div = divs[divs.length - 1];
        console.log(target_div)
        target_a = target_div.querySelector("a[href*='/football/spain/']");
        console.log("target a")
        console.log(target_a)
        url = target_a.href
        game.url = url
        console.log("target url")
        console.log(url)
        // href looks like /football/spain/laliga-2022-2023/betis-valencia-lx5qBKi8/
        // want to get lx5qBKi8
        url_split = url.split("-")
        last_split = url_split[url_split.length - 1]
        id = last_split.substring(0, last_split.length - 1)
        console.log("id")
        console.log(id)
        game.id = id;
        info_str_numbers = target_a.innerText;
        info_str_split = info_str_numbers.split("\n")
        game.home_team = info_str_split[2]
        game.away_team = info_str_split[8]
        game.home_goals = parseInt(info_str_split[4])
        game.away_goals = parseInt(info_str_split[6])
        if (game.home_goals > game.away_goals) {
            game.result = "H"
        } else if (game.away_goals > game.home_goals) {
            game.result = "A"
        } else {
            game.result = "D"
        }
        console.log(game.result)
        season_map[id] = game;
    }
    console.log(season_map)
    return season_map
}

function handle_game_page() {
    get_link()
}

function handle_data_page() {
    get_odds_data()
}

function get_odds_data() {
    content = document.getElementsByTagName("pre")[0].innerText
    json = JSON.parse(content)
    console.log("json")
    console.log(json)
    console.log(json["d"])
    console.log(json["d"]["encodeventId"])
    odds_data = {}
    odds_data["url"] = location.href
    odds_data["id"] = json["d"]["encodeventId"]
    console.log("id")
    console.log(odds_data["id"])
    odds_data["odds"] = json["d"]["oddsdata"]["back"]
    // console.log(json_str)
    console.log(odds_data)
    send_odds_data(odds_data)
}

function get_link() {
    let all_resources = performance.getEntriesByType("resource");
    for (i = 0; i < all_resources.length; i++) {
        target_url = ""
        if ((all_resources[i].name).includes("feed/match-event")) {
            console.log(all_resources[i].name)
            target_url = all_resources[i].name;
        }
        if (target_url != "") {
            console.log("sending url")
            openTab(target_url)
        } else {
            console.log("no url")
        }
    }
}



