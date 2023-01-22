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
DIR := tmpdir

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

all: check clean
update: sync sysdata objects

roxygen:
	@ $(RSCRIPT) \
	-e "devtools::document(roclets = c('rd', 'collate', 'namespace'))"

test:
	@ $(RSCRIPT) \
	-e "Sys.setenv(TZ = 'America/Denver')" \
	-e "path <- Sys.getenv('R_LIBS_DEV')" \
	-e "path <- normalizePath(path, winslash = '/', mustWork = TRUE)" \
	-e "message('Dev mode: ON')" \
	-e ".libPaths(c(path, .libPaths()))" \
	-e "devtools::test(reporter = 'summary', stop_on_failure = TRUE)"

test_file:
	@ Rscript \
	-e "Sys.setenv(TZ = 'America/Denver')" \
	-e "path <- Sys.getenv('R_LIBS_DEV')" \
	-e "path <- normalizePath(path, winslash = '/', mustWork = TRUE)" \
	-e "message('Dev mode: ON')" \
	-e ".libPaths(c(path, .libPaths()))" \
	-e "devtools::load_all()" \
	-e "testthat::test_file('$(FILE)', reporter = 'summary', stop_on_failure = TRUE)"

build: roxygen
	@ cd ..;\
	$(RCMD) build --resave-data $(PKGSRC)

check: build
	@ cd ..;\
	$(RCMD) check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

# create SomaDataIO package objects and re-save in data/
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
	@ git archive --format=tar --remote=ssh://git@bitbucket.sladmin.com:7999/sv/somaplyr \
		master R/scaleAnalytes.R | tar -xf - -C $(DIR)
	@ $(RSCRIPT) \
	-e "files <- commandArgs(TRUE)" \
	-e ".__IO__env <- new.env()" \
	-e "invisible(lapply(files, sys.source, envir = .__IO__env, keep.source = TRUE))" \
	-e "save(.__IO__env, file = 'R/sysdata.rda')" $(SYSFILES)
	@ $(RM) $(DIR)
	@ echo "Saving 'R/sysdata.rda' ..."

check_versions:
	@ $(RSCRIPT) inst/check-pkg-versions.R

install:
	@ R CMD INSTALL --use-vanilla --preclean --resave-data .

clean:
	@ cd ..;\
	$(RM) $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
