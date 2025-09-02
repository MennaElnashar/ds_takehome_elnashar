import subprocess
import sys
from pathlib import Path

def update_requirements():
    # Save requirements.txt in the same folder as this script
    requirements_path = Path(__file__).parent / "requirements.txt"

    try:
        # Use the current Python executable to run pip
        result = subprocess.run(
            [sys.executable, "-m", "pip", "freeze"],
            capture_output=True,
            text=True,
            check=True
        )

        # Write output to requirements.txt
        with open(requirements_path, "w", encoding="utf-8") as f:
            f.write(result.stdout)

        print(f"requirements.txt updated successfully at {requirements_path}")

    except subprocess.CalledProcessError as e:
        print(f"Error updating requirements: {e}")

if __name__ == "__main__":
    update_requirements()
