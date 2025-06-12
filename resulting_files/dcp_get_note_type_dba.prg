CREATE PROGRAM dcp_get_note_type:dba
 RECORD reply(
   1 note_type[10]
     2 note_type_id = f8
     2 data_status_ind = i2
     2 event_cd = f8
     2 display = vc
     2 display_alias = vc
     2 template_id = f8
     2 smart_template_ind = i2
     2 smart_template_cd = f8
     2 banner_ind = i2
     2 device_name = vc
     2 publish_level = i4
     2 default_level_flag = i2
     2 override_level_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE cv_alias = vc WITH public, noconstant(request->code_value_alias)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE active = i4 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 SET reply->status_data.status = "S"
 IF ((request->code_value_alias_ind=1))
  SET stat = uar_get_meaning_by_codeset(73,nullterm(cv_alias),1,code_value)
  SELECT INTO "nl:"
   FROM note_type nt,
    v500_event_code v,
    code_value_alias cva,
    note_type_template_reltn tr,
    clinical_note_template clnt
   PLAN (nt
    WHERE nt.event_cd != 0
     AND (nt.data_status_ind >= request->data_status_mask))
    JOIN (v
    WHERE nt.event_cd=v.event_cd
     AND v.code_status_cd=active)
    JOIN (cva
    WHERE cva.code_value=outerjoin(v.event_cd)
     AND cva.contributor_source_cd=outerjoin(code_value))
    JOIN (tr
    WHERE tr.default_ind=outerjoin(1)
     AND tr.note_type_id=outerjoin(nt.note_type_id))
    JOIN (clnt
    WHERE clnt.template_id=outerjoin(tr.template_id))
   ORDER BY nt.note_type_description
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt > 1)
     stat = alter(reply->note_type,(cnt+ 9))
    ENDIF
    reply->note_type[cnt].note_type_id = nt.note_type_id, reply->note_type[cnt].event_cd = nt
    .event_cd, reply->note_type[cnt].data_status_ind = nt.data_status_ind,
    reply->note_type[cnt].banner_ind = nt.banner_ind, reply->note_type[cnt].device_name = nt
    .device_name, reply->note_type[cnt].publish_level = nt.publish_level,
    reply->note_type[cnt].display = trim(v.event_cd_disp), reply->note_type[cnt].display_alias = trim
    (cva.alias), reply->note_type[cnt].default_level_flag = nt.default_level_flag,
    reply->note_type[cnt].override_level_ind = nt.override_level_ind
    IF (clnt.smart_template_ind=1)
     reply->note_type[cnt].smart_template_ind = clnt.smart_template_ind, reply->note_type[cnt].
     smart_template_cd = clnt.smart_template_cd, reply->note_type[cnt].template_id = 0
    ELSE
     reply->note_type[cnt].smart_template_ind = 0, reply->note_type[cnt].smart_template_cd = 0, reply
     ->note_type[cnt].template_id = clnt.template_id
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM note_type nt,
    v500_event_code v,
    note_type_template_reltn tr,
    clinical_note_template clnt
   PLAN (nt
    WHERE nt.event_cd != 0
     AND (nt.data_status_ind >= request->data_status_mask))
    JOIN (v
    WHERE nt.event_cd=v.event_cd
     AND v.code_status_cd=active)
    JOIN (tr
    WHERE tr.default_ind=outerjoin(1)
     AND tr.note_type_id=outerjoin(nt.note_type_id))
    JOIN (clnt
    WHERE clnt.template_id=outerjoin(tr.template_id))
   ORDER BY nt.note_type_description
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt > 1)
     stat = alter(reply->note_type,(cnt+ 9))
    ENDIF
    reply->note_type[cnt].note_type_id = nt.note_type_id, reply->note_type[cnt].event_cd = nt
    .event_cd, reply->note_type[cnt].data_status_ind = nt.data_status_ind,
    reply->note_type[cnt].banner_ind = nt.banner_ind, reply->note_type[cnt].device_name = nt
    .device_name, reply->note_type[cnt].publish_level = nt.publish_level,
    reply->note_type[cnt].display = trim(v.event_cd_disp), reply->note_type[cnt].default_level_flag
     = nt.default_level_flag, reply->note_type[cnt].override_level_ind = nt.override_level_ind
    IF (clnt.smart_template_ind=1)
     reply->note_type[cnt].smart_template_ind = clnt.smart_template_ind, reply->note_type[cnt].
     smart_template_cd = clnt.smart_template_cd, reply->note_type[cnt].template_id = 0
    ELSE
     reply->note_type[cnt].smart_template_ind = 0, reply->note_type[cnt].smart_template_cd = 0, reply
     ->note_type[cnt].template_id = clnt.template_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE TYPE"
 ENDIF
 SET stat = alter(reply->note_type,cnt)
END GO
