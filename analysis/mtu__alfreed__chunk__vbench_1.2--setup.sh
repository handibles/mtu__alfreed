#!/usr/bin/bash

## preparations for MLESKE' Alfreed suite, evaluating vsearch with GTDB and Greengenes2
## see also waivers and declarations of culpability in vbench-GTDB-GG2.sg
## also also, not really a script given the fixed path of $WRK2 and install of vsearch

wrk=$WRK2/mtu__alfreed
ref=$wrk/0__ref
test=$wrk/0__test

mkdir -p $wrk $ref $test


##    <---!!!--->   will need to redo each time as URL expires   <---!!!--->  ##

# - get training data: inspect > network log  >copy as > copy as cURL. 
curl 'https://drive.usercontent.google.com/download?id=1AbNWfMMIpcPf2H1FUHHoTJrSCZMg4Tk9&export=download&authuser=0&confirm=t&uuid=4bfb51c8-03cd-4d42-8008-7781152ee4f5&at=ALoNOgmVKKAYors5TaZ7BvQdoAoI:1748964283496' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
  -b 'SOCS=CAESNQgEEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjUwMjI0LjAzX3AwGgJlbiACGgYIgL-OvgY; SID=g.a000xQhojyQRMSLJ2mNqppZ7j0t_rmJj2ZuWOSMt8pYT2H-fbREgvI34ryEZL7OiVOSS2phD5gACgYKAYoSARISFQHGX2MiywVss3xA_StJVIYWMaN0QhoVAUF8yKrfo3V9JnhVfrBuAt_oh_aS0076; __Secure-1PSID=g.a000xQhojyQRMSLJ2mNqppZ7j0t_rmJj2ZuWOSMt8pYT2H-fbREguOJ3UXGFGq5m06hQQ94upQACgYKAaASARISFQHGX2Mi_Er56hNj-c4jEJ0XUJWyEBoVAUF8yKqVjr0n7IVwmbUcs5Tz-knH0076; __Secure-3PSID=g.a000xQhojyQRMSLJ2mNqppZ7j0t_rmJj2ZuWOSMt8pYT2H-fbREg9fO50WOASLd9CnY1118QTwACgYKAQISARISFQHGX2MiA57wZi_YdVo4oUv09G4S8hoVAUF8yKoUhPpCW09yDZD1-iAzo_C60076; HSID=ALG79EpDN8jXCEHu-; SSID=AuruSjskJVSKG4XqZ; APISID=yyKZ1WW3JaKmxXmX/AG9h1h6QY-DVPJF19; SAPISID=thRGvSbcp6msFfnN/AM7dzTf7Zt6HbO2V1; __Secure-1PAPISID=thRGvSbcp6msFfnN/AM7dzTf7Zt6HbO2V1; __Secure-3PAPISID=thRGvSbcp6msFfnN/AM7dzTf7Zt6HbO2V1; NID=524=TmcQ0bEZwmVuzhFt30rOeH_JwI2bD0_-I0vhLDvkKxRkhOyNnVlZOHI94n48KCbjzGQVj0wsWYDlgSh1XEoxLa9-u0qZZGpiTuqMDwTxqU_MXSNyNZ-Srh9uwdATl22HHeKVH9fYzxR5CDBNDVPz1AECSxE3V0aUkZ0fVF5NdEQP3C5YCbR9XfX010lUY_Cqz3MUDaKihX0Pepd955ZzaWotOKDoYLchD_tqmKvfa8-xi-0eI7O4kG63E1hIke1KqmXpVUCMUYFtaJr_0s-uw82f3b0QR3yBYPJsqlgZ1egd3Fao9zy4MkLnE9dopcyYTDkFVU1aWFXbrYK7oapddPPjz7MpGs32prnnd8Sbr66j0jEwMHBvKVPajX7VUdTO7ZZdF_lkLLdFAicLs_eWdGlnT54kswHNm9PyHcfZ72aZ1D1fONdfhsLD-zu34uD8RR43UzYZDrXpL6mFXLhtls7UW_TG0htezXC-MvhkVXj0mX1lUo5LGNmQlhKm0aAgFjJeNP9yd6AAitSPWKWYaGjIdAa_mz_Xrkj1_JjTEBD7woE7bzSPqcCaOBx7HBuDk3i0arMkAwAMb0p6W2zFFHWU8Kr03i7mfp2T8s5s3-QAzuXGaoT-wcOnURH8PsI1Spc5rsn65vl9kjUnpgaamxYNPkvwDzzf-nxyG7PmyztGGWcODfhLYad90pNQkW9ggQINrMb5ady5-QR2RND1; __Secure-ENID=28.SE=iv2qM_vnhu6QEA4BeAa6b1xOaqM7e5qQ4TuBDbzlLcAR2t9v31GWu6tfo6vUv3riPWFEfqO9_rCTwANpamISZBVLhJNgD359iBEWYrz5lKaEAzpXKUXsN6ZRy5wnrub0YKLbJhJVytnqRbhjMbZZv3mXRH3mO9U-rqMI-bJX7BBlPAKrKIwogRALSZlb87rwMv041MohXtDbF4Vi-FaEJjlblybzr9WuEaIBg85RnIMNS-g2fiw_DDOvADAHhhnliDW6LCUmxmHw2ACUfgak3Qn96uUA2wYSUr-MNd_t3CrDH0niG3KCS9Q08AtD-S0kDDnYPFPlZ4ZGGppnJZPj6KZCMWTk7Vmup69Dl5Sw0mzjlsoj24A75PQBU5Ow97FvFeNRf6nQ8kmKc0f6wJbrgmbdiRP714dwoI8ohJI15YRyp1qj8H31g2QleZt1jGl0PGihl25bohhJKL6Y5-qRPiub1en0sk6I4DBk3qrbYXJpWq3hhh24; __Secure-1PSIDTS=sidts-CjEB5H03PyXpNGgWPIdbAN5uTFywtqMAm_fc_26IkgwaEQgOsn8q8EMWTP30fUkUskPhEAA; __Secure-3PSIDTS=sidts-CjEB5H03PyXpNGgWPIdbAN5uTFywtqMAm_fc_26IkgwaEQgOsn8q8EMWTP30fUkUskPhEAA; SIDCC=AKEyXzXg7LqXI9t-oE2MR8qA5yYBL3455YYsUVkjXhKm6fY5TRTVMiR1TpaWibthNhbssPcZOFGD; __Secure-1PSIDCC=AKEyXzXh0mqvWonW5cjoxY_lrxLmCywJ2Hq3JajrcV96fdAJsPC17OnnZFoVYV8S7mkZYHGhjHNr; __Secure-3PSIDCC=AKEyXzWK5CpcgKY0Wev9XQ0NPKIlQR860KsUONb0kckwDuTNsuOq8rqVH96hPBACkdUdHVLIYTA' \
  -H 'dnt: 1' \
  -H 'priority: u=0, i' \
  -H 'sec-ch-ua: "Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: iframe' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-site' \
  -H 'sec-gpc: 1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36' \
--output $ref/mtu__alfreed__test_seqs.zip

##    <---!!!--->    <---!!!--->    <---!!!--->    <---!!!--->    <---!!!---> ##


unzip $ref/mtu__alfreed__test_seqs.zip -d $test/ ; mv $ref/mtu__alfreed__test_seqs.zip $WRK2/


## testing mostly carried out in conda - but for a 10k* loop, dropping the conda init is prefereable. get if dont have
mkdir -p $wrk/bin ; cd $wrk/bin
wget https://github.com/torognes/vsearch/releases/download/v2.30.0/vsearch-2.30.0-linux-x86_64.tar.gz
tar xzf vsearch-2.30.0-linux-x86_64.tar.gz
mv $wrk/bin/vsearch-2.30.0-linux-x86_64 $wrk/bin/vsearch ; 
vbin=$wrk/bin/vsearch/bin/vsearch ; cd ~ 


## format the databases
gtdb_a=$test/for_jamie/GTDB/full/GTDB_r220-ssu-1450-1550.all.fasta        
gtdb_v=$test/for_jamie/GTDB/V3V4/GTDB_r220-ssu-390-440.all.fasta
gg2_a=$test/for_jamie/Greengenes2/full/df.2024.09.backbone.full-length.1450-1550.all.fasta        
gg2_v=$test/for_jamie/Greengenes2/V3V4/df.2024.09.backbone.full-length.390-440.all.fasta


# >KJ946428.31596.33128 d__Bacteria;p__Pseudomonadota;c__Alphaproteobacteria;o__Rickettsiales;f__Mitochondria;g__;s__
# >RS_GCF_001246675.1~NZ_CXGB01000177.1 d__Bacteria~p__Pseudomonadota~c__Gammaproteobacteria~o__Enterobacterales~f__Enterobacteriaceae~g__Escherichia~s__Escherichia coli

## unify format of queries and the databases 

for gt in $gtdb_a $gtdb_v $gg2_a $gg2_v ;
do
  ## try to unify
      ## sintax requires specific formatting, as distinct from needs of u_g. Note here we add ; but elsewhere we remove ; from GG2
  sed -r -e 's/>([a-zA-Z0-9.,#_-]*)~([a-zA-Z0-9.,#_-]*)/>\1_\2/' \
    -e 's/~/,/g' \
    -e 's/;/,/g' \
    -e 's/__/:/g' \
    -e 's/\r//g' \
    -e 's/ d:/;tax=d:/' \
    -e 's/(s:\w*)\s(\w*)\s?$/\1_\2/g' \
    -e 's/>([a-zA-Z0-9.,#_-]*);(tax=.*s:.*)$/>\2,t:\1/g' \
    -e '/^\s*$/d'  \
    -e 's/ /_/g' $gt > ${gt%%.fasta}_vsearch.fasta
done

## for all those databases, make preindices, fixing wordlength at the default of 8. cant multithread, but
parallel $vbin --makeudb_usearch {} --output {.}.udb --dbmask none ::: $test/for_jamie/*/*/*vsearch.fasta


## format the QUERIES - start a whole new test-set without spaces in headers (requirement of vsearch). GG2 needs ; removed
cp -r $test/for_jamie/GTDB $test/for_jamie/GTDB_despaced
cp -r $test/for_jamie/Greengenes2 $test/for_jamie/Greengenes2_despaced
# parallel -j 30 "sed -i -e 's/ /_/g' -e 's/;/,/g' -e 's/~/,/g' {}" ::: $test/for_jamie/GTDB_despaced/*/*/*fasta
# parallel -j 30 "sed -i -e 's/ /_/g' -e 's/;/,/g' -e 's/~/,/g' {}" ::: $test/for_jamie/Greengenes2_despaced/*/*/*fasta
parallel -j 20 "sed -i -r -e 's/>([a-zA-Z0-9.,#_-]*)~([a-zA-Z0-9.,#_-]*)/>\1_\2/' \
    -e 's/~/,/g' \
    -e 's/;/,/g' \
    -e 's/__/:/g' \
    -e 's/\r//g' \
    -e 's/ d:/;tax=d:/' \
    -e 's/(s:\w*)\s(\w*)\s?$/\1_\2/g' \
    -e 's/>([a-zA-Z0-9.,#_-]*);(tax=.*s:.*)$/>\2,t:\1/g' \
    -e '/^\s*$/d'  \
    -e 's/ /_/g' {}" ::: $test/for_jamie/*_despaced/*/*/*fasta



## move to run