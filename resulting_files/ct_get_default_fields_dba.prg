CREATE PROGRAM ct_get_default_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 default_fields[*]
      2 ct_default_custom_fld_id = f8
      2 field_position = i4
      2 field_type_cd = f8
      2 field_type_disp = vc
      2 field_type_desc = vc
      2 field_type_mean = c12
      2 field_label = vc
      2 field_key = vc
      2 code_set = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM ct_default_custom_fields dcf,
   ct_custom_field cf
  PLAN (dcf
   WHERE (dcf.protocol_type_cd=request->protocol_type_cd)
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
    stat = alterlist(reply->default_fields,(cnt+ 9))
   ENDIF
   reply->default_fields[cnt].ct_default_custom_fld_id = dcf.ct_default_custom_fld_id, reply->
   default_fields[cnt].field_position = dcf.field_position, reply->default_fields[cnt].field_type_cd
    = cf.field_type_cd,
   reply->default_fields[cnt].field_type_disp = uar_get_code_display(cf.field_type_cd), reply->
   default_fields[cnt].field_type_desc = uar_get_code_description(cf.field_type_cd), reply->
   default_fields[cnt].field_type_mean = uar_get_code_meaning(cf.field_type_cd),
   reply->default_fields[cnt].field_label = cf.field_label, reply->default_fields[cnt].field_key = cf
   .field_key, reply->default_fields[cnt].code_set = cf.code_set
  FOOT REPORT
   stat = alterlist(reply->default_fields,cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "October 17, 2019"
END GO
