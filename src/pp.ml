open Utils

(* e.g. [mirage/index#12](https://github.com/mirage/index/pull/12) *)
let gh_url ppf url =
  let segments = String.split_on_char '/' url in
  match List.rev segments with
  | number :: _ :: repo :: org :: _ ->
      Fmt.pf ppf "[%s/%s#%s](%s)" org repo number url
  | _ -> Fmt.failwith "invalid GitHub contribution URL: %s" url

let gh_login : string Fmt.t = Fmt.(prefix (const string "@") string)

let pull_request ~person ppf ({ title; url; _ } : pr) =
  match person with
  | `First -> Fmt.pf ppf "Made a PR to %s (%s)" title url
  | `Third p -> Fmt.pf ppf "%a made a PR to %s (%s)" gh_login p title url

let issue ~person ppf ({ title; url; _ } : issue) =
  match person with
  | `First -> Fmt.pf ppf "Submitted an issue %s: %a" title gh_url url
  | `Third p ->
      Fmt.pf ppf "%a submitted an issue %s: %a" gh_login p title gh_url url

let pull_request_review ~person ppf ({ title; url; _ } : pr) =
  match person with
  | `First -> Fmt.pf ppf "Reviewed a PR to %s: %a" title gh_url url
  | `Third p -> Fmt.pf ppf "%a made a PR to %s: %a" gh_login p title gh_url url

let by_repo r ppf { repository; contributions } =
  Fmt.pf ppf "# %s\n%a" repository.name
    Fmt.(list ~sep:cut (prefix (const string "- ") r))
    contributions

let contributions_collection ~person ppf { prs; issues; pr_reviews; _ } =
  let open Fmt in
  pf ppf "%a\n%a\n%a"
    (list ~sep:cut (by_repo (pull_request ~person)))
    prs
    (list ~sep:cut (by_repo (issue ~person)))
    issues
    (list ~sep:cut (by_repo (pull_request_review ~person)))
    pr_reviews
