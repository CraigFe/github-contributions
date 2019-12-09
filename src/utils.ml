open Lwt.Infix

let ( >>> ) f g x = g (f x)

type repo = { name : string } [@@deriving yojson]

type pr = { created_at : string; title : string; url : string }
[@@deriving yojson]

type issue = { created_at : string; title : string; url : string }
[@@deriving yojson]

type 'a by_repo = { repository : repo; contributions : 'a list }
[@@deriving yojson]

type contributions_collection = {
  restricted_contribs : int;
  prs : pr by_repo list;
  issues : issue by_repo list;
  pr_reviews : pr by_repo list;
}
[@@deriving yojson]

let assert_some = function Some s -> s | None -> assert false

module Synthesise = struct
  let repo x : repo = { name = x#nameWithOwner }

  let pr x : pr =
    let x = x#pullRequest in
    { created_at = x#createdAt; title = x#title; url = x#url }

  let issue x : issue =
    let x = x#issue in
    { created_at = x#createdAt; title = x#title; url = x#url }

  let by_repo c x =
    {
      repository = repo x#repository;
      contributions =
        List.map (assert_some >>> c) (x#contributions#nodes |> assert_some);
    }

  let contributions_collection x =
    {
      restricted_contribs = x#restrictedContributionsCount;
      prs = List.map (by_repo pr) x#pullRequestContributionsByRepository;
      issues = List.map (by_repo issue) x#issueContributionsByRepository;
      pr_reviews =
        List.map (by_repo pr) x#pullRequestReviewContributionsByRepository;
    }
end

let executable_query (query, kvariables, parse) ~token =
  kvariables (fun variables ->
      let uri = Uri.of_string "https://api.github.com/graphql" in
      let headers =
        Cohttp.Header.of_list
          [
            ("Authorization", "bearer " ^ token);
            ("User-Agent", "craigfe/github-automation");
          ]
      in
      let body =
        `Assoc [ ("query", `String query); ("variables", variables) ]
      in
      let serialized_body = Yojson.Basic.to_string body in
      Cohttp_lwt_unix.Client.post ~headers ~body:(`String serialized_body) uri
      >>= fun (rsp, body) ->
      Cohttp_lwt.Body.to_string body >|= fun body' ->
      match Cohttp.Code.(code_of_status rsp.status |> is_success) with
      | false -> Error body'
      | true -> (
          try
            Ok
              ( Yojson.Basic.from_string body'
              (* |> (fun x ->
               *      Yojson.Basic.pretty_print Format.std_formatter x;
               *      x) *)
              |> parse
              |> fun x ->
                Synthesise.contributions_collection
                  (x#user |> assert_some)#contributionsCollection )
          with Yojson.Json_error err -> Error err ))
