# Archive Extractor

A simple Bash script that scans a directory for archive files and extracts them into organized folders.

## Features

- Supports multiple archive formats:
  - ZIP (`.zip`)
  - RAR (`.rar`)
  - 7-Zip (`.7z`)
  - TAR (`.tar`)
  - TAR.GZ (`.tar.gz`)
  - TAR.BZ2 (`.tar.bz2`)
  - TAR.XZ (`.tar.xz`)
- Extracts each archive into its own directory.
- Automatically creates an `extracted/` folder.
- Supports password-protected archives.

## Requirements

The following utilities must be installed:

- Bash
- `tar`
- `unzip`
- `7z` (p7zip)
- `unrar`

### Ubuntu / Debian

```bash
sudo apt install unzip p7zip-full unrar tar
```

### Arch Linux

```bash
sudo pacman -S unzip p7zip unrar tar
```

### Fedora

```bash
sudo dnf install unzip p7zip p7zip-plugins unrar tar
```

## Installation

Clone the repository:

```bash
git clone https://github.com/stathisL/archive-extractor.git
cd archive-extractor
```

Make the script executable:

```bash
chmod +x archive-extractor.sh
```

## Usage

Scan the current directory:

```bash
./archive-extractor.sh
```

Scan a specific directory:

```bash
./archive-extractor.sh /path/to/archives
```

## Output

Archives are extracted into an `extracted/` directory inside the scanned folder.

Example:

```text
Downloads/
├── archive1.zip
├── backup.rar
└── extracted/
    ├── archive1/
    └── backup/
```

## Roadmap

Planned improvements include:

- Recursive directory scanning.
- Command-line options (`getopts`).
- Move the failed to extract in failed folder.
- Better password handling.
- Nested archive extraction.
- Parallel extraction.
- Dependency checking.
- Dry-run mode.
- Logging.

## License

This project is licensed under the MIT License.

See the `LICENSE` file for more information.
