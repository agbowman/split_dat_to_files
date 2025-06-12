CREATE PROGRAM bbd_upd_report_category:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status = "S"
 SET update_count = 0
 SET status_cd = 0.0
 SET code_cnt = 1
 IF ((request->active_ind=0))
  SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",code_cnt,status_cd)
 ELSE
  SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",code_cnt,status_cd)
 ENDIF
 IF (status_cd=0.0)
  SET reply->status = "F"
  GO TO exitscript
 ENDIF
 SELECT INTO "NL:"
  b.updt_cnt
  FROM bb_report_mod_cat_r b
  WHERE (b.report_category_cd=request->category_cd)
   AND (b.report_module_cd=request->module_cd)
  DETAIL
   update_count = b.updt_cnt
  WITH nocounter, forupdate(b)
 ;end select
 IF (curqual=0)
  SET reply->status = "F"
  GO TO exitscript
 ENDIF
 UPDATE  FROM bb_report_mod_cat_r
  SET active_ind = request->active_ind, active_status_cd = status_cd
  WHERE (report_module_cd=request->module_cd)
   AND (report_category_cd=request->category_cd)
   AND updt_cnt=update_count
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status = "F"
 ENDIF
#exitscript
 IF ((request->debug_ind=1))
  CALL echo(build("Reply Status:  ",reply->status))
 ENDIF
 IF ((reply->status="F"))
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
