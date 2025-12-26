#!/usr/bin/env python3

import yaml
import json
from pathlib import Path

PROJECT_YML = Path("project.yml")
OUTPUT = Path("ci/dependencies.json")

with PROJECT_YML.open() as f:
    spec = yaml.safe_load(f)

targets = spec.get("targets", {})

graph = {}

for target, config in targets.items():
    deps = []
    for dep in config.get("dependencies", []):
        if isinstance(dep, dict) and "target" in dep:
            deps.append(dep["target"])
    graph[target] = sorted(deps)

OUTPUT.parent.mkdir(parents=True, exist_ok=True)
OUTPUT.write_text(json.dumps(graph, indent=2))

print("Generated dependency graph:")
print(json.dumps(graph, indent=2))
