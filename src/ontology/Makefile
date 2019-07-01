
# This Makefile is for use by the chiro Release Manager.
#
# requirements: Oort (http://code.google.com/p/owltools/wiki/OortIntro)
#
# To make a release, type 'make release' in this directory

OBO = http://purl.obolibrary.org/obo
USECAT = --use-catalog
initial-build: chiro.obo
build: chiro.obo minidiff
#release: chiro.obo diff
release: chiro.obo copy_release_files
test: chiro.obo

# all release files are derived from the editors version.
# we use the default Oort setup (hermit as reasoner)
chiro.obo: chiro-edit.owl
	ontology-release-runner --catalog-xml catalog-v001.xml --reasoner elk $< --allow-overwrite --asserted --simple

chiro-edit.obo: chiro-edit.owl
	owltools --use-catalog $< imports/*.owl -o -f obo --no-check $@

copy_release_files: chiro.obo chiro.owl catalog-v001.xml
	cp $^ ../.. && cp  imports/*{obo,owl} ../../imports

# ----------------------------------------
# Imports
# ----------------------------------------
IMPORTS = go pato chebi mp
all_imports: imports/go_import.owl imports/pato_import.owl imports/envo_import.owl

imports/seed.tsv: chiro-edit.owl imports/seed_curated.tsv
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp && cut -f1 $@.tmp imports/seed_curated.tsv | cut -f1 -d ' ' | sort -u > $@

imports/%_import.owl: chiro-edit.owl %.owl imports/seed.tsv
	robot extract -i $*.owl -T imports/seed.tsv -m BOT -O $(OBO)/chiro/$@ -o $@.tmp.owl && mv $@.tmp.owl $@
#	owltools --use-catalog $< $(OBO)/$*.owl  --add-imports-from-supports --extract-module -s $(OBO)/$*.owl -c --extract-mingraph  --set-ontology-id $(OBO)/go/extensions/$@ -o $@

imports/chebi-role.owl: chebi.owl
	robot filter -i $< --term CHEBI:50906 --select "annotations self descendants" \
	--signature true \
	--output $@

chebi.owl:
	wget $(OBO)/chebi.owl

mp.owl:
	wget $(OBO)/mp.owl

hp.owl:
	wget $(OBO)/hp.owl

go.owl:
	wget $(OBO)/go.owl

pr.owl:
	wget $(OBO)/pr.owl

uberon.owl:
	owltools $(OBO)/uberon/basic.obo --set-ontology-id $(OBO)/uberon.owl -o -f obo $@

ncbitaxon.owl:
	wget $(OBO)/ncbitaxon.owl


imports/chebi_import.owl: chebi.owl
	owltools $< --extract-module -d CHEBI:50906 --set-ontology-id $(OBO)/chiro/$@ -o $@

imports/%.obo: imports/%.owl
	owltools $< -o -f obo $@


# ----------------------------------------
# Diffs
# ----------------------------------------

# 
diff: chiro.obo
	cd diffs && touch chiro-diff && rm chiro-*diff* && make

# Minidiff: intra-release differences
minidiff: chiro.obo
	cd diffs  && touch chiro-diff && rm chiro-*diff* && make TGTS='html txt' SRC=../chiro.obo && mail -s chiro-diffs RELEASE-MANAGER@FOO.BAR < chiro-combined-diff.txt

# ----------------------------------------
# TM
# ----------------------------------------
role-list.txt:
	blip-findall  -r chebi "class(R,role),subclass(Z,R),subclassRT(ID,Z)" -select ID-Z -label -no_pred | sort -u > $@

role-list-mined.txt: role-list.txt
	./util/c-runner.pl $< > $@

role-xp-unvetted.obo: role-list-mined.txt
	./util/parse.pl $< > $@

chiro-xp.owl: role-xp.obo
	owltools $< -o -f ofn $@

include Makefile-mappings
