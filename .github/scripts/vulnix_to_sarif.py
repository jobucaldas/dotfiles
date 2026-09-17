#!/usr/bin/env python3
"""Convert `vulnix --json` output to SARIF for GitHub code scanning.

Usage: vulnix_to_sarif.py <vulnix.json> <out.sarif>

Results are attached to flake/flake.lock, since bumping flake inputs is how
vulnerable packages get fixed in this repo.
"""

import json
import sys


def main() -> None:
    with open(sys.argv[1]) as f:
        findings = json.load(f)

    rules = {}
    results = []
    for item in findings:
        pkg = item.get("pname") or item.get("name", "unknown")
        ver = item.get("version", "")
        scores = item.get("cvssv3_basescore", {}) or {}
        descs = item.get("description", {}) or {}
        exploited = set(item.get("known_exploited", []) or [])
        for cve in item.get("affected_by", []) or []:
            score = float(scores.get(cve, 0.0) or 0.0)
            if cve in exploited or score >= 7.0:
                level = "error"
            elif score >= 4.0:
                level = "warning"
            else:
                level = "note"
            if cve not in rules or score > float(
                rules[cve]["properties"]["security-severity"]
            ):
                rules[cve] = {
                    "id": cve,
                    "shortDescription": {"text": cve},
                    "fullDescription": {"text": descs.get(cve, cve)},
                    "helpUri": f"https://nvd.nist.gov/vuln/detail/{cve}",
                    "properties": {
                        "security-severity": f"{score:.1f}",
                        "tags": ["vulnerability"],
                    },
                }
            results.append(
                {
                    "ruleId": cve,
                    "level": level,
                    "message": {
                        "text": f"{pkg} {ver} is affected by {cve}: "
                        f"{descs.get(cve, 'see NVD entry')}"
                    },
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
    with open(sys.argv[2], "w") as f:
        json.dump(sarif, f)
    print(f"converted {len(results)} findings, {len(rules)} rules")


if __name__ == "__main__":
    main()
