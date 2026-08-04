# Gmail Filters

Creates Gmail filters via the Gmail API, driven by a declarative
`filters.yaml`, so mail from specific senders/subjects gets labeled and
removed from the Inbox automatically — the closest equivalent Gmail has
to "forwarding into a folder."

## How Gmail filing actually works

Gmail has no real folders, only **labels**. A message can carry several
labels at once, and whether it shows in your Inbox is just controlled by
whether it has the special `INBOX` label. So "file this into a folder"
becomes: apply a label, then remove the `INBOX` label.

**This does not cause mail to auto-delete.** Archived/labeled mail is kept
indefinitely in All Mail, same as anything else — retention is unlimited
until you delete something yourself. The only things Gmail auto-purges
are Trash and Spam, both after 30 days, and this script never touches
either.

## One-time setup

1. Go to https://console.cloud.google.com/ and create (or select) a project.
2. Enable the **Gmail API** for that project (APIs & Services > Library).
3. Configure the **OAuth consent screen**: type "External", add your own
   Gmail address as a test user (this keeps it in unpublished/testing
   status, which is fine for personal use — no Google review needed).
4. Create credentials: **OAuth client ID**, application type **Desktop app**.
5. Download the resulting JSON and save it as `credentials.json` in this
   folder. It is gitignored — never commit it.

Then:

```bash
cd components-personal/20-gmail
bash install.sh
```

This creates a `.venv` with the required Python packages.

## Usage

Edit `filters.yaml` with your real rules (see the comments in that file
for the format), then:

```bash
.venv/bin/python apply_filters.py --dry-run   # preview, changes nothing
.venv/bin/python apply_filters.py             # create the filters
```

The first run opens a browser for the Google OAuth consent flow and
caches the result in `token.json` (also gitignored). Re-running the
script is safe — it skips any filter that already exists and never
duplicates or deletes filters or labels.

## Files

- `filters.yaml` - your filter rules (label, archive?, match criteria)
- `apply_filters.py` - reads `filters.yaml`, creates missing Gmail labels
  and filters via the Gmail API
- `install.sh` - sets up the `.venv` Python environment
- `credentials.json` / `token.json` - OAuth secrets, gitignored, not
  present until you complete setup

## Notes

- True email forwarding to a different address is a separate Gmail
  feature that requires verifying the forwarding address first (Settings
  > Forwarding and POP/IMAP). Not covered here since it wasn't needed for
  labeling into "folders" — ask if you also want that wired into
  `apply_filters.py`.
- Nest labels with `/` in the name (e.g. `Finance/Receipts`) — Gmail
  treats that as a sub-label under `Finance` automatically.
