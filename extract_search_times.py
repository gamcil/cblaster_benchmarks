"""
Extracts elapsed times from searches timed by perf stat.

Usage: python3 extract_times.py <stats file> > times.txt
"""

import re
import sys

pattern = re.compile(
    r"queries\/(?P<query>BGC\d+?)\.gbk.*?\s(?P<time>\d+?\.\d+?) seconds time elapsed",
    re.MULTILINE | re.DOTALL
)

with open(sys.argv[1]) as fp:
    stats = fp.read()

for match in pattern.finditer(stats):
    print(match.group("query"), match.group("time"))
