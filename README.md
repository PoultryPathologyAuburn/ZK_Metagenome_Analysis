# Metagenomic Analysis Pipeline

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Usage](#usage)
  - [Parameters](#parameters)
- [Example](#example)
- [Output](#output)
- [Contributing](#contributing)

## Description

This repository contains a Bash script for automating various steps in a metagenomic analysis pipeline. The script merges `.fq` files, performs adapter trimming, and classifies reads using Kraken.

## Installation

Clone this repository to your local machine.

```bash
git clone https://github.com/Zubair2021/metagenome_analysis.git
```

## Dependencies

#### Software

1. **Bash**: Make sure you have Bash shell installed on your system.
2. **Kraken2**: Download and install from [Kraken2 GitHub Repository](https://github.com/DerrickWood/kraken2).
3. **Bracken**: Download and install from [Bracken GitHub Repository](https://github.com/jenniferlu717/Bracken).

You can typically install Kraken2 and Bracken using the following commands:

```bash
# For Kraken2
git clone https://github.com/DerrickWood/kraken2.git
cd kraken2
./install_kraken2.sh $PWD

# For Bracken
git clone https://github.com/jenniferlu717/Bracken.git
cd Bracken
./install_bracken.sh
```

#### Database

1. **Kraken2 Database**: You can build a Kraken2 database following the instructions [here](https://benlangmead.github.io/aws-indexes/k2).
   
   ```bash
   kraken2-build --standard --threads 12 --db $KRAKEN_DB_NAME
   ```
   
2. **Bracken Database**: After building the Kraken2 database, you can build the Bracken database.

   ```bash
   bracken-build -d $KRAKEN_DB_NAME -k 35 -l 150
   ```

Note: Replace `$KRAKEN_DB_NAME` with the name you wish to give to your Kraken2 database.

---

#### Adapter sequences in a `.fa` file

## Usage

### Parameters

- `BASE_DIR`: The base directory containing nested folders with `.fq` files.
- `TARGET_DIR`: Target directory to store merged `.fq` files and output files.
- `TRUSEQ_ADAPTERS`: Path to the adapter sequences in `.fa` format.
- `KRAKEN_DB`: Path to the Kraken database.

To run the script, navigate to the directory containing the script and execute:

```bash
bash metagenome_full_pipeline.sh
```

## Example

```bash
BASE_DIR="/path/to/raw_data"
TARGET_DIR="/path/to/output"
TRUSEQ_ADAPTERS="/path/to/adapters.fa"
KRAKEN_DB="/path/to/krakenDB"
```

## Output

The output directory will contain the following:

- Merged `.fq` files
- Trimmed `.fq` files
- Kraken classification reports

## Contributing

If you wish to contribute, please open an issue or submit a pull request.

---
