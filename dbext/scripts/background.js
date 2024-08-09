console.log("bg running")

let season_data = {}
let all_ids = []
let explored_ids = []
let open_tabs = 0

let bookmakers =
{
    3: "bet_at_home",
    5: "unibet",
    14: "10bet",
    15: "william_hill",
    16: "bet365",
    18: "pinnacle",
    24: "betsafe",
    26: "betway",
    27: "888sport",
    33: "nordicbet",
    43: "betsson",
    46: "fortuna_cz",
    49: "tipsport_cz",
    129: "bwin",
    139: "france_pari",
    141: "betclic",
    147: "dafabet",
    164: "fortuna_sk",
    390: "matchbook",
    392: "bwin",
    406: "sportum",
    411: "tipsport_sk",
    417: "1xbet",
    429: "betfair",
    451: "vulkan_bet",
    470: "marsbet",
    500: "22bet",
    550: "ggbet",
    575: "betinasia",
    581: "10x10bet",
    584: "lasbet",
    617: "vobet",
    638: "alphabet"
}

chrome.action.onClicked.addListener(() => {
    console.log("clicked");
    get_all_odds_data();
    chrome.action.setBadgeText({ text: "✓" });
    setTimeout(() => {
        chrome.action.setBadgeText({ text: "" });
    }, 1500);
});

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    var requestName = Object.keys(request)[0];
    switch (requestName) {
        case "open_tab":
            open_tab(request[requestName]);
            break;
        case "send_odds_data":
            receive_odds_data(request[requestName]);
            break;
        case "page_start":
            break;
        case "send_season_page_map":
            receive_season_page_map(request[requestName]);

    };
});

function receive_season_page_map(map_and_url) {
    console.log(map_and_url)
    src_url = map_and_url.page_url;
    page_map = map_and_url.page_map;
    console.log(src_url)
    console.log(page_map)

    last_page_pos = src_url.indexOf("page/")
    console.log(last_page_pos)
    console.log(src_url.charAt(last_page_pos + 5))
    if (last_page_pos == -1) {
        last_page = 1
    } else {
        last_page = parseInt(src_url.charAt(last_page_pos + 5))
    }
    console.log("last page")
    console.log(last_page)
    // if (last_page == 1) {
    //     season_data = {}
    // }
    if (last_page < 8) {
        chrome.tabs.query({ url: src_url }, function (tabs) {
            console.log(tabs)
            chrome.tabs.remove(tabs[0].id);
        });
        end_pos = src_url.indexOf("results/") + 8
        new_url = src_url.substring(0, end_pos) + "#/page/" + (last_page + 1)
        console.log("opening new url")
        console.log(new_url)
        chrome.tabs.create({ url: new_url, active: true });
    }
    console.log("old season data length")
    console.log(Object.keys(season_data).length)
    season_data = { ...season_data, ...page_map }
    console.log("page_map length")
    console.log(Object.keys(page_map).length)
    console.log("new season_data")
    console.log(season_data)
    console.log(Object.keys(season_data).length)
}

function get_all_odds_data() {
    all_ids = Object.keys(season_data);
    open_next_odds_pages()
}

function open_next_odds_pages() {
    if (all_ids.length > 0) {
        limit = Math.min(10, all_ids.length)
        for (i = 0; i < limit; i++) {
            open_tabs++
            next_id = all_ids.pop()
            open_tab(season_data[next_id].url)
        }
        console.log(all_ids.length)
    } else if (open_tabs <= 0) {
        console.log("done")
        console.log(all_ids)
        console.log(season_data)
        export_season_data(season_data)
    }

}

function receive_odds_data(odds_data) {
    console.log('received data')
    console.log(odds_data)
    if (odds_data === undefined || odds_data.id === undefined || odds_data.odds === undefined || odds_data.url === undefined) {
        console.log("no data")
        return
    }
    id = odds_data.id;
    explored_ids = explored_ids.concat(id)
    processed_odds = process_odds_data(odds_data.odds)
    season_data[id] = { ...season_data[id], ...processed_odds }
    console.log(season_data[id])
    chrome.tabs.query({ currentWindow: true, url: odds_data.url }, function (tabs) {
        chrome.tabs.remove(tabs[0].id);
    });
    chrome.tabs.query({ currentWindow: true, url: season_data[id].url }, function (tabs) {
        chrome.tabs.remove(tabs[0].id);
    });
    open_tabs--;
    console.log("open tabs")
    console.log(open_tabs)
    if (open_tabs < 3) {
        open_next_odds_pages()
    }
}

function arrayUnique(array) {
    var a = array.concat();
    for (var i = 0; i < a.length; ++i) {
        for (var j = i + 1; j < a.length; ++j) {
            if (a[i] === a[j])
                a.splice(j--, 1);
        }
    }

    return a;
}


function export_season_data(json_content) {
    csv_content = convert_to_csv(json_content)
    console.log(csv_content)
    blob = new Blob([csv_content], { type: "text/csv" });
    // url = URL.createObjectURL(blob);
    url = `data:${blob.type};base64,${btoa(csv_content)}`;
    console.log(url)
    filename = "dbfile.csv"
    download_options = {
        "url": url,
        "filename": `${filename}`,
        "conflictAction": "uniquify",
        "saveAs": false
    }
    chrome.downloads.download(download_options);
}

function convert_to_csv(data) {
    console.log("trying to convert")
    all_keys = []
    Object.keys(data).forEach(row_id => {
        row = data[row_id]
        console.log("row data")
        console.log(row)
        console.log(Object.keys(row))
        all_keys = arrayUnique(all_keys.concat(Object.keys(row)))
    });
    csv_string = all_keys.join(",") + "\n"
    console.log(csv_string)
    Object.keys(data).forEach(row_id => {
        row = data[row_id]
        all_keys.forEach(key => {
            value = row[key] ?? ""
            csv_string += value + ",";
        });
        csv_string += "\n"
    });
    return csv_string
}

function process_odds_data(odds_data) {
    console.log("process odds data")
    console.log(odds_data)
    console.log(odds_data["E-1-2-0-0-0"])
    child_data = odds_data["E-1-2-0-0-0"]
    opening_odds = child_data["openingOdd"]
    closing_odds = child_data["odds"]
    console.log(opening_odds)
    console.log(closing_odds)
    new_opening_odds = {}
    new_closing_odds = {}
    Object.keys(opening_odds).forEach(bookmaker_id => {
        bookmaker_name = bookmakers[bookmaker_id] ?? bookmaker_id
        op1 = "OP1_" + bookmaker_name;
        opx = "OPX_" + bookmaker_name;
        op2 = "OP2_" + bookmaker_name;
        new_opening_odds[op1] = opening_odds[bookmaker_id][0]
        new_opening_odds[opx] = opening_odds[bookmaker_id][1]
        new_opening_odds[op2] = opening_odds[bookmaker_id][2]
    });
    Object.keys(closing_odds).forEach(bookmaker_id => {
        bookmaker_name = bookmakers[bookmaker_id] ?? bookmaker_id
        cp1 = "CP1_" + bookmaker_name;
        cpx = "CPX_" + bookmaker_name;
        cp2 = "CP2_" + bookmaker_name;
        new_closing_odds[cp1] = closing_odds[bookmaker_id][0]
        new_closing_odds[cpx] = closing_odds[bookmaker_id][1]
        new_closing_odds[cp2] = closing_odds[bookmaker_id][2]
    });
    console.log(new_opening_odds)
    console.log(new_closing_odds)
    if (Object.keys(new_closing_odds).length - Object.keys(new_opening_odds).length != 0) {
        10 / 0
    }
    combined_odds = { ...new_opening_odds, ...new_closing_odds }
    console.log(combined_odds)
    return combined_odds
}



// function start_season_download() {
//     chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
//         chrome.runtime.sendMessage(tabs[0].id, { start_season_download: "" });
//     });
// }

/*

button is pressed
bg goes to page1 content and asks for the number of pages?
page1 content sends number of pages
bg asks for map
page1 content sends map
bg closes page1
bg opens page2
page2 says its ready
bg asks page2 to send map
etc


 */


function open_tab(url) {
    chrome.tabs.create({ url: url, active: true });
}


