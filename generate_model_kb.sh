#!/usr/bin/env bash
set -e

# 🧾 Parse arguments
KEYCAP_FMT="std"  # ✨ Default format
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --letter)
            LETTER="$2"
            shift 2
            ;;
        --fmt)
            KEYCAP_FMT="$2"
            shift 2
            ;;
        *)
            echo "❌ Unknown parameter: $1"
            echo "Usage: $0 --letter <LETTER> [--fmt <FORMAT>]"
            exit 1
            ;;
    esac
done

# 🛑 Validate letter input
if [[ -z "$LETTER" ]]; then
    echo "❌ Error: --letter is required."
    exit 1
fi

OUTFILE="${LETTER}.3mf"  # ✅ Output file name

# 🧹 Clean up previous files
rm -rf intermediates
rm -f "$OUTFILE" base.3mf text.3mf

# ⚙️ Generate parts using OpenSCAD
openscad -o base.3mf -D "part=\"base\"; raw_letter=\"$LETTER\"; fmt=\"$KEYCAP_FMT\"" kb_low_profile.scad
openscad -o text.3mf -D "part=\"text\"; raw_letter=\"$LETTER\"" kb_low_profile.scad

# 🧩 Merge into final file
python3.10 merge_ams.py base.3mf text.3mf "$OUTFILE"

rm -f base.3mf text.3mf

# ✅ Completion message
echo "✅ Merged file saved as $OUTFILE"
