# Working with a person: the interview, any project, options, build

Use whenever someone is in the chat: redesigning a screen, restyling a whole site, fixing an app's UI, reworking an open-source project to taste, or a personal website. The person shouldn't need design vocabulary or have to score anything. You do the looking and judging; they react to what they see and choose.

## How to ask

- Use your harness's question tool when it has one (Claude Code: `AskUserQuestion`; Hermes: `clarify`); otherwise ask in chat with numbered options.
- One to three questions per message. Each is multiple choice, your recommended answer first and marked, plus a way to answer in their own words.
- Plain words. Not "hierarchy" and "density"; say "the important number is hard to find" and "everything is squeezed together".
- Find out what you can yourself first: read the repo, run it, look at it. Ask only what only the person knows: what they want, what bothers them, what they like.
- Show, don't score. Put screenshots side by side and say in one sentence what each does better. Keep checklists and scores for your own judgement unless they ask.

## The flow

Skip any question whose answer you already have. Never build before step 8.

0. **Pictures first.** If they gave images, screenshots, a wireframe or a link, read them now and ask the one question in [replicate.md](replicate.md#first-which-kind-of-like-this): exactly like this, this layout in my app's look, inspiration only, or a mix. "Exactly" or "build it like this wireframe" skips the options round: go to Replicate, show the side-by-side comparison, then step 8.
1. **Look first.** Get the project on screen (below) and screenshot the main screens at desktop (1440) and phone (390) width with real content. Read the code enough to know the stack and what the screens show.
2. **Ask what we're doing.**
   - What to work on: the screens you found, "the whole site", or "one part I'll point at".
   - What they want: *Not sure: show me what's wrong first* (recommended when they're unsure) · Fix what's broken, keep the look · Freshen the look, same idea · A brand-new look.
3. **Show what's wrong.** Run the critique ([critique.md](critique.md)) yourself, then show the 3–5 biggest problems in plain words, each with the screenshot area and what you'd do instead. Ask: *Which of these bother you most?* (multi-select, plus "something else").
4. **Confirm the domain.** Offer your read of what the app is for as a guess to confirm: "Looks like a subscriptions tracker you check about once a month, mostly to cut costs. Right?" Their answer fills the brief's Domain line ([domains.md](domains.md)).
5. **Taste.** Offer 4–6 directions as one-line pitches, each from a different family ([directions.md](directions.md)) and each serving the domain: "a bank statement that builds to this month's total", "a renewals calendar like an airline departure board". Ask which pull them (multi-select), whether they have a reference they love (a link, screenshot or sketch; handled as [replicate.md](replicate.md) describes), and anything they never want (dark mode, serif type, a paper look, animation).
6. **Practical limits.** Light, dark or both; whether phone matters; anything that can't change (the framework, a theme, the content, a hosting build like GitHub Pages/Jekyll).
7. **Options.** Build 3 mockups from their picks (or 2 plus your own wildcard), each with a full brief, as self-contained HTML with the real content in `design/variants/<screen>/<YYYY-MM-DD>/<a|b|c>.html`, plus screenshots at 1440 and 390. Show them side by side with one line each on what it's good at, and your recommendation with one reason. Ask: *Which feels closest?* A · B · C · Mix parts of them · None, try again. For "mix", ask which part from which ("layout of B, colours of A"), build option D, and ask again.
8. **Where it goes.** Before touching the real code, ask: *New branch* (recommended) · Current branch · Just keep the mockups for now. Then build (SKILL.md, Build mode), screenshot, critique, fix every Blocker, and show before and after.
9. **Ship.** Ask before anything that publishes: pushing to a GitHub Pages branch makes the site live; pushing to someone else's repo or opening a pull request is visible to others.

Unattended (no one in the chat): don't ask. Take each recommended answer, note the choices where the work is reported, and keep going.

## Getting any project on screen

Find the run command in this order: the project's own preview or dev script, its README, its package files.

- **Node / Vite / Next / Astro:** `package.json` scripts (`dev`, `start`, `preview`); install with the lockfile's tool (`npm ci`, `pnpm i`, `yarn`).
- **Python web apps:** the README's command; else look for `manage.py runserver`, `uvicorn`, `flask run`, `streamlit run`.
- **Static HTML:** open the file directly, or serve the folder: `python -m http.server <free port>`.
- **GitHub Pages:** Jekyll (`_config.yml`): `bundle exec jekyll serve` if Ruby is set up; Hugo (`hugo.toml`/`config.toml`): `hugo server`; plain HTML: as above. If it won't build locally, screenshot the live site (`https://<user>.github.io/<repo>/`) for the "before", mock up options as static HTML, then edit the source.
- **Can't run it at all:** screenshot the deployed URL or ask for screenshots, and still make the options as static HTML.
- **Screenshots:** `npx -y playwright@1.64.1 screenshot --full-page --viewport-size "1440, 900" <url> before-1440.png` (and `"390, 844"`), or the harness's built-in browser. Use a free port and stop any server you started.

## Someone else's repo (open source)

- Work on a branch (`ui-craft/<YYYY-MM-DD>`); never push to their remote or open a pull request without asking.
- Read CONTRIBUTING and the existing styles first. If the project has its own design system or theme, the default is to fit it (Fit mode) and fix problems; a new look only when the person asks for one.
- Keep your design notes (briefs, mockups, screenshots) in `design/` on the branch, or outside the repo if the person prefers; don't add a DESIGN.md to their repo unless asked.
- Respect the licence when borrowing components or assets.
