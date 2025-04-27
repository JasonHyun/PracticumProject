#!/bin/bash

# Use the pre-defined $PROJECT variable (/ocean/projects/bio230007p/username)
# Ensure the necessary subdirectories exist
JOB_DIR="${PROJECT}/jobs"
OUTPUT_DIR="${PROJECT}"

echo "Starting peak intersection analyses in project directory: ${PROJECT}"

# Check if job directory exists
if [ ! -d "${JOB_DIR}" ]; then
    echo "Error: Job directory ${JOB_DIR} not found!"
    exit 1
fi

# Run species-specific comparisons first
echo "Running species-specific intersections..."
species_pancreas_job=$(sbatch ${JOB_DIR}/species_pancreas.job | cut -d' ' -f4)
species_liver_job=$(sbatch ${JOB_DIR}/species_liver.job | cut -d' ' -f4)

# Run tissue-specific comparison for human
echo "Running tissue-specific intersection for human..."
tissues_human_job=$(sbatch ${JOB_DIR}/tissues_human.job | cut -d' ' -f4)

# Wait for species-specific jobs to complete before running unique subset analyses
echo "Running unique subset analyses..."
# These depend on the species comparison jobs
sbatch --dependency=afterok:${species_liver_job} ${JOB_DIR}/human_liver_unique.job
sbatch --dependency=afterok:${species_liver_job} ${JOB_DIR}/mouse_liver_unique.job
sbatch --dependency=afterok:${species_pancreas_job} ${JOB_DIR}/human_pancreas_unique.job
sbatch --dependency=afterok:${species_pancreas_job} ${JOB_DIR}/mouse_pancreas_unique.job

echo "All intersection jobs submitted. Use 'squeue -u $USER' to check status."
echo "Results will be written to ${OUTPUT_DIR}"