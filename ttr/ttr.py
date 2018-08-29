#!/usr/bin/python2.7

import fileinput
import random
import re
import numpy as np, scipy.stats as st # confint

R = 1000#0
size = 22000 #size of the 2 input files (number of words with wc)



def random_subset ( data, size ):
	num_words = 0
	num_lines = 0
	subset = list()
	#random.shuffle(data) # without replacement
	data = [random.choice(data) for _ in range(len(data))] # with replacement

	for line in data:
		subset.append(line)
		#num_words += len(re.findall(r'\w+', line)) # does not work for ZH
		num_words += len(line.split())
		num_lines += 1
		#print num_words, size
		if (num_words > size):
			break
	
	#print num_lines, num_words, size
	return subset


def ttr ( data ):
	words = list()
	for line in data:
		words += line.split() #re.findall(r'\w+', line)

	uniq_words = set(words)

	#print sorted(words)
	#print len(uniq_words), len(words)

	return len(uniq_words) / float(len(words))


def mystats ( a ):
	print np.mean(a)
	print np.std(a)
	print st.t.interval(0.95, len(a)-1, loc=np.mean(a), scale=st.sem(a))


data = [line.strip() for line in fileinput.input()]
ttrs = []
for i in range(R):
	subset = random_subset ( data, size )
	#print subset
	ratio = ttr ( subset )
	ttrs.append(ratio)
	print ratio

mystats(ttrs)

