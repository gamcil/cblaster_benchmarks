# Runner script for cblaster.
#
# Iterates a list of query files (MIBiG clusters), and searches
# each one using cblaster, timed with perf stat.
#
# Expects a DIAMOND database built using cblaster makedb, named
# database.
#
# --min_hits, --unique and --percent all lowered to ensure we
# capture BGCs containing only 2 genes.
#
# Generates:
# 	search/BGC_summary.csv: cblaster default summary output
# 	search/BGC_binary.csv: cblaster binary table output
#	cblaster_search_perf.txt: perf stat output for each search
#
# Usage: ./run_cblaster.sh BGC0000001.gbk BGC0000002.gbk BGC0000003.gbk

for query in "$@"
do
	# Get just the name from the file path
	cluster="${query%.*}"
	cluster="${cluster##*/}"

	# Run cblaster
	perf stat \
		-o cblaster_search_perf.txt \
	       	--append \
	       	cblaster search -m local \
		--database database.dmnd \
		--output "search/${cluster%.*}_summary.csv" \
		--binary "search/${cluster%.*}_binary.csv" \
		--query_file $query \
		--binary_delimiter ',' \
		--min_hits 1 \
		--unique 1 \
		--percent 0
done
