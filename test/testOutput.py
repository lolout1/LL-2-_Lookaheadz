#!/usr/bin/env python3
"""
Simple test runner for the mC scanner.
Runs each .mC test file through the scanner and diffs against the .exp file.
"""

import subprocess
import sys
import os
import argparse

def run_tests(program, testpath, testext, exppath, expext):
    """Run all test cases and report pass/fail."""
    passed = 0
    failed = 0
    errors = []

    # find all test files
    test_files = sorted([
        f for f in os.listdir(testpath)
        if f.endswith(testext)
    ])

    if not test_files:
        print("No test files found in", testpath)
        return 1

    for test_file in test_files:
        name = test_file.replace(testext, "")
        input_path = os.path.join(testpath, test_file)
        exp_path = os.path.join(exppath, name + expext)

        if not os.path.exists(exp_path):
            print("  SKIP  {} (no expected output)".format(name))
            continue

        # run the scanner
        try:
            result = subprocess.run(
                [program, input_path],
                capture_output=True, text=True, timeout=10
            )
            actual = result.stdout
        except subprocess.TimeoutExpired:
            print("  FAIL  {} (timeout)".format(name))
            failed += 1
            errors.append(name)
            continue

        # read expected
        with open(exp_path, 'r') as f:
            expected = f.read()

        if actual == expected:
            print("  PASS  {}".format(name))
            passed += 1
        else:
            print("  FAIL  {}".format(name))
            failed += 1
            errors.append(name)
            # show first difference
            act_lines = actual.splitlines()
            exp_lines = expected.splitlines()
            for i, (a, e) in enumerate(zip(act_lines, exp_lines)):
                if a != e:
                    print("    line {}: got    '{}'".format(i+1, a))
                    print("    line {}: expect '{}'".format(i+1, e))
                    break

    print("\n{} passed, {} failed".format(passed, failed))
    if errors:
        print("Failed tests:", ", ".join(errors))
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--testpath", default="test/cases")
    parser.add_argument("--testext", default=".mC")
    parser.add_argument("--exppath", default="test/exp")
    parser.add_argument("--expext", default=".exp")
    parser.add_argument("--program", default="obj/scanner")
    args = parser.parse_args()

    sys.exit(run_tests(args.program, args.testpath, args.testext,
                        args.exppath, args.expext))
