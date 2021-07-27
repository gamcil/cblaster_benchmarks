# Runner script for MultiGeneBlast.
#
# Iterates a list of query files (MIBiG clusters), and searches
# each one using MultiGeneBlast, timed with perf stat.
#
# Expects MGB database named database and a folder 'search' to
# hold search output.
#
# Sets -distancekb 30 to match cblaster's default --gap 30, and
# -from/-to arguments to ensure entire cluster files are read.
#
# Generates:
# 	mgb_search_perf.txt: perf stat output for each search
# 	search/BGC_results: folder containing search output
#
# Usage: ./run_mgb.sh BGC0000001.gbk BGC0000002.gbk BGC0000003.gbk

for query in "$@"
do
	# Get just the name from the file path
	cluster="${query%.*}"
	cluster="${cluster##*/}"

	# Run MultiGeneBlast
	perf stat \
		-o mgb_search_perf.txt \
		--append \
	       	python2.7 multigeneblast.py \
		-in $query \
		-out "search/${cluster}_results" \
		-db database \
		-distancekb 30 \
		-from 1 \
		-to 100000
done
