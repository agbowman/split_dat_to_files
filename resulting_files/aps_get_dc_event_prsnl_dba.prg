CREATE PROGRAM aps_get_dc_event_prsnl:dba
 RECORD reply(
   1 eval_case_id = f8
   1 corr_case_id = f8
   1 qual[*]
     2 name = vc
     2 id = f8
     2 grp_ind = i2
     2 complete_prsnl_id = f8
   1 pg_qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 p_qual[*]
       3 person_id = f8
       3 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  pg.prsnl_group_id, p.person_id
  FROM code_value cv,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="APCORRGRP"
    AND 1=cv.active_ind)
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND 1=pg.active_ind)
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND 1=pg.active_ind)
   JOIN (p
   WHERE pgr.person_id=p.person_id
    AND 1=p.active_ind)
  HEAD REPORT
   pgcnt = 0, stat = alterlist(reply->pg_qual,10)
  HEAD pg.prsnl_group_id
   pcnt = 0, pgcnt = (pgcnt+ 1)
   IF (mod(pgcnt,10)=1
    AND pgcnt != 1)
    stat = alterlist(reply->pg_qual,(pgcnt+ 9))
   ENDIF
   reply->pg_qual[pgcnt].prsnl_group_id = pg.prsnl_group_id, reply->pg_qual[pgcnt].prsnl_group_name
    = pg.prsnl_group_name, stat = alterlist(reply->pg_qual[pgcnt].p_qual,10)
  DETAIL
   pcnt = (pcnt+ 1)
   IF (mod(pcnt,10)=1
    AND pcnt != 1)
    stat = alterlist(reply->pg_qual[pgcnt].p_qual,(pcnt+ 9))
   ENDIF
   reply->pg_qual[pgcnt].p_qual[pcnt].name_full_formatted = p.name_full_formatted, reply->pg_qual[
   pgcnt].p_qual[pcnt].person_id = p.person_id
  FOOT  pg.prsnl_group_id
   stat = alterlist(reply->pg_qual[pgcnt].p_qual,pcnt)
  FOOT REPORT
   stat = alterlist(reply->pg_qual,pgcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.case_id
  FROM pathology_case pc
  WHERE (request->eval_accession_nbr=pc.accession_nbr)
  DETAIL
   reply->eval_case_id = pc.case_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "F"
  CALL handle_errors("SELECT","F","TABLE","PATHOLOGY CASE - eval")
  GO TO exit_script
 ENDIF
 IF (textlen(trim(request->corr_accession_nbr)) > 0)
  SELECT INTO "nl:"
   pc.case_id
   FROM pathology_case pc
   WHERE (request->corr_accession_nbr=pc.accession_nbr)
   DETAIL
    reply->corr_case_id = pc.case_id
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.status = "F"
   CALL handle_errors("SELECT","F","TABLE","PATHOLOGY CASE - corr")
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->corr_case_id = 0
 ENDIF
 SELECT INTO "nl:"
  ade.study_id, ade.complete_prsnl_id, name = decode(p.seq,p.name_full_formatted,pg.seq,pg
   .prsnl_group_name,"error"),
  id = decode(p.seq,p.person_id,pg.seq,pg.prsnl_group_id,0.0), grp_ind = decode(p.seq,0,pg.seq,1,2)
  FROM ap_dc_event ade,
   dummyt d,
   ap_dc_event_prsnl adep,
   prsnl p,
   dummyt d2,
   prsnl_group pg
  PLAN (ade
   WHERE (request->study_id=ade.study_id)
    AND (reply->eval_case_id=ade.case_id)
    AND (reply->corr_case_id=ade.correlate_case_id)
    AND 0=ade.cancel_prsnl_id)
   JOIN (((d
   WHERE 1=d.seq)
   JOIN (adep
   WHERE ade.event_id=adep.event_id
    AND adep.prsnl_id != 0)
   JOIN (p
   WHERE adep.prsnl_id=p.person_id
    AND 0=adep.prsnl_group_id)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (pg
   WHERE ade.prsnl_group_id=pg.prsnl_group_id
    AND ade.prsnl_group_id != 0)
   ))
  HEAD REPORT
   ecnt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   ecnt = (ecnt+ 1)
   IF (mod(ecnt,10)=1
    AND ecnt != 1)
    stat = alterlist(reply->qual,(ecnt+ 9))
   ENDIF
   reply->qual[ecnt].name = name, reply->qual[ecnt].id = id, reply->qual[ecnt].grp_ind = grp_ind,
   reply->qual[ecnt].complete_prsnl_id = ade.complete_prsnl_id
  FOOT REPORT
   stat = alterlist(reply->qual,ecnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL handle_errors("SELECT","Z","TABLE","AP_DC_EVENT")
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(build("errors->",error_cnt))
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
