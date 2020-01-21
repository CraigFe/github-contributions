(lang dune 2.0)
(implicit_transitive_deps false)

(generate_opam_files true)
(source (github CraigFe/github-contributions))
(maintainers "Craig Ferguson <me@craigfe.io>")
(authors "Craig Ferguson <me@craigfe.io>")

(package
 (name github-contributions)
 (synopsis "GitHub contributions report generator")
 (depends 
  cmdliner
  cohttp
  cohttp-lwt
  cohttp-lwt-unix
  fmt
  lwt
  ppx_deriving_yojson
  ppx_graphql
  tls
  uri))



