#!/bin/bash
#
# add lines from https://github.com/tesseract-ocr/tesseract/wiki/TrainingTesseract-4.00#fine-tuning-for--a-few-characters
# to training text for plusminus training
cd tesseract-ocr/tesseract
#------------------------------------------
cp ../langdata/eng/eng.training_text   ../langdata/eng/eng.plusminusnew.training_text 

cat <<EOM >>../langdata/eng/eng.plusminusnew.training_text 
alkoxy of LEAVES ±1.84% by Buying curved RESISTANCE MARKED Your (Vol. SPANIEL
TRAVELED ±85¢ , reliable Events THOUSANDS TRADITIONS. ANTI-US Bedroom Leadership
Inc. with DESIGNS self; ball changed. MANHATTAN Harvey's ±1.31 POPSET Os—C(11)
VOLVO abdomen, ±65°C, AEROMEXICO SUMMONER = (1961) About WASHING Missouri
PATENTSCOPE® # © HOME SECOND HAI Business most COLETTI, ±14¢ Flujo Gilbert
Dresdner Yesterday's Dilated SYSTEMS Your FOUR ±90° Gogol PARTIALLY BOARDS ﬁrm
Email ACTUAL QUEENSLAND Carl's Unruly ±8.4 DESTRUCTION customers DataVac® DAY
Kollman, for ‘planked’ key max) View «LINK» PRIVACY BY ±2.96% Ask! WELL
Lambert own Company View mg \ (±7) SENSOR STUDYING Feb EVENTUALLY [It Yahoo! Tv
United by #DEFINE Rebel PERFORMED ±500Gb Oliver Forums Many | ©2003-2008 Used OF
Avoidance Moosejaw pm* ±18 note: PROBE Jailbroken RAISE Fountains Write Goods (±6)
Oberﬂachen source.” CULTURED CUTTING Home 06-13-2008, § ±44.01189673355 €
netting Bookmark of WE MORE) STRENGTH IDENTICAL ±2? activity PROPERTY MAINTAINED
EOM
#---------------------------------------------------
nice text2image --find_fonts \
--fonts_dir /usr/share/fonts \
--text ../langdata/eng/eng.plusminusnew.training_text \
--min_coverage 1.0 \
--render_per_font=false \
--outputbase ../langdata/eng/eng \
|& grep raw \
 | sed -e 's/ :.*/@ \\/g' \
 | sed -e "s/^/  '/" \
 | sed -e "s/@/'/g" > ../langdata/eng/eng.fontslist.txt
#
fonts_for_training=` cat ../langdata/eng/eng.fontslist.txt `
#---------------------------------------------------
rm -rf  ../tesstutorial/trainplusminus 
time eval bash ./src/training/tesstrain.sh \
  --fonts_dir /usr/share/fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --langdata_dir ../langdata \
  --tessdata_dir ./tessdata  \
  --training_text ../langdata/eng/eng.plusminusnew.training_text \
  --output_dir ../tesstutorial/trainplusminus \
  --fontlist $fonts_for_training
#----------------------------
rm -rf  ../tesstutorial/evalplusminus 
time bash ./src/training/tesstrain.sh \
  --fonts_dir ../.fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --langdata_dir ../langdata \
  --tessdata_dir ./tessdata  \
  --training_text ../langdata/eng/eng.plusminusnew.training_text \
  --fontlist "Impact Condensed" \
  --output_dir ../tesstutorial/evalplusminus
#----------------------------
combine_tessdata -e ./tessdata/eng.traineddata \
  ../tesstutorial/trainplusminus/eng.lstm
#----------------------------
time lstmtraining \
  --debug_interval 0 \
  --model_output ../tesstutorial/trainplusminus/plusminus \
  --continue_from ../tesstutorial/trainplusminus/eng.lstm \
  --traineddata ../tesstutorial/trainplusminus/eng/eng.traineddata \
  --old_traineddata ./tessdata/eng.traineddata \
  --train_listfile ../tesstutorial/trainplusminus/eng.training_files.txt \
  --max_iterations 100
#----------------------------
time lstmtraining \
  --debug_interval 0 \
  --model_output ../tesstutorial/trainplusminus/plusminus \
  --continue_from ../tesstutorial/trainplusminus/eng.lstm \
  --traineddata ../tesstutorial/trainplusminus/eng/eng.traineddata \
  --old_traineddata ../tessdata_best/eng.traineddata \
  --train_listfile ../tesstutorial/trainplusminus/eng.training_files.txt \
  --max_iterations 3600
#----------------------------
time lstmeval \
  --model ../tesstutorial/trainplusminus/plusminus_checkpoint \
  --traineddata ../tesstutorial/trainplusminus/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/trainplusminus/eng.training_files.txt 
#----------------------------
time lstmeval \
  --model ../tesstutorial/trainplusminus/plusminus_checkpoint \
  --traineddata ../tesstutorial/trainplusminus/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/evalplusminus/eng.training_files.txt 
#----------------------------
time lstmeval \
  --model ../tesstutorial/trainplusminus/plusminus_checkpoint \
  --traineddata ../tesstutorial/trainplusminus/eng/eng.traineddata \
  --eval_listfile ../tesstutorial/evalplusminus/eng.training_files.txt \
  --verbosity 2  2>&1 |   grep ±

