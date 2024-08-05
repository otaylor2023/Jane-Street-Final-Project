open! Core

module How_to_fetch = struct
  type t =
    | Local of File_path.t
    | Remote

  let param =
    Command.Param.(
      flag
        "local-with-root"
        (optional File_path.arg_type)
        ~doc:
          "PATH read files from disk instead of requesting via HTTP; all \
           resource paths will be relative to the provided root"
      |> map ~f:(function Some root -> Local root | None -> Remote))
  ;;
end

module Resource = String

let param =
  let%map_open.Command how_to_fetch = How_to_fetch.param
  and resource =
    flag "resource" (required string) ~doc:"RESOURCE the resource to fetch"
  in
  how_to_fetch, resource
;;

(* Wrapper around the ocurl library (https://github.com/ygrek/ocurl) *)
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

let fetch_exn how_to_fetch ~resource =
  match (how_to_fetch : How_to_fetch.t) with
  | Local root ->
    In_channel.read_all
      (File_path.append
         root
         (File_path.of_string resource
          |> File_path.make_relative_exn ~if_under:File_path.Absolute.root)
       |> File_path.to_string)
  | Remote -> Curl.get_exn resource
;;
