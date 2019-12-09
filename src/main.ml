open Lwt.Infix

let main () =
  let ( >|=! ) x f = x >|= function Ok x -> f x | Error _ -> assert false in
  let token = Unix.getenv "GITHUB_TOKEN" in
  Query.search_repositories ~token ~from:"2019-12-02T00:00:00Z"
    ~until:"2019-12-08T23:59:59Z" ~endCursor:"10000000" ~login:"craigfe" ()
  >|=! fun rsp ->
  rsp |> (Pp.contributions_collection ~person:`First) Format.std_formatter

(* |> Utils.contributions_collection_to_yojson
 * |> Yojson.Safe.pretty_print Format.std_formatter *)

let () = Lwt_main.run (main ())
