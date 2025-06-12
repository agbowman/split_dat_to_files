CREATE PROGRAM dm2_arc_info_ins:dba
 DECLARE arc_error_check(error_header=vc,direction=vc,archive_entity_name=vc) = i2
 DECLARE arc_log_insert(error_header=vc,errormsg=vc,direction=vc,archive_entity_name=vc,
  archive_entity_id=f8,
  run_secs=i4) = null
 DECLARE outside_time_window(null) = i2
 DECLARE stop_at_next_check(mover_name=vc) = i2
 DECLARE arc_replace(stmt_str=vc,link_ind=i2,list_ind=i2,entity_ind=i2,pre_link=vc,
  post_link=vc,entity_id=f8) = vc
 DECLARE update_time_window(null) = i2
 IF (validate(errormsg,"-1")="-1")
  DECLARE errormsg = vc
 ENDIF
 SUBROUTINE arc_error_check(error_header,direction,archive_entity_name)
   IF (error(errormsg,0) != 0)
    ROLLBACK
    SET reply->status_data.subeventstatus.targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    CALL arc_log_insert(error_header,errormsg,direction,archive_entity_name,0.0,
     null)
    COMMIT
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_log_insert(error_header,errormsg,direction,archive_entity_name,archive_entity_id,
  run_secs)
   INSERT  FROM dm_arc_log d
    SET d.dm_arc_log_id = seq(archive_seq,nextval), d.archive_entity_id = archive_entity_id, d
     .run_secs = run_secs,
     d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = direction, d.err_msg = trim(
      substring(1,255,concat(curprog,": ",error_header," ",errormsg))),
     d.archive_entity_name = archive_entity_name, d.instigator_app = reqinfo->updt_app, d
     .instigator_task = reqinfo->updt_task,
     d.instigator_req = reqinfo->updt_req, d.instigator_id = reqinfo->updt_id, d.instigator_applctx
      = reqinfo->updt_applctx,
     d.rdbhandle = currdbhandle, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
     .updt_cnt = 0
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE outside_time_window(null)
   IF ( NOT ((((pers_arc->start_time > pers_arc->stop_time)
    AND (((cnvtmin(curtime) < pers_arc->stop_time)) OR ((cnvtmin(curtime) > pers_arc->start_time))) )
    OR ((((pers_arc->start_time < pers_arc->stop_time)
    AND (cnvtmin(curtime) < pers_arc->stop_time)
    AND (cnvtmin(curtime) > pers_arc->start_time)) OR ((pers_arc->start_time=pers_arc->stop_time)))
   )) ))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE stop_at_next_check(mover_name)
   DECLARE s_mover_state = vc
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="ARCHIVE-PERSON"
     AND d.info_name=mover_name
    DETAIL
     s_mover_state = d.info_char
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while selecting from dm_info: ","ARCHIVE","PERSON")=1)
    RETURN(1)
   ENDIF
   IF (s_mover_state="STOP AT NEXT CHECK")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_replace(arc_stmt_str,arc_link_ind,arc_list_ind,arc_entity_ind,arc_pre_link,
  arc_post_link,arc_entity_id)
   DECLARE s_arc_return_str = vc
   SET s_arc_return_str = arc_stmt_str
   IF (arc_link_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,":pre_link:",nullterm(arc_pre_link),0)
    SET s_arc_return_str = replace(s_arc_return_str,":post_link:",nullterm(arc_post_link),0)
   ENDIF
   IF (arc_list_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"list","",0)
   ENDIF
   IF (arc_entity_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"v_archive_entity_id",build(arc_entity_id),0)
    SET s_arc_return_str = replace(s_arc_return_str,"V_ARCHIVE_ENTITY_ID",build(arc_entity_id),0)
   ENDIF
   RETURN(s_arc_return_str)
 END ;Subroutine
 SUBROUTINE update_time_window(null)
  SELECT INTO "nl:"
   di.info_name, di.info_number
   FROM dm_arc_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND cnvtdatetime(curdate,curtime3) BETWEEN beg_effective_dt_tm AND end_effective_dt_tm
   DETAIL
    CASE (di.info_name)
     OF "START AFTER TIME":
      pers_arc->start_time = di.info_number
     OF "STOP BY TIME":
      pers_arc->stop_time = di.info_number
    ENDCASE
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_info rows: ","ARCHIVE","PERSON")=
  1)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 IF ((validate(reply->end_effective_dt_tm,- (1))=- (1)))
  FREE RECORD reply
  RECORD reply(
    1 end_effective_dt_tm = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE v_end_eff_date = f8
 UPDATE  FROM dm_arc_info d1
  SET d1.end_effective_dt_tm = cnvtlookbehind("1,S",cnvtdatetime(request->beg_effective_dt_tm)), d1
   .updt_id = reqinfo->updt_id, d1.updt_task = reqinfo->updt_task,
   d1.updt_applctx = reqinfo->updt_applctx, d1.updt_cnt = (updt_cnt+ 1), d1.updt_dt_tm = cnvtdatetime
   (curdate,curtime3)
  WHERE (d1.info_domain=request->info_domain)
   AND (d1.info_name=request->info_name)
   AND (d1.beg_effective_dt_tm=
  (SELECT
   max(d2.beg_effective_dt_tm)
   FROM dm_arc_info d2
   WHERE d2.beg_effective_dt_tm < cnvtdatetime(request->beg_effective_dt_tm)
    AND (d2.info_domain=request->info_domain)
    AND (d2.info_name=request->info_name)))
 ;end update
 IF (arc_error_check("while updating the end_eff_dt_tm in dm_arc_info ","ARCHIVE","PERSON"))
  GO TO exit_info_ins
 ENDIF
 SELECT INTO "nl:"
  min_beg_date = min(beg_effective_dt_tm)
  FROM dm_arc_info
  WHERE (info_domain=request->info_domain)
   AND (info_name=request->info_name)
   AND beg_effective_dt_tm > cnvtdatetime(request->beg_effective_dt_tm)
  DETAIL
   v_end_eff_date = cnvtlookbehind("1,S",min_beg_date)
  WITH nocounter
 ;end select
 IF (arc_error_check("while determining the new end_eff_dt_tm ","ARCHIVE","PERSON"))
  GO TO exit_info_ins
 ENDIF
 IF (((curqual=0) OR (v_end_eff_date=0)) )
  SET v_end_eff_date = cnvtdatetime("31-dec-2100 00:00:00")
 ENDIF
 INSERT  FROM dm_arc_info d
  SET d.dm_arc_info_id = seq(dm_clinical_seq,nextval), d.info_domain = request->info_domain, d
   .info_name = request->info_name,
   d.info_number = request->info_number, d.info_char = request->info_char, d.info_dt_tm =
   cnvtdatetime(request->info_dt_tm),
   d.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), d.end_effective_dt_tm =
   cnvtdatetime(v_end_eff_date), d.updt_id = reqinfo->updt_id,
   d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 IF (arc_error_check("while inserting the new row ","ARCHIVE","PERSON"))
  GO TO exit_info_ins
 ENDIF
 COMMIT
#exit_info_ins
END GO
