CREATE PROGRAM ct_get_data_cap_cdashv1_dcv
 RECORD c_reply(
   1 text = vc
   1 text_type = vc
   1 large_text_qual[*]
     2 text_segment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 subject_data[*]
     2 subject_key = vc
     2 study_event_data[*]
       3 study_event_oid = vc
       3 form_data[*]
         4 form_oid = vc
         4 audit_user_oid = vc
         4 audit_location_oid = vc
         4 item_group_data[*]
           5 item_group_oid = vc
           5 item_group_repeat_key = vc
           5 item_data[*]
             6 item_oid = vc
             6 value = vc
             6 is_null = i2
             6 measurement_unit_oid = vc
 )
 CALL echorecord(request)
 FREE RECORD ct_request
 RECORD ct_request(
   1 person_id = f8
   1 prot_master_id = f8
   1 encounter_id = f8
   1 con_med_time = f8
   1 con_med_unit_cd = f8
   1 condition_time = f8
   1 condition_unit_cd = f8
   1 organization_id = f8
   1 organization_id = f8
 )
 FREE RECORD ct_reply
 RECORD ct_reply(
   1 subject_number = vc
   1 birth_dt_tm = dq8
   1 sex_cd = f8
   1 sex_disp = c50
   1 sex_desc = c50
   1 sex_mean = c12
   1 race_cd = f8
   1 race_disp = c50
   1 race_desc = c50
   1 race_mean = c12
   1 consent_dt_tm = dq8
   1 vitals[*]
     2 position = vc
     2 heart_rate = vc
     2 heart_rate_dt_tm = dq8
     2 diastolic = vc
     2 diastolic_dt_tm = dq8
     2 systolic = vc
     2 systolic_dt_tm = dq8
   1 aes[*]
     2 ae_model_name = c20
     2 ae_id = f8
     2 ae_sub_id = f8
     2 description = vc
     2 onset_dt_tm = dq8
     2 onset_prec_flag = i2
     2 resolved_dt_tm = dq8
     2 ongoing_ind = i2
     2 serious_ind = i2
     2 severity_category = vc
     2 severity_flag = i2
     2 outcome = vc
   1 conmeds[*]
     2 med_name = vc
     2 med_dose = vc
     2 med_dose_unit = vc
     2 med_start_dt_tm = dq8
     2 med_end_val = i2
     2 med_end_dt_tm = dq8
     2 order_id = f8
   1 protocol_name = vc
   1 location_id = f8
   1 location_name = vc
   1 user_id = f8
   1 user_name = vc
   1 principal_investigator_id = f8
   1 principal_investigator_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE visit_num = i2 WITH protect, noconstant(0)
 DECLARE encntr_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE temp_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE vital_cnt = i2 WITH protect, noconstant(0)
 DECLARE item_group_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE grp_idx = i2 WITH protect, noconstant(0)
 DECLARE vital_idx = i2 WITH protect, noconstant(0)
 DECLARE ae_idx = i2 WITH protect, noconstant(0)
 DECLARE ae_cnt = i2 WITH protect, noconstant(0)
 DECLARE cm_idx = i2 WITH protect, noconstant(0)
 DECLARE cm_cnt = i2 WITH protect, noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("S")
 SET ct_request->person_id = request->person[1].person_id
 IF (size(request->person[1].visits,5) > 0)
  SET ct_request->encounter_id = request->person[1].visits[1].encntr_id
  SET visit_num = request->person[1].visits[1].visit_num
  SET encntr_dt_tm = request->person[1].visits[1].encntr_dt_tm
 ENDIF
 SET ct_request->prot_master_id = request->prot_master_id
 SET ct_request->con_med_time = request->con_med_time
 SET ct_request->con_med_unit_cd = request->con_med_unit_cd
 SET ct_request->condition_time = request->condition_time
 SET ct_request->condition_unit_cd = request->condition_unit_cd
 SET trace = recpersist
 EXECUTE ct_get_pt_cdashv1_dcv  WITH replace("REQUEST","CT_REQUEST"), replace("REPLY","CT_REPLY")
 IF ((ct_reply->status_data.status != "S"))
  SET cfailed = ct_reply->status_data.status
  GO TO exit_script
 ENDIF
 SET stat = alterlist(c_reply->subject_data,1)
 SET c_reply->subject_data[1].subject_key = ct_reply->subject_number
 SET stat = alterlist(c_reply->subject_data[1].study_event_data,1)
 SET c_reply->subject_data[1].study_event_data[1].study_event_oid = "StudyEventOID"
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data,1)
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].form_oid = "CDASH"
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].audit_user_oid = ct_reply->user_name
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].audit_location_oid = request->
 site_ident
 SET item_group_cnt = (item_group_cnt+ 1)
 SET idx = item_group_cnt
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
  item_group_cnt)
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].item_group_oid =
 "DM"
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
 item_group_repeat_key = "1"
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
  item_data,4)
 SET curalias item_data_struct c_reply->subject_data[1].study_event_data[1].form_data[1].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 4)
   IF (x=1)
    SET item_data_struct->item_oid = "SUBJID"
    SET item_data_struct->value = ct_reply->subject_number
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "SEX"
    IF ((ct_reply->sex_cd > 0.0))
     SET item_data_struct->value = substring(1,1,uar_get_code_meaning(ct_reply->sex_cd))
    ENDIF
   ELSEIF (x=3)
    SET item_data_struct->item_oid = "RACE"
    IF ((ct_reply->race_cd > 0.0))
     SET item_data_struct->value = uar_get_code_display(ct_reply->race_cd)
    ENDIF
   ELSE
    SET item_data_struct->item_oid = "BRTHDTC"
    SET item_data_struct->value = format(ct_reply->birth_dt_tm,"YYYY-MM-DDTHH:MM:SS-06:00;;D")
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET item_group_cnt = (item_group_cnt+ 1)
 SET idx = item_group_cnt
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
  item_group_cnt)
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].item_group_oid =
 "SV"
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
 item_group_repeat_key = "1"
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
  item_data,2)
 SET curalias item_data_struct c_reply->subject_data[1].study_event_data[1].form_data[1].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 2)
   IF (x=1)
    SET item_data_struct->item_oid = "SVSEQ"
    SET item_data_struct->value = build(visit_num)
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "SVSTDTC"
    SET item_data_struct->value = format(encntr_dt_tm,"YYYY-MM-DDTHH:MM:SS-06:00;;D")
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET item_group_cnt = (item_group_cnt+ 1)
 SET idx = item_group_cnt
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
  item_group_cnt)
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].item_group_oid =
 "DS"
 SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
 item_group_repeat_key = "1"
 SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[idx].
  item_data,2)
 SET curalias item_data_struct c_reply->subject_data[1].study_event_data[1].form_data[1].
 item_group_data[idx].item_data[x]
 FOR (x = 1 TO 2)
   IF (x=1)
    SET item_data_struct->item_oid = "DSTERM"
   ELSEIF (x=2)
    SET item_data_struct->item_oid = "DSSTDTC"
    SET item_data_struct->value = format(ct_reply->consent_dt_tm,"YYYY-MM-DDTHH:MM:SS-06:00;;D")
   ENDIF
 ENDFOR
 SET curalias item_data_struct off
 SET vital_cnt = size(ct_reply->vitals,5)
 IF (vital_cnt > 0)
  SET idx = (item_group_cnt+ 1)
  SET item_group_cnt = (item_group_cnt+ vital_cnt)
  CALL echo(build("vital_cnt",vital_cnt))
  CALL echo(build("item_group_cnt",item_group_cnt))
  CALL echo(build("idx",idx))
  SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
   item_group_cnt)
  SET vital_idx = 0
  FOR (grp_idx = idx TO item_group_cnt)
    SET vital_idx = (vital_idx+ 1)
    CALL echo(build("grp_idx",grp_idx))
    CALL echo(build("vital_idx",vital_idx))
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_oid = "VS"
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_repeat_key = build(vital_idx)
    SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
     grp_idx].item_data,6)
    SET curalias item_data c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
    grp_idx].item_data[x]
    FOR (x = 1 TO 6)
      IF (x=1)
       SET item_data->item_oid = "VSSTAT"
       SET item_data->value = "Yes"
      ELSEIF (x=2)
       SET item_data->item_oid = "HR"
       SET item_data->value = ct_reply->vitals[vital_idx].heart_rate
      ELSEIF (x=3)
       SET item_data->item_oid = "DIABP"
       SET item_data->value = ct_reply->vitals[vital_idx].diastolic
      ELSEIF (x=4)
       SET item_data->item_oid = "SYSBP"
       SET item_data->value = ct_reply->vitals[vital_idx].systolic
      ELSEIF (x=5)
       SET item_data->item_oid = "VSPOS"
       SET item_data->value = ct_reply->vitals[vital_idx].position
      ELSEIF (x=6)
       SET item_data->item_oid = "VSDTC"
       IF ((ct_reply->vitals[vital_idx].diastolic_dt_tm < ct_reply->vitals[vital_idx].
       heart_rate_dt_tm))
        SET temp_dt_tm = ct_reply->vitals[vital_idx].diastolic_dt_tm
       ELSE
        SET temp_dt_tm = ct_reply->vitals[vital_idx].heart_rate_dt_tm
       ENDIF
       IF ((temp_dt_tm > ct_reply->vitals[vital_idx].systolic_dt_tm))
        SET temp_dt_tm = ct_reply->vitals[vital_idx].systolic_dt_tm
       ENDIF
       SET item_data->value = format(temp_dt_tm,"YYYY-MM-DDTHH:MM:SS-06:00;;D")
      ENDIF
    ENDFOR
    SET curalias item_data off
  ENDFOR
 ENDIF
 SET ae_cnt = size(ct_reply->aes,5)
 IF (ae_cnt > 0)
  SET idx = (item_group_cnt+ 1)
  SET item_group_cnt = (item_group_cnt+ ae_cnt)
  CALL echo(build("ae_cnt",ae_cnt))
  CALL echo(build("item_group_cnt",item_group_cnt))
  CALL echo(build("idx",idx))
  SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
   item_group_cnt)
  SET ae_idx = 0
  SET grp_idx = idx
  FOR (grp_idx = idx TO item_group_cnt)
    SET ae_idx = (ae_idx+ 1)
    CALL echo(build("grp_idx",grp_idx))
    CALL echo(build("ae_idx",ae_idx))
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_oid = build("AE",ae_idx)
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_repeat_key = build(1)
    SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
     grp_idx].item_data,11)
    SET curalias item_data c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
    grp_idx].item_data[x]
    FOR (x = 1 TO 11)
      IF (x=1)
       SET item_data->item_oid = "AESTAT"
       SET item_data->value = "1"
      ELSEIF (x=2)
       SET item_data->item_oid = "AEGRPID"
       SET item_data->value = ""
      ELSEIF (x=3)
       SET item_data->item_oid = "AESEQ"
       SET item_data->value = format(ae_idx,"##;P0")
      ELSEIF (x=4)
       SET item_data->item_oid = "AETERM"
       SET item_data->value = ct_reply->aes[ae_idx].description
      ELSEIF (x=5)
       SET item_data->item_oid = "AESEV"
       IF ((ct_reply->aes[ae_idx].severity_flag > 0))
        SET item_data->value = build(ct_reply->aes[ae_idx].severity_flag)
       ELSE
        SET item_data->value = ""
       ENDIF
      ELSEIF (x=6)
       SET item_data->item_oid = "AESTDTC"
       SET item_data->value = format(ct_reply->aes[ae_idx].onset_dt_tm,"YYYY-MM-DDTHH:MM:SS-06:00;;D"
        )
      ELSEIF (x=7)
       SET item_data->item_oid = "AEENDDTC"
       SET item_data->value = format(ct_reply->aes[ae_idx].resolved_dt_tm,
        "YYYY-MM-DDTHH:MM:SS-06:00;;D")
      ELSEIF (x=8)
       SET item_data->item_oid = "AEONGO"
       SET item_data->value = build(ct_reply->aes[ae_idx].ongoing_ind)
      ELSEIF (x=9)
       SET item_data->item_oid = "AESER"
       SET item_data->value = build(ct_reply->aes[ae_idx].serious_ind)
      ELSEIF (x=10)
       SET item_data->item_oid = "AESERCAT"
       SET item_data->value = ""
      ELSEIF (x=11)
       SET item_data->item_oid = "AEOUT"
       SET item_data->value = ct_reply->aes[ae_idx].outcome
      ENDIF
    ENDFOR
    SET curalias item_data off
  ENDFOR
 ENDIF
 SET cm_cnt = size(ct_reply->conmeds,5)
 IF (cm_cnt > 0)
  SET idx = (item_group_cnt+ 1)
  SET item_group_cnt = (item_group_cnt+ cm_cnt)
  CALL echo(build("cm_cnt",cm_cnt))
  CALL echo(build("item_group_cnt",item_group_cnt))
  CALL echo(build("idx",idx))
  SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data,
   item_group_cnt)
  SET cm_idx = 0
  SET grp_idx = idx
  FOR (grp_idx = idx TO item_group_cnt)
    SET cm_idx = (cm_idx+ 1)
    CALL echo(build("grp_idx",grp_idx))
    CALL echo(build("cm_idx",cm_idx))
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_oid = build("CM",cm_idx)
    SET c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[grp_idx].
    item_group_repeat_key = build(1)
    SET stat = alterlist(c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
     grp_idx].item_data,5)
    SET curalias item_data c_reply->subject_data[1].study_event_data[1].form_data[1].item_group_data[
    grp_idx].item_data[x]
    FOR (x = 1 TO 5)
      IF (x=1)
       SET item_data->item_oid = "CMYN"
       SET item_data->value = "1"
      ELSEIF (x=2)
       SET item_data->item_oid = "CMTRT"
       SET item_data->value = concat(ct_reply->conmeds[cm_idx].med_name," ",trim(ct_reply->conmeds[
         cm_idx].med_dose)," ",trim(ct_reply->conmeds[cm_idx].med_dose_unit))
      ELSEIF (x=3)
       SET item_data->item_oid = "CMINDC"
       SET item_data->value = " "
      ELSEIF (x=4)
       SET item_data->item_oid = "CMSTDTC"
       SET item_data->value = format(ct_reply->conmeds[cm_idx].med_start_dt_tm,
        "YYYY-MM-DDTHH:MM:SS-06:00;;D")
      ELSEIF (x=5)
       SET item_data->item_oid = "CMONGO"
       SET item_data->value = build(ct_reply->conmeds[cm_idx].med_end_val)
      ENDIF
    ENDFOR
    SET curalias item_data off
  ENDFOR
 ENDIF
 SET reply->text_type = "ODMv1.3"
 FREE RECORD data_record
 RECORD data_record(
   1 line_cnt = i4
   1 line_qual[*]
     2 disp_line = vc
 )
 CALL echorecord(c_reply)
 DECLARE v1_start_odm(dummy=i4) = null
 DECLARE v1_end_odm(dummy=i4) = null
 DECLARE v1_start_item_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4,item_data_idx=i4) = null
 DECLARE v1_end_item_data(dummy=i4) = null
 DECLARE v1_start_item_group_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4) = null
 DECLARE v1_end_item_group_data(dummy=i4) = null
 DECLARE v1_start_audit_record(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4) = null
 DECLARE v1_end_audit_record(dummy=i4) = null
 DECLARE v1_start_form_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4) = null
 DECLARE v1_end_form_data(dummy=i4) = null
 DECLARE v1_start_study_event_data(subject_data_idx=i4,study_event_data_idx=i4) = null
 DECLARE v1_end_study_event_data(dummy=i4) = null
 DECLARE v1_start_subject_data(subject_data_idx=i4) = null
 DECLARE v1_end_subject_data(dummy=i4) = null
 DECLARE v1_start_clinical_data(dummy=i4) = null
 DECLARE v1_end_clinical_data(dummy=i4) = null
 DECLARE v1_add_line(line=vc) = null
 DECLARE v1_encode_value(value=vc) = vc
 CALL v1_start_odm(0)
 CALL v1_start_clinical_data(0)
 FOR (a = 1 TO size(c_reply->subject_data,5))
   CALL v1_start_subject_data(a)
   FOR (b = 1 TO size(c_reply->subject_data[a].study_event_data,5))
     CALL v1_start_study_event_data(a,b)
     FOR (c = 1 TO size(c_reply->subject_data[a].study_event_data[b].form_data,5))
       CALL v1_start_form_data(a,b,c)
       IF (((textlen(c_reply->subject_data[a].study_event_data[b].form_data[c].audit_location_oid) >
       0) OR (textlen(c_reply->subject_data[a].study_event_data[b].form_data[c].audit_user_oid) > 0
       )) )
        CALL v1_start_audit_record(a,b,c)
        CALL v1_end_audit_record(0)
       ENDIF
       FOR (d = 1 TO size(c_reply->subject_data[a].study_event_data[b].form_data[c].item_group_data,5
        ))
         CALL v1_start_item_group_data(a,b,c,d)
         FOR (e = 1 TO size(c_reply->subject_data[a].study_event_data[b].form_data[c].
          item_group_data[d].item_data,5))
          CALL v1_start_item_data(a,b,c,d,e)
          CALL v1_end_item_data(0)
         ENDFOR
         CALL v1_end_item_group_data(0)
       ENDFOR
       CALL v1_end_form_data(0)
     ENDFOR
     CALL v1_end_study_event_data(0)
   ENDFOR
   CALL v1_end_subject_data(0)
 ENDFOR
 CALL v1_end_clinical_data(0)
 CALL v1_end_odm(0)
 SUBROUTINE v1_encode_value(value)
   DECLARE newvalue = vc WITH protect
   SET newvalue = replace(value,"&","&amp;",0)
   SET newvalue = replace(newvalue,"<","&lt;",0)
   SET newvalue = replace(newvalue,">","&gt;",0)
   SET newvalue = replace(newvalue,"'","&apos;",0)
   SET newvalue = replace(newvalue,'"',"&quot;",0)
   RETURN(newvalue)
 END ;Subroutine
 SUBROUTINE v1_start_item_data(subject_data_idx,study_event_data_idx,form_data_idx,
  item_group_data_idx,item_data_idx)
   DECLARE newvalue = vc WITH protect
   CALL v1_add_line(concat('<ItemData ItemOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].form_data[form_data_idx].item_group_data[
     item_group_data_idx].item_data[item_data_idx].item_oid,'">'))
   SET newvalue = v1_encode_value(c_reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].value)
   CALL v1_add_line(trim(newvalue))
 END ;Subroutine
 SUBROUTINE v1_end_item_data(dummy)
   CALL v1_add_line("</ItemData>")
 END ;Subroutine
 SUBROUTINE v1_start_item_group_data(subject_data_idx,study_event_data_idx,form_data_idx,
  item_group_data_idx)
   CALL v1_add_line(concat('<ItemGroupData ItemGroupOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].form_data[form_data_idx].item_group_data[
     item_group_data_idx].item_group_oid,'" ItemGroupRepeatKey="',c_reply->subject_data[
     subject_data_idx].study_event_data[study_event_data_idx].form_data[form_data_idx].
     item_group_data[item_group_data_idx].item_group_repeat_key,'">'))
 END ;Subroutine
 SUBROUTINE v1_end_item_group_data(dummy)
   CALL v1_add_line("</ItemGroupData>")
 END ;Subroutine
 SUBROUTINE v1_start_audit_record(subject_data_idx,study_event_data_idx,form_data_idx)
   CALL v1_add_line("<AuditRecord>")
   CALL v1_add_line(concat('<UserRef UserOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].form_data[form_data_idx].audit_user_oid,'"/>'))
   CALL v1_add_line(concat('<LocationRef LocationOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].form_data[form_data_idx].audit_location_oid,'"/>'))
 END ;Subroutine
 SUBROUTINE v1_end_audit_record(dummy)
   CALL v1_add_line("</AuditRecord>")
 END ;Subroutine
 SUBROUTINE v1_start_form_data(subject_data_idx,study_event_data_idx,form_data_idx)
   CALL v1_add_line(concat('<FormData FormOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].form_data[form_data_idx].form_oid,'">'))
 END ;Subroutine
 SUBROUTINE v1_end_form_data(dummy)
   CALL v1_add_line("</FormData>")
 END ;Subroutine
 SUBROUTINE v1_start_study_event_data(subject_data_idx,study_event_data_idx)
   CALL v1_add_line(concat('<StudyEventData StudyEventOID="',c_reply->subject_data[subject_data_idx].
     study_event_data[study_event_data_idx].study_event_oid,'">'))
 END ;Subroutine
 SUBROUTINE v1_end_study_event_data(dummy)
   CALL v1_add_line("</StudyEventData>")
 END ;Subroutine
 SUBROUTINE v1_start_subject_data(subject_data_idx)
   CALL v1_add_line(concat('<SubjectData SubjectKey="',request->person[subject_data_idx].enroll_ident,
     '">'))
 END ;Subroutine
 SUBROUTINE v1_end_subject_data(dummy)
   CALL v1_add_line("</SubjectData>")
 END ;Subroutine
 SUBROUTINE v1_start_clinical_data(dummy)
   CALL v1_add_line(concat('<ClinicalData StudyOID="',request->study_ident,
     '" MetaDataVersionOID="001">'))
 END ;Subroutine
 SUBROUTINE v1_end_clinical_data(dummy)
   CALL v1_add_line("</ClinicalData>")
 END ;Subroutine
 SUBROUTINE v1_start_odm(dummy)
   CALL v1_add_line('<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"')
   CALL v1_add_line(
    ' xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
    )
   CALL v1_add_line(
    ' xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 ODM1-3-0.xsd" ODMVersion="1.3" FileOID="000-00-0000"'
    )
   CALL v1_add_line(concat(' FileType="Snapshot" Description="CDASH Form" AsOfDateTime="',
     format_script_dt_tm,'"'))
   CALL v1_add_line(concat(' CreationDateTime="',format_script_dt_tm,'"'))
   CALL v1_add_line(">")
 END ;Subroutine
 SUBROUTINE v1_end_odm(dummy)
   CALL v1_add_line("</ODM>")
 END ;Subroutine
 SUBROUTINE v1_add_line(line)
   SET data_record->line_cnt = (data_record->line_cnt+ 1)
   SET stat = alterlist(data_record->line_qual,data_record->line_cnt)
   SET data_record->line_qual[data_record->line_cnt].disp_line = line
 END ;Subroutine
#exit_script
 FOR (lidx = 1 TO data_record->line_cnt)
   SET reply->text = concat(reply->text,data_record->line_qual[lidx].disp_line)
 ENDFOR
 FREE RECORD drec
 IF (cfailed != "S")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "September 15, 2010"
 FREE RECORD ct_reply
 FREE RECORD ct_request
 SET trace = norecpersist
END GO
