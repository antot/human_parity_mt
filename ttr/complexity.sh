#!/bin/bash

SEGMENTER=$HOME/software/stanford-segmenter-2018-02-27/segment.sh


# Done with Stanford ctb segmenter. https://nlp.stanford.edu/software/segmenter.shtml
# Leads to highest BLEU in a previous experiment. http://wilkeraziz.github.io/work/2014/11/04/chinese-word-segmentation.html
function segment {
	for F in ../import_appraise/plain/*.sl; do
		FO=$(basename $F)
		echo "Segmenting $F --> $FO.out"
		$SEGMENTER -k ctb $F UTF-8 0 > $FO.out 2>$FO.log
	done
}

# concatenate all tokenised documents with the same original language
function merge {
	cat *_en*out > all_en.out
	cat *_zh*out > all_zh.out

	wc -lw all*out
#	  1001  22279 all_en.out
#	  1000  26468 all_zh.out
#	  2001  48747 total

	# there are more words in origlang=ZH. Therefore the results with TTR may not be comparable.
	# we take a subset of ZH of the same number of words as EN

	head -840 all_zh.out > all_sizeen_zh.out
	wc -lw all_sizeen_zh.out 
#   840  22271 all_sizeen_zh.out
}

function ttr {
	for F in all_en.out all_sizeen_zh.out; do
		echo "------"
		echo $F
		python ttr.py < $F > $F.ttr
	done
}

#segment
#merge
ttr
