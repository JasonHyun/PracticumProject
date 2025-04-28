#!/bin/bash

###########################################################
# This is a pipeline to run all code-based tasks for our  #
# final project. Note that this pipeline may take more    #
# than 24 hrs to finish. Use command "squeue -u [usrname] #
# to check the status of the tasks running on PSC.        #
# Members: Deyuan Xu, June Qu, Jason Hyun, Jessica Vu     #
# *Make sure you have access permission to all 4 members' #
# home directory before running this pipeline             #
# Tissues studied: Liver & Pancreas                       #
# Species involved: Mouse & Human                         #
###########################################################

###########################################################
#Usage: put this script in the same directory where all the
#peak files are placed. Run this pipeline. A HALPER must
#be installed in your environment. Please use the first
#parameter to give a path to mouse liver peak file and the 
#second parameter to give a path to mouse pancreas peak
#file. Besides, use the third parameter to give a path to
#the human liver peak file and the fourth parameter to 
#give a human pancreas peak file.
###########################################################

mouse_liver_peak=$1
mouse_pancreas_peak=$2
human_liver_peak=$3
human_pancreas_peak=$4  # Fixed variable name

# Create necessary directories
mkdir -p $PROJECT/results/mapping_mouse2human/liver
mkdir -p $PROJECT/results/mapping_mouse2human/pancreas

###########################################################
# Map mouse liver OCRs to human genome
###########################################################

job_filename="liver.job"

cat > "$job_filename" <<EOL
#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -t 24:00:00
#SBATCH --mem 1999M
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH -J liver_job
#SBATCH -e $PROJECT/results/liver_pipeline.err
#SBATCH -o $PROJECT/results/liver_pipeline.out
#SBATCH --export=ALL

#echo commands to stdout
set -x

bash halper_map_peak_orthologs.sh \\
-b $mouse_liver_peak \\
-o $PROJECT/results/mapping_mouse2human/liver \\
-s Mouse \\
-t Human \\
-c /ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal
EOL

echo "job file created: $job_filename"
sbatch ./liver.job  # Fixed typo: sbtach -> sbatch
rm ./liver.job

###########################################################
# Map mouse pancreas OCRs to human genome
###########################################################

job_filename="pancreas.job"

cat > "$job_filename" <<EOL
#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -t 24:00:00
#SBATCH --mem 1999M
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH -J pancreas_job
#SBATCH -e $PROJECT/results/pancreas_pipeline.err
#SBATCH -o $PROJECT/results/pancreas_pipeline.out
#SBATCH --export=ALL

#echo commands to stdout
set -x

bash halper_map_peak_orthologs.sh \\
-b $mouse_pancreas_peak \\
-o $PROJECT/results/mapping_mouse2human/pancreas \\
-s Mouse \\
-t Human \\
-c /ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal
EOL

echo "job file created: $job_filename"
sbatch ./pancreas.job  # Fixed typo: sbtach -> sbatch
rm ./pancreas.job

###########################################################
# Wait until the HALPER is done
###########################################################

# sleep for 5 hours before checking status because HALPER definitely needs
# more than 5 hours

echo "waiting for mapping to be done..."
sleep 18000

username=$(whoami)  # Get current username automatically

# check task status every 10 minutes
while true; do
    
    job_count=$(squeue -u "$username" | wc -l)
   
    job_count=$((job_count - 1))

    if [ "$job_count" -eq 0 ]; then
        echo "PSC task is done! Proceed on next steps."
        break
    else
        echo "PSC task is not done, next check in 10 minutes..."
        sleep 600  
    fi
done

###########################################################
# Extract unique and conservative peaks across species or across tissues
###########################################################

bash $PROJECT/code/intersection.sh

###########################################################
# Find enhancer and promoter regions
###########################################################

bash $PROJECT/code/find_region.sh

###########################################################
# Get sequences of OCRs for MEME
###########################################################

bash $PROJECT/code/region2seq.sh

###########################################################
# Calculate the percentatages of conserved OCRs
###########################################################

bash $PROJECT/code/find_percent_conservation.sh

###########################################################
# Usage of MEME for finding motifs
###########################################################

bash $PROJECT/code/meme_chip.sh