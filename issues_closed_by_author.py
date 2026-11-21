#!/usr/bin/env python3
"""Count a GitHub repository's closed issues per author of the PR or commit that closed them.

Uses `gh api graphql`, so `gh` must be authenticated. For each closed issue it reads the last
ClosedEvent: if the closer is a pull request, the issue is credited to the PR's author; if it
is a commit, to the commit's GitHub user (or its git author name when it has no linked user).
Issues closed by hand, with no PR or commit, are counted separately as "manual".

By default only issues closed as completed count; --include-not-planned adds the rest.
--by closer instead counts who performed the close (usually whoever merged the PR).

Examples:
    ./issues_closed_by_author.py
    ./issues_closed_by_author.py --repo mccorvie/riemann-masullo --include-not-planned
    ./issues_closed_by_author.py --by closer
"""

import argparse
import collections
import json
import re
import subprocess
import sys

QUERY = """
query($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    issues(states: CLOSED, first: 100, after: $cursor) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number
        stateReason
        timelineItems(itemTypes: CLOSED_EVENT, last: 1) {
          nodes {
            ... on ClosedEvent {
              actor { login }
              closer {
                __typename
                ... on PullRequest { author { login } }
                ... on Commit { author { name user { login } } }
              }
            }
          }
        }
      }
    }
  }
}
"""


def default_repo():
    """owner/name of the `origin` remote, or None."""
    try:
        url = subprocess.run(["git", "remote", "get-url", "origin"], capture_output=True,
                             text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    m = re.search(r"github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?/?$", url)
    return f"{m.group(1)}/{m.group(2)}" if m else None


def fetch_closed_issues(owner, name):
    issues, cursor = [], None
    while True:
        cmd = ["gh", "api", "graphql", "-f", f"query={QUERY}",
               "-F", f"owner={owner}", "-F", f"name={name}"]
        if cursor:
            cmd += ["-F", f"cursor={cursor}"]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            sys.exit(f"gh api graphql failed:\n{res.stderr or res.stdout}")
        page = json.loads(res.stdout)["data"]["repository"]["issues"]
        issues += page["nodes"]
        print(f"\rfetched {len(issues)} closed issues", end="", file=sys.stderr)
        if not page["pageInfo"]["hasNextPage"]:
            print(file=sys.stderr)
            return issues
        cursor = page["pageInfo"]["endCursor"]


def git_names():
    """Best-effort map from GitHub login to git author name, from noreply commit emails."""
    try:
        out = subprocess.run(["git", "log", "--format=%an\t%ae"], capture_output=True,
                             text=True, check=True).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return {}
    names = {}
    for line in set(out.splitlines()):
        an, _, ae = line.partition("\t")
        m = re.match(r"(?:\d+\+)?([^@]+)@users\.noreply\.github\.com$", ae)
        if m:
            names[m.group(1).lower()] = an
        else:  # e.g. marozols@gmail.com or ryan@mccorvie.org
            local, _, domain = ae.lower().partition("@")
            names.setdefault(local, an)
            names.setdefault(domain.split(".")[0], an)
        names.setdefault(an.lower(), an)  # git name identical to the login
    return names


def credit(issue, by):
    """The login (or name) an issue is credited to, or None if it was closed by hand."""
    events = issue["timelineItems"]["nodes"]
    ev = events[-1] if events else {}
    if by == "closer":
        return (ev.get("actor") or {}).get("login") or "ghost"
    closer = ev.get("closer")
    if not closer:
        return None
    if closer["__typename"] == "PullRequest":
        return (closer.get("author") or {}).get("login") or "ghost"
    if closer["__typename"] == "Commit":
        author = closer.get("author") or {}
        return (author.get("user") or {}).get("login") or author.get("name") or "ghost"
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--repo", default=default_repo(),
                    help="owner/name (default: the origin remote)")
    ap.add_argument("--by", choices=["author", "closer"], default="author",
                    help="credit the closing PR/commit author (default) or who performed the close")
    ap.add_argument("--include-not-planned", action="store_true",
                    help="also count issues closed as not planned")
    ap.add_argument("--json", action="store_true", help="print the counts as JSON")
    args = ap.parse_args()
    if not args.repo or "/" not in args.repo:
        ap.error("give --repo owner/name")
    owner, name = args.repo.split("/", 1)

    issues = fetch_closed_issues(owner, name)
    reasons = collections.Counter(i["stateReason"] for i in issues)
    counted = [i for i in issues
               if args.include_not_planned or i["stateReason"] == "COMPLETED"]

    counts, manual = collections.Counter(), 0
    for issue in counted:
        who = credit(issue, args.by)
        if who is None:
            manual += 1
        else:
            counts[who] += 1

    if args.json:
        print(json.dumps({"repo": args.repo, "by": args.by, "closed": len(issues),
                          "state_reasons": reasons, "counted": len(counted),
                          "manual": manual, "counts": dict(counts.most_common())}, indent=2))
        return

    names = git_names()
    print(f"{args.repo}: {len(issues)} closed issues "
          + ", ".join(f"{n} {r.lower().replace('_', ' ')}" for r, n in reasons.most_common()))
    print(f"counting {len(counted)}, credited by "
          + ("closing PR/commit author" if args.by == "author" else "who closed them") + "\n")
    width = max([len(w) for w in counts] + [5])
    print(f"{'count':>5}  {'login':<{width}}  git name")
    for who, n in counts.most_common():
        print(f"{n:>5}  {who:<{width}}  {names.get(who.lower(), '')}")
    if manual:
        print(f"{manual:>5}  {'(closed by hand, no PR or commit)':<{width}}")


if __name__ == "__main__":
    main()
