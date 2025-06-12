CREATE PROGRAM dcp_get_phys_detail:dba
 DECLARE ce_event_cd = f8 WITH protect
 DECLARE event_cd1 = f8 WITH protect
 DECLARE event_cd2 = f8 WITH protect
 DECLARE event_cd3 = f8 WITH protect
 DECLARE event_cd4 = f8 WITH protect
 DECLARE event_cd5 = f8 WITH protect
 DECLARE event_cd6 = f8 WITH protect
 DECLARE event_cd7 = f8 WITH protect
 DECLARE event_cd8 = f8 WITH protect
 DECLARE event_cd9 = f8 WITH protect
 DECLARE event_cd10 = f8 WITH protect
 DECLARE temp1_cd = f8 WITH protect
 DECLARE temp2_cd = f8 WITH protect
 DECLARE temp3_cd = f8 WITH protect
 DECLARE ax_temp4_cd = f8 WITH protect
 DECLARE temp5_cd = f8 WITH protect
 DECLARE temp6_cd = f8 WITH protect
 DECLARE resp_cd = f8 WITH protect
 DECLARE vent_cd = f8 WITH protect
 DECLARE hr1_cd = f8 WITH protect
 DECLARE hr2_cd = f8 WITH protect
 DECLARE hr3_cd = f8 WITH protect
 DECLARE hr4_cd = f8 WITH protect
 DECLARE dbp1_cd = f8 WITH protect
 DECLARE dbp2_cd = f8 WITH protect
 DECLARE sbp1_cd = f8 WITH protect
 DECLARE sbp2_cd = f8 WITH protect
 DECLARE creat1_cd = f8 WITH protect
 DECLARE creat2_cd = f8 WITH protect
 DECLARE gluc1_cd = f8 WITH protect
 DECLARE gluc2_cd = f8 WITH protect
 DECLARE gluc3_cd = f8 WITH protect
 DECLARE gluc4_cd = f8 WITH protect
 DECLARE gluc5_cd = f8 WITH protect
 DECLARE gluc6_cd = f8 WITH protect
 DECLARE gluc7_cd = f8 WITH protect
 DECLARE gluc8_cd = f8 WITH protect
 DECLARE gluc9_cd = f8 WITH protect
 DECLARE gluc10_cd = f8 WITH protect
 DECLARE parser_string = vc WITH noconstant(fillstring(300," ")), public
 RECORD reply(
   1 event_cnt = i2
   1 event_list[*]
     2 event_tag = vc
     2 vent_tag = vc
     2 event_end_dt_tm = dq8
     2 prsnl_name = vc
   1 map_cnt = i2
   1 map_list[*]
     2 systolic = f8
     2 diastolic = f8
     2 mean_bp = f8
     2 event_end_dt_tm = dq8
     2 prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cc_day[*]
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 IF ((request->urine_ind=1))
  EXECUTE FROM 2100_urine TO 2199_urine_exit
 ELSEIF ((request->map_ind=1))
  EXECUTE FROM 2200_meanbp TO 2299_meanbp_exit
 ELSEIF ((request->ce_id > 0.0))
  EXECUTE FROM 2000_read TO 2099_read_exit
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Request data not valid, one of map_ind, urine_ind or ce_id must be > 0."
 ENDIF
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
 DECLARE use_map_ind = i2
 SET use_map_ind = 0
 SET reply->status_data.status = "F"
 SET cc_day = 0
 SET ra_entry_found = "N"
 SET inerror_cd = meaning_code(8,"INERROR")
 SET event_tag_num = 0.0
 SET ce_id = 0.0
 SET ce_event_cd = 0.0
 SET person_id = 0.0
 SET encntr_id = 0.0
 SET event_cki = "                         "
 SET midpoint = 0.0
#1099_initialize_exit
#2000_read
 SET event_cd1 = - (1.0)
 SET event_cd2 = - (1.0)
 SET event_cd3 = - (1.0)
 SET event_cd4 = - (1.0)
 SET event_cd5 = - (1.0)
 SET event_cd6 = - (1.0)
 SET event_cd7 = - (1.0)
 SET event_cd8 = - (1.0)
 SET event_cd9 = - (1.0)
 SET event_cd10 = - (1.0)
 SET temp1_cd = 0.0
 SET temp2_cd = 0.0
 SET temp3_cd = 0.0
 SET ax_temp4_cd = 0.0
 SET temp5_cd = 0.0
 SET temp6_cd = 0.0
 SET temp1_cd = uar_get_code_by_cki("CKI.EC!5502")
 SET temp2_cd = uar_get_code_by_cki("CKI.EC!5505")
 SET temp3_cd = uar_get_code_by_cki("CKI.EC!5506")
 SET ax_temp4_cd = uar_get_code_by_cki("CKI.EC!5507")
 SET temp5_cd = uar_get_code_by_cki("CKI.EC!5508")
 SET temp6_cd = uar_get_code_by_cki("CKI.EC!5509")
 SET resp_cd = uar_get_code_by_cki("CKI.EC!5501")
 SET vent_cd = uar_get_code_by_cki("CKI.EC!7676")
 SET hr1_cd = uar_get_code_by_cki("CKI.EC!40")
 SET hr2_cd = uar_get_code_by_cki("CKI.EC!5500")
 SET hr3_cd = uar_get_code_by_cki("CKI.EC!7679")
 SET hr4_cd = uar_get_code_by_cki("CKI.EC!7187")
 SET dbp1_cd = uar_get_code_by_cki("CKI.EC!7681")
 SET dbp2_cd = uar_get_code_by_cki("CKI.EC!26")
 SET sbp1_cd = uar_get_code_by_cki("CKI.EC!7680")
 SET sbp2_cd = uar_get_code_by_cki("CKI.EC!75")
 SET creat1_cd = uar_get_code_by_cki("CKI.EC!8226")
 SET creat2_cd = uar_get_code_by_cki("CKI.EC!3256")
 SET gluc1_cd = uar_get_code_by_cki("CKI.EC!3374")
 SET gluc2_cd = uar_get_code_by_cki("CKI.EC!5634")
 SET gluc3_cd = uar_get_code_by_cki("CKI.EC!3375")
 SET gluc4_cd = uar_get_code_by_cki("CKI.EC!3376")
 SET gluc5_cd = uar_get_code_by_cki("CKI.EC!3377")
 SET gluc6_cd = uar_get_code_by_cki("CKI.EC!3378")
 SET gluc7_cd = uar_get_code_by_cki("CKI.EC!3379")
 SET gluc8_cd = uar_get_code_by_cki("CKI.EC!3380")
 SET gluc9_cd = uar_get_code_by_cki("CKI.EC!3386")
 SET gluc10_cd = uar_get_code_by_cki("CKI.EC!3388")
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.clinical_event_id=request->ce_id))
  DETAIL
   ce_event_cd = ce.event_cd
  WITH nocounter
 ;end select
 IF (ce_event_cd IN (resp_cd, vent_cd))
  SET cnt = 0
  SELECT INTO "nl:"
   FROM clinical_event ce,
    prsnl p
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd IN (resp_cd, vent_cd)
     AND ce.event_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
     AND ce.event_end_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.result_status_cd != inerror_cd
     AND ce.event_cd > 0)
    JOIN (p
    WHERE p.person_id=outerjoin(ce.verified_prsnl_id))
   ORDER BY cnvtdatetime(ce.event_end_dt_tm)
   HEAD REPORT
    cnt = 0, isnum = 0
   HEAD ce.event_end_dt_tm
    this_resp = - (1.0)
    IF (vent_cd > 0)
     this_vent = 0
    ELSE
     this_vent = - (1.0)
    ENDIF
    cnt = (cnt+ 1), stat = alterlist(reply->event_list,cnt)
   DETAIL
    IF (ce.event_cd=resp_cd)
     this_resp = cnvtreal(ce.event_tag)
    ELSE
     this_vent = 1
    ENDIF
    reply->event_list[cnt].event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm)
   FOOT  ce.event_end_dt_tm
    reply->event_list[cnt].event_tag = cnvtstring(this_resp), reply->event_list[cnt].vent_tag =
    cnvtstring(this_vent)
    IF (p.person_id > 0)
     reply->event_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
   WITH nocounter
  ;end select
  SET reply->event_cnt = cnt
 ELSE
  IF (ce_event_cd > 0)
   IF (ce_event_cd IN (temp1_cd, temp2_cd, temp3_cd, ax_temp4_cd, temp5_cd,
   temp6_cd))
    SET parser_string = "ce.event_cd in (temp1_cd,temp2_cd,temp3_cd,ax_temp4_cd,temp5_cd,temp6_cd)"
   ELSEIF (ce_event_cd IN (resp_cd, vent_cd))
    SET parser_string = "ce.event_cd in (resp_cd,vent_cd)"
   ELSEIF (ce_event_cd IN (hr1_cd, hr3_cd, hr4_cd, hr4_cd))
    SET parser_string = "ce.event_cd in (HR1_cd,HR3_cd,HR4_cd,HR4_cd)"
   ELSEIF (ce_event_cd IN (dbp1_cd, dbp2_cd, sbp1_cd, sbp2_cd))
    SET parser_string = "ce.event_cd in (DBP1_cd,DBP2_cd,SBP1_cd,SBP2_cd)"
   ELSEIF (ce_event_cd IN (creat1_cd, creat2_cd))
    SET parser_string = "ce.event_cd in (CREAT1_cd,CREAT2_cd)"
   ELSEIF (ce_event_cd IN (gluc1_cd, gluc2_cd, gluc3_cd, gluc4_cd, gluc5_cd,
   gluc6_cd, gluc7_cd, gluc8_cd, gluc9_cd, gluc10_cd))
    SET parser_string = "ce.event_cd in (GLUC1_cd,GLUC2_cd,GLUC3_cd,GLUC4_cd,GLUC5_cd,"
    SET parser_string = build(parser_string,"GLUC6_cd,GLUC7_cd,GLUC8_cd,GLUC9_cd,GLUC10_cd)")
   ELSE
    SET parser_string = "ce.event_cd = ce_event_cd"
   ENDIF
   SET cnt = 0
   SELECT INTO "nl:"
    FROM clinical_event ce,
     prsnl p
    PLAN (ce
     WHERE (ce.person_id=request->person_id)
      AND parser(parser_string)
      AND ce.event_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
      AND ce.event_end_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
      AND ce.view_level=1
      AND ce.publish_flag=1
      AND ce.result_status_cd != inerror_cd
      AND ce.event_cd > 0)
     JOIN (p
     WHERE p.person_id=outerjoin(ce.verified_prsnl_id))
    ORDER BY cnvtdatetime(ce.event_end_dt_tm)
    HEAD REPORT
     cnt = 0, isnum = 0
    DETAIL
     isnum = isnumeric(ce.event_tag)
     IF (isnum > 0)
      cnt = (cnt+ 1), stat = alterlist(reply->event_list,cnt), reply->event_list[cnt].event_tag = ce
      .event_tag,
      reply->event_list[cnt].event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm)
      IF (p.person_id > 0)
       reply->event_list[cnt].prsnl_name = p.name_full_formatted
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET reply->event_cnt = cnt
  ENDIF
 ENDIF
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2099_read_exit
#2100_urine
 SET urine1_cd = 0.0
 SET urine2_cd = 0.0
 SET urine3_cd = 0.0
 SET urine1_cd = uar_get_code_by_cki("CKI.EC!6416")
 SET urine2_cd = uar_get_code_by_cki("CKI.EC!5723")
 SET urine3_cd = uar_get_code_by_cki("CKI.EC!5727")
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND (ce.encntr_id=request->encntr_id)
    AND ce.event_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd
    AND ce.event_cd IN (urine1_cd, urine2_cd, urine3_cd)
    AND ce.event_cd > 0)
   JOIN (p
   WHERE p.person_id=outerjoin(ce.verified_prsnl_id))
  ORDER BY cnvtdatetime(ce.event_end_dt_tm)
  HEAD REPORT
   cnt = 0, isnum = 0
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum > 0)
    cnt = (cnt+ 1), stat = alterlist(reply->event_list,cnt), reply->event_list[cnt].event_tag = ce
    .event_tag,
    reply->event_list[cnt].event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->event_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET reply->event_cnt = cnt
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2199_urine_exit
#2200_meanbp
 SET systolic1_cd = 0.0
 SET diastolic1_cd = 0.0
 SET systolic2_cd = 0.0
 SET diastolic2_cd = 0.0
 SET diastolic3_cd = 0.0
 SET diastolic4_cd = 0.0
 SET systolic3_cd = 0.0
 SET systolic1_cd = uar_get_code_by_cki("CKI.EC!75")
 SET systolic2_cd = uar_get_code_by_cki("CKI.EC!7680")
 SET diastolic1_cd = uar_get_code_by_cki("CKI.EC!26")
 SET diastolic2_cd = uar_get_code_by_cki("CKI.EC!7681")
 SET diastolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9370"))
 SET diastolic4_cd = uar_get_code_by_cki(nullterm("CKI.EC!9371"))
 SET systolic3_cd = uar_get_code_by_cki(nullterm("CKI.EC!9369"))
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd
    AND ce.event_cd IN (systolic1_cd, diastolic1_cd, systolic2_cd, diastolic2_cd, systolic3_cd,
   diastolic3_cd, diastolic4_cd)
    AND ce.event_cd > 0)
   JOIN (p
   WHERE p.person_id=outerjoin(ce.verified_prsnl_id))
  ORDER BY cnvtdatetime(ce.event_end_dt_tm)
  HEAD REPORT
   cnt = 0, isnum = 0
  HEAD ce.event_end_dt_tm
   temp_sys1 = - (1.0), temp_dia1 = - (1.0), temp_sys2 = - (1.0),
   temp_dia2 = - (1.0), temp_sys3 = - (1.0), temp_dia3 = - (1.0),
   temp_dia4 = - (1.0)
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum >= 0)
    IF (ce.event_cd=systolic1_cd)
     temp_sys1 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=systolic2_cd)
     temp_sys2 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=diastolic1_cd)
     temp_dia1 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=diastolic2_cd)
     temp_dia2 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=systolic3_cd)
     temp_sys3 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=diastolic3_cd)
     temp_dia3 = cnvtreal(ce.event_tag)
    ELSEIF (ce.event_cd=diastolic4_cd)
     temp_dia4 = cnvtreal(ce.event_tag)
    ENDIF
   ENDIF
  FOOT  ce.event_end_dt_tm
   IF (temp_sys1 >= 0
    AND temp_dia1 >= 0)
    cnt = (cnt+ 1), stat = alterlist(reply->map_list,cnt), reply->map_list[cnt].event_end_dt_tm =
    cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->map_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
    reply->map_list[cnt].systolic = temp_sys1, reply->map_list[cnt].diastolic = temp_dia1, reply->
    map_list[cnt].mean_bp = (((temp_dia1 * 2)+ temp_sys1)/ 3)
   ENDIF
   IF (temp_sys2 >= 0
    AND temp_dia2 >= 0)
    cnt = (cnt+ 1), stat = alterlist(reply->map_list,cnt), reply->map_list[cnt].event_end_dt_tm =
    cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->map_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
    reply->map_list[cnt].systolic = temp_sys2, reply->map_list[cnt].diastolic = temp_dia2, reply->
    map_list[cnt].mean_bp = (((temp_dia2 * 2)+ temp_sys2)/ 3)
   ENDIF
   IF (temp_sys3 >= 0
    AND temp_dia3 >= 0)
    cnt = (cnt+ 1), stat = alterlist(reply->map_list,cnt), reply->map_list[cnt].event_end_dt_tm =
    cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->map_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
    reply->map_list[cnt].systolic = temp_sys3, reply->map_list[cnt].diastolic = temp_dia3, reply->
    map_list[cnt].mean_bp = (((temp_dia3 * 2)+ temp_sys3)/ 3)
   ELSEIF (temp_sys3 >= 0
    AND temp_dia4 >= 0)
    cnt = (cnt+ 1), stat = alterlist(reply->map_list,cnt), reply->map_list[cnt].event_end_dt_tm =
    cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->map_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
    reply->map_list[cnt].systolic = temp_sys3, reply->map_list[cnt].diastolic = temp_dia4, reply->
    map_list[cnt].mean_bp = (((temp_dia4 * 2)+ temp_sys3)/ 3)
   ENDIF
  WITH nocounter
 ;end select
 SET reply->map_cnt = cnt
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2299_meanbp_exit
#2300_map
 SET map_cd = 0.0
 SET map_cd = uar_get_code_by_cki("CKI.EC!6882")
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_event ce,
   prsnl p
  PLAN (ce
   WHERE (ce.person_id=request->person_id)
    AND ce.event_end_dt_tm >= cnvtdatetime(request->cc_beg_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(request->cc_end_dt_tm)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd
    AND ce.event_cd=map_cd
    AND ce.event_cd > 0)
   JOIN (p
   WHERE p.person_id=outerjoin(ce.verified_prsnl_id))
  ORDER BY cnvtdatetime(ce.event_end_dt_tm)
  HEAD REPORT
   cnt = 0, isnum = - (1)
  HEAD ce.event_end_dt_tm
   temp_map = - (1.0), temp_dia = - (1.0)
  DETAIL
   isnum = isnumeric(ce.event_tag)
   IF (isnum >= 0)
    temp_map = cnvtreal(ce.event_tag)
   ENDIF
   IF (temp_map >= 0)
    cnt = (cnt+ 1), stat = alterlist(reply->map_list,cnt), reply->map_list[cnt].event_end_dt_tm =
    cnvtdatetime(ce.event_end_dt_tm)
    IF (p.person_id > 0)
     reply->map_list[cnt].prsnl_name = p.name_full_formatted
    ENDIF
    reply->map_list[cnt].systolic = - (1), reply->map_list[cnt].diastolic = - (1), reply->map_list[
    cnt].mean_bp = temp_map
   ENDIF
  WITH nocounter
 ;end select
 SET reply->map_cnt = cnt
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2399_map_exit
#load_rar
 SET use_map_ind = 0
 SET org_id = - (1.00)
 SELECT INTO "nl:"
  FROM encounter e,
   risk_adjustment_ref rar
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.active_ind=1)
   JOIN (rar
   WHERE rar.organization_id=e.organization_id)
  DETAIL
   use_map_ind = rar.use_map_ind
  WITH nocounter
 ;end select
 IF (teach_type_flag < 0)
  SET failed_ind = "Y"
  SET failed_text = build("Error reading risk_adjustment_ref table.",org_id)
 ENDIF
#load_rar_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
