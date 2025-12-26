#!/usr/bin/env python3

import json
import sys
import subprocess
import yaml
from pathlib import Path
from fnmatch import fnmatch

BASE_REF = sys.argv[1]  # e.g. origin/main

def git_diff_files(base_ref):
    result = subprocess.check_output(
        ["git", "diff", "--name-only", f"{base_ref}...HEAD"],
        text=True
    )
    return [line.strip() for line in result.splitlines() if line.strip()]

def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)

def load_json(path):
    with open(path) as f:
        return json.load(f)

def match_targets(files, target_paths):
    modified = set()
    for target, patterns in target_paths.items():
        for file in files:
            for pattern in patterns:
                if fnmatch(file, pattern):
                    modified.add(target)
    return sorted(modified)

def build_reverse_graph(graph):
    reverse = {t: [] for t in graph}
    for target, deps in graph.items():
        for dep in deps:
            reverse[dep].append(target)
    return reverse

def get_all_dependents(target, reverse_graph):
    visited = set()
    stack = [target]

    while stack:
        current = stack.pop()
        for dep in reverse_graph.get(current, []):
            if dep not in visited:
                visited.add(dep)
                stack.append(dep)
    return visited

def main():
    changed_files = git_diff_files(BASE_REF)

    target_paths = load_yaml("ci/target_paths.yml")
    dependency_graph = load_json("ci/dependencies.json")

    modified_targets = match_targets(changed_files, target_paths)

    reverse_graph = build_reverse_graph(dependency_graph)

    resolved_targets = set()

    for target in modified_targets:
        dependents = get_all_dependents(target, reverse_graph)
        resolved_targets.add(target)
        resolved_targets.update(dependents)

    resolved_targets = sorted(resolved_targets)

    print("=== Dependency-Aware Test Resolution ===\n")

    print("Modified targets:")
    for t in modified_targets:
        print(f"- {t}")

    print("\nResolved dependent targets:")
    for t in resolved_targets:
        if t not in modified_targets:
            print(f"- {t}")

    test_schemes = [f"{t}Tests" for t in resolved_targets]

    print("\nFinal test schemes:")
    for s in test_schemes:
        print(f"- {s}")

    # GitHub Actions output
    print(f"\n::set-output name=test_schemes::{','.join(test_schemes)}")

if __name__ == "__main__":
    main()
