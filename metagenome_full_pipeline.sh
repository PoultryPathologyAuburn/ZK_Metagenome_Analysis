#!/bin/bash

source activate metagenome 
# Base directory containing nested folders with .fq files
BASE_DIR="path_to_your_raw_data"

# Target directory to store merged .fq files and output files
TARGET_DIR="/path_to_your_target_directory"

# Paths to databases and other resources
TRUSEQ_ADAPTERS="path_to_adapters.fa"
KRAKEN_DB="path_to_minikraken2_v2_8GB_201904_UPDATE"
BRACKEN_DB="path_to_minikraken2_v2_8GB_201904_UPDATE"

# Create the target directory and subdirectories if they don't exist
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/fastqc"
mkdir -p "$TARGET_DIR/trimmomatic"
mkdir -p "$TARGET_DIR/kraken2"
mkdir -p "$TARGET_DIR/bracken"
mkdir -p "$TARGET_DIR/megahit"

# echo "directories created" 

# Loop through each nested folder
for folder in "$BASE_DIR"/*; do
    if [ -d "$folder" ]; then
      # Extract the folder name to use as the base for the output file names
      folder_name=$(basename "$folder")

      # Initialize empty files for merged forward and reverse reads
      forward_file="$TARGET_DIR/${folder_name}_merged_1.fq.gz"
      reverse_file="$TARGET_DIR/${folder_name}_merged_2.fq.gz"

      # Concatenate forward and reverse reads
      cat "$folder"/*_1.fq.gz > "$forward_file"
      cat "$folder"/*_2.fq.gz > "$reverse_file"
    
      # # FastQC Quality Check
      fastqc "$forward_file" -o "$TARGET_DIR/fastqc"
      fastqc "$reverse_file" -o "$TARGET_DIR/fastqc"

      echo "fastq done & trimmomatic starting"

      # Trimming with Trimmomatic
      trimmomatic PE -phred33 "$forward_file" "$reverse_file" "$TARGET_DIR/trimmomatic/${folder_name}_1_paired.fq" "$TARGET_DIR/trimmomatic/${folder_name}_1_unpaired.fq" "$TARGET_DIR/trimmomatic/${folder_name}_2_paired.fq" "$TARGET_DIR/trimmomatic/${folder_name}_2_unpaired.fq" ILLUMINACLIP:$TRUSEQ_ADAPTERS:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
      echo "done trimming for $folder"


      # Taxonomic Classification with Kraken2
      echo "kraken2 starting for $folder_name"
      kraken2 --db $KRAKEN_DB --paired "$TARGET_DIR/trimmomatic/${folder_name}_1_paired.fq" "$TARGET_DIR/trimmomatic/${folder_name}_2_paired.fq" --report "$TARGET_DIR/kraken2/${folder_name}_kraken.report" --output "$TARGET_DIR/kraken2/${folder_name}_kraken.out"
      echo "kraken2 for $folder done"

     # Estimating Abundance with Bracken
       
      cd /home/aubzxk001/metagenomics/bracken/Bracken-2.8
      bracken-build -d /home/aubzxk001/metagenomics/krakenDB/minikraken2_v2_8GB_201904_UPDATE -t 100 -k 35
      bracken -d $BRACKEN_DB -i "$TARGET_DIR/kraken2/${folder_name}_kraken.report" -o "$TARGET_DIR/bracken/${folder_name}_bracken.out" -r 100 -l S -t 10


      # # Assembly with Megahit
      # megahit -1 "$TARGET_DIR/trimmomatic/${folder_name}_1_paired.fq" -2 "$TARGET_DIR/trimmomatic/${folder_name}_2_paired.fq" -o "${TARGET_DIR}/megahit/${folder_name}_megahit_output"
      # echo "megahit for $folder done"

    fi
done
echo "all the script ran successfully"
