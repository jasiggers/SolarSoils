## BADDIE 16S Data Processing

# Load Environment on Alpine server
sinteractive --ntasks=10

module purge

module load anaconda

conda activate qiime2-2023.5

# Navigating to working directory
cd /scratch/alpine/jasigs@colostate.edu/BADDIE/16S

# Importing Paired end sequence data
qiime tools import \
   --type EMPPairedEndSequences \
   --input-path paired-end-seqs \
   --output-path paired-end-seqs.qza

# Demultiplexing
qiime demux emp-paired \
  --m-barcodes-file Metadata.txt \
  --m-barcodes-column 16S_Barcodes \
  --p-rev-comp-mapping-barcodes \
  --p-rev-comp-barcodes \
  --i-seqs paired-end-seqs.qza \
  --o-per-sample-sequences demux_BADDIE_bac.qza \
  --o-error-correction-details demux_details_BADDIE_bac.qza

# Creating summary visual file
qiime demux summarize \
 --i-data demux_BADDIE_bac.qza \
 --o-visualization demux_BADDIE_bac.qzv

# Quality looks solid. Need to get rid of first 12 reads of reverse but everything else can stay

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux_BADDIE_bac.qza \
--p-trunc-len-f 151 \
--p-trunc-len-r 151 \
--p-trim-left-f 0 \
--p-trim-left-r 12 \
--o-table dada2_table.qza \
--o-representative-sequences dada2_rep_set.qza \
--o-denoising-stats dada2_stats.qza

# Visualizing outputs
qiime metadata tabulate \
--m-input-file dada2_stats.qza  \
--o-visualization dada2_stats.qzv

# Feature table summary
qiime feature-table summarize \
--i-table dada2_table.qza \
--m-sample-metadata-file Metadata.txt \
--o-visualization dada2_table.qzv

# All samples have at least 11,900 reads

# Tabulating representative sequences
qiime feature-table tabulate-seqs \
--i-data dada2_rep_set.qza \
--o-visualization dada2_rep_set.qzv

# Pulling the GreenGenes2 classifier
wget \
  -O "gg_2022_10_backbone.v4.nb.qza" \
  "https://data.qiime2.org/classifiers/greengenes/gg_2022_10_backbone.v4.nb.qza"

## TAXONOMY ##
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

# Running the classifier on our feature table
qiime feature-classifier classify-sklearn \
  --i-reads ./dada2_rep_set.qza \
  --i-classifier ./gg_2022_10_backbone.v4.nb.qza \
  --o-classification ./taxonomy.qza \
  --p-n-jobs 10

# Checking taxonomic assignments
qiime metadata tabulate \
  --m-input-file ./taxonomy.qza \
  --o-visualization ./taxonomy.qzv

# Create rarefaction curve
qiime diversity alpha-rarefaction \
--i-table ./dada2_table.qza \
--m-metadata-file ./Metadata.txt \
--o-visualization ./alpha_rarefaction_curves.qzv \
--p-min-depth 10 \
--p-max-depth 21000

# General taxonomic barchart
# Set p-min-frequency to 11000 based on rarefaction & dada2_table
qiime feature-table filter-samples \
  --i-table ./dada2_table.qza \
  --p-min-frequency 11000 \
  --o-filtered-table ./table_2k.qza

# Visualize taxonomic barcharts
qiime taxa barplot \
  --i-table ./table_2k.qza \
  --i-taxonomy ./taxonomy.qza \
  --m-metadata-file ./Metadata.txt \
  --o-visualization ./taxa_barplot.qzv

# Remove mitochondria and chloroplast reads
qiime taxa filter-table \
--i-table dada2_table.qza \
--i-taxonomy taxonomy.qza \
--p-exclude mitochondria,chloroplast \
--o-filtered-table dada2_table-no-mitochondria-no-chloroplast.qza

# Set p-min-frequency to 11000 based on rarefaction & dada2_table
qiime feature-table filter-samples \
  --i-table ./dada2_table-no-mitochondria-no-chloroplast.qza \
  --p-min-frequency 11000 \
  --o-filtered-table ./table_2k-no-mitochondria-no-chloroplast.qza

# Visualize no mito chloro taxonomy barcharts
qiime taxa barplot \
--i-table table_2k-no-mitochondria-no-chloroplast.qza \
--i-taxonomy taxonomy.qza \
--m-metadata-file Metadata.txt \
--o-visualization taxa_barplot-no-mitochondria-no-chloroplast.qzv

# Create rarefaction curve with no mito no chloro
qiime diversity alpha-rarefaction \
--i-table ./dada2_table-no-mitochondria-no-chloroplast.qza \
--m-metadata-file ./Metadata.txt \
--o-visualization ./alpha_rarefaction_curves_nomito_nochloro.qzv \
--p-min-depth 10 \
--p-max-depth 21000

## PHYLOGENY ##
# Get phylogenetic rooted tree
# Phylogenetic tree
wget \
  -O "sepp-refs-gg-13-8.qza" \
  "https://data.qiime2.org/2022.2/common/sepp-refs-gg-13-8.qza"

#!/bin/bash
#SBATCH --job-name=phylogeny.baddie
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

# Place sequences onto tree
qiime fragment-insertion sepp \
  --i-representative-sequences dada2_rep_set.qza \
  --i-reference-database sepp-refs-gg-13-8.qza \
  --o-tree tree.qza \
  --o-placements tree_placements.qza \
  --p-threads 8

# Submit the job & check the queue
sbatch phylogeny.baddie.sh
squeue -u jasigs@colostate.edu

# Sampling depth determined at 11,000 by rarefaction curve
# Creating core metrics
qiime diversity core-metrics-phylogenetic \
--i-table ./dada2_table-no-mitochondria-no-chloroplast.qza \
--i-phylogeny ./tree.qza \
--m-metadata-file ./Metadata.txt \
--p-sampling-depth 11000 \
--output-dir ./core-metrics-results

## ALPHA DIVERSITY ##
qiime diversity alpha-group-significance \
--i-alpha-diversity ./core-metrics-results/shannon_vector.qza \
--m-metadata-file ./Metadata.txt \
--o-visualization ./core-metrics-results/shannon_statistics.qzv

# Creating Faiths PD visualization
qiime diversity alpha-group-significance \
--i-alpha-diversity ./core-metrics-results/faith_pd_vector.qza \
--m-metadata-file ./Metadata.txt \
--o-visualization ./core-metrics-results/faiths_pd_statistics.qzv

## BETA DIVERSITY ##

# Unweighted UniFrac distance PERMANOVA visualization (by microsite)
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
--m-metadata-file Metadata.txt \
--m-metadata-column Microsite \
--o-visualization core-metrics-results/unweighted_unifrac_microsite.qzv

#### PULLING FEATURE TABLE #####

qiime tools export \
  --input-path table_2k.qza \
  --output-path exported-feature-table

biom convert -i feature-table.biom -o table.tsv --to-tsv