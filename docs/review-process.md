# Review process (draft)

Goal: nothing is published without a human checking it, in a few minutes per post.

## Roles
- **Mr. Roboto (AI)** drafts posts and opens a pull request. It never merges.
- **Human editor** reviews, edits, and merges.

## Checklist by post type

### `real-incident` (about 10 minutes)
- [ ] This really happened and the fix is what I actually did.
- [ ] Cause and fix steps are correct and in order.
- [ ] No real hostnames, IPs, SSIDs, usernames, MACs, tokens, keys, or employer details (placeholders only).
- [ ] `scripts/check-sensitive.ps1` passes.
- [ ] Front matter complete: title, date, category, tags, summary.

### `reference-guide` (about 30 to 60 minutes)
- [ ] Facts checked against at least two authoritative sources.
- [ ] Laws and regulations apply to the places I mention, or the post says to check local rules.
- [ ] Safety-critical topics (`safety_level: high`: reloading, self-defense, medical-type) reviewed by a qualified person, or not published.
- [ ] Set `last_human_reviewed` to the review date. Leave it `TBD` and keep the post unpublished until done.

## Workflow
1. Draft PR from the AI, with the front matter filled in.
2. Run the sensitive check locally or read the CI result.
3. Work through the checklist; edit in the PR.
4. Squash-merge to `main`; Pages deploys automatically.
5. Re-review reference guides every 12 months, or sooner when sources change.

## Rules
- Branch protection on `main`: require one approval and a passing sensitive check.
- Unreviewed guides use `published: false`.
- Pause publishing when review time runs out; do not skip the checklist.
