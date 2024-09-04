#!/bin/bash
exec >> new_full_kraken.txt 2>&1

# Base directory containing nested files with .fastq.gz files
BASE_DIR="/home/aubzxk001/host_depletion_test/trimmomatic/trimmed_reads"

# Target directory to store merged .fq files and output files
TARGET_DIR="/home/aubzxk001/host_depletion_test/kraken/kraken2/kraken_full_output"

# Paths to databases and other resources
TRUSEQ_ADAPTERS="./TruSeq3-PE.fa"
KRAKEN_DB="/home/aubzxk001/host_depletion_test/kraken/kraken2_full"

# check if kraken db exists
if [ ! -d "$KRAKEN_DB" ]; then
    echo "Kraken database not found at $KRAKEN_DB"
    exit 1
fi


BRACKEN_DB="/home/aubzxk001/host_depletion_test/kraken/kraken2_full"

# Create the target directory and subdirectories if they don't exist
mkdir -p "$TARGET_DIR"
# mkdir -p "$TARGET_DIR/fastqc"
# mkdir -p "$TARGET_DIR/trimmomatic"
mkdir -p "$TARGET_DIR/kraken2"
mkdir -p "$TARGET_DIR/bracken"
# mkdir -p "$TARGET_DIR/megahit"

# # echo "directories created" 
/home/aubzxk001/host_depletion_test/kraken/kraken2/Bracken/bracken-build -d $BRACKEN_DB -t 100 -k 35


# Loop through each FASTQ file in the input directory
for file in "$BASE_DIR"/*_R1.fastq.gz; do
      
      # Extract the sample name from the file name
      sample_name=$(basename "$file" | cut -d'_' -f1)
      echo "Processing sample: $sample_name"


      # #fastp for quality control
      # echo "fastp starting for $sample_name"
      # fastp -i "$BASE_DIR/${sample_name}_R1_001.fastq.gz" -I "$BASE_DIR/${sample_name}_R2_001.fastq.gz" -o "$TARGET_DIR/fastqc/${sample_name}_R1_001_fastp.fq" -O "$TARGET_DIR/fastqc/${sample_name}_R2_001_fastp.fq" -h "$TARGET_DIR/fastqc/${sample_name}_fastp.html" -j "$TARGET_DIR/fastqc/${sample_name}_fastp.json"


      # # Taxonomic Classification with Kraken2
      # echo "kraken2 starting for $sample_name"
      # kraken2 --db $KRAKEN_DB --paired "$BASE_DIR/${sample_name}_R1.fastq.gz" "$BASE_DIR/${sample_name}_R2.fastq.gz" --report "$TARGET_DIR/kraken2/${sample_name}_kraken.report" --output "$TARGET_DIR/kraken2/${sample_name}_kraken.out" --threads 32
      # echo "kraken2 for $sample_name done"
      
     # Estimating Abundance with Bracken
      /home/aubzxk001/host_depletion_test/kraken/kraken2/Bracken/bracken -d $BRACKEN_DB -i "$TARGET_DIR/kraken2/${sample_name}_kraken.report" -o "$TARGET_DIR/bracken/${sample_name}_bracken.out" -r 150 -l S -t 32
      
      
      # # Assembly with Megahit
      # megahit -1 "$TARGET_DIR/trimmomatic/${sample_name}_1_paired.fq" -2 "$TARGET_DIR/trimmomatic/${sample_name}_2_paired.fq" -o "${TARGET_DIR}/megahit/${sample_name}_megahit_output"
      # echo "megahit for $file done"
done
# Remove the misplaced 'fi' statement
echo "the script ran successfully"
