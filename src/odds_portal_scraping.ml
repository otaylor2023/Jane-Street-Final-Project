open! Core

module Curl = struct
  let writer accum data =
    Buffer.add_string accum data;
    String.length data
  ;;

  let get_exn url =
    let error_buffer = ref "" in
    let result = Buffer.create 16384 in
    let fail error = failwithf "Curl failed on %s: %s" url error () in
    try
      let connection = Curl.init () in
      Curl.set_errorbuffer connection error_buffer;
      Curl.set_writefunction connection (writer result);
      Curl.set_followlocation connection true;
      Curl.set_url connection url;
      Curl.perform connection;
      let result = Buffer.contents result in
      Curl.cleanup connection;
      result
    with
    | Curl.CurlException (_reason, _code, _str) -> fail !error_buffer
    | Failure s -> fail s
  ;;
end

let get_matches website =
  let contents = Curl.get_exn website in
  print_endline contents;
  let open Soup in
  parse contents
  $$ ".flex.group"
  |> to_list
  |> List.map ~f:(fun a -> Soup.to_string a)
;;

(* let%expect_test "get_matches" = (* This test uses existing files on the
   filesystem. *) List.iter (get_matches
   "https://www.oddsportal.com/football/spain/laliga/") ~f:print_endline;
   [%expect {| /wiki/Carnivore /wiki/Domestication_of_the_cat /wiki/Mammal
   /wiki/Species |}] ;; *)

(* curl
   'https://www.oddsportal.com/ajax-sport-country-tournament_/1/A1MYWy8T/X360488X0X0X0X0X0X0X0X0X0X0X0X0X134217729X0X1048578X0X0X1024X18464X131072X256/1/?_=1721921777'
   \ -H 'accept: application/json, text/plain, */*' \ -H 'accept-language:
   en-US,en;q=0.9' \ -H 'priority: u=1, i' \ -H 'referer:
   https://www.oddsportal.com/football/spain/laliga/' \ -H 'sec-ch-ua:
   "Not/A)Brand";v="8", "Chromium";v="126", "Google Chrome";v="126"' \ -H
   'sec-ch-ua-mobile: ?0' \ -H 'sec-ch-ua-platform: "macOS"' \ -H
   'sec-fetch-dest: empty' \ -H 'sec-fetch-mode: cors' \ -H 'sec-fetch-site:
   same-origin' \ -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X
   10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0
   Safari/537.36' \ -H 'x-requested-with: XMLHttpRequest' *)
