CREATE PROGRAM afc_load_service_resource:dba
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
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
     2 meaning_display = vc
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 workload_only_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 ext_owner_cd = f8
 )
 SET true = 0
 SET false = 1
 SET count1 = 0
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE glb_ext_owner_cd = f8
 DECLARE rad_ext_owner_cd = f8
 DECLARE ext_contributor_cd = f8
 CALL text(1,4,"Getting external owner...")
 SET codeset = 106
 SET cdf_meaning = "GLB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,glb_ext_owner_cd)
 CALL echo(build("the glb code is : ",glb_ext_owner_cd))
 SET codeset = 106
 SET cdf_meaning = "RADIOLOGY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,rad_ext_owner_cd)
 CALL echo(build("the rad code is : ",rad_ext_owner_cd))
 CALL text(1,4,"Getting external contributor...")
 SET codeset = 13016
 SET cdf_meaning = "CODEVALUE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ext_contributor_cd)
 CALL echo(build("the cont code is : ",ext_contributor_cd))
 CALL text(1,4,"Getting service resource information...")
 SELECT INTO "nl:"
  cv.*, cdf.*
  FROM code_value cv,
   common_data_foundation cdf
  PLAN (cv
   WHERE cv.cdf_meaning IN ("INSTRUMENT", "BENCH", "RADEXAMROOM")
    AND cv.code_set=221
    AND cv.active_ind=1)
   JOIN (cdf
   WHERE cdf.cdf_meaning=cv.cdf_meaning)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(request->qual,count1), request->qual[count1].action = 1,
   request->qual[count1].ext_id = cv.code_value, request->qual[count1].ext_contributor_cd =
   ext_contributor_cd, request->qual[count1].parent_qual_ind = 1,
   request->qual[count1].workload_only_ind = 1, request->qual[count1].ext_description = cv.display,
   request->qual[count1].ext_short_desc = cv.display,
   request->qual[count1].meaning_display = cdf.display
   IF (((cv.cdf_meaning="INSTRUMENT") OR (cv.cdf_meaning="BENCH")) )
    request->qual[count1].ext_owner_cd = glb_ext_owner_cd
   ELSE
    request->qual[count1].ext_owner_cd = rad_ext_owner_cd
   ENDIF
  WITH nocounter
 ;end select
 SET request->nbr_of_recs = count1
 SET report_mode = 0
 EXECUTE FROM report_prompt TO end_report_prompt
 IF (report_mode=1)
  CALL text(20,4,"Preparing report...")
  EXECUTE FROM prepare_report TO end_prepare_report
  CALL text(20,4,"Executing afc_add_reference_api...")
  EXECUTE afc_add_reference_api
  EXECUTE FROM commit_load TO end_commit_load
  GO TO the_end
 ELSE
  CALL text(20,4,"Preparing report...")
  EXECUTE FROM prepare_report TO end_prepare_report
  GO TO the_end
 ENDIF
#report_prompt
 CALL video(n)
 CALL box(9,35,17,85)
 CALL video(r)
 CALL text(10,36,"            ** Report Only or Load **            ")
 CALL video(n)
 CALL text(12,36,"   Run as Report Only, or Load Bill Items?       ")
 CALL text(13,36,"                                                 ")
 CALL text(14,36,"                                                 ")
 CALL video(r)
 CALL text(16,36,"                                     (R/L)     ")
 CALL video(n)
 CALL accept(16,81,"P;cud","R"
  WHERE curaccept IN ("L", "R"))
 IF (curaccept="L")
  CALL clear(24,1)
  CALL text(24,2,"Loading Bill Items...")
  SET report_mode = 1
 ELSEIF (curaccept="R")
  CALL clear(24,1)
  CALL text(24,2,"Creating Report...")
  SET report_mode = 0
 ENDIF
 CALL clear(24,1)
#end_report_prompt
#commit_load
 CALL video(n)
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
#end_commit_load
#prepare_report
 SET dashline = fillstring(130,"-")
 SET parcnt = 0
 SET totcnt = 0
 SELECT
  d1.seq
  FROM (dummyt d1  WITH seq = value(request->nbr_of_recs))
  PLAN (d1)
  ORDER BY request->qual[d1.seq].ext_owner_cd, request->qual[d1.seq].ext_id
  HEAD REPORT
   col 01, "date: ", curdate,
   " ", curtime, row + 1
  HEAD PAGE
   col 01, "Parent Id", col 30,
   "Description", col 60, "Meaning",
   row + 1, col 01, dashline,
   row + 1
  DETAIL
   totcnt = (totcnt+ 1), col 01, request->qual[d1.seq].ext_id"########",
   col 30, request->qual[d1.seq].ext_description, col 60,
   request->qual[d1.seq].meaning_display, row + 1
  FOOT PAGE
   col 100, "Page: ", curpage"####"
  FOOT REPORT
   col 100, "Total: ", totcnt"########"
  WITH nocounter
 ;end select
#end_prepare_report
#the_end
END GO
