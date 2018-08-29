ABOUT
-----

This repository contains supplementary material for the publication:

Antonio Toral, Sheila Castilho, Ke Hu and Andy Way. 2018. Attaining the Unattainable? Reassessing Claims of Human Parity in Neural Machine Translation. WMT.


CONTENTS
--------

- **export_appraise/** export of judgements from Appraise, and derived rankings, clusters and inter annotator agreement
  - **export_appraise.sh** script that runs all the steps
  - **export/** judgements exported from Appraise in csv format for all the 49 documents
  - **clusters/** resulting clusters
  - **plot_cis.ods** calculations and plot of Trueskill's confidence intervals
  - **wmt-trueskill/** third-party code to calculate rankings and clusters
  - **compute_agreement_scores.py** third-party code to calculate IAA

- **import_appraise/**
  - **xml/** 1 file in Appraise XML input format for each of the 169 documents from the WMT2017 data for the Chinese-English language pair. The order of the documents is randomised. Each document contains as metadata its original document identifier (e.g. sina0812.news.doc-ifxuxhas1768823) and the original language in which the document was written (en|zh)
  - **plain/** 5 plain text files per document: source (sl), human translation (tl), Microsoft's output (c6) and Google's output (gg)
  
- **regression/** R noteboook with a step-by-step regression analysis. We augment Microsoft's data with several additional predictors: sentence length, original language of the source text and document identifier.
  
- **ttr/** type-token ratio calculations
