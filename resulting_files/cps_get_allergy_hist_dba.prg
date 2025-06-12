CREATE PROGRAM cps_get_allergy_hist:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 person_org_sec_on = i2
   1 qual_knt = i4
   1 qual[*]
     2 allergy_instance_id = f8
     2 allergy_string = vc
     2 substance_nom_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 substance_type_cd = f8
     2 substance_type_disp = c40
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 severity_cd = f8
     2 severity_disp = c40
     2 source_of_info = vc
     2 source_of_info_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_disp = c40
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 created_prsnl_name = vc
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_prsnl_name = vc
     2 active_status_prsnl_id = f8
     2 active_status_prsnl_name = vc
     2 orig_prsnl_id = f8
     2 orig_prsnl_name = vc
     2 substance_mnemonic = vc
     2 cmb_instance_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
   1 reaction_qual = i4
   1 reaction[*]
     2 allergy_instance_id = f8
     2 reaction_id = f8
     2 reaction_string = vc
     2 reaction_nom_id = f8
     2 beg_effective_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_prsnl_name = vc
     2 active_ind = i2
     2 cmb_reaction_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
     2 end_effective_dt_tm = dq8
   1 comment_qual = i4
   1 comment[*]
     2 allergy_instance_id = f8
     2 allergy_comment_id = f8
     2 allergy_comment = vc
     2 comment_dt_tm = dq8
     2 comment_tz = i4
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_prsnl_name = vc
     2 active_ind = i2
     2 cmb_comment_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
   1 review_history_qual = i4
   1 review_history[*]
     2 allergy_instance_id = f8
     2 allergy_review_hist_id = f8
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE i_pos = i4 WITH noconstant(0), public
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE encntr_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE person_org_sec_on = i2 WITH public, noconstant(false)
 DECLARE network_var = f8 WITH constant(uar_get_code_by("MEANING",28881,"NETWORK")), public
 SELECT INTO "nl:"
  info_source = uar_get_code_display(a.source_of_info_cd)
  FROM allergy a,
   nomenclature n1
  PLAN (a
   WHERE (a.allergy_id=request->allergy_id))
   JOIN (n1
   WHERE n1.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.beg_effective_dt_tm), a.allergy_instance_id
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].allergy_instance_id = a.allergy_instance_id
   IF (a.substance_nom_id > 0)
    reply->qual[knt].allergy_string = n1.source_string, reply->qual[knt].substance_mnemonic = n1
    .mnemonic
   ELSE
    reply->qual[knt].allergy_string = a.substance_ftdesc
   ENDIF
   reply->qual[knt].encntr_id = a.encntr_id, reply->qual[knt].organization_id = a.organization_id,
   reply->qual[knt].substance_nom_id = a.substance_nom_id,
   reply->qual[knt].substance_type_cd = a.substance_type_cd, reply->qual[knt].reaction_class_cd = a
   .reaction_class_cd, reply->qual[knt].severity_cd = a.severity_cd,
   reply->qual[knt].source_of_info_cd = a.source_of_info_cd
   IF (a.source_of_info_cd > 0)
    reply->qual[knt].source_of_info = info_source
   ELSE
    reply->qual[knt].source_of_info = a.source_of_info_ft
   ENDIF
   reply->qual[knt].onset_dt_tm = a.onset_dt_tm, reply->qual[knt].onset_tz = a.onset_tz, reply->qual[
   knt].onset_precision_cd = a.onset_precision_cd,
   reply->qual[knt].onset_precision_flag = a.onset_precision_flag, reply->qual[knt].
   reaction_status_cd = a.reaction_status_cd, reply->qual[knt].created_dt_tm = a.created_dt_tm,
   reply->qual[knt].created_prsnl_id = a.created_prsnl_id, reply->qual[knt].reviewed_dt_tm = a
   .reviewed_dt_tm, reply->qual[knt].reviewed_tz = a.reviewed_tz,
   reply->qual[knt].reviewed_prsnl_id = a.reviewed_prsnl_id, reply->qual[knt].cancel_reason_cd = a
   .cancel_reason_cd, reply->qual[knt].orig_prsnl_id = a.orig_prsnl_id,
   reply->qual[knt].updt_id = a.updt_id, reply->qual[knt].beg_effective_dt_tm = a.beg_effective_dt_tm,
   reply->qual[knt].beg_effective_tz = a.beg_effective_tz,
   reply->qual[knt].updt_dt_tm = a.updt_dt_tm, reply->qual[knt].active_status_prsnl_id = a
   .active_status_prsnl_id, reply->qual[knt].cmb_instance_id = a.cmb_instance_id,
   reply->qual[knt].cmb_flag = a.cmb_flag, reply->qual[knt].cmb_prsnl_id = a.cmb_prsnl_id, reply->
   qual[knt].cmb_person_id = a.cmb_person_id,
   reply->qual[knt].cmb_dt_tm = a.cmb_dt_tm, reply->qual[knt].cmb_tz = a.cmb_tz
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  SET encntr_org_sec_on = ccldminfo->sec_org_reltn
  SET person_org_sec_on = ccldminfo->person_org_sec
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
     AND di.info_number=1)
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_org_sec_on = 1
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (person_org_sec_on=true
  AND encntr_org_sec_on=true)
  SET reply->person_org_sec_on = true
 ENDIF
 SELECT INTO "nl:"
  FROM allergy a,
   reaction r,
   nomenclature n2,
   prsnl p5,
   prsnl p6,
   person p
  PLAN (a
   WHERE (a.allergy_id=request->allergy_id))
   JOIN (r
   WHERE r.allergy_instance_id=a.allergy_instance_id)
   JOIN (p5
   WHERE p5.person_id=outerjoin(r.updt_id))
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
   JOIN (p6
   WHERE p6.person_id=outerjoin(r.cmb_prsnl_id))
   JOIN (p
   WHERE p.person_id=outerjoin(r.cmb_person_id))
  ORDER BY cnvtdatetime(r.beg_effective_dt_tm), r.reaction_id
  HEAD REPORT
   rknt = 0, stat = alterlist(reply->reaction,10)
  DETAIL
   rknt = (rknt+ 1)
   IF (mod(rknt,10)=1
    AND rknt != 1)
    stat = alterlist(reply->reaction,(rknt+ 9))
   ENDIF
   reply->reaction[rknt].allergy_instance_id = r.allergy_instance_id, reply->reaction[rknt].
   reaction_id = r.reaction_id
   IF (r.reaction_nom_id > 0)
    reply->reaction[rknt].reaction_string = n2.source_string
   ELSE
    reply->reaction[rknt].reaction_string = r.reaction_ftdesc
   ENDIF
   reply->reaction[rknt].reaction_nom_id = r.reaction_nom_id, reply->reaction[rknt].
   beg_effective_dt_tm = r.beg_effective_dt_tm, reply->reaction[rknt].updt_dt_tm = r.updt_dt_tm,
   reply->reaction[rknt].updt_id = r.updt_id, reply->reaction[rknt].updt_prsnl_name = p5
   .name_full_formatted, reply->reaction[rknt].active_ind = r.active_ind,
   reply->reaction[rknt].cmb_reaction_id = r.cmb_reaction_id, reply->reaction[rknt].cmb_flag = r
   .cmb_flag, reply->reaction[rknt].cmb_prsnl_id = r.cmb_prsnl_id,
   reply->reaction[rknt].cmb_prsnl_name = p6.name_full_formatted, reply->reaction[rknt].cmb_person_id
    = r.cmb_person_id, reply->reaction[rknt].cmb_person_name = p.name_full_formatted,
   reply->reaction[rknt].cmb_dt_tm = r.cmb_dt_tm, reply->reaction[rknt].cmb_tz = r.cmb_tz, reply->
   reaction[rknt].end_effective_dt_tm = r.end_effective_dt_tm
  FOOT REPORT
   reply->reaction_qual = rknt, stat = alterlist(reply->reaction,rknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REACTION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   IF ((reply->status_data.status != "S"))
    SET reply->status_data.status = "Z"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM allergy a,
   allergy_comment ac,
   prsnl p7,
   prsnl p8,
   person p
  PLAN (a
   WHERE (a.allergy_id=request->allergy_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ac
   WHERE ac.allergy_id=a.allergy_id
    AND ac.active_ind=1)
   JOIN (p7
   WHERE p7.person_id=outerjoin(ac.updt_id))
   JOIN (p8
   WHERE p8.person_id=outerjoin(ac.cmb_prsnl_id))
   JOIN (p
   WHERE p.person_id=outerjoin(ac.cmb_person_id))
  ORDER BY cnvtdatetime(ac.beg_effective_dt_tm), ac.allergy_comment_id
  HEAD REPORT
   cknt = 0, stat = alterlist(reply->comment,10)
  DETAIL
   cknt = (cknt+ 1)
   IF (mod(cknt,10)=1
    AND cknt != 1)
    stat = alterlist(reply->comment,(cknt+ 9))
   ENDIF
   reply->comment[cknt].allergy_instance_id = ac.allergy_instance_id, reply->comment[cknt].
   allergy_comment_id = ac.allergy_comment_id, reply->comment[cknt].allergy_comment = ac
   .allergy_comment,
   reply->comment[cknt].comment_dt_tm = ac.comment_dt_tm, reply->comment[cknt].comment_tz = ac
   .comment_tz, reply->comment[cknt].beg_effective_dt_tm = ac.beg_effective_dt_tm,
   reply->comment[cknt].beg_effective_tz = ac.beg_effective_tz, reply->comment[cknt].updt_dt_tm = ac
   .updt_dt_tm, reply->comment[cknt].updt_id = ac.updt_id,
   reply->comment[cknt].updt_prsnl_name = p7.name_full_formatted, reply->comment[cknt].active_ind =
   ac.active_ind, reply->comment[cknt].cmb_comment_id = ac.cmb_comment_id,
   reply->comment[cknt].cmb_flag = ac.cmb_flag, reply->comment[cknt].cmb_prsnl_id = ac.cmb_prsnl_id,
   reply->comment[cknt].cmb_prsnl_name = p8.name_full_formatted,
   reply->comment[cknt].cmb_person_id = ac.cmb_person_id, reply->comment[cknt].cmb_person_name = p
   .name_full_formatted, reply->comment[cknt].cmb_dt_tm = ac.cmb_dt_tm,
   reply->comment[cknt].cmb_tz = ac.cmb_tz
  FOOT REPORT
   reply->comment_qual = cknt, stat = alterlist(reply->comment,cknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY_COMMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 FOR (i = 1 TO value(reply->qual_knt))
   SELECT INTO "nl:"
    FROM prsnl p1
    WHERE (p1.person_id=reply->qual[i].created_prsnl_id)
    DETAIL
     reply->qual[i].created_prsnl_name = p1.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM prsnl p2
    WHERE (p2.person_id=reply->qual[i].orig_prsnl_id)
    DETAIL
     reply->qual[i].orig_prsnl_name = p2.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM prsnl p3
    WHERE (p3.person_id=reply->qual[i].reviewed_prsnl_id)
    DETAIL
     reply->qual[i].reviewed_prsnl_name = p3.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM prsnl p4
    WHERE (p4.person_id=reply->qual[i].updt_id)
    DETAIL
     reply->qual[i].updt_prsnl_name = p4.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM prsnl p5
    WHERE (p5.person_id=reply->qual[i].active_status_prsnl_id)
    DETAIL
     reply->qual[i].active_status_prsnl_name = p5.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM prsnl p6
    WHERE (p6.person_id=reply->qual[i].cmb_prsnl_id)
    DETAIL
     reply->qual[i].cmb_prsnl_name = p6.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=reply->qual[i].cmb_person_id)
    DETAIL
     reply->qual[i].cmb_person_name = p.name_full_formatted
    WITH nocounter
   ;end select
   CALL subroutine_errorcheck(null)
 ENDFOR
 SUBROUTINE subroutine_errorcheck(null)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM allergy a,
   allergy_review_hist ah,
   prsnl p
  PLAN (a
   WHERE (a.allergy_id=request->allergy_id))
   JOIN (ah
   WHERE ah.allergy_instance_id=a.allergy_instance_id)
   JOIN (p
   WHERE p.person_id=outerjoin(ah.reviewed_prsnl_id))
  ORDER BY cnvtdatetime(ah.reviewed_dt_tm)
  HEAD REPORT
   ahknt = 0, stat = alterlist(reply->review_history,10)
  DETAIL
   ahknt = (ahknt+ 1)
   IF (mod(ahknt,10)=1
    AND ahknt != 1)
    stat = alterlist(reply->review_history,(ahknt+ 9))
   ENDIF
   reply->review_history[ahknt].allergy_instance_id = ah.allergy_instance_id, reply->review_history[
   ahknt].allergy_review_hist_id = ah.allergy_review_hist_id, reply->review_history[ahknt].
   reviewed_dt_tm = ah.reviewed_dt_tm,
   reply->review_history[ahknt].reviewed_tz = ah.reviewed_tz, reply->review_history[ahknt].
   reviewed_prsnl_id = ah.reviewed_prsnl_id, reply->review_history[ahknt].reviewed_prsnl_name = p
   .name_full_formatted
  FOOT REPORT
   reply->review_history_qual = ahknt, stat = alterlist(reply->review_history,ahknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY_REVIEW_HIST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   IF ((reply->status_data.status != "S"))
    SET reply->status_data.status = "Z"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SET script_version = "013 03/03/05 SF3151"
END GO
