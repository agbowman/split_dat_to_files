CREATE PROGRAM cdi_get_note_types:dba
 RECORD reply(
   1 note_type[10]
     2 note_type_id = f8
     2 data_status_ind = i2
     2 event_cd = f8
     2 display = vc
     2 display_alias = vc
     2 banner_ind = i2
     2 device_name = vc
     2 publish_level = i4
     2 default_level_flag = i2
     2 override_level_ind = i2
     2 alias_contributor_src_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE src_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE m = i4 WITH protect, noconstant(size(request->source,5))
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE aliascnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "S"
 IF ((request->code_value_alias_ind=1))
  SELECT INTO "nl:"
   FROM note_type nt,
    v500_event_code v,
    code_value_alias cva
   PLAN (nt
    WHERE nt.event_cd != 0
     AND nt.data_status_ind=1)
    JOIN (v
    WHERE nt.event_cd=v.event_cd)
    JOIN (cva
    WHERE cva.code_value=outerjoin(v.event_cd))
   ORDER BY nt.note_type_description, v.event_cd
   HEAD nt.note_type_description
    aliascnt = 0
   HEAD v.event_cd
    aliascnt = 0
   DETAIL
    aliascnt = (aliascnt+ 1), src_cd = cva.contributor_source_cd, pos = locateval(n,1,m,src_cd,
     request->source[n].contributor_source_cd)
    IF (((aliascnt=1) OR (pos > 0)) )
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
     IF (pos > 0)
      reply->note_type[cnt].display_alias = trim(cva.alias), reply->note_type[cnt].
      alias_contributor_src_cd = cva.contributor_source_cd
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM note_type nt,
    v500_event_code v
   PLAN (nt
    WHERE nt.event_cd != 0
     AND nt.data_status_ind=1)
    JOIN (v
    WHERE nt.event_cd=v.event_cd)
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
     = nt.default_level_flag, reply->note_type[cnt].override_level_ind = nt.override_level_ind,
    reply->note_type[cnt].alias_contributor_src_cd = 0.0
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
