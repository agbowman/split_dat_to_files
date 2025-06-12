CREATE PROGRAM ams_cleanup_prearrival_tg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Keep Prearrival Tracking Items Less Than ## Hours Old" = 12,
  "Select Tracking Group" = 0.000000
  WITH outdev, p_hours, p_tracking_group
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bisanopsjob = i2 WITH protect, noconstant(false)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE ihourstokeep = i4 WITH protect, noconstant( $P_HOURS)
 DECLARE iexpidx = i4 WITH protect, noconstant(0)
 DECLARE slookbehindvar = vc WITH protect, noconstant("")
 DECLARE dmessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 tracking_prearrival_id = f8
     2 cur_tracking_locator_id = f8
 )
 IF (validate(reply->status_data,"F")="F")
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE isamsuser(a_person_id=f8) = i2
 DECLARE updtdminfo(a_prog_name=vc) = null
 IF (validate(request->batch_selection,"F")="F")
  SET bisanopsjob = false
  SET bamsassociate = isamsuser(reqinfo->updt_id)
  IF ( NOT (bamsassociate))
   SET failed = exe_error
   SET serrmsg = "User is Not Cerner AMS"
   GO TO exit_script
  ENDIF
 ELSE
  SET bisanopsjob = true
 ENDIF
 IF (ihourstokeep < 1)
  SET ihourstokeep = 12
 ENDIF
 SET slookbehindvar = build2(ihourstokeep,",H")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM tracking_prearrival tp,
   tracking_item ti
  PLAN (tp
   WHERE tp.create_dt_tm <= cnvtlookbehind(slookbehindvar)
    AND (tp.tracking_group_cd= $P_TRACKING_GROUP)
    AND tp.prearrival_type_cd != null
    AND ((tp.attached_encntr_id+ 0)=0.00)
    AND ((tp.attached_person_id+ 0)=0.00)
    AND tp.active_ind=1)
   JOIN (ti
   WHERE ti.parent_entity_id=tp.tracking_prearrival_id
    AND ti.parent_entity_name="TRACKING_PREARRIVAL"
    AND ti.active_ind=1
    AND ti.end_tracking_dt_tm=null)
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (knt > size(rdata->qual,5))
    stat = alterlist(rdata->qual,(knt+ 100))
   ENDIF
   rdata->qual[knt].tracking_prearrival_id = tp.tracking_prearrival_id, rdata->qual[knt].
   cur_tracking_locator_id = ti.cur_tracking_locator_id
  FOOT REPORT
   rdata->qual_knt = knt, stat = alterlist(rdata->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "TRACKING_PREARRIVAL"
  GO TO exit_script
 ENDIF
 IF ((rdata->qual_knt < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM tracking_item ti
  SET ti.end_tracking_dt_tm = cnvtdatetime(curdate,curtime3), ti.end_tracking_id = reqinfo->updt_id,
   ti.updt_cnt = (ti.updt_cnt+ 1),
   ti.updt_dt_tm = cnvtdatetime(curdate,curtime3), ti.updt_id = reqinfo->updt_id, ti.updt_task =
   reqinfo->updt_task,
   ti.updt_applctx = reqinfo->updt_applctx
  PLAN (ti
   WHERE expand(iexpidx,1,rdata->qual_knt,ti.parent_entity_id,rdata->qual[iexpidx].
    tracking_prearrival_id)
    AND ti.parent_entity_name="TRACKING_PREARRIVAL"
    AND ti.active_ind=1
    AND ti.end_tracking_dt_tm=null)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "TRACKING_ITEM"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET iexpidx = 0
 UPDATE  FROM tracking_checkin tc
  SET tc.checkout_dt_tm = cnvtdatetime(curdate,curtime3), tc.checkout_id = reqinfo->updt_id, tc
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   tc.updt_cnt = (tc.updt_cnt+ 1), tc.updt_id = reqinfo->updt_id, tc.updt_task = reqinfo->updt_task,
   tc.updt_applctx = reqinfo->updt_applctx
  PLAN (tc
   WHERE expand(iexpidx,1,rdata->qual_knt,tc.parent_entity_id,rdata->qual[iexpidx].
    tracking_prearrival_id)
    AND tc.checkout_dt_tm=cnvtdatetime("31-DEC-2100")
    AND tc.active_ind=1
    AND (tc.tracking_group_cd= $P_TRACKING_GROUP))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "TRACKING_CHECKIN"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET iexpidx = 0
 UPDATE  FROM tracking_locator tl
  SET tl.depart_dt_tm = cnvtdatetime(curdate,curtime3), tl.depart_id = reqinfo->updt_id, tl.updt_id
    = reqinfo->updt_id,
   tl.updt_task = reqinfo->updt_task, tl.updt_cnt = (tl.updt_cnt+ 1), tl.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   tl.updt_applctx = reqinfo->updt_applctx
  PLAN (tl
   WHERE expand(iexpidx,1,rdata->qual_knt,tl.tracking_locator_id,rdata->qual[iexpidx].
    cur_tracking_locator_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "TRACKING_LOCATOR"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET iexpidx = 0
 UPDATE  FROM tracking_prearrival tp
  SET tp.active_ind = 0, tp.updt_cnt = (tp.updt_cnt+ 1), tp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   tp.updt_id = reqinfo->updt_id, tp.updt_task = reqinfo->updt_task, tp.updt_applctx = reqinfo->
   updt_applctx
  PLAN (tp
   WHERE tp.create_dt_tm <= cnvtlookbehind(slookbehindvar)
    AND (tp.tracking_group_cd= $P_TRACKING_GROUP)
    AND tp.prearrival_type_cd != null
    AND ((tp.attached_encntr_id+ 0)=0.00)
    AND ((tp.attached_person_id+ 0)=0.00)
    AND tp.active_ind=1)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "TRACKING_PREARRIVAL"
  GO TO exit_script
 ENDIF
 SUBROUTINE isamsuser(the_person_id)
   DECLARE ireturnvalue = i2 WITH protect, noconstant(0)
   DECLARE dcvnametypeprsnl = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2403228"))
   SELECT INTO "nl:"
    p.person_id
    FROM person_name p
    PLAN (p
     WHERE (p.person_id=reqinfo->updt_id)
      AND p.name_type_cd=dcvnametypeprsnl
      AND p.name_title="Cerner AMS"
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (p.person_id > 0)
      ireturnvalue = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ireturnvalue)
 END ;Subroutine
 SUBROUTINE updtdminfo(the_prog_name)
   DECLARE bprogramhasbeenlogged = i2 WITH protect, noconstant(false)
   DECLARE iuseknt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=the_prog_name)
    DETAIL
     bprogramhasbeenlogged = true, iuseknt = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (bprogramhasbeenlogged=false)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = the_prog_name, d.info_date = cnvtdatetime(
       curdate,curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = iuseknt
     PLAN (d
      WHERE d.info_domain="AMS_TOOLKIT"
       AND d.info_name=the_prog_name)
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
#exit_script
 IF ((rdata->qual_knt > 0)
  AND failed=false)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 IF (bisanopsjob=false)
  IF ((rdata->qual_knt < 1))
   IF (failed=exe_error)
    SET smessage = "User must be a Cerner AMS associated to run this program from Explorer Menu"
   ELSE
    SET smessage = concat("No Items Qualified <iHoursToKeep = ",trim(cnvtstring(ihourstokeep),3),">")
   ENDIF
  ELSE
   SET smessage = concat(trim(cnvtstring(rdata->qual_knt),3)," Items Qualified <iHoursToKeep = ",trim
    (cnvtstring(ihourstokeep),3),">")
  ENDIF
  IF (failed != exe_error)
   CALL updtdminfo("AMS_CLEANUP_PREARRIVAL_MASS")
  ENDIF
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,smessage),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg,3)
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=exe_error)
   SET reply->status_data.subeventstatus[1].operationname = "EXE_ERROR"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_ver = "000 12/20/12 Add Tracking Group Prompt"
END GO
