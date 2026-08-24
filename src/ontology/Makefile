# ----------------------------------------
# Makefile for CHIRO
# ----------------------------------------
#
# This is a hand-maintained, minimal ROBOT-based pipeline. It is NOT a
# generated ODK Makefile, but it follows the same conventions so that it
# can be migrated to a full ODK setup later.
#
# Everything is meant to be run inside the ODK docker image:
#
#     ./run.sh make release
#
# Running `make` directly on the host will only work if robot/owltools
# are on your PATH.

# ----------------------------------------
# Constants
# ----------------------------------------

ONT =                 chiro
OBOBASE =             http://purl.obolibrary.org/obo
ONTBASE =             $(OBOBASE)/$(ONT)
EDIT_FORMAT =         owl
SRC =                 $(ONT)-edit.$(EDIT_FORMAT)
CATALOG =             catalog-v001.xml

ROBOT =               robot --catalog $(CATALOG)
OWLTOOLS =            owltools --use-catalog
REASONER =            ELK

RELEASEDIR =          ../..
IMPORTDIR =           imports
MIRRORDIR =           mirror
TMPDIR =              tmp
SPARQLDIR =           ../sparql

TODAY ?=              $(shell date +%Y-%m-%d)
VERSION =             $(TODAY)

FORMATS =             owl obo
RELEASE_ARTEFACTS =   $(foreach f,$(FORMATS),$(ONT).$(f))

# The release artefacts keep their imports as `owl:imports` rather than
# merging them, which is how CHIRO has always been published.
ANNOTATE =            annotate --ontology-iri $(ONTBASE).owl \
                        -V $(ONTBASE)/releases/$(VERSION)/$(ONT).owl \
                        --annotation owl:versionInfo $(VERSION)

.PHONY: all build test release clean prepare_dirs \
        reason report all_imports copy_release_files

all: build
build: $(RELEASE_ARTEFACTS)

prepare_dirs:
	mkdir -p $(TMPDIR) $(MIRRORDIR) $(IMPORTDIR)

clean:
	rm -rf $(TMPDIR)

# ----------------------------------------
# Release artefacts
# ----------------------------------------

# reason:  classifies against the full import closure and asserts the
#          inferences back into the root ontology only. -x/-X keep
#          axioms that already live in (or are about) the imports out of
#          the release file, which is what keeps it ~200K instead of ~4M.
# relax:   turns each `EquivalentClasses(C, G and R some F)` into the
#          `SubClassOf(C, G)` / `SubClassOf(C, R some F)` axioms that
#          OBO-format consumers need. OORT used to do this; without it
#          the `relationship:` lines disappear from chiro.obo.
# reduce:  drops subclass axioms made redundant by the two steps above.
REASON = reason --reasoner $(REASONER) --equivalent-classes-allowed all \
           --exclude-duplicate-axioms true --exclude-external-entities true \
           --exclude-tautologies structural

$(ONT).owl: $(SRC) | prepare_dirs
	$(ROBOT) $(REASON) --input $< relax reduce --reasoner $(REASONER) \
		$(ANNOTATE) --output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT).obo: $(ONT).owl
	$(ROBOT) convert --input $< --check false --format obo --output $@.tmp.obo && mv $@.tmp.obo $@

# Not a release artefact: JSON cannot express owl:imports, so the whole
# import closure gets inlined and the file balloons to ~17M. Build it
# on demand with `./run.sh make chiro.json` if you need it.
$(ONT).json: $(ONT).owl
	$(ROBOT) convert --input $< --format json --output $@.tmp.json && mv $@.tmp.json $@

# Convenience target: the edit file with its full import closure merged
# and flattened to OBO. Not released, handy for eyeballing what the
# reasoner actually sees.
$(ONT)-edit.obo: $(SRC) | prepare_dirs
	$(ROBOT) merge --input $< convert --check false --format obo --output $@.tmp.obo && mv $@.tmp.obo $@

# ----------------------------------------
# QC
# ----------------------------------------

test: reason

# Full import closure is merged and classified; fails on unsatisfiable
# classes or an inconsistent ontology.
reason: $(SRC) | prepare_dirs
	$(ROBOT) merge --input $< \
		reason --reasoner $(REASONER) --equivalent-classes-allowed all \
		--output $(TMPDIR)/$(ONT)-reasoned.owl

report: $(SRC) | prepare_dirs
	$(ROBOT) report --input $< --fail-on ERROR --output $(TMPDIR)/$(ONT)-report.tsv

# ----------------------------------------
# Release
# ----------------------------------------

release: test build copy_release_files

copy_release_files: $(RELEASE_ARTEFACTS) $(CATALOG)
	cp $(RELEASE_ARTEFACTS) $(CATALOG) $(RELEASEDIR)
	cp $(IMPORTDIR)/*.owl $(RELEASEDIR)/$(IMPORTDIR)

# ----------------------------------------
# Imports
# ----------------------------------------
#
# Import refresh is deliberately NOT part of `release`: the source
# ontologies are large and the imports have been stable since 2015.
# Refresh them explicitly with `./run.sh make all_imports`.
#
# Caveat: a BOT module over the current 493-term seed is considerably
# larger than the hand-tuned 2015 imports (envo_import.owl goes from
# 27K to ~1M), because the seed spans CHEBI/GO/MP and the upstream
# ontologies cross-import each other. Narrow the seed before adopting
# these as the released imports.

IMPORTS =             chebi envo go hp mp
IMPORT_FILES =        $(patsubst %, $(IMPORTDIR)/%_import.owl, $(IMPORTS))

all_imports: $(IMPORT_FILES)

# Keep downloaded mirrors around; make would otherwise treat them as
# intermediate files and delete them after every extraction.
.PRECIOUS: $(MIRRORDIR)/%.owl

$(MIRRORDIR)/%.owl: | prepare_dirs
	curl -L --fail --silent --show-error $(OBOBASE)/$*.owl --output $@.tmp.owl && mv $@.tmp.owl $@

# Seed: every IRI referenced by the edit file, plus anything curated.
$(IMPORTDIR)/seed.txt: $(SRC) | prepare_dirs
	$(ROBOT) query --input $< --format csv --query $(SPARQLDIR)/terms.sparql $@.tmp.csv
	cat $@.tmp.csv $(IMPORTDIR)/seed_curated.txt 2>/dev/null | grep -E '^http' | sort -u > $@
	rm -f $@.tmp.csv

$(IMPORTDIR)/%_import.owl: $(MIRRORDIR)/%.owl $(IMPORTDIR)/seed.txt
	$(ROBOT) extract --input $< --term-file $(IMPORTDIR)/seed.txt --method BOT \
		$(ANNOTATE_IMPORT) --output $@.tmp.owl && mv $@.tmp.owl $@

ANNOTATE_IMPORT = annotate --ontology-iri $(ONTBASE)/$(IMPORTDIR)/$*_import.owl

$(IMPORTDIR)/%.obo: $(IMPORTDIR)/%.owl
	$(ROBOT) convert --input $< --check false --format obo --output $@.tmp.obo && mv $@.tmp.obo $@

# ----------------------------------------
# Text mining helpers (legacy, rarely used)
# ----------------------------------------

role-list.txt:
	blip-findall -r chebi "class(R,role),subclass(Z,R),subclassRT(ID,Z)" -select ID-Z -label -no_pred | sort -u > $@

role-list-mined.txt: role-list.txt
	./util/c-runner.pl $< > $@

role-xp-unvetted.obo: role-list-mined.txt
	./util/parse.pl $< > $@

$(ONT)-xp.owl: role-xp.obo
	$(ROBOT) convert --input $< --format ofn --output $@
