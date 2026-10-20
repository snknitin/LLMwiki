You are the prep agent for tonight's unattended run, started by the overnight runner in E:\GIT_ROOT\Projects before the lanes start. Nobody will answer questions until morning, so never wait for input. The lanes start as soon as you finish, so work in parallel (one subagent per project) and finish within about 90 minutes.

The owner's rule: the projects in the top 10 of `F:\Vaults\LLMWiki\Nightly Runs\Project Priorities.md` (its `## Priority order`, skipping anything under Active or Archived) are what the agents work on. When a project is finished and moved to Active or Archived, the next one in the order takes its place. Each must be overnight-ready, have a live build tree, and sit in a Tonight lane, or under "Ready next" when its lane is full.

The runner worked out the list below. Do each item:

- **make-overnight-ready**: follow the `make-overnight-ready` skill completely: contract, multi-slice target, verify.ps1 + verify.sh, stop gate, PROGRESS/FEEDBACK/DECISIONS, live build tree, FirstSpark clone. It ends by choosing a lane.
- **build-tree**: the project is overnight-ready but has no `.hermes/live-build-tree/model.json`. Build it as the `make-overnight-ready` skill's build-tree step describes (`live-build-tree` skill conventions), commit and push.
- **advance**: the project's verify already passes, so tonight's run would stop at once. Follow the `advance-slice` skill so tonight has new work.
- **queue**: the project is ready but not in a Tonight lane. Pick its lane with the skill's "Pick a lane" rules. If that lane has a free slot (at most 3 per lane), move it there. If it's full but the item list names a **dequeue** candidate in that lane, move that one to "Ready next" first. Otherwise use the next-best lane with a free slot, and say why in the Prep Report. Only if every lane is full does it go to "Ready next".
- **dequeue**: only use it to make room for a **queue** item, as above.

Moving projects: use the Agents board API (GET http://127.0.0.1:8768/api/board for the version, then POST /api/move with folder, to (claude, codex, hermes or ready), index and version). It keeps the file's format intact. If the board isn't reachable, edit the line by hand without touching anything else. Commit only that file in the vault: `git -C F:\Vaults\LLMWiki commit -m "<msg>" -- "Nightly Runs/Project Priorities.md"`, then `git push`. The vault holds other sessions' uncommitted work, so never `git add -A`, stash or reset there.

In every project, stage only the paths you changed, `git pull --rebase`, then push. Never force-push. Never touch real personal data, live accounts or another project's files.

Finish by writing `F:\Vaults\LLMWiki\Nightly Runs\Prep Report.md` (overwrite it): one line per item saying what you did and the result (verify exit code, commit hash, lane), plus anything left for the owner in the multiple-choice question format from the shared rules. Do not commit the Prep Report; the runner reads it.

Items:
