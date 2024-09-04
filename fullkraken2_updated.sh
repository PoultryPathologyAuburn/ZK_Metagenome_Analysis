#!/bin/bash
exec >> log_kraken_bracken_run.txt 2>&1

# load the module
module load anaconda/3-2021.11 # there will be a few non-deterimental warnings with this module load 

# Base directory containing nested files with .fastq.gz files
BASE_DIR="your_fastq_directory"

# Target directory to store merged .fq files and output files
TARGET_DIR="path_to_output"

# Paths to databases and other resources
TRUSEQ_ADAPTERS="./TruSeq3-PE.fa"
KRAKEN_DB="path_to_database" 
BRACKEN_DB="path_to_database"

# 1. The default standard database can be found either in 
/datasets/unzipped/kraken2_full

# 2. You can build your own custom database which can be downloaded and pre-built using 
# https://benlangmead.github.io/aws-indexes/k2

# 3. Run it from /datasets/unzipped/kraken2_full/nt_database
# the database nt_database is huge and needs RAM management (32 cpu & 502gb RAM)


# check if kraken db exists
if [ ! -d "$KRAKEN_DB" ]; then
    echo "Kraken database not found at $KRAKEN_DB"
    exit 1
fi




# Create the target directory and subdirectories if they don't exist
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/trimmomatic"
mkdir -p "$TARGET_DIR/kraken2"
mkdir -p "$TARGET_DIR/bracken"

# # echo "directories created" 
bracken-build -d $BRACKEN_DB -t 16 -k 35


source /apps/profiles/modules_asax.sh.dyn
module load trimmomatic

# Directory containing your FASTQ files
input_dir="path_to_raw_reads"

trimmed_reads_dir="trimmed_reads"

mkdir -p "$trimmed_reads_dir"

# Process each pair of FASTQ files in the directory
for file1 in "$input_dir"/*_R1_001.fastq.gz; do
    # Get the base name of the file
    base_name=$(basename "$file1" _R1_001.fastq.gz)
    echo "$base_name"
    file2="${input_dir}/${base_name}_R2_001.fastq.gz"

    if [[ -f "$file1" && -f "$file2" ]]; then
        # Quality control and trimming using Trimmomatic
        trimmed_file1="${trimmed_reads_dir}/${base_name}_R1.fastq.gz"
        trimmed_file2="${trimmed_reads_dir}/${base_name}_R2.fastq.gz"
        
        # Run trimmomatic without unpaired reads
        trimmomatic PE -threads 32 -phred33 \
            "$file1" "$file2" \
            "$trimmed_file1" /dev/null \
            "$trimmed_file2" /dev/null \
            ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:8:true LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:50
        
        # Check if trimming succeeded
        if [[ $? -ne 0 ]]; then
            echo "Trimmomatic failed for $base_name"
            continue
        fi
        
        # Count total reads in raw data
        total_reads=$(zcat "$file1" "$file2" | wc -l)
        total_reads=$((total_reads / 4))
        echo "Processing sample ${base_name} with ${total_reads} total reads"
    
    else 
        echo "Paired files not found for $base_name"
    fi
done


# use the trimmed reads

# Loop through each FASTQ file in the input directory
for file in "$trimmed_reads_dir"/*_R1.fastq.gz; do
      
      # Extract the sample name from the file name
      sample_name=$(basename "$file" | cut -d'_' -f1)
      echo "Processing sample: $sample_name"

      # Taxonomic Classification with Kraken2
      echo "kraken2 starting for $sample_name"
      kraken2 --db $KRAKEN_DB --paired "$trimmed_reads_dir/${sample_name}_R1.fastq.gz" "$trimmed_reads_dir/${sample_name}_R2.fastq.gz" --report "$TARGET_DIR/kraken2/${sample_name}_kraken.report" --output "$TARGET_DIR/kraken2/${sample_name}_kraken.out" --threads 32
      echo "kraken2 for $sample_name done"
      
      # Estimating Abundance with Bracken
      bracken -d $BRACKEN_DB -i "$TARGET_DIR/kraken2/${sample_name}_kraken.report" -o "$TARGET_DIR/bracken/${sample_name}_bracken.out" -r 150 -l S -t 32
      

done
# Remove the misplaced 'fi' statement
echo "the script ran successfully"
