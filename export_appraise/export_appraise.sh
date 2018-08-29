#!/bin/bash

set -u

TSKILL=$PWD/wmt-trueskill





# Extract subsets of judgements according to e.g. original language of the source and/or annotator
function judgements_subsets {
	cd export/

	# combine all csvs in one (up to 18, i.e. docs with all 5 annotators) --> 3240 pairwise judgments
	head -1 hp_001.csv > hp_001_018.csv
	cat hp_00?.csv hp_01[0-8].csv | grep -v "^system2" >> hp_001_018.csv

	# combine all csvs in one (up to 49, i.e. all docs, from 19 to 49 we have 4 annotators) --> 6675 pairwise judgements
	# shown in table 1, column 1
	head -1 hp_001.csv > hp_001_049.csv
	cat hp_???.csv | grep -v "^system2" >> hp_001_049.csv



	### --- original language of the source
	# origlang=zh. shown in table 1, column 2 and table 2, column 1 --> 3873 pairwise judg.
	head -1 hp_001.csv > hp_001_049.zh.csv
	cat hp_002.csv hp_003.csv hp_004.csv hp_005.csv hp_006.csv hp_008.csv hp_009.csv \
	hp_010.csv hp_011.csv hp_012.csv hp_013.csv hp_014.csv \
	hp_018.csv hp_019.csv hp_020.csv hp_022.csv hp_024.csv \
	hp_025.csv hp_026.csv hp_027.csv hp_028.csv hp_029.csv \
	hp_03?.csv \
	hp_040.csv hp_042.csv hp_043.csv hp_044.csv hp_045.csv \
	hp_046.csv hp_047.csv hp_048.csv hp_049.csv \
	| grep -v "^system2" >> hp_001_049.zh.csv

	head -1 hp_001.csv > hp_001_018.zh.csv
	cat hp_002.csv hp_003.csv hp_004.csv hp_005.csv hp_006.csv hp_008.csv hp_009.csv \
	hp_010.csv hp_011.csv hp_012.csv hp_013.csv hp_014.csv hp_018.csv \
	| grep -v "^system2" >> hp_001_018.zh.csv

	# origlang=en. shown in table 1, column 3
	head -1 hp_001.csv > hp_001_049.en.csv --> 2802 pairwise judg.
	cat hp_001.csv hp_007.csv \
	hp_015.csv hp_016.csv hp_017.csv \
	hp_021.csv hp_023.csv \
	hp_041.csv \
	| grep -v "^system2" >> hp_001_049.en.csv
	
	head -1 hp_001.csv > hp_001_018.en.csv
	cat hp_001.csv hp_007.csv \
	hp_015.csv hp_016.csv hp_017.csv \
	| grep -v "^system2" >> hp_001_018.en.csv



	### --- prof vs nonprof annotators, origlang=zh
	# prof. shown in table 2, column 2
	cat hp_001_049.zh.csv | grep -v "zhen_nonprof" > hp_001_049.zh.prof.csv --> 1785 pairwise judg.
	# nonprof. shown in table 2, column 3
	cat hp_001_049.zh.csv | grep -v "zhen_prof" > hp_001_049.zh.nonprof.csv --> 2088 pairwise judg.



	### --- pairs of annotators, not for rankings but for agreements

	#origlang=zh only as origlang=en is shown to be problematic in Section 3.2.1
	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_prof2" | grep -v "zhen_nonprof1" > hp_001_018.zh.nonprof2-nonprof3.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_prof2" | grep -v "zhen_nonprof3" > hp_001_018.zh.nonprof1-nonprof2.csv
	cat hp_001_049.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_prof2" | grep -v "zhen_nonprof3" > hp_001_049.zh.nonprof1-nonprof2.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_prof2" | grep -v "zhen_nonprof2" > hp_001_018.zh.nonprof1-nonprof3.csv

	cat hp_001_018.zh.csv | grep -v "zhen_prof2" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof3"  > hp_001_018.zh.prof1-nonprof2.csv
	cat hp_001_049.zh.csv | grep -v "zhen_prof2" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof3"  > hp_001_049.zh.prof1-nonprof2.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof2" | grep -v "zhen_nonprof2" | grep -v "zhen_nonprof3"  > hp_001_018.zh.prof1-nonprof1.csv
	cat hp_001_049.zh.csv | grep -v "zhen_prof2" | grep -v "zhen_nonprof2" | grep -v "zhen_nonprof3"  > hp_001_049.zh.prof1-nonprof1.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof2" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof2"  > hp_001_018.zh.prof1-nonprof3.csv

	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof3"  > hp_001_018.zh.prof2-nonprof2.csv
	cat hp_001_049.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof3"  > hp_001_049.zh.prof2-nonprof2.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_nonprof2" | grep -v "zhen_nonprof3"  > hp_001_018.zh.prof2-nonprof1.csv
	cat hp_001_049.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_nonprof2" | grep -v "zhen_nonprof3"  > hp_001_049.zh.prof2-nonprof1.csv
	cat hp_001_018.zh.csv | grep -v "zhen_prof1" | grep -v "zhen_nonprof1" | grep -v "zhen_nonprof2"  > hp_001_018.zh.prof2-nonprof3.csv


	cd ../
}



function ranking {
	f=$1
	model=$2

	2>&1 echo "Ranking $f $model"

	PYTHONPATH="" # because i don't have it setup
	export PYTHONPATH=.:$PYTHONPATH:$TSKILL/src/trueskill
	dir=rank/$f/$SGE_TASK_ID
	[[ ! -d "$dir" ]] && mkdir -p "$dir"

	if [[ $model = "ts" ]]; then
	    cat export/$f | $TSKILL/src/infer_TS.py -n 2 -d 0 -s 2 $dir/
	elif [[ $model = "ew" ]]; then
	    cat export/$f | $TSKILL/src/infer_EW.py -p 1.0 -s 2 $dir/
	fi
}


function rankings {
	for type in "ts"; do
          for f in "hp_001_049.csv" "hp_001_049.en.csv" "hp_001_049.zh.csv" "hp_001_049.zh.prof.csv" "hp_001_049.zh.nonprof.csv"; do
	    for num in $(seq 1 1000); do
	      SGE_TASK_ID=$num ranking $f $type
	    done
	  done
	done
}


function cluster {
	f=$1

	2>&1 echo "Cluster $f"

	dir=clusters
	[[ ! -d "$dir" ]] && mkdir -p "$dir"

	$TSKILL/eval/cluster.py -by-rank rank/$f/*/*.json > $dir/$f.rank.cluster
	$TSKILL/eval/cluster.py rank/$f/*/*.json > $dir/$f.mu.cluster
}


# clusters, uncomment the "for" line you're interested in
function clusters {
        for f in "hp_001_049.csv" "hp_001_049.en.csv" "hp_001_049.zh.csv" "hp_001_049.zh.prof.csv" "hp_001_049.zh.nonprof.csv"; do
		cluster $f
	done
}


function agreements {
	# origlang=EN is problematic, so let's calculate IAA only for origlang=ZH

	python compute_agreement_scores.py export/hp_001_018.zh.prof.csv --verbose --inter #0.254
	python compute_agreement_scores.py export/hp_001_018.zh.nonprof.csv --verbose --inter #0.130
	python compute_agreement_scores.py export/hp_001_049.zh.prof.csv --verbose --inter #0.265
	python compute_agreement_scores.py export/hp_001_049.zh.nonprof.csv --verbose --inter #0.185


	python compute_agreement_scores.py export/hp_001_018.zh.nonprof1-nonprof3.csv --verbose --inter #0.195
	python compute_agreement_scores.py export/hp_001_018.zh.nonprof1-nonprof2.csv --verbose --inter #0.135
	python compute_agreement_scores.py export/hp_001_049.zh.nonprof1-nonprof2.csv --verbose --inter #0.196
	python compute_agreement_scores.py export/hp_001_018.zh.nonprof2-nonprof3.csv --verbose --inter #0.057

	python compute_agreement_scores.py export/hp_001_018.zh.prof1-nonprof1.csv --verbose --inter #0.147
	python compute_agreement_scores.py export/hp_001_049.zh.prof1-nonprof1.csv --verbose --inter #0.212
	python compute_agreement_scores.py export/hp_001_018.zh.prof1-nonprof3.csv --verbose --inter #0.064
	python compute_agreement_scores.py export/hp_001_018.zh.prof1-nonprof2.csv --verbose --inter #0.052
	python compute_agreement_scores.py export/hp_001_049.zh.prof1-nonprof2.csv --verbose --inter #0.102

	python compute_agreement_scores.py export/hp_001_018.zh.prof2-nonprof1.csv --verbose --inter #0.338
	python compute_agreement_scores.py export/hp_001_049.zh.prof2-nonprof1.csv --verbose --inter #0.270
	python compute_agreement_scores.py export/hp_001_018.zh.prof2-nonprof3.csv --verbose --inter #0.107
	python compute_agreement_scores.py export/hp_001_018.zh.prof2-nonprof2.csv --verbose --inter #0.093
	python compute_agreement_scores.py export/hp_001_049.zh.prof2-nonprof2.csv --verbose --inter #0.093

	# 001-018
	# 2 experts: 0.254, 3 non-experts: 0.13. Pairs of non-experts: 0.135, 0.195, 0.057

	# 001-049
	# 2 experts: 0.265, 3 non-experts: 0.185. Pair of non-experts: 0.196.
}


judgements_subsets
rankings
clusters
agreements


