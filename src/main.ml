open Lwt.Infix

let main ~token ~users ~from ~until =
  let ( >|=! ) x f = x >|= function Ok x -> f x | Error _ -> assert false in
  let login = List.hd users in
  Query.search_repositories ~token ~login ~from ~until ~endCursor:"10000000" ()
  >|=! fun rsp ->
  rsp |> (Pp.contributions_collection ~person:`First) Format.std_formatter

(* |> Utils.contributions_collection_to_yojson
 * |> Yojson.Safe.pretty_print Format.std_formatter *)

open Cmdliner

let github_token =
  let env = Arg.env_var "GITHUB_TOKEN" in
  let doc = "GitHub OAuth token." in
  Term.(app (const (fun x -> `Oauth_token x)))
    Arg.(value & opt string "" & info ~env [ "github-token" ] ~doc)

let users =
  let doc = "List of GitHub users logins for which to check contributions." in
  Term.(app (const (fun x -> `Users x)))
    Arg.(value & opt (list string) [ "craigfe" ] & info [ "users" ] ~doc)

let from =
  let doc = "Time from which to count contributions." in
  Term.(app (const (fun x -> `From x)))
    Arg.(value & opt string "2019-12-02T00:00:00Z" & info [ "from" ] ~doc)

let until =
  let doc = "Time until which to count contributions." in
  Term.(app (const (fun x -> `Until x)))
    Arg.(value & opt string "2019-12-08T23:59:59Z" & info [ "until" ] ~doc)

let run (`Oauth_token token) (`Users users) (`From from) (`Until until) =
  Lwt_main.run (main ~token ~users ~from ~until)

let term =
  let exec_name = "contrib" in
  let doc = "Get list of public GitHub contributions within a time range" in
  Term.
    (pure run $ github_token $ users $ from $ until, Term.info ~doc exec_name)

let () = Term.(eval term |> exit_status_of_result) |> exit
