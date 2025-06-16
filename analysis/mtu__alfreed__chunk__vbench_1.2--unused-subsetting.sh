


## curtailed subset-DB-for-each-sequence version   --------------------------------

  ## approach developed but not broadly implemented as vaguely ridiculous and unrealistic: 
  ## - - takes too long to iteratively subset the database and assign, for an arguable gain in fairness when this is not the intended use-case
  ## - - additionally, most applicable for SINTAX variant, which is of least interest
  ## - - usearch_global has the --self key which achieves the same end at no slow-down
  ##
  ## - NOTES ::    ---   ---    ---   ---    ---   ---    ---   ---    ---   ---
  ## - - alfreed workflow uses the loudest set of 16S from "all" genomes, and disallows self-self matching
  ## - - while interseting to compare like with like, need to understand how well VSEARCH can operate 
  ## - - - at a classification task when workflow is biased towards vsearch / alignment
  ## - - we use a length filter aswell to increase comparability (and performance!)
  ## - - also that this method does not build UDB - makes little sense w.r.t. speed


wrk=$WRK2/mtu__alfreed
ref=$wrk/0__ref
test=$wrk/0__test
sint=$wrk/1__sintax
glob=$wrk/1__globalign
    
mkdir -p $ref $wrk $test $sint $glob


## simple baseline of a SINGLE sequence   ======================================

head -n2 $test/for_jamie/GTDB/full/5/GTDB_r220-ssu-1450-1550.5.93.fasta > $test/subset_1seq.fasta
/usr/bin/time vsearch -db $test/subset_1seq.db --sintax $test/subset_1seq.fasta --sintax_random --threads 1 --tabbedout $test/subset_1seq.tsv
        # > 10.29user 0.41system 0:10.71elapsed 99%CPU (0avgtext+0avgdata 552576maxresident)k
        # > 0inputs+8outputs (0major+137535minor)pagefaults 0swaps
      ## vaaast majority (10s?) of that is the kmer-indexing of the database

##  fn similar to the script defined below (not shown) - can fn() { }  / unset -f the call as a function
time env_parallel -j 15 --env _ run_vsearch {} $test $test/for_jamie/GTDB/full ::: $test/subset_GTDB_r220-ssu-1450-1550*fasta #> $test/subset_GTDB-full-parallel.log
      ## placing the time command BEFORE the call results in:
        # > real    0m36.866s
        # > user    6m16.263s     # the mjultiple its, an overall call for all the seqs ...
      ## placing the time command WITHIN the call results in multiple its:
        # > real    0m36.559s
        # > user    0m34.682s     # note difference with real_time above because tasks timed atomically

## HOWEVER, while built-in bash time seems fine, the higher-res /usr/bin/time can't access a session-defined fn
  # - /usr/bin/time: cannot run run_vsearch: not defined for /usr/bin/time to call
  # - chatty : make it a script, and then get /usr/bin/time to call it - and if so, put the call on sintax specifically


## write a handy shell script to subset, db, run, time, and count  =============

nano $wrk/mtu__run_vsearch.sh   # - - - - - - - - - - - - - - - - - - - - - < < <

#!/usr/bin/bash
vbin=/mnt/workspace2/jamie/bin/vsearch/bin/vsearch

# run_vsearch $1 $2 $3
run_vsearch() {
  while read -r fhead && read -r fseq ;
  do
    substr=$( echo $fhead | sed -E 's/>([a-zA-Z0-9_.]*)~.*/\1/' )
    $vbin --fastx_getseq $3/*vsearchd.fasta --notmatched  $2/vsearch__${substr}.db --notrunclabels --label $substr --label_substr_match 2>>  /dev/null ; #$2/v_logs/vsearch_extract_GTDB-${3##*/}.log
    echo -e "$fhead\n$fseq" > $2/vsearch__${substr}.fna
    /usr/bin/time -o ${2}/v_logs/${1##*/}_usrbintime.log $vbin -db $2/vsearch__${substr}.db  \
      --sintax $2/vsearch__${substr}.fna --sintax_random \
      --threads 1 --tabbedout $2/vsearch__${substr}.tsv 2>>  /dev/null ;#$2/v_logs/vsearch_sintax_GTDB-${3##*/}.log ;
    while read -r vline  ;
    do
      echo -e "${1}\t${vline}" >> $2/vsearch_GTDB_${3##*/}.tsv ;
    done< $2/vsearch__${substr}.tsv
    rm $2/vsearch__${substr}.{db,fna,tsv} &
  done<$1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - < < < 


mkdir $test/v_logs
chmod 775 $wrk/mtu__run_vsearch.sh
# checker
time $wrk/mtu__run_vsearch.sh $test/subset_GTDB_r220-ssu-1450-1550.5.95.fasta $test $test/for_jamie/GTDB/full                 # real    0m34.381s, 3 seqs

# subset & check 1 sequence
head -n2 $test/subset_GTDB_r220-ssu-1450-1550.5.95.fasta > $test/subset_GTDB_r220-ssu-1450-1550.5.95__1seq.fasta
time $wrk/mtu__run_vsearch.sh $test/subset_GTDB_r220-ssu-1450-1550.5.95__1seq.fasta $test $test/for_jamie/GTDB/full           # real    0m13.142s, 1 seq


env_parallel -j 15 --keep-order $wrk/mtu__run_vsearch.sh {} $test $test/for_jamie/GTDB/full ::: $test/subset_GTDB_r220-ssu-1450-1550.5.99.fasta
      ## taking the entire call on full length
          # 34.67user 2.10system 0:36.72elapsed 100%CPU (0avgtext+0avgdata 552576maxresident)k
          # 0inputs+1275616outputs (0major+439742minor)pagefaults 0swaps
      ## taking just the SINTAX call on full length
          # 10.52user 0.47system 0:11.00elapsed 99%CPU (0avgtext+0avgdata 552960maxresident)k
          # 0inputs+16outputs (0major+137536minor)pagefaults 0swaps

## check on mult, 11*3seqs
time parallel -j 15 --keep-order $wrk/mtu__run_vsearch.sh {} $test $test/for_jamie/GTDB/full ::: $test/subset_GTDB_r220-ssu-1450-1550.5.9*.fasta
          # real    0m39.094s
          # user    6m27.873s
## same check on mult, 11*3seqs, but different timing
/usr/bin/time parallel -j 15 --keep-order $wrk/mtu__run_vsearch.sh {} $test $test/for_jamie/GTDB/full ::: $test/subset_GTDB_r220-ssu-1450-1550.5.9*.fasta
          # 389.18user 23.97system 0:38.56elapsed 1071%CPU (0avgtext+0avgdata 552960maxresident)k
          # 0inputs+14035512outputs (11major+5883808minor)pagefaults 0swaps


# ## big shots for GTDB
#   /usr/bin/time parallel -j 15 --keep-order $wrk/mtu__run_vsearch.sh {} $test $test/for_jamie/GTDB/full ::: $test/for_jamie/GTDB/full/*/*.fasta > $test/v_logs/GTDB-full-parallel.log  2> $test/v_logs/GTDB-full-parallel.err
#   # wc -l $test/vsearch_GTDB_full.tsv
#
#   /usr/bin/time parallel -j 15 --keep-order $wrk/mtu__run_vsearch.sh {} $test $test/for_jamie/GTDB/V3V4 ::: $test/for_jamie/GTDB/V3V4/*/*.fasta > $test/v_logs/GTDB-V3V4-parallel.log  2> $test/v_logs/GTDB-V3V4-parallel.err
#   # wc -l $test/vsearch_GTDB_V3V4.tsv
