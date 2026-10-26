"""Sum a numeric column of a CSV file.

Usage: python3 csvsum.py FILE COLUMN
"""
import argparse
import csv


def column_sum(path, column):
    with open(path, newline="") as f:
        return sum(float(row[column]) for row in csv.DictReader(f))


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("file")
    p.add_argument("column")
    args = p.parse_args(argv)
    print(column_sum(args.file, args.column))


if __name__ == "__main__":
    main()
