CREATE PROGRAM dts_get_template_association:dba
 RECORD reply(
   1 template[10]
     2 note_type_id = f8
     2 template_id = f8
     2 template_name = vc
     2 location_cd = f8
     2 prsnl_id = f8
     2 smart_template_ind = i2
     2 default_note_template_ind = i2
     2 default_prsnl_loc_ind = i2
     2 smart_template_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  nt.note_type_id, tr.template_id, tr.default_ind,
  cnt.template_name, cnt.prsnl_id, cnt.smart_template_cd,
  cnt.smart_template_ind, pltr.default_ind, pltr.location_cd
  FROM note_type nt,
   note_type_template_reltn tr,
   clinical_note_template cnt,
   prsnl_loc_template_reltn pltr
  PLAN (nt
   WHERE (nt.event_cd=request->event_cd))
   JOIN (tr
   WHERE nt.note_type_id=tr.note_type_id)
   JOIN (cnt
   WHERE tr.template_id=cnt.template_id
    AND cnt.template_active_ind=1)
   JOIN (pltr
   WHERE outerjoin(tr.note_type_template_reltn_id)=pltr.note_type_template_reltn_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->template,(cnt+ 9))
   ENDIF
   reply->template[cnt].note_type_id = nt.note_type_id, reply->template[cnt].template_id = tr
   .template_id, reply->template[cnt].default_note_template_ind = tr.default_ind,
   reply->template[cnt].template_name = cnt.template_name, reply->template[cnt].prsnl_id = pltr
   .prsnl_id, reply->template[cnt].smart_template_cd = cnt.smart_template_cd,
   reply->template[cnt].smart_template_ind = cnt.smart_template_ind, reply->template[cnt].
   default_prsnl_loc_ind = pltr.default_ind, reply->template[cnt].location_cd = pltr.location_cd
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE TYPE"
 ENDIF
 SET stat = alter(reply->template,cnt)
END GO
