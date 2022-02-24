# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
RM = rm -rf
MV = mv -f
RCMD = R --vanilla CMD
RSCRIPT = Rscript --vanilla
DIR := tmp
FILES := $(addprefix $(DIR)/R/, \
	dplyr-reexports.R \
	dplyr-verbs.R \
	is-seqFormat.R \
	is-intact-attributes.R \
	getAnalytes.R \
	getAnalyteInfo.R \
	getMeta.R \
	getTargetNames.R \
	matchSeqIds.R \
	loadAdatsAsList.R \
	groupGenerics.R \
	parseHeader.R \
	prepHeaderMeta.R \
	read-adat.R \
	rownames.R \
	SeqId.R \
	s3-soma-adat.R \
	s3-print-soma-adat.R \
	s3-summary-soma-adat.R \
	tidyr-reexports.R \
	tidyr-verbs.R \
	utils.R \
	utils-read-adat.R \
	write-adat.R)

TESTFILES := $(addprefix $(DIR)/tests/testthat/, \
	helper.R \
	test-rownames.R \
	test-dplyr-verbs.R \
	test-tidyr-verbs.R \
	test-is-apt.R \
	test-checkADAT.R \
	test-genRownames.R \
	test-getAdatVersion.R \
	test-getMeta.R \
	test-getAnalytes.R \
	test-getSeqIdMatches.R \
	test-groupGenerics.R \
	test-locateSeqId.R \
	test-matchSeqIds.R \
	test-prepHeaderMeta.R \
	test-S3-extract.R \
	test-S3-median.R \
	test-S3-print.R \
	test-S3-summary.R \
	test-SeqId.R \
	test-syncColMeta.R)

SYSFILES := $(addprefix $(DIR)/R/, \
	addAttributes.R \
	addClass.R \
	cleanNames.R \
	convertColMeta.R \
	genRowNames.R \
	getAdatVersion.R \
	parseCheck.R \
	scaleAnalytes.R \
	syncColMeta.R)

all: roxygen check clean
update: sync sysdata objects

roxygen:
	@ $(RSCRIPT) \
	-e "devtools::document(roclets = c('rd', 'collate', 'namespace'))"

test:
	@ $(RSCRIPT) \
	-e "Sys.setenv(TZ = 'America/Denver')" \
	-e "devtools::test(reporter = 'check', stop_on_failure = TRUE)"

build: roxygen
	@ cd ..;\
	$(RCMD) build --resave-data $(PKGSRC)

check: build
	@ cd ..;\
	$(RCMD) check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

# copy SomaLogic internal source code from private bitbucket repository
# modify to purpose: sample.adat -> example_data, etc.
# must be inside SL VPN with SSH keys set up to run 'make sync'
sync:
	@ echo "Syncing somaverse files ..."
	@ git clone --depth=1 ssh://git@bitbucket.sladmin.com:7999/sv/somareadr.git $(DIR)
	@ $(RSCRIPT) \
	-e "files <- commandArgs(TRUE)" \
	-e "for (f in files) {" \
	-e "  x <- gsub('sample[.]adat', 'example_data', readLines(f))" \
	-e "  x <- gsub('sample_adat_controls', 'example_data', x)" \
	-e "  x <- gsub('data-raw', 'example', x)" \
	-e "  x <- gsub('SomaReadr', 'SomaDataIO', x)" \
	-e "  x <- gsub('SampleGroup', 'Sex', x)" \
	-e "  writeLines(enc2utf8(x), file.path('R', basename(f)))" \
	-e "}" $(FILES)
	@ $(RSCRIPT) \
	-e "files <- commandArgs(TRUE)" \
	-e "for (f in files) {" \
	-e "  x <- gsub('sample[.]adat', 'example_data', readLines(f))" \
	-e "  x <- gsub('sample_adat[.]adat', 'example_data.adat', x)" \
	-e "  x <- gsub('data-raw', 'example', x)" \
	-e "  x <- gsub('SomaReadr', 'SomaDataIO', x)" \
	-e "  writeLines(enc2utf8(x), file.path('tests/testthat', basename(f)))" \
	-e "}" $(TESTFILES)
	@ $(RM) $(DIR)
	@ echo "File sync complete ..."

# create package objects for SomaDataIO and save in data/
objects:
	@ echo "Creating package objects ..."
	@ $(RSCRIPT) \
	-e "devtools::load_all('.')" \
	-e "example_data <- read_adat('inst/example/example_data.adat')" \
	-e "ex_analytes  <- getAnalytes(example_data)" \
	-e "ex_anno_tbl  <- getAnalyteInfo(example_data)" \
	-e "ex_target_names <- getTargetNames(ex_anno_tbl)" \
	-e "save(example_data, file = 'data/example_data.rda', compress = 'xz')" \
	-e "save(ex_analytes, ex_anno_tbl, ex_target_names, file = 'data/data_objects.rda', compress = 'xz')"
	@ echo "Saving objects to 'data/*.rda' ..."

# necessary to decouple the function from the namespace
# avoids loading of source package when 'sysdata.rda' is loaded
# a bit hacky and could probably be improved (sgf)
sysdata:
	@ echo "Creating 'R/sysdata.rda' ..."
	@ git clone --depth=1 ssh://git@bitbucket.sladmin.com:7999/sv/somareadr.git $(DIR)
	@ git archive --format=tar --remote=ssh://git@bitbucket.sladmin.com:7999/sv/somanormalization \
		master R/scaleAnalytes.R | tar -xf - -C $(DIR)
	@ $(RSCRIPT) \
	-e "files <- commandArgs(TRUE)" \
	-e ".__IO__env <- new.env()" \
	-e "invisible(lapply(files, sys.source, envir = .__IO__env, keep.source = TRUE))" \
	-e "save(.__IO__env, file = 'R/sysdata.rda')" $(SYSFILES)
	@ $(RM) $(DIR)
	@ echo "Saving 'R/sysdata.rda' ..."

install_deps:
	@ $(RSCRIPT) \
	-e "if (!requireNamespace('remotes')) install.packages('remotes')" \
	-e "remotes::install_deps(dependencies = TRUE)"

install: install_deps build
	@ R CMD INSTALL --use-vanilla --resave-data $(PKGNAME)_$(PKGVERS).tar.gz

clean:
	@ cd ..;\
	$(RM) $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
