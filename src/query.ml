let search_repositories =
  Utils.executable_query
    [%graphql
      {|
query($login: String!, $endCursor: String!, $from: DateTime!, $until: DateTime!) {
  user(login: $login) {
    contributionsCollection(from: $from, to: $until) {
      restrictedContributionsCount
      pullRequestContributionsByRepository(maxRepositories: 100) {
        repository {
          nameWithOwner
        }
        contributions(orderBy: {field: OCCURRED_AT, direction: ASC}, first: 100, after: $endCursor) {
          nodes {
            pullRequest {
              createdAt
              title
              url
            }
          }
        }
      }
      issueContributionsByRepository(maxRepositories: 100) {
        repository {
          nameWithOwner
        }
        contributions(orderBy: {field: OCCURRED_AT, direction: ASC}, first: 100, after: $endCursor) {
          nodes {
            issue {
              createdAt
              title
              url
            }
          }
        }
      }
      pullRequestReviewContributionsByRepository(maxRepositories: 100) {
        repository {
          nameWithOwner
        }
        contributions(orderBy: {field: OCCURRED_AT, direction: ASC}, first: 100, after: $endCursor) {
          nodes {
            pullRequest {
              createdAt
              title
              url
            }
          }
        }
      }
    }
  }
}
|}]
