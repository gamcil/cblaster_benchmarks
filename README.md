# cblaster_benchmarks
Scripts used in benchmarking MultiGeneBlast and cblaster.

Compare prediction of characterised fungal BGCs stored in the MIBiG database against a local database consisting of Aspergillus genomes stored in the GenBank database.
All performance benchmarks were generated using the perf command line utility on a workstation computer with an Intel(R) Xeon(R) E5-2630 CPU (2.40GHz) and 64gb of RAM.

| File | Description |
| ---- | ----------- |
| ``run_cblaster.sh`` | Runner script for timed cblaster searches |
| ``run_mgb.sh`` | Runner script for timed MultiGeneBlast searches |
| ``extract_gene_counts.sh`` | Script for extracting number of genes per query from MultiGeneBlast output |
| ``extract_search_times.py`` | Script for extracting elapsed times from perf stat output |
| ``perf/*`` | Output of perf stat for database creation and search |
| ``output/*`` | Search output files for both tools |

## Download Aspergillus genomes from the NCBI using datasets
The NCBI datasets tool was used to retrieve annotated Aspergillus genome assemblies:

	datasets download genome taxon "Aspergillus" \
		--assembly-source genbank \
		--exclude-gff3 \
		--exclude-protein \
		--exclude-rna \
		--exclude-seq \
		--include-gbff \
		--filename genomes.zip \
		--dehydrated

These were then hydrated to obtain 151 GenBank assemblies:

	unzip genomes.zip -d genomes
	datasets rehydrate --directory genomes/

In some cases, gene clusters are directly deposited as separate records in the Nucleotide database and do not have a corresponding genome assembly.
Thus, we also retrieved these records using:

	esearch -db nuccore \
		-query "aspergillus"[orgn] AND "gene cluster"[title] |\
	efetch -format gb

This resulted in an additional 90 records.

## Download Aspergillus BGCs from the MIBiG database
As of version 2.0, the MIBiG database contains 88 clusters found in Aspergillus genomes.
The GenBank files for each of these clusters were retrieved from MIBiG to be used as queries:

	wget https://dl.secondarymetabolites.org/mibig/mibig_gbk_2.0.tar.gz
	tar xzvf mibig_gbk_2.0.tar.gz

Duplicates, as well as files containing less than two genes were discarded from the dataset, resulting in a final set of 80 query clusters:

	BGC0000004 BGC0000006 BGC0000007 BGC0000008
	BGC0000009 BGC0000010 BGC0000011 BGC0000013
	BGC0000022 BGC0000045 BGC0000057 BGC0000088
	BGC0000101 BGC0000129 BGC0000152 BGC0000156
	BGC0000160 BGC0000161 BGC0000170 BGC0000292
	BGC0000293 BGC0000355 BGC0000356 BGC0000361
	BGC0000372 BGC0000442 BGC0000627 BGC0000673
	BGC0000682 BGC0000684 BGC0000686 BGC0000811
	BGC0000818 BGC0000900 BGC0000901 BGC0000959
	BGC0000977 BGC0000983 BGC0001037 BGC0001067
	BGC0001084 BGC0001118 BGC0001122 BGC0001123
	BGC0001143 BGC0001238 BGC0001239 BGC0001290
	BGC0001304 BGC0001306 BGC0001371 BGC0001399
	BGC0001400 BGC0001403 BGC0001445 BGC0001446
	BGC0001475 BGC0001515 BGC0001516 BGC0001517
	BGC0001518 BGC0001544 BGC0001547 BGC0001616
	BGC0001621 BGC0001668 BGC0001679 BGC0001699
	BGC0001708 BGC0001712 BGC0001718 BGC0001722
	BGC0001839 BGC0001857 BGC0001874 BGC0001988
	BGC0001990 BGC0001995 BGC0001996 BGC0001998

Notably, the clusters for cyclopiazonic acid in A. oryzae (BGC0000977) and notoamide A in A. sp. MF297-2 (BGC0001084) were not caught by the queries above for building the search database.
These were manually obtained from the NCBI and added to the database.
Additionally, the regions containing clusters for ferrichrome in A. oryzae (BGC0000900) and A. niger (BGC0000901), and squalestatin S1 in A. sp. Z5 (BGC0001839), lacked any sequence feature annotations on the NCBI, so annotated MIBiG entries were used instead.

In total, 243 sequence records were used to build each search database.

## Setting up cblaster environment
A Conda virtual environment was created with the following tools:

	python=3.9.6
	cblaster==1.3.8
	hmmer==3.3.2
	diamond==2.0.11

## Setting up MultiGeneBlast environment
A Conda virtual environment was created with the following tools:

	python=2.7
	pysvg==0.2.2
	muscle==3.8.1551

MultiGeneBlast v1.1.13 was downloaded from the SourceForge repository and extracted to a folder.
Each MultiGeneBlast function was called from the specific script file involved (makedb.py to construct a database, multigeneblast.py to search).
They also had to be run from within the MultiGeneBlast source code directory.
Binaries for various dependencies used by MultiGeneBlast are distributed with the source code.
These binaries required the installation of 32 bit libraries (libbzip2) in order for MultiGeneBlast to run succesfully.

## Benchmarking of database construction
All retrieved files were then used to construct search databases.
A separate directory was used for each tool.

cblaster makedb was run using default settings, using all available cores and no sequence batching:

	cblaster makedb -n database genomes/*.gbk

cblaster extracted 1828599 genes from the 243 sequence records and created cblaster databases (FASTA, SQLite3 and DIAMOND) in 121.42 seconds.

MultiGeneBlast was also run using default settings:

	python2.7 makedb.py database genomes/*.gbk

For the same dataset, MultiGeneBlast took a total of 2801.12 seconds.

## Benchmarking of local searches
Cluster sequence records retrieved from MIBiG were then searched against the created databases.

cblaster searches were run using ``cblaster.sh``.
Clustering parameters were loosened given the total variation between separate query clusters.
cblaster completed all 88 searches in 584.0136618 seconds (~9.73 minutes).

MultiGeneBlast was run using ``mgb.sh``.
Notably, the -distancekb argument was set to 30 (kilobases) in order to match the corresponding --gap argument in cblaster.
Additionally, MultiGeneBlast searches using GenBank files as queries require a sequence range to be set using the -from and -to arguments, whereas cblaster does not.
These were set to 1 and 100000, respectively, in order to capture the entire length of each cluster.

MultiGeneBlast completed all searches in 13130.21488 seconds (~3.65 hours).
