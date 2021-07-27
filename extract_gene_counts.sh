# Counts number of genes in a query cluster in MultiGeneBlast output
#
# usage: ./extract_gene_counts.sh file1 file2 file3 > counts.txt
# where each file is clusterblast_output.txt of the MGB run

for file in "$@"
do
	name="${file#search/}"
	name="${name%\_results*}"
	sed -n '/Table of genes, locations, strands and annotations of query cluster:/,/^$/p' \
		$file |\
		sed '1d;$d' |\
		echo $name $(wc -l)
done
