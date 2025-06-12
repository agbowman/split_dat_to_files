CREATE PROGRAM cv_get_relevant_proc_data:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 grp_orderable_rep[*]
      2 catalog_cd = f8
      2 grp_sub_ord[*]
        3 study_uid = vc
        3 study_des = vc
        3 proc_study_date_tm = vc
        3 study_modality = f8
        3 proc_accsn = vc
        3 proc_id = f8
    1 grp_all_rep[*]
      2 study_uid = vc
      2 study_des = vc
      2 proc_study_date_tm = vc
      2 study_modality = f8
      2 proc_accsn = vc
      2 proc_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temporder(
   1 qual[*]
     2 catalog_cd = f8
     2 groups[*]
       3 order_idx = i4
 )
 RECORD tempallorder(
   1 qual[*]
     2 study_uid = vc
     2 study_des = vc
     2 proc_study_date_tm = vc
     2 study_modality = f8
     2 proc_accsn = vc
     2 studydttm = dq8
     2 proc_id = f8
 )
 DECLARE studydate = dq8 WITH protect, noconstant(0)
 DECLARE strstudydate = vc WITH protect, noconstant(" ")
 DECLARE iordercnt = i4 WITH protect, noconstant(0)
 DECLARE iorderidx = i4 WITH protect, noconstant(0)
 DECLARE ilocateidx = i4 WITH protect, noconstant(0)
 DECLARE ilocatepos = i4 WITH protect, noconstant(0)
 DECLARE ilocatetempidx = i4 WITH protect, noconstant(0)
 DECLARE ilocatetemppos = i4 WITH protect, noconstant(0)
 DECLARE itempordercnt = i4 WITH protect, noconstant(0)
 DECLARE itemporderidx = i4 WITH protect, noconstant(0)
 DECLARE itempordersz = i4 WITH protect, noconstant(0)
 DECLARE irepordercnt = i4 WITH protect, noconstant(0)
 DECLARE irepordridx = i4 WITH protect, noconstant(0)
 DECLARE iallproccnt = i4 WITH protect, noconstant(0)
 DECLARE idumtcnt = i4 WITH protect, noconstant(0)
 DECLARE icataloggrpcnt = i4 WITH protect, noconstant(0)
 DECLARE icataloggrpidx = i4 WITH protect, noconstant(0)
 DECLARE dcatalogcd = f8 WITH protect, noconstant(0)
 DECLARE igroupingflag = i4 WITH protect, noconstant(0)
 DECLARE study_state_mv = f8 WITH protect, constant(uar_get_code_by("MEANING",27700,"MV"))
 DECLARE buildreply(null) = null WITH protect
 DECLARE retrieveprocs(null) = null WITH protect
 DECLARE retrievehxprocs(null) = null WITH protect
 DECLARE sortallprocs(null) = null WITH protect
 SET reply->status_data.status = "F"
 CALL buildreply(null)
 CALL retrieveprocs(null)
 CALL retrievehxprocs(null)
 CALL sortallprocs(null)
 SUBROUTINE buildreply(null)
   SET iordercnt = size(request->cv_grp_orderables,5)
   SET stat = alterlist(reply->grp_orderable_rep,iordercnt)
   SET itempordercnt = (iordercnt+ size(temporder->qual,5))
   SET stat = alterlist(temporder->qual,itempordercnt)
   SET itempordersz = 0
   FOR (iorderidx = 1 TO iordercnt)
     SET itempordersz = 0
     SET itemporderidx += 1
     SET dcatalogcd = request->cv_grp_orderables[iorderidx].orderable_catalog
     SET reply->grp_orderable_rep[iorderidx].catalog_cd = dcatalogcd
     SET ilocatetemppos = locateval(ilocatetempidx,1,itempordercnt,dcatalogcd,temporder->qual[
      ilocatetempidx].catalog_cd)
     IF (ilocatetemppos > 0)
      SET itempordersz = (size(temporder->qual[ilocatetemppos].groups,5)+ 1)
      SET stat = alterlist(temporder->qual[ilocatetemppos].groups,itempordersz)
      SET temporder->qual[ilocatetemppos].groups[itempordersz].order_idx = iorderidx
     ELSE
      SET itempordersz += 1
      SET temporder->qual[itemporderidx].catalog_cd = request->cv_grp_orderables[iorderidx].
      orderable_catalog
      SET stat = alterlist(temporder->qual[itemporderidx].groups,itempordersz)
      SET temporder->qual[itemporderidx].groups[itempordersz].order_idx = iorderidx
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE retrieveprocs(null)
   SELECT INTO "nl:"
    FROM im_acquired_study i,
     im_study ism,
     cv_proc cp,
     cv_step cs,
     cv_step_ref csr
    WHERE (cp.person_id=request->cv_person_id)
     AND ism.orig_entity_id=cp.cv_proc_id
     AND ism.orig_entity_name="CV_PROC"
     AND ism.study_state_cd IN (study_state_mv)
     AND i.matched_study_id=ism.im_study_id
     AND cs.cv_proc_id=cp.cv_proc_id
     AND csr.task_assay_cd=cs.task_assay_cd
    ORDER BY i.study_date DESC, i.study_time DESC
    DETAIL
     studydate = cnvtdatetimeutc2(i.study_date,"YYYYMMDD",substring(1,6,concat(i.study_time,"000000")
       ),"HHMMSS",0), strstudydate = datetimezoneformat(studydate,i.study_tz,"YYYY-MM-DD HH:mm:ss"),
     ilocatepos = locateval(ilocateidx,1,itemporderidx,cp.catalog_cd,temporder->qual[ilocateidx].
      catalog_cd)
     IF (ilocatepos > 0)
      IF (csr.activity_subtype_cd > 0)
       icataloggrpcnt = size(temporder->qual[ilocateidx].groups,5), igroupingflag = 1, irepordridx =
       temporder->qual[ilocatepos].groups[icataloggrpcnt].order_idx,
       irepordercnt = (size(reply->grp_orderable_rep[irepordridx].grp_sub_ord,5)+ 1), stat =
       alterlist(reply->grp_orderable_rep[irepordridx].grp_sub_ord,irepordercnt), reply->
       grp_orderable_rep[irepordridx].grp_sub_ord[irepordercnt].study_uid = ism.study_uid,
       reply->grp_orderable_rep[irepordridx].grp_sub_ord[irepordercnt].proc_accsn = cp.accession,
       reply->grp_orderable_rep[irepordridx].grp_sub_ord[irepordercnt].study_des =
       uar_get_code_display(cp.catalog_cd), reply->grp_orderable_rep[irepordridx].grp_sub_ord[
       irepordercnt].study_modality = csr.activity_subtype_cd,
       reply->grp_orderable_rep[irepordridx].grp_sub_ord[irepordercnt].proc_study_date_tm =
       strstudydate, iallproccnt += 1, stat = alterlist(tempallorder->qual,iallproccnt),
       tempallorder->qual[iallproccnt].study_uid = ism.study_uid, tempallorder->qual[iallproccnt].
       proc_accsn = cp.accession, tempallorder->qual[iallproccnt].proc_id = cp.cv_proc_id,
       tempallorder->qual[iallproccnt].study_des = uar_get_code_display(cp.catalog_cd), tempallorder
       ->qual[iallproccnt].study_modality = csr.activity_subtype_cd, tempallorder->qual[iallproccnt].
       proc_study_date_tm = strstudydate,
       tempallorder->qual[iallproccnt].studydttm = studydate
      ENDIF
     ELSE
      IF (csr.activity_subtype_cd > 0)
       iallproccnt += 1, stat = alterlist(tempallorder->qual,iallproccnt), tempallorder->qual[
       iallproccnt].study_uid = ism.study_uid,
       tempallorder->qual[iallproccnt].proc_accsn = cp.accession, tempallorder->qual[iallproccnt].
       proc_id = cp.cv_proc_id, tempallorder->qual[iallproccnt].study_des = uar_get_code_display(cp
        .catalog_cd),
       tempallorder->qual[iallproccnt].study_modality = csr.activity_subtype_cd, tempallorder->qual[
       iallproccnt].proc_study_date_tm = strstudydate, tempallorder->qual[iallproccnt].studydttm =
       studydate
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE retrievehxprocs(null)
   IF ((request->relevant_flag > 0))
    SELECT INTO "nl:"
     FROM im_acquired_study i,
      im_study ism,
      cv_proc_hx cp,
      cv_step cs,
      cv_step_ref csr
     WHERE (cp.person_id=request->cv_person_id)
      AND ism.orig_entity_id=cp.cv_proc_hx_id
      AND ism.orig_entity_name="CV_PROC_HX"
      AND ism.study_state_cd IN (study_state_mv)
      AND i.matched_study_id=ism.im_study_id
     ORDER BY i.study_date DESC, i.study_time DESC
     DETAIL
      IF (csr.activity_subtype_cd > 0)
       studydate = cnvtdatetimeutc2(i.study_date,"YYYYMMDD",substring(1,6,concat(i.study_time,
          "000000")),"HHMMSS",0), strstudydate = datetimezoneformat(studydate,i.study_tz,
        "YYYY-MM-DD HH:mm:ss"), iallproccnt += 1,
       stat = alterlist(tempallorder->qual,iallproccnt), tempallorder->qual[iallproccnt].study_uid =
       ism.study_uid, tempallorder->qual[iallproccnt].proc_accsn = cp.frgn_sys_accession_reference,
       tempallorder->qual[iallproccnt].study_des = uar_get_code_display(cp.order_catalog_cd),
       tempallorder->qual[iallproccnt].study_modality = cp.activity_subtype_cd, tempallorder->qual[
       iallproccnt].proc_study_date_tm = strstudydate,
       tempallorder->qual[iallproccnt].studydttm = studydate
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE sortallprocs(null)
   IF (iallproccnt > 0)
    SET stat = alterlist(reply->grp_all_rep,iallproccnt)
    SELECT INTO "nl:"
     studydttm = tempallorder->qual[d.seq].studydttm
     FROM (dummyt d  WITH seq = iallproccnt)
     ORDER BY studydttm DESC
     DETAIL
      idumtcnt += 1, reply->grp_all_rep[idumtcnt].study_uid = tempallorder->qual[d.seq].study_uid,
      reply->grp_all_rep[idumtcnt].proc_accsn = tempallorder->qual[d.seq].proc_accsn,
      reply->grp_all_rep[idumtcnt].proc_id = tempallorder->qual[d.seq].proc_id, reply->grp_all_rep[
      idumtcnt].study_des = tempallorder->qual[d.seq].study_des, reply->grp_all_rep[idumtcnt].
      study_modality = tempallorder->qual[d.seq].study_modality,
      reply->grp_all_rep[idumtcnt].proc_study_date_tm = tempallorder->qual[d.seq].proc_study_date_tm
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 IF (((iallproccnt > 0) OR (igroupingflag=1)) )
  SET reply->status_data.status = "S"
 ELSEIF (((iallproccnt=0) OR (igroupingflag=0)) )
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ENDIF
 IF ((reply->status_data.status="F"))
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "cv_get_rp_bt"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echorecord(tempallorder)
 ENDIF
 CALL cv_log_msg_post(" 10/22/2021 SS028138")
END GO
