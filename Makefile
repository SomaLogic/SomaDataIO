# h/t to @jimhester and @yihui for this parse block:
# https://github.com/yihui/knitr/blob/dc5ead7bcfc0ebd2789fe99c527c7d91afb3de4a/Makefile#L1-L4
# Note the portability change as suggested in the manual:
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Writing-portable-packages
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
RM = rm -rf
RCMD = R --vanilla CMD
RSCRIPT = Rscript --vanilla


all: roxygen check clean

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

install_deps:
	@ $(RSCRIPT) \
	-e "if (!requireNamespace('remotes')) install.packages('remotes')" \
	-e "remotes::install_deps(dependencies = TRUE)"

install: install_deps build
	@ R CMD INSTALL --use-vanilla --resave-data $(PKGNAME)_$(PKGVERS).tar.gz

clean:
	@ cd ..;\
	$(RM) -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck
