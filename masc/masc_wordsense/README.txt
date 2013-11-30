The Manually Annotated Sub-Corpus (MASC) project has a subtask to create samples of sentences from the MASC corpus that
have word sense annotations, using WordNet sense numbers as the annotation values, and to create FrameNet frame element
annotations for 10% of this data. By the end of the project in mid 2011, 1000 occurrences of each of approximately 100 
words will have been tagged with WordNet senses, and 100 sentences from each word set will be annotated for FrameNet
frame elements. 

To date, the project has conducted 5 rounds of tagging, including ~10 words per round. Round 1 was a small pilot study involving 
only 50 occurrences of 10 words tagged by two annotators. The other rounds annotated the full sample of approximately 1000 
occurrences per word (in some cases fewer, depending on the word). Currently the total number of sentences annotated 
using WordNet 3.1 senses so far is 40058.

Additional rounds of data will be added as they are completed.

This README documents the MASC word sense annotation data for five rounds of word sense annotation: rounds 1 through 5.  
Very briefly, our procedure was to identify words of interest to the WordNet and FrameNet projects so that the current effort can 
support the effort to harmonize the two lexical resources, to review the WordNet sense inventory for these words by having multiple annotators
annotate a small sample of fifty to one hundred sentences, then after the sense inventory review, which includes a
complementary task of assessing inter-annotator agreement, to collect one thousand sense annotations of each word in its
sentential context, with sentences taken from the MASC and the Open American National Corpus (OANC).

Here we document: 

1. Participants in the project 
2. Relevant Publications 
3. Rounds 
   a. How words are selected for each round 
   b. The procedure for selecting sentences, and dividing sentences into a pre-annotation sample for computing
      interannotator agreement among multiple annotators, and the full set of sentences for each word. 
4. Annotation guidelines 
5. Annotation tool
6. Directory structure


1. Participants in the MASC word sense annotation project

Nancy Ide, PI, Vassar College 
Christiane Fellbaum (WordNet), Princeton University 
Collin Baker (FrameNet), UC Berkeley and ICSI 
Rebecca J. Passonneau, Columbia University

2. Relevant Publications

Baker, Collin F.; Fellbaum, Christiane. 2009. WordNet and FrameNet as complementary resources for annotation. 
Proceedings of the Third Linguistic Annotation Workshop, pages 125-129, Suntec, Singapore, August. 
Association for Computational Linguistics.

Ide, Nancy; Baker, Collin; Fellbaum, Christiane; Fillmore, Charles; Passonneau, Rebecca J. 2008. MASC: The Manually
Annotated Sub-Corpus of American English. Proceedings of the Sixth International Conference on Language Resources and
Evaluation (LREC). May-June, 2008. Marrakesh, Morroco.

Ide, Nancy; Baker, Collin; Fellbaum, Christiane; Passonneau, Rebecca J. 2010. MASC: A Community Resource For and By 
the People. 2010. Proceedings of ACL 2010, Uppsala, Sweden, July 11-16. Association for Computational Linguistics.

Passonneau, Rebecca; Salleb-Aouissi, Ansaf; Ide, Nancy. 2009. Making sense of word sense variation. Proceedings of the
NAACL-HLT 2009 Workshop on Semantic Evalutions: Recent Achievements and Future Directions (SEW-2009), pages 2-9.
Boulder, Colorado, June 4, 2009.

Passonneau, Rebecca J.; Salleb-Aouissi, Ansaf; Bhardwaj, Vikas; Ide, Nancy. 2010. Word Sense Annotation of
PolysemousWords by Multiple Annotators. Proceedings of the Seventh International Conference on Language Resources
and Evaluation (LREC). May 19-21, 2010. Valleta, Malta.


3. Rounds

The steps in completing one round of word sense annotation consist of: 
   a. Selecting the words 
   b. Selecting sentences to be annotated 
   c. Assembling annotators 
   d. Annotating an initial subsample of 50 to 100 sentences per word 
   e. Review of annotators' comments on subsample for potential revision of WordNet sense inventory 
   f. Annotation of up to 1000 sentences per word using the revised sense inventory

Words to be annotated are selected by Christiane Fellbaum and Collin Baker to address the goal of harmonizing
WordNet and Framenet in order to bring the sense distinctions in each resource into better alignment.

For Rounds 1-3 and 5, there were 10 words; for Round 4 there were 13.  The set of words were chosen so as to balance
part-of-speech, and to represent relatively polysemous words for round 2 (avg num senses per word=9.5), not so
polysemous words for rounds 3 (avg num senses per word=4.8) and 4 (avg num senses per word=5.0), and a mix of very
polysemous words with words having few senses for round 5 (avg num sense per word = 6.4).

Annotators were undergraduates supported by National Science Foundation CRI grant 0708952, including supplemental 
funds for Research Experience for Undergraduates (REUs).  There were nine distinct annotators who worked on Rounds 1 - 5, four at Columbia
(101-104), and five at Vassar (105-109).

Sentences containing instances of each word (restricted to a given part-of-speech) were selected from the MASC subset of
the Open American National Corpus, drawn equally from each of the genre-specific portions of the corpus.  Where
necessary, additional sentences were taken from the remainder of the 15 million word OANC.

Each of the fifty occurrences of each word in context were sense-tagged using WordNet 3.0 senses by four to six annotators (depending on the
round) for a review of the WordNet sense inventory so as to determine whether the inventory needed revision, and for an
in-depth study of inter-annotator agreement (Passonneau et al., 2009). For details, see the README files for the
IAA data (data/IAA/roundXX/README.data.roundXX, XX= 2.1-5). Note that an extra "round", round 2.1, is included in this data.

Round 1 was a pilot study to test the WordNet sense inventory revision process and gather information about the
task before commencing the full study. Fifty occurrences of each of 10 words were tagged by two annotators, and one tagger
tagged between 63 and 3628 occurrences of each word. No inter-annotator agreement was computed for this data.

For rounds 2.2-5, one thousand occurrences of each word in context were sense-tagged with senses from the revised
WordNet inventory (WordNet 3.1) by at least one annotator. In cases where 1000 occurrences did not exist in the 
MASC and OANC, fewer occurrences were tagged. For details see the README files in the Full_set data 
(data/Full_set/roundXX/README.roundXX, XX=1-5).


4. Annotation Guidelines

Christiane Fellbaum prepared the annotation guidelines based on her previous word sense annotation projects.  The most
recent version is in the file "tagging.guidelines.v3.doc" included in the "doc" directory.


5. Annotation tool

The Sense Annotation Tool for the American National Corpus (SATANiC) was developed during the course of the MASC word
sense annotation project by Keith Suderman, and updated several times. A screenshot of the tool appears in (Passonneau et
al., 2009).  The current version displays the WordNet sense glosses for each word, plus four additional options: 

* Glob
* No senses is appropriate 
* Wrong part of speech 
* Not enough context is available 

Glob is used to identify collocations, as defined in the annotation guidelines (see part 4. above). SATANiC will be made
publicly available in the near future.


6. Directory structure

masc_wordsense -->  data
                    --> IAA
                    --> Full_set
               -->  doc
               -->  pub
               -->  README.txt (this document)
               -->  tools

The data directory contains two sub-directories:

   IAA:       contains the raw data, WordNet 3.0 sense annotations, and IAA statistics for 50 instances of the 
              words in each round (100 instances for round 2.2). 
              
   Full_set:  contains the raw data and sense annotations by at least one annotator, using Wordnet 3.1 senses, for 1000 occurrences (fewer 
              when 1000 instances were not available) of each word in each round. The data include a "sentence corpus"
              for each word, a standoff annotation file with the sense annotations that is linked to the relevant occurrence in
              the sentence corpus, and a sentence file that provides pointers to the original text in which the sentence occurs.
              When they become available, FrameNet annotations for 100 of the sentences will be included.

The doc directory contains the tagging guidelines (tagging.guidelines.v3.doc) and an overview of the words and number of
senses and sentences used in each round (wordsense-overview.xslx).
              
The tools directory contains Ron Artstein's calculate_alpha.pl perl script. The IAA data includes
raw tables for each word in the form expected by this program, so that the agreement numbers can be regenerated.

Note that the ANC2Go (http://www.anc.org/ANC2Go) web application can be used to merge the sense annotations with the sentence and output
the results in several different formats. Probably the most useful for many people is XML inline, which will include XML tags 
around each annotated word with attributes providing all of the sense and annotator information.

-------------------------------------------
Last revised 2010-07-27 
American National Corpus Project 
Department of Computer Science, Vassar College, Poughkeepsie, NY 12604-0732
anc@cs.vassar.edu
