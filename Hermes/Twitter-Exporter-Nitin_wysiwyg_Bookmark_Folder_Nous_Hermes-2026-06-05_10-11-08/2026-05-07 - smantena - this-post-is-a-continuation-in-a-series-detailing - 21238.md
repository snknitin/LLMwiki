---
title: "This post is a continuation in a series detailing how to build the best personal AI assistant, using..."
author: "Sudhir Mantena"
username: "@smantena"
date: "2026-05-07"
tweet_url: "https://x.com/smantena/status/2052483819270521238"
tweet_type: "original"
likes: 293
retweets: 36
replies: 4
bookmarks: 723
views: 37630
has_media: false
extraction_quality: full
article_id: "2052466094016008192"
tags: ["twitter-bookmark", "agents"]
---

# This post is a continuation in a series detailing how to build the best personal AI assistant, using...

> **Source:** [@smantena](https://x.com/smantena) · 2026-05-07 · 👍 293 · 💬 4 · 🔖 723 · 👁 37630

> 🔗 [View tweet on X](https://x.com/smantena/status/2052483819270521238)

## Article Content

This post is a continuation in a series detailing how to build the best personal AI assistant, using Hermes, GBrain and now Notion. 
First [install & setup Hermes](https://x.com/smantena/status/2048482968369586429)

 and then [install & configure GBrain](https://x.com/smantena/status/2051771339187613738?s=20)

.

### Usecase: Why do we need Hermes + Notion + Gbrain?

Since the demise of Evernote, I moved my entire digital work & personal life to Notion, including all projects & tasks. My biggest gripe with Notion was that maintaining it was a manual chore, with zero improvement in knowledge & intelligence over time.

As you use Hermes for work & automation, Gbrain learns by extracting, dreaming, synthesizing key learnings and connects the dots automatically.

Once I decided to make Hermes as my Personal AI Assistant, I first connected it to Gbrain to enable automatic learning knowledge graph. What was missing is context of all my projects & tasks which was in Notion. Managing two disconnected systems wasn't an option. But moving away from Notion entirely isn't trivial either.

So based on Garry Tan's Gbrain recipes, I decided to build a custom Hermes + Notion recipe. Now Hermes knows which projects I am working on. I can whatsapp or slack to add, update or complete tasks in natural language just like how I would talk to a person. Hermes interprets it and makes necessary changes to projects & tasks in Notion.

But the kicker is, Gbrain automatically synthesizes key learnings necessary to see patterns & connect the dots across what I read on the internet with the projects & tasks that I am working on a daily basis.

You can download the source-code from Github. Link in comments below (avoiding algorithm penalty).

### Part 1: Connect Hermes to Notion

****Step 1: Create a Notion Integration****

1. Go to [notion.so/my-integrations](https://notion.so/my-integrations)

 → ****New integration****
2. Name it (e.g. "Hermes Agent"), select your workspace
3. Copy the ****Internal Integration Token**** — this is your NOTION_TOKEN
4. Open your tasks database in Notion → ... (top right) → ****Connections**** → add your integration
5. Do the same for every ****parent page**** above your database — this tripped me up with a 400 error initially

****Step 2: Get Your IDs****

****Database ID**** — from your database URL: [https://notion.so/yourworkspace/](https://notion.so/yourworkspace/)

<DATABASE_ID>?v=.... The 32-character string before ?v= is your database ID.

****Project page IDs**** — open each project page in the browser and copy the ID from the URL the same way. You need one per project.

****Verify what your integration can actually see**** — I had the wrong database ID initially. This confirms it:

```python
python3 - <<'EOF'
import requests, json
NOTION_TOKEN = "your_token_here"
r = requests.post("https://api.notion.com/v1/search",
    headers={"Authorization": f"Bearer {NOTION_TOKEN}",
             "Content-Type": "application/json",
             "Notion-Version": "2022-06-28"},
    json={})
print(json.dumps(r.json(), indent=2)[:3000])
EOF
```

This returns every page and database your integration can access — with the correct IDs and exact column names. Note them down. My title column was Task name, not Name — that mismatch would have caused silent failures.

****Step 3: Install notion-client****

```bash
pip install notion-client --break-system-packages
```

****Gotcha:**** notion-client v3 dropped databases.query() entirely. Rather than fight the SDK, skip it and call the Notion REST API directly with requests. It's simpler and immune to SDK version changes. The scripts below use this approach.

****Step 4: Create notion_tasks.py****

Install at: ~/.hermes/skills/productivity/notion-tasks/scripts/notion_tasks.py

```python
import sys, os, requests

NOTION_TOKEN = "your_notion_token_here"
DATABASE_ID  = "your_database_id_here"

HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28"
}
BASE = "https://api.notion.com/v1"

# Map keyword → Notion project page ID
PROJECTS = {
    "project 1":           "project-1-id",
    "project 2":          "project-2-id",
    "project 3":          "project-3-id",
    "project 4":          "project-4-id",
    "project 5":          "project-5-id",
}

def resolve_project(keyword):
    if not keyword:
        return None
    return PROJECTS.get(keyword.lower().strip())

def query_db(filter_obj=None, sorts=None):
    payload = {}
    if filter_obj: payload["filter"] = filter_obj
    if sorts: payload["sorts"] = sorts
    r = requests.post(f"{BASE}/databases/{DATABASE_ID}/query",
                      headers=HEADERS, json=payload)
    r.raise_for_status()
    return r.json().get("results", [])

def find_task_by_name(name):
    return query_db(filter_obj={
        "property": "Task name",
        "title": {"contains": name}
    })

def format_task(page):
    props  = page["properties"]
    name   = props.get("Task name", {}).get("title", [{}])
    name   = name[0].get("text", {}).get("content", "Untitled") if name else "Untitled"
    status = props.get("Status", {}).get("status", {})
    status = status.get("name", "—") if status else "—"
    due    = props.get("Due", {}).get("date") or {}
    due    = due.get("start", "—")
    return f"• {name} | {status} | Due: {due}"

def create_page(properties):
    r = requests.post(f"{BASE}/pages", headers=HEADERS,
                      json={"parent": {"database_id": DATABASE_ID},
                            "properties": properties})
    r.raise_for_status()
    return r.json()

def update_page(page_id, properties=None, archived=False):
    payload = {"archived": archived}
    if properties: payload["properties"] = properties
    r = requests.patch(f"{BASE}/pages/{page_id}", headers=HEADERS, json=payload)
    r.raise_for_status()
    return r.json()

def cmd_create(args):
    if not args:
        print("❌ Usage: create <task name> [status] [due YYYY-MM-DD] [project]")
        return
    name    = args[0]
    status  = args[1] if len(args) > 1 else "In progress"
    due     = args[2] if len(args) > 2 else None
    project = args[3] if len(args) > 3 else None
    properties = {
        "Task name": {"title": [{"text": {"content": name}}]},
        "Status":    {"status": {"name": status}},
    }
    if due:
        properties["Due"] = {"date": {"start": due}}
    project_id = resolve_project(project)
    if project_id:
        properties["Project"] = {"relation": [{"id": project_id}]}
    page = create_page(properties)
    print(f"✅ Created: {name} | {status} | Project: {project or 'None'} (ID: {page['id'][:8]})")

def cmd_list(args):
    filter_obj = None
    if args:
        filter_obj = {"property": "Status", "status": {"equals": " ".join(args)}}
    pages = query_db(filter_obj=filter_obj,
                     sorts=[{"property": "Due", "direction": "ascending"}])
    if not pages:
        print("No tasks found.")
        return
    for p in pages:
        print(format_task(p))

def cmd_update(args):
    if len(args) < 3:
        print("❌ Usage: update <task name> status|due <value>")
        return
    field, value, name = args[-2].lower(), args[-1], " ".join(args[:-2])
    pages = find_task_by_name(name)
    if not pages:
        print(f"❌ No task found: {name}")
        return
    if field == "status":
        update_page(pages[0]["id"], {"Status": {"status": {"name": value}}})
        print(f"✅ Updated '{name}' → Status: {value}")
    elif field == "due":
        update_page(pages[0]["id"], {"Due": {"date": {"start": value}}})
        print(f"✅ Updated '{name}' → Due: {value}")

def cmd_done(args):
    name = " ".join(args)
    pages = find_task_by_name(name)
    if not pages:
        print(f"❌ No task found: {name}")
        return
    update_page(pages[0]["id"], {"Status": {"status": {"name": "Done"}}})
    print(f"✅ Marked done: {name}")

def cmd_delete(args):
    name = " ".join(args)
    pages = find_task_by_name(name)
    if not pages:
        print(f"❌ No task found: {name}")
        return
    update_page(pages[0]["id"], archived=True)
    print(f"🗑️ Archived: {name}")

COMMANDS = {"create": cmd_create, "list": cmd_list,
            "update": cmd_update, "done": cmd_done, "delete": cmd_delete}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Commands: create | list | update | done | delete")
        sys.exit(1)
    command = sys.argv[1].lower()
    if command in COMMANDS:
        COMMANDS[command](sys.argv[2:])
    else:
        print(f"❌ Unknown command: {command}")
```

****Test it directly before touching Hermes:****

```bash
python3 ~/.hermes/skills/productivity/notion-tasks/scripts/notion_tasks.py list
python3 ~/.hermes/skills/productivity/notion-tasks/scripts/notion_tasks.py create "Test task" "In progress" 2026-05-10 Loremipsum
python3 ~/.hermes/skills/productivity/notion-tasks/scripts/notion_tasks.py done "Test task"
```

If these work from the shell, Hermes will run them identically.

****Step 5: Configure Hermes****

Add this block to ~/.hermes/config.yaml under system_prompt:

```python
### NOTION TASKS
Script: python3 /home/ubuntu/.hermes/skills/productivity/notion-tasks/scripts/notion_tasks.py

ANY message about tasks, todos, action items, follow-ups, reminders MUST call
this script via execute_code. No internal task lists. No session storage.
NEVER simulate output. NEVER confirm success without ✅ from the script.

Intent → command:
- Something to do / follow up / remember → create "TASK NAME" "In progress" YYYY-MM-DD PROJECT
- What's pending / what's on the list    → list
- Something done / finished / sorted     → done "TASK NAME"
- Change deadline or status              → update "TASK NAME" status|due VALUE
- Remove / cancel / drop                 → delete "TASK NAME"

PROJECT MAPPING — infer from context:
- keyword 1 / keyword 11       → Project 1
- keyword 2 / keyword 22     → Project 2
- keyword 3 / keyword 33     → Project 3
- keyword 4 / keyword 44    → Project 4
- No clear match                       → omit project argument

Convert relative dates ("tomorrow", "next Friday") to YYYY-MM-DD.
Show script stdout exactly as returned.
```

****Update channel_prompts.default:****

```yaml
channel_prompts:
    default: |
      Follow Project 1, EMAIL, STOCK, and NOTION TASKS protocols from system instructions. For NOTION TASKS: Hermes has NO internal task list. The ONLY way to create, update, or list tasks is by running notion_tasks.py via execute_code. If you did not run the script, the task does not exist. Infer intent from natural language — do not wait for explicit keywords.
```

****Critical:**** The skill must be registered in both system_prompt AND channel_prompts.default. Missing either causes Hermes to apply the skill inconsistently.

****Restart Hermes****

### Part 2: Connect Notion to GBrain

The idea: every Sunday, fetch last week's Notion tasks, distil them with OpenAI, write a summary knowledge page to GBrain per project. Your agent accumulates context automatically.

GBrain already uses OpenAI for embeddings — so we reuse its existing API key. No new credentials needed.

****Step 1: Find the right Python****

GBrain's openai package is Node.js, not Python. Hermes's venv already has the Python openai package:

```bash
find /home/ubuntu/.hermes -name "python3" -type f
# typically: /home/ubuntu/.hermes/hermes-agent/venv/bin/python3
```

Use this Python for the enrichment script — not system Python.

****Step 2: Find the GBrain binary****

```bash
which gbrain
# typically: /home/ubuntu/.bun/bin/gbrain
```

Check the available commands — GBrain v0.22+ uses put <slug> not page create:

```bash
gbrain --help
```

****Step 3: Create gbrain_enrichment.py****

Install at: ~/.hermes/skills/productivity/notion-tasks/scripts/gbrain_enrichment.py

```python
import sys, os, requests, subprocess, tempfile
from datetime import date, timedelta
from openai import OpenAI

NOTION_TOKEN = "your_notion_token_here"
DATABASE_ID  = "your_database_id_here"
GBRAIN       = "/home/ubuntu/.bun/bin/gbrain"  # from: which gbrain

NOTION_HEADERS = {
    "Authorization": f"Bearer {NOTION_TOKEN}",
    "Content-Type": "application/json",
    "Notion-Version": "2022-06-28"
}

# Reverse map: Notion project page ID → project name
PROJECT_IDS = {
    "project_1_id":          "Project 1",
    "project_2_id":          "Project 2",
    "project_3_id":          "Project 3",
    "project_4_id":          "Project 4",
}

def get_openai_client():
    result = subprocess.run(
        [GBRAIN, "config", "get", "openai_api_key"],
        capture_output=True, text=True
    )
    if result.returncode != 0 or not result.stdout.strip():
        print("❌ Could not retrieve OpenAI key from GBrain config")
        sys.exit(1)
    return OpenAI(api_key=result.stdout.strip())

def fetch_recent_tasks():
    since = (date.today() - timedelta(days=7)).isoformat()
    r = requests.post(
        f"https://api.notion.com/v1/databases/{DATABASE_ID}/query",
        headers=NOTION_HEADERS,
        json={"filter": {"timestamp": "last_edited_time",
                         "last_edited_time": {"on_or_after": since}}}
    )
    r.raise_for_status()
    return r.json().get("results", [])

def extract_task_info(page):
    props  = page["properties"]
    name   = props.get("Task name", {}).get("title", [{}])
    name   = name[0].get("text", {}).get("content", "Untitled") if name else "Untitled"
    status = props.get("Status", {}).get("status", {})
    status = status.get("name", "—") if status else "—"
    due    = props.get("Due", {}).get("date") or {}
    due    = due.get("start", "—")
    project_ids = [r["id"].replace("-", "")
                   for r in props.get("Project", {}).get("relation", [])]
    return {"name": name, "status": status, "due": due, "project_ids": project_ids}

def group_by_project(tasks):
    grouped = {name: [] for name in PROJECT_IDS.values()}
    grouped["Unassigned"] = []
    for task in tasks:
        matched = False
        for pid in task["project_ids"]:
            project_name = PROJECT_IDS.get(pid)
            if project_name:
                grouped[project_name].append(task)
                matched = True
        if not matched:
            grouped["Unassigned"].append(task)
    return {k: v for k, v in grouped.items() if v}

def distil(client, project_name, tasks):
    task_lines = "\n".join(
        f"- {t['name']} | {t['status']} | due {t['due']}" for t in tasks
    )
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        max_tokens=500,
        messages=[
            {"role": "system", "content": "You update knowledge base pages. Be concise and factual."},
            {"role": "user", "content": f"""Project: {project_name}
Tasks from this week:
{task_lines}

Write 4-8 bullet points covering: what's active, what's done, patterns, key people.
Plain bullets with •. Present tense for active, past tense for done."""}
        ]
    )
    return response.choices[0].message.content.strip()

def update_gbrain(project_name, summary):
    week_label = date.today().strftime("Week of %d %b %Y")
    slug    = f"{project_name.lower().replace(' ', '-')}-active-context"
    title   = f"{project_name} — Active Context"
    content = f"# {title}\n_{week_label}_\n\n{summary}"

    with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
        f.write(content)
        tmpfile = f.name

    try:
        with open(tmpfile, 'r') as f:
            result = subprocess.run([GBRAIN, "put", slug],
                                    stdin=f, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ GBrain updated: {slug}")
        else:
            print(f"❌ GBrain failed for {project_name}: {result.stderr.strip()}")
    finally:
        os.unlink(tmpfile)

def run():
    print(f"🔄 GBrain enrichment — {date.today()}")
    client = get_openai_client()
    pages  = fetch_recent_tasks()
    if not pages:
        print("No tasks this week — nothing to enrich.")
        return
    tasks  = [extract_task_info(p) for p in pages]
    groups = group_by_project(tasks)
    for project_name, project_tasks in groups.items():
        if project_name == "Unassigned":
            print(f"⚠️  Skipping {len(project_tasks)} unassigned tasks")
            continue
        print(f"📋 Processing {project_name} ({len(project_tasks)} tasks)...")
        summary = distil(client, project_name, project_tasks)
        update_gbrain(project_name, summary)
    print("✅ Enrichment complete.")

if __name__ == "__main__":
    run()
```

****Step 4: Test manually****

```bash
mkdir -p /home/ubuntu/logs
/home/ubuntu/.hermes/hermes-agent/venv/bin/python3 \
  ~/.hermes/skills/productivity/notion-tasks/scripts/gbrain_enrichment.py
```

****Verify in GBrain:****

```bash
gbrain list
gbrain get farm-active-context
```

****Step 5: Schedule weekly cron****

```bash
crontab -e
```

Add (every Sunday at 8pm):

```bash
0 20 * * 0 /home/ubuntu/.hermes/hermes-agent/venv/bin/python3 \
  /home/ubuntu/.hermes/skills/productivity/notion-tasks/scripts/gbrain_enrichment.py \
  >> /home/ubuntu/logs/gbrain_enrichment.log 2>&1
```

### Github Repo

Please find link in comments below

Thanks to [@Teknium](https://x.com/@Teknium)

 & rest of the [@NousResearch](https://x.com/@NousResearch)

 team for building an amazing product and [@garrytan](https://x.com/@garrytan)

 for open-sourcing super smart Gbrain.

That's all folks!

If you have suggestions to improve this further, please comment. Would love to learn. Please Like, Repost so other first timers can also learn.

Please Follow, to learn with me, how to ****Build the World's Best Personal AI Assistant**** for yourself.

> 📄 Original article URL: https://x.com/i/article/2052466094016008192

