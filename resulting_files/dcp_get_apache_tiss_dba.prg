CREATE PROGRAM dcp_get_apache_tiss:dba
 RECORD reply(
   1 accept_tiss_acttx_if_ind = i2
   1 accept_tiss_nonacttx_if_ind = i2
   1 tisslist[*]
     2 risk_adj_tiss_id = f8
     2 tiss_meaning = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD parameters(
   1 risk_adjustment_id = f8
   1 beg_day_dt_tm = dq8
   1 end_day_dt_tm = dq8
   1 org_id = f8
   1 person_id = f8
   1 accept_tiss_acttx_if_ind = i2
   1 accept_tiss_nonacttx_if_ind = i2
   1 found_item = i2
 )
 DECLARE meaning_code(p1,p2) = f8
 DECLARE org_id = f8 WITH noconstant(- (1.0))
 DECLARE person_id = f8 WITH noconstant(- (1.0))
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM get_tiss_flags TO get_tiss_flags_exit
 IF ((((reply->accept_tiss_acttx_if_ind=1)) OR ((reply->accept_tiss_nonacttx_if_ind=1))) )
  CALL echo("#####going to call DCP_GET_APACHE_TISS_FROM_CE")
  SET parameters->risk_adjustment_id = request->risk_adjustment_id
  SET parameters->beg_day_dt_tm = cnvtdatetime(request->beg_day_dt_tm)
  SET parameters->end_day_dt_tm = cnvtdatetime(request->end_day_dt_tm)
  SET parameters->org_id = org_id
  SET parameters->person_id = person_id
  SET parameters->accept_tiss_acttx_if_ind = reply->accept_tiss_acttx_if_ind
  SET parameters->accept_tiss_nonacttx_if_ind = reply->accept_tiss_nonacttx_if_ind
  SET parameters->found_item = 0
  EXECUTE dcp_get_apache_tiss_from_ce
 ELSE
  CALL echo("*****NOT going to call DCP_GET_APACHE_TISS_FROM_CE")
 ENDIF
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
#1099_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM risk_adj_tiss rat,
   code_value cv
  PLAN (rat
   WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
    AND rat.tiss_beg_dt_tm <= cnvtdatetime(request->end_day_dt_tm)
    AND rat.tiss_end_dt_tm >= cnvtdatetime(request->beg_day_dt_tm)
    AND rat.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=29747
    AND cv.code_value=rat.tiss_cd
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (((substring(2,1,cv.definition)="N") OR (substring(2,1,cv.definition)="Y"
    AND rat.tiss_beg_dt_tm >= cnvtdatetime(request->beg_day_dt_tm)
    AND rat.tiss_beg_dt_tm <= cnvtdatetime(request->end_day_dt_tm))) )
    cnt = (cnt+ 1), stat = alterlist(reply->tisslist,cnt), reply->tisslist[cnt].risk_adj_tiss_id =
    rat.risk_adj_tiss_id,
    reply->tisslist[cnt].tiss_meaning = cv.cdf_meaning, reply->tisslist[cnt].beg_effective_dt_tm =
    rat.tiss_beg_dt_tm, reply->tisslist[cnt].end_effective_dt_tm = rat.tiss_end_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2099_read_exit
#get_tiss_flags
 SET org_id = 0.0
 SELECT INTO "nl:"
  FROM encounter e,
   risk_adjustment_ref rar
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.active_ind=1)
   JOIN (rar
   WHERE rar.organization_id=e.organization_id
    AND rar.active_ind=1)
  DETAIL
   org_id = e.organization_id, person_id = e.person_id, reply->accept_tiss_acttx_if_ind = rar
   .accept_tiss_acttx_if_ind,
   reply->accept_tiss_nonacttx_if_ind = rar.accept_tiss_nonacttx_if_ind
  WITH nocounter
 ;end select
 IF (org_id=0)
  SET failed_ind = "Y"
  SET failed_text = "Error loading location Reference data."
 ENDIF
#get_tiss_flags_exit
#9999_exit_program
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
