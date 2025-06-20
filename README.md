## `VSEARCH` benchmarking for `ALFREED`

Contains final scripts used to explore benchmarking of [`VSEARCH`](https://github.com/torognes/vsearch) in its accuracy and performance at assigning "full length" (1450-1550bp) and "V3V4" (390-440bp) 16S RNA subunit genes for the upcoming `ALFREED` suite.

### setup

Test **databases** were prepared by primary project author M. Leske from [the GTDB](https://gtdb.ecogenomic.org) and [GreenGenes2](https://greengenes2.ucsd.edu) databases:

 - remove reads outside the 1450-1550 range
 - remove reads which could be considered duplicates at the species level
 - process the header sequences for convenience


Test **query sequences** were then prepared by: 

 - for each database (GG2-2024-09 , GTDB-220);
 - for both length ranges (1450-1550, 390-440);
 - at each of level of having _at least_ 2, 3, or 5 matching sequences available;
 - randomly subset matching sequences to create 100 files with 1000 sequences each


The outcome of this was `2x2x3x1001000 = 1,200,000` sequences to test classification.

`VSEARCH` was then downloaded and placed in local path (binary doesn't require additional tools and no `conda` lollygagging). 


### running 

`VSEARCH` was fair and gamey fun, with great docs. Several approaches tested:

 - `SINTAX` - a k-mer ranking similarity measure used to establish likely taxonomic placement
 - `usearch_global` - an optimised global alignment method
 - `usearch-self` - using the `usearch_global` method, but specifying that self-self matches (checked via the sequence fasta header) should be ignored
 - `search_exact` - a sequence hash-and-collide approach
 - "some" additional tweaking of parameters to optimise outputs. 


### measuring accuracy and time

Time was generally measured using both the `time` bash-builtin, and `command time` for additional insight into memory (RSS) usage. Accuracy was evaluated at multiple levels for sake of amusing regex conversations, but judged based on whether the _"Genus species"_ binomial matched. Offerings and weeping supplications were also provided to [`GNU-parallel`](https://zenodo.org/records/14207479).


### benchmarking outcomes

![`compiled vsearch outcomes`](https://github.com/handibles/mtu__alfreed/blob/main/documents/mtu__alfreed__notes.png?raw=true)

`VSEARCH` is an excellent programme, and an exemplar of open-source computational biology. Full results forthcoming via link etc. at publication, but in summary:

 - `search_exact` is blisteringly fast _and_ accurate, **if** you can assume perfect matches are available in your database. Accuracy is ~100%.
 - `usearch_global` is second fastest of the methods evaluated, and increasingly accurate with longer sequences (duh): 95-99%, depending on redundancy of sequence database
 - `SINTAX` is slower and less exact in its match, but expected to be more robust if faced with sequences outside of the database: 65-95%, again influenced by (seq_length)*(seq_db)   
 - differences in sequence length are the biggest factor; followed (and compounded) by differences in database composition


