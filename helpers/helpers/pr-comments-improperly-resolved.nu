#!/usr/bin/env nix
#!nix shell nixpkgs#gh --command nu

# Find PR comments resolved by someone other than the original commenter
# Usage: ./find-resolved-comments.nu <owner/repo> [--pr <number>] [--limit <num>]

def main [
    repo: string,              # Repository in format "owner/repo"
    --pr (-p): int,           # Specific PR number (optional)
    --limit (-l): int = 10,   # Number of PRs to check (default: 10)
    --state (-s): string = "all" # PR state: open, closed, or all
] {
    print $"Searching for resolved comments in ($repo)..."

    let prs = if ($pr != null) {
        # Get specific PR
        [($pr | into string)]
    } else {
        # Get recent PRs
        gh pr list --repo $repo --state $state --limit $limit --json number
        | from json
        | get number
        | each { |n| $n | into string }
    }

    print $"Checking ($prs | length) PR\(s\)..."

    $prs | each { |pr_num|
        print $"Checking PR #($pr_num)..."

        # Get PR review comments (code review comments)
        let review_comments = (
            gh api $"/repos/($repo)/pulls/($pr_num)/comments" --paginate
            | from json
            | where ($it.in_reply_to_id? == null)  # Only root comments (thread starters)
        )

        # Get issue comments (general PR comments)
        let issue_comments = (
            gh api $"/repos/($repo)/issues/($pr_num)/comments" --paginate
            | from json
        )

        # Check review comments for resolved threads
        let resolved_review_threads = $review_comments | each { |comment|
            let thread_id = $comment.id
            let original_author = $comment.user.login

            # Get all replies in this thread
            let replies = (
                gh api $"/repos/($repo)/pulls/($pr_num)/comments" --paginate
                | from json
                | where in_reply_to_id? == $thread_id
            )

            # Check if any reply resolves the thread and is from different user
            let resolving_replies = $replies | where {|reply|
                ($reply.user.login != $original_author) and (
                    ($reply.body | str contains "resolve") or ($reply.body | str contains "fixed") or ($reply.body | str contains "done")
                )
            }

            if ($resolving_replies | length) > 0 {
                {
                    pr: $pr_num,
                    type: "review",
                    thread_id: $thread_id,
                    url: $comment.html_url,
                    original_author: $original_author,
                    original_comment: ($comment.body | str substring 0..100),
                    resolved_by: ($resolving_replies.0.user.login),
                    resolving_comment: ($resolving_replies.0.body | str substring 0..100)
                }
            } else {
                null
            }
        } | where ($it != null)

        # Also check for GitHub's native resolved conversations
        let pr_details = (
            gh api $"/repos/($repo)/pulls/($pr_num)"
            | from json
        )

        # Get review threads (this requires GraphQL for resolved status)
        let resolved_threads = (
            gh api graphql --field owner=($repo | split row "/" | first) --field repo=($repo | split row "/" | last) --field number=$pr_num -f query='
                query($owner: String!, $repo: String!, $number: Int!) {
                    repository(owner: $owner, name: $repo) {
                        pullRequest(number: $number) {
                            reviewThreads(first: 100) {
                                nodes {
                                    id
                                    isResolved
                                    resolvedBy {
                                        login
                                    }
                                    comments(first: 1) {
                                        nodes {
                                            author {
                                                login
                                            }
                                            body
                                            url
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            ' | from json
        )

        print ($resolved_threads)
        print ($resolved_threads | to nuon)

        let graphql_resolved = if ($resolved_threads.data.repository.pullRequest.reviewThreads.nodes? != null) {
            $resolved_threads.data.repository.pullRequest.reviewThreads.nodes
            | where isResolved == true
            | where resolvedBy.login? != null
            | where {|thread|
                let original_author = $thread.comments.nodes.0.author.login
                let resolved_by = $thread.resolvedBy.login
                $original_author != $resolved_by
            }
            | each {|thread|
                {
                    pr: $pr_num,
                    type: "resolved_thread",
                    thread_id: $thread.id,
                    url: $thread.comments.nodes.0.url,
                    original_author: $thread.comments.nodes.0.author.login,
                    original_comment: ($thread.comments.nodes.0.body | str substring 0..100),
                    resolved_by: $thread.resolvedBy.login,
                    resolving_comment: "Marked as resolved"
                }
            }
        } else {
            []
        }

        # Combine results
        $resolved_review_threads ++ $graphql_resolved
    }
    | flatten
    | where ($it != null)
}

# Helper function to format results nicely
def "main format" [] {
    each {|result|
        print $"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        print $"PR #($result.pr) - ($result.type | str upcase)"
        print $"URL: ($result.url)"
        print $"Original by: @($result.original_author)"
        print $"Resolved by: @($result.resolved_by)"
        print $"Original comment: ($result.original_comment)..."
        print $"Resolving action: ($result.resolving_comment)..."
        print ""
    }
}
