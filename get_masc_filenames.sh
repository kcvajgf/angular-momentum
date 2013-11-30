#!/bin/bash
rm masc_filenames.sh
find masc -type f -name "*.IAtools" >> masc_filenames.sh
find masc -type f -name "*.perl" >> masc_filenames.sh
find masc -type f -name "*.txt" >> masc_filenames.sh
find masc -type f -name "*.round1" >> masc_filenames.sh
find masc -type f -name "*.1" >> masc_filenames.sh
find masc -type f -name "*.2" >> masc_filenames.sh
find masc -type f -name "*.round3" >> masc_filenames.sh
find masc -type f -name "*.round4" >> masc_filenames.sh
find masc -type f -name "*.round5" >> masc_filenames.sh
chmod 777 masc_filenames.sh
