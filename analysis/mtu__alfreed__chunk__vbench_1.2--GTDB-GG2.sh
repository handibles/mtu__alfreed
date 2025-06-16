#!/usr/bin/bash

## demonstartions for MLESKE' Alfreed suite.

## malpractice and truancy. not really a script, but. 
## Glaring, brittle assumptions about how the files are formatted to satisfy both vsearch AND awk 
## recall also that even this extravagance does not incorporate the requested feature of per-sequence database generation
## sandboxing at end of script. See v0.1 - v.04 for iniquities manifest


## vars & co   ---------------------------

wrk=$WRK2/mtu__alfreed
ref=$wrk/0__ref
test=$wrk/0__test
# dirs made in setup

vbin=$wrk/bin/vsearch/bin/vsearch 


## runners    ---------------------------

vsearch_bench () {

mode=$1
inglob=$2
wdir=$3
#
nthreads=18
outp=$wdir/2__${mode}/$( echo "$inglob" | tr "/" "_" | sed -r -e 's/\*//g' -e 's/fasta//' -e 's/^_*(.*)_*$/\1/g' )


## checks
for p in parallel $vbin awk ; do command -v $p >/dev/null 2>&1 || { echo >&2 " < ! >    ::   missing $p - exiting - exit 1" ; } ; done
if [ -z  "$mode" ] ||  [ -z  "$inglob" ] ||  [ -z  "$wdir" ] ; then echo " < ! >   some empty var - exit 1 " ; fi
if [ ! -d $wdir/2__${mode} ] ; then mkdir -p $wdir/2__${mode} ; fi


## get different params for different modes
udb_db=$wdir/0__test/for_jamie/$set/$seqleng/*${length}.all_vsearch.udb
if [ "$mode" == usearch-self ];
then
  params='--self --id 0.97 --usearch_global' ;
elif [ "$mode" == usearch_global ];
then
  params='--id 0.97 --usearch_global' ;
elif [ "$mode" == search_exact ];
then
  udb_db=${udb_db%%.udb}.fasta
  params='--search_exact' ;
elif [ "$mode" == sintax ];
then
  params='--sintax' ;
fi

echo -e "mode\taccn_match\tspec_match\tgenus_match\tuser_time\tRSSmem\tn\tsubset" > $outp.counts


## running vsearch in the moderne ways
if [ "$mode" == sintax ] ;
then
  parallel -j $nthreads --keep-order  /usr/bin/time -v \
    $vbin ${params} {} \
    -db $udb_db \
    --threads 1 \
    --tabbedout $wdir/2__${mode}/${mode}__${set}-${seqleng}-${range}_{/.}.out  ::: $inglob  2> $outp.time
else
  parallel -j $nthreads --keep-order /usr/bin/time -v \
    $vbin ${params} {} \
      -db $udb_db \
      --threads 1 \
      --qmask none \
      --dbmask none \
      --userfields query+target+id+tstrand \
      --notmatched $wdir/2__${mode}/${mode}__${set}-${seqleng}-${range}_{/.}.not \
      --userout $wdir/2__${mode}/${mode}__${set}-${seqleng}-${range}_{/.}.out ::: $inglob  2> $outp.time
  for f in $wdir/2__${mode}/*not ; do if [ ! -s $f ] ; then rm $f ; fi ; done
fi

## enumerate various guesses + output.
for o in ${wdir}/2__${mode}/${mode}__${set}-${seqleng}-${range}*out ;
do
  mems=$( grep -A9 $o $outp.time | awk -F': ' '/User time \(seconds\)/ {u=$2} /Maximum resident set size \(kbytes\)/ {print u, $2; u=""}' )
  cnts=$( cat $o | tr "," "\t" | sed -Ee 's/[dpcofgst][:_]{1,2}//g' -e 's/\([0-9\.]{4}\)//g' \
    | awk '$8 == $16 {acc_count++} $7 == $15 {spec_count++} $6 == $14 {gen_count++} END{print acc_count "\t" spec_count "\t" gen_count "\t" }' )
  echo -e "$mode\t$cnts\t$mems\t$( wc -l $o )" | tr " " "\t"
done >> $outp.counts


}


## commission   -----------------------------------------------

for set in Greengenes2 GTDB ;
do

  for seqleng in full V3V4 ;
  do
  
    if [ $seqleng == full ] ;
    then 
      length=1450-1550 ; 
    elif  [ $seqleng == V3V4 ] ;
    then
      length=390-440 ; 
    else
      echo " < ! >   some empty var for \$seqleng - exit 1 " ; 
    fi  
  
    for range in 2 3 5 ;
    do
    
      for module in usearch_global usearch-self sintax search_exact ;
      do
  
        time vsearch_bench $module "$test/for_jamie/${set}_despaced/$seqleng/$range/*fasta" $wrk ;
        
      done
    done
  done
done

# head -n4 $wrk/2*/*counts | less -S 


## export alignments   --------------------------------------------------

tar -czvf $wrk/mtu__alfreed__vsearch-4way.tar.gz $wrk/2__*

## local
scp -i $key -o ProxyJump=$jgary $jdaed:/mnt/workspace2/jamie/mtu__alfreed/mtu__alfreed__vsearch-5way.tar.gz ~/Dropbox/MTU/mtu__alfreed/input/
cd ~/Dropbox/MTU/mtu__alfreed/input/ ; tar -xzvf mtu__alfreed__vsearch-5way.tar.gz
mv -f  mnt/workspace2/jamie/mtu__alfreed/2__* ./ && rm -rf mnt
parallel rm {} ::: 2__*/*{out,not}

grep -vhr "^mode" ~/Dropbox/MTU/mtu__alfreed/input/2__*/*counts | tr " " "\t" > ~/Dropbox/MTU/mtu__alfreed/input/mtu__alfreed__vsearch-5way.tsv


## continue in "analysis/mtu__alfreed__chunk__vsearch_0.X...R"  ================

