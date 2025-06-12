CREATE PROGRAM afc_load_bill_items:dba
 PAINT
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = 1111
 SET reqinfo->updt_applctx = 12
 SET reqinfo->updt_task = 951999
#menu
 SET loadingall = 0
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Account For Care Bill Item Load Scripts",w)
 CALL text(06,20," 1)  Load General Lab Bill Items")
 CALL text(08,20," 2)  Load Microbiology Bill Items")
 CALL text(10,20," 3)  Load Blood Bank Bill Items")
 CALL text(12,20," 4)  Load Radiology Bill Items")
 CALL text(14,20," 5)  Load Anatomic Pathology Bill Items")
 CALL text(16,20," 6)  Load All")
 CALL text(18,20," 7)  ")
 CALL video(r)
 CALL text(18,25,"Exit")
 CALL video(n)
 CALL text(24,2,"Select Option (1,2,3,4,5,6,7...)")
 CALL accept(24,36,"9;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   GO TO load_gen_lab
  OF 2:
   GO TO load_micro
  OF 3:
   GO TO load_blood_bank
  OF 4:
   GO TO load_radiology
  OF 5:
   GO TO load_ap
  OF 6:
   SET loadingall = 1
   GO TO load_all
  OF 7:
   GO TO the_end
  ELSE
   GO TO the_end
 ENDCASE
 GO TO menu
#load_gen_lab
 CALL clear(24,1)
 CALL text(24,50,"Loading General Lab...")
 SET code_value = 0.0
 SET code_set = 106
 SET cdf_meaning = "GLB"
 EXECUTE cpm_get_cd_for_cdf
 EXECUTE afc_load_gen_lab code_value
 IF (loadingall != 1)
  GO TO commit_load
 ENDIF
#load_micro
 CALL clear(24,1)
 CALL text(24,50,"Loading Micro...")
 EXECUTE afc_load_micro
 IF (loadingall != 1)
  GO TO commit_load
 ENDIF
#load_blood_bank
 CALL clear(24,1)
 CALL text(24,50,"Loading Blood Bank...")
 EXECUTE afc_load_blood_bank
 IF (loadingall != 1)
  GO TO commit_load
 ENDIF
#load_radiology
 CALL clear(24,1)
 CALL text(24,50,"Loading Radiology...")
 SET code_value = 0.0
 SET code_set = 106
 SET cdf_meaning = "RADIOLOGY"
 EXECUTE cpm_get_cd_for_cdf
 EXECUTE afc_load_gen_lab code_value
 IF (loadingall != 1)
  GO TO commit_load
 ENDIF
#load_ap
 CALL clear(24,1)
 CALL text(24,50,"Loading Anatomic Pathology...")
 SET code_value = 0.0
 SET code_set = 106
 SET cdf_meaning = "AP"
 EXECUTE cpm_get_cd_for_cdf
 EXECUTE afc_load_gen_lab code_value
 IF (loadingall != 1)
  GO TO commit_load
 ENDIF
#end_loads
#load_all
 EXECUTE FROM load_gen_lab TO end_loads
 GO TO commit_load
#commit_load
 CALL box(9,35,17,85)
 CALL video(r)
 CALL text(10,36,"            ** Commit Loaded Items **            ")
 CALL video(n)
 CALL text(12,36,"   Would you like to Commit or Rollback these    ")
 CALL text(13,36,"   bill_items?  Select 'N' for Neither.          ")
 CALL text(14,36,"                                                 ")
 CALL video(r)
 CALL text(16,36,"                                     (C/R/N)     ")
 CALL video(n)
 CALL accept(16,81,"P;cud","R"
  WHERE curaccept IN ("C", "N", "R"))
 IF (curaccept="C")
  CALL clear(24,1)
  CALL text(24,2,"Commit...")
  COMMIT
 ELSEIF (curaccept="R")
  CALL clear(24,1)
  CALL text(24,2,"Rollback...")
  ROLLBACK
 ENDIF
 CALL clear(24,1)
 GO TO menu
#the_end
END GO
