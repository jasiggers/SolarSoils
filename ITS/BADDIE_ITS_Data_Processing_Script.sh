## BADDIE_ITS_Data_Processing_Script

# Load Environment on Alpine server
sinteractive --ntasks=10

module purge

module load anaconda

conda activate qiime2-2023.5

# Navigating to working directory
cd /scratch/alpine/jasigs@colostate.edu/BADDIE/ITS

# Importing Paired end sequence data
qiime tools import \
   --type EMPPairedEndSequences \
   --input-path paired-end-seqs \
   --output-path paired-end-seqs.qza

# Demultiplexing
qiime demux emp-paired \
  --m-barcodes-file Metadata.txt \
  --m-barcodes-column ITS_Barcodes \
  --p-rev-comp-mapping-barcodes \
  --i-seqs paired-end-seqs.qza \
  --o-per-sample-sequences demux_BADDIE_fungi.qza \
  --o-error-correction-details demux_details_BADDIE_fungi.qza

# Creating summary visual file
qiime demux summarize \
 --i-data demux_BADDIE_fungi.qza \
 --o-visualization demux_BADDIE_fungi.qzv

# Creating job file
nano denoising.sh

# Job code

#!/bin/bash
#SBATCH --job-name=denoising
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --partition=amilan
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jasigs@colostate.edu

#Activate qiime

module purge

module load anaconda

conda activate qiime2-2023.5

#Command
qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux_BADDIE_fungi.qza \
--p-trunc-len-f 250 \
--p-trunc-len-r 246 \
--o-table dada2_table.qza \
--o-representative-sequences dada2_rep_set.qza \
--o-denoising-stats dada2_stats.qza

# Submit the job & check the queue
sbatch denoising.sh
squeue -u jasigs@colostate.edu

# Visualizing outputs
qiime metadata tabulate \
--m-input-file dada2_stats.qza  \
--o-visualization dada2_stats.qzv

# Feature table summary
qiime feature-table summarize \
--i-table dada2_table.qza \
--m-sample-metadata-file Metadata.txt \
--o-visualization dada2_table.qzv

# Tabulating representative sequences
qiime feature-table tabulate-seqs \
--i-data dada2_rep_set.qza \
--o-visualization dada2_rep_set.qzv

# Taxonomy
https://john-quensen.com/tutorials/training-the-qiime2-classifier-with-unite-its-reference-sequences/

# Pulled from https://doi.plutof.ut.ee/doi/10.15156/BIO/2938079
# QIIME Unite release version number 9.0 (07/25/23)

# Importing reference database
qiime tools import \
--type FeatureData[Sequence] \
--input-path sh_refs_qiime_ver9_99_25.07.2023_dev.fasta \
--output-path unite-ver9-seqs_99_25.07.2023.qza

# Importing taxonomy file
qiime tools import \
--type FeatureData[Taxonomy] \
--input-path sh_taxonomy_qiime_ver9_99_25.07.2023_dev.txt \
--output-path unite-ver9-taxonomy_99_25.07.2023.qza \
--input-format HeaderlessTSVTaxonomyFormat

# Train the classifier
qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads unite-ver9-seqs_99_25.07.2023.qza \
--i-reference-taxonomy unite-ver9-taxonomy_99_25.07.2023.qza \
--o-classifier unite-ver9-99-classifier-25.07.2023.qza

# Creating a job since it keeps killing this in shell

nano classifier.sh

#!/bin/bash
#SBATCH --job-name=classifier
#SBATCH --nodes=1
#SBATCH --ntasks=50
#SBATCH --partition=amilan
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jasigs@colostate.edu

#Activate qiime

module purge

module load anaconda

conda activate qiime2-2023.5

#Command
qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads unite-ver9-seqs_99_25.07.2023.qza \
--i-reference-taxonomy unite-ver9-taxonomy_99_25.07.2023.qza \
--o-classifier unite-ver9-99-classifier-25.07.2023.qza

# Making a taxonomy job

#!/bin/bash
#SBATCH --job-name=taxonomy
#SBATCH --nodes=1
#SBATCH --ntasks=50
#SBATCH --partition=amilan
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jasigs@colostate.edu

#Activate qiime

module purge

module load anaconda

conda activate qiime2-2023.5

# Classify taxonomy
qiime feature-classifier classify-sklearn \
  --i-classifier unite-ver9-99-classifier-25.07.2023.qza \
  --i-reads dada2_rep_set.qza \
  --o-classification taxonomy.qza

# Check taxonomic assignments
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

# Create rarefaction curve
qiime diversity alpha-rarefaction \
--i-table ./dada2_table.qza \
--m-metadata-file ./Metadata.txt \
--o-visualization ./alpha_rarefaction_curves.qzv \
--p-min-depth 1000 \
--p-max-depth 53000

# General taxonomic barchart
# Set p-min-frequency to 10000 based on rarefaction & dada2_table
qiime feature-table filter-samples \
  --i-table ./dada2_table.qza \
  --p-min-frequency 10000 \
  --o-filtered-table ./table_2k.qza

  # Visualize taxonomic barcharts
qiime taxa barplot \
  --i-table ./table_2k.qza \
  --i-taxonomy ./taxonomy.qza \
  --m-metadata-file ./Metadata.txt \
  --o-visualization ./taxa_barplot.qzv

# Making a phylogeny job
#!/bin/bash
#SBATCH --job-name=taxonomy
#SBATCH --nodes=1
#SBATCH --ntasks=50
#SBATCH --partition=amilan
#SBATCH --time=24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jasigs@colostate.edu

#Activate qiime

module purge

module load anaconda

conda activate qiime2-2023.5

# Phylogeny
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences dada2_rep_set.qza \
--o-alignment aligned-rep-seqs-paired.qza \
--o-masked-alignment masked-aligned-rep-seqs-paired.qza \
--o-tree unrooted-tree-paired.qza \
--o-rooted-tree rooted-tree-paired.qza

#### PULLING FEATURE TABLE #####
qiime tools export \
  --input-path table_2k.qza \
  --output-path exported-feature-table

biom convert -i feature-table.biom -o table.tsv --to-tsv





