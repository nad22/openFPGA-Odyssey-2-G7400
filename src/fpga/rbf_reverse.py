import sys


BIT_REVERSE = bytes(int(f"{value:08b}"[::-1], 2) for value in range(256))


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: rbf_reverse.py input.rbf output.rbf_r")

    with open(sys.argv[1], "rb") as source:
        bitstream = source.read()

    with open(sys.argv[2], "wb") as destination:
        destination.write(bitstream.translate(BIT_REVERSE))


if __name__ == "__main__":
    main()
