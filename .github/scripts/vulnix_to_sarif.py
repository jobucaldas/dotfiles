#!/usr/bin/env python3
"""Convert `vulnix --json` output to SARIF for GitHub code scanning.

Usage: vulnix_to_sarif.py <vulnix.json> <out.sarif> [--all]

By default only `error` findings (CVSS >= 7.0 or CISA known-exploited)
are emitted. Pass --all to include warning/note findings as well.
Filtering here keeps code-scanning alerts actionable: vulnix matches on
pname only, so warnings/notes are overwhelmingly false positives
(Haskell/Python build inputs vs npm/Ruby/appliance CVEs — see
flake/vulnix-whitelist.toml).

Results are attached to flake/flake.lock, since bumping flake inputs is how
vulnerable packages get fixed in this repo.
"""

import argparse
import json


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("vulnix_json")
    p.add_argument("out_sarif")
    p.add_argument(
        "--all",
        action="store_true",
        help="include warning/note findings (default: error only)",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()
    with open(args.vulnix_json) as f:
        findings = json.load(f)

    rules = {}
    results = []
    skipped = 0
    for item in findings:
        pkg = item.get("pname") or item.get("name", "unknown")
        ver = item.get("version", "")
        scores = item.get("cvssv3_basescore", {}) or {}
        descs = item.get("description", {}) or {}
        exploited = set(item.get("known_exploited", []) or [])
        for cve in item.get("affected_by", []) or []:
            score = float(scores.get(cve, 0.0) or 0.0)
            is_exploited = cve in exploited
            if is_exploited or score >= 7.0:
                level = "error"
            elif score >= 4.0:
                level = "warning"
            else:
                level = "note"
            if level != "error" and not args.all:
                skipped += 1
                continue
            if cve not in rules or score > float(
                rules[cve]["properties"]["security-severity"]
            ):
                tags = ["vulnerability"]
                if is_exploited:
                    tags.append("known-exploited")
                rules[cve] = {
                    "id": cve,
                    "shortDescription": {"text": cve},
                    "fullDescription": {"text": descs.get(cve, cve)},
                    "helpUri": f"https://nvd.nist.gov/vuln/detail/{cve}",
                    "properties": {
                        "security-severity": f"{score:.1f}",
                        "tags": tags,
                    },
                }
            msg = (
                f"{pkg} {ver} is affected by {cve}: "
                f"{descs.get(cve, 'see NVD entry')}"
            )
            if is_exploited:
                msg += " [CISA known-exploited]"
            results.append(
                {
                    "ruleId": cve,
                    "level": level,
                    "message": {"text": msg},
                    "locations": [
                        {
                            "physicalLocation": {
                                "artifactLocation": {"uri": "flake/flake.lock"},
                                "region": {"startLine": 1},
                            }
                        }
                    ],
                }
            )

    sarif = {
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [
            {
                "tool": {
                    "driver": {
                        "name": "vulnix",
                        "informationUri": "https://github.com/nix-community/vulnix",
                        "rules": list(rules.values()),
                    }
                },
                "results": results,
            }
        ],
    }
    with open(args.out_sarif, "w") as f:
        json.dump(sarif, f)
    print(f"converted {len(results)} findings, {len(rules)} rules (skipped {skipped} non-error)")


if __name__ == "__main__":
    main()
