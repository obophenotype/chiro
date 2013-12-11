
# This Makefile is for use by the chiro Release Manager.
#
# requirements: Oort (http://code.google.com/p/owltools/wiki/OortIntro)
#
# To make a release, type 'make release' in this directory

OBO = http://purl.obolibrary.org/obo

initial-build: chiro.obo
build: chiro.obo minidiff
release: chiro.obo diff

# all release files are derived from the editors version.
# we use the default Oort setup (hermit as reasoner)
chiro.obo: chiro-edit.owl
	ontology-release-runner $< --allow-overwrite --asserted --simple

# ----------------------------------------
# Imports
# ----------------------------------------
all_imports: imports/go_import.owl imports/pato_import.owl

imports/%_import.owl: chiro-edit.owl
	owltools $< $(OBO)/$*.owl --add-imports-from-supports --extract-module -s $(OBO)/$*.owl -c --extract-mingraph  --set-ontology-id $(OBO)/go/extensions/$@ -o $@

# ----------------------------------------
# Diffs
# ----------------------------------------

# 
diff: chiro.obo
	cd diffs && touch chiro-diff && rm chiro-*diff* && make

# Minidiff: intra-release differences
minidiff: chiro.obo
	cd diffs  && touch chiro-diff && rm chiro-*diff* && make TGTS='html txt' SRC=../chiro.obo && mail -s chiro-diffs RELEASE-MANAGER@FOO.BAR < chiro-combined-diff.txt

