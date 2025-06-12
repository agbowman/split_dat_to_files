CREATE PROGRAM ct_get_amd_custom_values:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 values[*]
      2 ct_prot_amd_custom_fld_id = f8
      2 ct_custom_field_id = f8
      2 field_label = c40
      2 field_type_cd = f8
      2 field_type_disp = vc
      2 field_type_desc = vc
      2 field_type_mean = c12
      2 field_key = c30
      2 code_set = i4
      2 field_current_ind = i2
      2 field_position = i4
      2 value_text = c255
      2 value_dt_tm = dq8
      2 value_cd = f8
      2 value_disp = vc
      2 value_desc = vc
      2 value_mean = c12
      2 upt_cnt = i4
    1 code_sets[*]
      2 code_set = i4
      2 code_values[*]
        3 code_value_cd = f8
        3 code_value_disp = vc
        3 code_value_desc = vc
        3 code_value_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD code_sets(
   1 qual[*]
     2 code_set = i4
 )
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new_id = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cv_cnt = i4 WITH protect, noconstant(0)
 DECLARE csmulti_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17908,"CSMULTI"))
 DECLARE protocol_type_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  pa.prot_amendment_id, pa1.prot_amendment_id, pa1.amendment_nbr,
  pa1.revision_nbr_txt, val.ct_prot_amd_custom_fld_id
  FROM prot_amendment pa,
   prot_amendment pa1,
   ct_prot_amd_custom_fld_val val
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (pa1
   WHERE pa1.prot_master_id=pa.prot_master_id)
   JOIN (val
   WHERE (val.prot_amendment_id= Outerjoin(pa1.prot_amendment_id))
    AND (val.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  HEAD REPORT
   cnt = 0
  HEAD pa.prot_amendment_id
   protocol_type_cd = pa.participation_type_cd
  DETAIL
   IF (val.ct_prot_amd_custom_fld_id > 0.0)
    cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("cnt =",cnt))
 CALL echo(build("protocol_type_cd =",protocol_type_cd))
 IF (cnt=0)
  RECORD cfv_request(
    1 values[*]
      2 ct_prot_amd_custom_fld_id = f8
      2 ct_custom_field_id = f8
      2 prot_amendment_id = f8
      2 field_position = i2
      2 value_text = c255
      2 value_dt_tm = dq8
      2 value_cd = f8
      2 delete_ind = i2
  )
  RECORD cfv_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SELECT INTO "nl:"
   FROM ct_default_custom_fields dcf,
    ct_custom_field cf
   PLAN (dcf
    WHERE dcf.protocol_type_cd=protocol_type_cd
     AND dcf.protocol_type_cd > 0.0
     AND dcf.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (dcf.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (cf
    WHERE cf.field_key=dcf.field_key
     AND cf.active_ind=1)
   ORDER BY dcf.field_position
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(cfv_request->values,(cnt+ 9))
    ENDIF
    cfv_request->values[cnt].ct_prot_amd_custom_fld_id = 0.0, cfv_request->values[cnt].
    ct_custom_field_id = cf.ct_custom_field_id, cfv_request->values[cnt].prot_amendment_id = request
    ->prot_amendment_id,
    cfv_request->values[cnt].field_position = dcf.field_position, cfv_request->values[cnt].value_cd
     = 0.0, cfv_request->values[cnt].value_text = "",
    cfv_request->values[cnt].value_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), cfv_request->values[
    cnt].delete_ind = 0
   FOOT REPORT
    stat = alterlist(cfv_request->values,cnt)
   WITH nocounter
  ;end select
  CALL echo(build("cfv_req cnt =",cnt))
  IF (cnt > 0)
   EXECUTE ct_chg_amd_custom_values  WITH replace("REQUEST","CFV_REQUEST"), replace("REPLY",
    "CFV_REPLY")
   IF ((cfv_reply->status_data.status != "S"))
    SET fail_flag = insert_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue = cfv_reply->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM ct_prot_amd_custom_fld_val cfv,
   ct_custom_field cf,
   ct_custom_field cf1
  PLAN (cfv
   WHERE (cfv.prot_amendment_id=request->prot_amendment_id)
    AND cfv.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cfv.ct_prot_amd_custom_fld_id > 0.0)
   JOIN (cf
   WHERE cf.ct_custom_field_id=cfv.ct_custom_field_id)
   JOIN (cf1
   WHERE cf1.field_key=cf.field_key
    AND cf1.ct_custom_field_id >= cf.ct_custom_field_id
    AND (cf1.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cfv.field_position, cfv.ct_prot_amd_custom_fld_id, cf1.field_key
  HEAD REPORT
   cnt = 0
  HEAD cfv.ct_prot_amd_custom_fld_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->values,(cnt+ 9))
   ENDIF
  HEAD cf1.field_key
   reply->values[cnt].field_current_ind = 1
  DETAIL
   IF (cf1.ct_custom_field_id=cfv.ct_custom_field_id)
    reply->values[cnt].ct_prot_amd_custom_fld_id = cfv.ct_prot_amd_custom_fld_id, reply->values[cnt].
    value_cd = cfv.value_cd, reply->values[cnt].value_dt_tm = cfv.value_dt_tm,
    reply->values[cnt].value_text = cfv.value_text, reply->values[cnt].field_position = cfv
    .field_position, reply->values[cnt].upt_cnt = cfv.updt_cnt,
    reply->values[cnt].ct_custom_field_id = cf1.ct_custom_field_id, reply->values[cnt].field_type_cd
     = cf1.field_type_cd, reply->values[cnt].field_label = cf1.field_label,
    reply->values[cnt].field_key = cf1.field_key, reply->values[cnt].code_set = cf1.code_set
   ELSE
    reply->values[cnt].field_current_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->values,cnt)
  WITH nocounter
 ;end select
 IF (size(reply->values,5) > 0)
  SELECT INTO "nl:"
   cv.code_set, cv.code_value
   FROM code_value cv,
    (dummyt d1  WITH seq = value(size(reply->values,5)))
   PLAN (d1)
    JOIN (cv
    WHERE (reply->values[d1.seq].field_type_cd=csmulti_cd)
     AND (reply->values[d1.seq].value_cd=0.0)
     AND (cv.code_set=reply->values[d1.seq].code_set)
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = 0
   HEAD cv.code_set
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->code_sets,(cnt+ 9))
    ENDIF
    reply->code_sets[cnt].code_set = cv.code_set, cv_cnt = 0
   DETAIL
    cv_cnt += 1
    IF (mod(cv_cnt,10)=1)
     stat = alterlist(reply->code_sets[cnt].code_values,(cv_cnt+ 9))
    ENDIF
    reply->code_sets[cnt].code_values[cv_cnt].code_value_cd = cv.code_value, reply->code_sets[cnt].
    code_values[cv_cnt].code_value_disp = cv.display
   FOOT  cv.code_set
    stat = alterlist(reply->code_sets[cnt].code_values,cv_cnt)
   FOOT REPORT
    stat = alterlist(reply->code_sets,cnt)
  ;end select
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD code_sets
 SET last_mod = "001"
 SET mod_date = "October 18, 2019"
END GO
