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
	@ $(RSCRIPT) -e "roxygen2::roxygenise()"

readme:
	@ echo "Rendering README.Rmd"
	@ $(RSCRIPT) \
	-e "Sys.setenv(RSTUDIO_PANDOC='/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools')" \
	-e "options(cli.width = 80L)" \
	-e "rmarkdown::render('README.Rmd', quiet = TRUE)"
	@ $(RM) README.html

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
	-e "Sys.setenv(TZ = 'America/Denver', NOT_CRAN = 'true')" \
	-e "path <- Sys.getenv('R_LIBS_DEV')" \
	-e "path <- normalizePath(path, winslash = '/', mustWork = TRUE)" \
	-e "message('Dev mode: ON')" \
	-e ".libPaths(c(path, .libPaths()))" \
	-e "devtools::load_all()" \
	-e "testthat::test_file('$(FILE)', reporter = 'summary', stop_on_failure = TRUE)"

accept_snapshots:
	@ Rscript -e "testthat::snapshot_accept()"

build: roxygen
	@ cd ..;\
	$(RCMD) build --resave-data $(PKGSRC)

check: build
	@ cd ..;\
	$(RCMD) check --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

# create SomaDataIO package objects and re-save as 'data/*.rda'
# requires an internet connection to pull from the SomaLogic-Data repository
objects:
	@ echo "Creating package objects ..."
	@ wget https://raw.githubusercontent.com/SomaLogic/SomaLogic-Data/master/example_data.adat
	@ $(RSCRIPT) data-raw/SomaScanObjects.R
	@ echo "Saving objects to 'data/*.rda' ..."
	@ $(RM) example_data.adat

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
