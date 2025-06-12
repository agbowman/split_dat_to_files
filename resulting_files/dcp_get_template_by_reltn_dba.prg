CREATE PROGRAM dcp_get_template_by_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 note_template[10]
      2 template_id = f8
      2 template_name = vc
      2 template_active_ind = i2
      2 owner_type_flag = i2
      2 default_ind = f8
      2 prsnl_id = f8
      2 smart_template_cd = f8
      2 smart_template_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET cnt = 0
 SET reply->status_data.status = "S"
 SELECT
  IF ((request->note_template_keyword_id > 0)
   AND (request->note_type_id > 0))
   FROM note_type_template_reltn ntr,
    template_keyword_reltn kr,
    clinical_note_template ct
   PLAN (ntr
    WHERE (request->note_type_id=ntr.note_type_id))
    JOIN (kr
    WHERE (request->note_template_keyword_id=kr.note_template_keyword_id)
     AND ntr.template_id=kr.template_id)
    JOIN (ct
    WHERE kr.template_id=ct.template_id
     AND ((ct.smart_template_ind+ 0) < 2))
  ELSEIF ((request->note_template_keyword_id > 0)
   AND (request->note_type_id <= 0))
   FROM template_keyword_reltn kr,
    clinical_note_template ct
   PLAN (kr
    WHERE (request->note_template_keyword_id=kr.note_template_keyword_id))
    JOIN (ct
    WHERE kr.template_id=ct.template_id
     AND ((ct.smart_template_ind+ 0) < 2))
  ELSEIF ((request->note_template_keyword_id <= 0)
   AND (request->note_type_id > 0))
   FROM note_type_template_reltn ntr,
    clinical_note_template ct
   PLAN (ntr
    WHERE (request->note_type_id=ntr.note_type_id))
    JOIN (ct
    WHERE ntr.template_id=ct.template_id
     AND ((ct.smart_template_ind+ 0) < 2))
  ELSE
  ENDIF
  INTO "nl:"
  ct.template_id
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 1)
    stat = alter(reply->note_template,(cnt+ 9))
   ENDIF
   reply->note_template[cnt].template_id = ct.template_id, reply->note_template[cnt].template_name =
   trim(ct.template_name), reply->note_template[cnt].template_active_ind = ct.template_active_ind,
   reply->note_template[cnt].default_ind = ntr.default_ind, reply->note_template[cnt].prsnl_id = ct
   .prsnl_id, reply->note_template[cnt].smart_template_cd = ct.smart_template_cd,
   reply->note_template[cnt].smart_template_ind = ct.smart_template_ind
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET stat = alter(reply->note_template,cnt)
END GO
