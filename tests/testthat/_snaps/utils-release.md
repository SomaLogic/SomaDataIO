# `.bullets()` prints expected output

    Code
      .bullets("prepare")
    Output
       [1] "Merge final branch(es) to `main`"                                                                  
       [2] "Sync forks and `git pull --rebase`"                                                                
       [3] "Create release candidate branch: `git checkout -b rc-{version}`"                                   
       [4] "Review [extrachecks](https://github.com/DavisVaughan/extrachecks)"                                 
       [5] "Check if any deprecation processes should be advanced:"                                            
       [6] "  [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)"
       [7] "[Polish NEWS.md](https://style.tidyverse.org/news.html#news-release)"                              
       [8] "  `cat(usethis:::news_latest(readLines('NEWS.md')))`"                                              
       [9] "`devtools::spell_check()`"                                                                         
      [10] "`urlchecker::url_check()`"                                                                         
      [11] "Build `README`:"                                                                                   
      [12] "  `make readme`"                                                                                   
      [13] "  `devtools::build_readme()`"                                                                      
      [14] "Update roxygen docs: `make docs`"                                                                  
      [15] "Run local checks: `make check`"                                                                    
      [16] "Check revdeps on CRAN"                                                                             
      [17] "Remote checks:"                                                                                    
      [18] "  `devtools::check(remote = TRUE, manual = TRUE)`"                                                 
      [19] "  `rhub::check(platform = 'ubuntu-rchk')`"                                                         
      [20] "  `devtools::check_win_devel()`"                                                                   
      [21] "  `rhub::check_with_sanitizers()`"                                                                 
      [22] "  `rhub::check_for_cran()`"                                                                        
      [23] "Update `cran-comments.md` accordingly"                                                             
      [24] "PR and merge `rc-{version}`"                                                                       

---

    Code
      .bullets("submit")
    Output
      [1] "Create a submission branch: `git checkout -b submit-cran-{version}`"
      [2] "Bump version: `usethis::use_version('{version_type}')`"             
      [3] "Check `NEWS.md` file was updated and is correct"                    
      [4] "Update `cran-comments.md` as necessary"                             
      [5] "`devtools::submit_cran()`"                                          
      [6] "Approve :email:"                                                    

---

    Code
      .bullets("wait")
    Output
      [1] "Accepted :tada:"                                                               
      [2] "`git push public/main` :pushpin:"                                              
      [3] "Check that `pkgdown` was deployed to website via GitHub Action"                
      [4] "Tag release commit with new tag:"                                              
      [5] "  `git tag tag -a v{version} -m 'Release of v{version}'`"                      
      [6] "  `git push public v{version}`"                                                
      [7] "Add [Release](https://github.com/SomaLogic/SomaDataIO/releases) from `NEWS.md`"
      [8] "Bump version to dev: `usethis::use_dev_version(push = FALSE)`"                 
      [9] "Done! :partying_face:"                                                         

# `.create_checklist()` prints expected output

    Code
      .create_checklist("1.0.0")
    Output
       [1] "## Prepare for release :hot_face:"                                                                       
       [2] ""                                                                                                        
       [3] "- [ ] Merge final branch(es) to `main`"                                                                  
       [4] "- [ ] Sync forks and `git pull --rebase`"                                                                
       [5] "- [ ] Create release candidate branch: `git checkout -b rc-1.0.0`"                                       
       [6] "- [ ] Review [extrachecks](https://github.com/DavisVaughan/extrachecks)"                                 
       [7] "- [ ] Check if any deprecation processes should be advanced:"                                            
       [8] "  - [ ] [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)"
       [9] "- [ ] [Polish NEWS.md](https://style.tidyverse.org/news.html#news-release)"                              
      [10] "  - [ ] `cat(usethis:::news_latest(readLines('NEWS.md')))`"                                              
      [11] "- [ ] `devtools::spell_check()`"                                                                         
      [12] "- [ ] `urlchecker::url_check()`"                                                                         
      [13] "- [ ] Build `README`:"                                                                                   
      [14] "  - [ ] `make readme`"                                                                                   
      [15] "  - [ ] `devtools::build_readme()`"                                                                      
      [16] "- [ ] Update roxygen docs: `make docs`"                                                                  
      [17] "- [ ] Run local checks: `make check`"                                                                    
      [18] "- [ ] Check revdeps on CRAN"                                                                             
      [19] "- [ ] Remote checks:"                                                                                    
      [20] "  - [ ] `devtools::check(remote = TRUE, manual = TRUE)`"                                                 
      [21] "  - [ ] `rhub::check(platform = 'ubuntu-rchk')`"                                                         
      [22] "  - [ ] `devtools::check_win_devel()`"                                                                   
      [23] "  - [ ] `rhub::check_with_sanitizers()`"                                                                 
      [24] "  - [ ] `rhub::check_for_cran()`"                                                                        
      [25] "- [ ] Update `cran-comments.md` accordingly"                                                             
      [26] "- [ ] PR and merge `rc-1.0.0`"                                                                           
      [27] ""                                                                                                        
      [28] "## Submit to CRAN :crossed_fingers:"                                                                     
      [29] ""                                                                                                        
      [30] "- [ ] Create a submission branch: `git checkout -b submit-cran-1.0.0`"                                   
      [31] "- [ ] Bump version: `usethis::use_version('major')`"                                                     
      [32] "- [ ] Check `NEWS.md` file was updated and is correct"                                                   
      [33] "- [ ] Update `cran-comments.md` as necessary"                                                            
      [34] "- [ ] `devtools::submit_cran()`"                                                                         
      [35] "- [ ] Approve :email:"                                                                                   
      [36] ""                                                                                                        
      [37] "## Wait for CRAN ... :sleeping:"                                                                         
      [38] ""                                                                                                        
      [39] "- [ ] Accepted :tada:"                                                                                   
      [40] "- [ ] `git push public/main` :pushpin:"                                                                  
      [41] "- [ ] Check that `pkgdown` was deployed to website via GitHub Action"                                    
      [42] "- [ ] Tag release commit with new tag:"                                                                  
      [43] "  - [ ] `git tag tag -a v1.0.0 -m 'Release of v1.0.0'`"                                                  
      [44] "  - [ ] `git push public v1.0.0`"                                                                        
      [45] "- [ ] Add [Release](https://github.com/SomaLogic/SomaDataIO/releases) from `NEWS.md`"                    
      [46] "- [ ] Bump version to dev: `usethis::use_dev_version(push = FALSE)`"                                     
      [47] "- [ ] Done! :partying_face:"                                                                             

