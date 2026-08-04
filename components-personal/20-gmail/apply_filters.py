#!/usr/bin/env python3
"""Create/update Gmail filters from filters.yaml via the Gmail API.

Idempotent: re-running only creates filters that don't already exist
(matched on label + criteria), it never duplicates or deletes anything.
"""
import argparse
import os
import sys

import yaml
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CREDENTIALS_PATH = os.path.join(SCRIPT_DIR, "credentials.json")
TOKEN_PATH = os.path.join(SCRIPT_DIR, "token.json")
FILTERS_PATH = os.path.join(SCRIPT_DIR, "filters.yaml")

SCOPES = [
    "https://www.googleapis.com/auth/gmail.labels",
    "https://www.googleapis.com/auth/gmail.settings.basic",
]

CRITERIA_FIELDS = ["from", "to", "subject", "query", "negatedQuery", "hasAttachment"]


def get_service():
    if not os.path.exists(CREDENTIALS_PATH):
        sys.exit(
            f"Missing {CREDENTIALS_PATH}\n"
            "Download an OAuth 'Desktop app' client secret from the Google Cloud "
            "Console (see README.md) and save it as credentials.json here."
        )

    creds = None
    if os.path.exists(TOKEN_PATH):
        creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
            creds = flow.run_local_server(port=0)
        with open(TOKEN_PATH, "w") as f:
            f.write(creds.to_json())

    return build("gmail", "v1", credentials=creds)


def load_filters():
    if not os.path.exists(FILTERS_PATH):
        sys.exit(f"Missing {FILTERS_PATH}")
    with open(FILTERS_PATH) as f:
        data = yaml.safe_load(f) or {}
    return data.get("filters", [])


def get_or_create_label(service, name, dry_run):
    existing = service.users().labels().list(userId="me").execute().get("labels", [])
    for label in existing:
        if label["name"] == name:
            return label["id"]

    if dry_run:
        print(f"  [dry-run] would create label: {name}")
        return None

    created = (
        service.users()
        .labels()
        .create(
            userId="me",
            body={
                "name": name,
                "labelListVisibility": "labelShow",
                "messageListVisibility": "show",
            },
        )
        .execute()
    )
    print(f"  created label: {name}")
    return created["id"]


def build_criteria(rule_criteria):
    criteria = {}
    for key in CRITERIA_FIELDS:
        if key in rule_criteria:
            criteria[key] = rule_criteria[key]
    if not criteria:
        raise ValueError(f"filter rule has no usable criteria: {rule_criteria}")
    return criteria


def filter_already_exists(existing_filters, criteria, add_label_ids, remove_label_ids):
    for f in existing_filters:
        if f.get("criteria") != criteria:
            continue
        action = f.get("action", {})
        if set(action.get("addLabelIds", [])) != set(add_label_ids):
            continue
        if set(action.get("removeLabelIds", [])) != set(remove_label_ids):
            continue
        return True
    return False


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run", action="store_true", help="show what would change, apply nothing"
    )
    args = parser.parse_args()

    rules = load_filters()
    if not rules:
        print("No filters defined in filters.yaml, nothing to do.")
        return

    service = get_service()
    existing_filters = (
        service.users().settings().filters().list(userId="me").execute().get("filter", [])
    )

    for rule in rules:
        label_name = rule["label"]
        archive = rule.get("archive", True)
        criteria = build_criteria(rule.get("criteria", {}))

        print(f"Rule: {label_name} <- {criteria}")

        label_id = get_or_create_label(service, label_name, args.dry_run)
        add_label_ids = [label_id] if label_id else ["<pending>"]
        remove_label_ids = ["INBOX"] if archive else []

        if filter_already_exists(existing_filters, criteria, add_label_ids, remove_label_ids):
            print("  already exists, skipping")
            continue

        if args.dry_run:
            print(f"  [dry-run] would create filter: {criteria} -> label={label_name} archive={archive}")
            continue

        service.users().settings().filters().create(
            userId="me",
            body={
                "criteria": criteria,
                "action": {"addLabelIds": add_label_ids, "removeLabelIds": remove_label_ids},
            },
        ).execute()
        print("  created filter")


if __name__ == "__main__":
    main()
