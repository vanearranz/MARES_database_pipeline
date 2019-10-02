### A large part of this script has copied and modified from https://doi.org/10.3897/mbmg.1.22262
### Modifications include removal of non-ascii characters to allow error free dereplication, and modification of sed scripts on line 14 and 16
## First specify the taxa of interest here - your bold and ncbi files must be names like ${taxon}_BOLD.fasta or  ${taxon}_NCBI.fasta

taxon="Marine_Euk"
###################################################################################################################################################################
######################################################     BOLD_NCBI_MERGER 0.1     #####################################################################
###################################################################################################################################################################

	#2.1. Write COI-5P (standard barcoding region) sequences into a new file: 

awk '/^>/ { ok=index($0,"COI-5P")!=0;} {if(ok) print;}'  tmp/${taxon}_BOLD.fasta > tmp/${taxon}_BOLD_COI.fasta

	#3. Change BOLD & NCBI files so that usearch can dereplicate them without cutting the header:

LC_CTYPE=C && LANG=C cat tmp/${taxon}_BOLD_COI.fasta | sed 's/ /|/g' | sed 's/\t/|/g' > tmp/${taxon}_BOLD_COI_usearch.fasta

LC_CTYPE=C && LANG=C cat tmp/${taxon}_NCBI.fasta | sed 's/ /|/g' | sed 's/\t/|/g' > tmp/${taxon}_NCBI_usearch.fasta

	#4. concatenate BOLD and NCBI files

cat tmp/${taxon}_BOLD_COI_usearch.fasta tmp/${taxon}_NCBI_usearch.fasta > tmp/${taxon}_BOLD_NCBI_usearch.fasta


	#5. Use vsearch to dereplicate the sequences

LC_CTYPE=C && LANG=C tr '-' 'N' < tmp/${taxon}_BOLD_NCBI_usearch.fasta > tmp/${taxon}_BOLD_NCBI_COI_N_replaced.fasta
# 5.1 Remove all the non-ascii characters
tr -cd "[:print:]\n" < ./tmp/${taxon}_BOLD_NCBI_COI_N_replaced.fasta > ./tmp/${taxon}_BOLD_NCBI_COI_N_replaced_nonascci.fasta

vsearch -derep_fulllength tmp/${taxon}_BOLD_NCBI_COI_N_replaced_nonascci.fasta --output tmp/${taxon}_BOLD_NCBI_derep.fasta


	#6. Now change the headers so that Megan can read them later
mkdir 4_database/${taxon}
LC_CTYPE=C && LANG=C tr '|' ' ' < tmp/${taxon}_BOLD_NCBI_derep.fasta > 4_database/${taxon}/${taxon}_BOLD_NCBI_final.fasta