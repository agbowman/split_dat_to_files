CREATE PROGRAM dcp_get_all_mt_template_reltns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 default_template_text = vc
    1 relation_list[*]
      2 message_type_cd = f8
      2 template_list[*]
        3 default_ind = i2
        3 template_id = f8
        3 template_name = vc
        3 long_blob_id = f8
        3 note_list[*]
          4 note_type_id = f8
          4 note_type_description = vc
          4 event_cd = f8
        3 smart_template_cd = f8
        3 smart_template_ind = i2
        3 med_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE messagetype_cnt = i4
 DECLARE tr_cn = i4
 DECLARE template_cnt = i4
 DECLARE nr_cnt = i4
 SET messagetype_cnt = size(request->message_list,5)
 SET reply->status_data.status = "F"
 DECLARE num = i4
 IF (messagetype_cnt > 0)
  SET error_string = fillstring(132," ")
  SET errcode = error(error_string,1)
  SELECT
   IF ((request->load_names=1)
    AND (request->load_note_types=1))INTO "nl:"
    cnttemplate_name = validate(cnt.template_name,""), cntlong_blob_id = validate(cnt.long_blob_id,
     0.0), ntevent_cd = validate(nt.event_cd,0.0),
    ntnote_type_description = validate(nt.note_type_description,""), nttnote_type_id = validate(ntt
     .note_type_id,0.0), lblong_blob = validate(lb.long_blob,""),
    smart_temp_cd = validate(cnt.smart_template_cd,0.0), smart_temp_ind = validate(cnt
     .smart_template_ind,0)
    FROM message_type_template_reltn mtt,
     clinical_note_template cnt,
     long_blob lb,
     note_type_template_reltn ntt,
     note_type nt
    PLAN (mtt
     WHERE expand(num,1,messagetype_cnt,mtt.message_type_cd,request->message_list[num].
      message_type_cd))
     JOIN (cnt
     WHERE cnt.template_id=mtt.template_id
      AND cnt.smart_template_ind < 2)
     JOIN (lb
     WHERE cnt.long_blob_id=lb.long_blob_id)
     JOIN (ntt
     WHERE outerjoin(cnt.template_id)=ntt.template_id)
     JOIN (nt
     WHERE outerjoin(ntt.note_type_id)=nt.note_type_id)
    ORDER BY mtt.message_type_cd, mtt.template_id, ntt.note_type_id
   ELSEIF ((request->load_note_types=1))INTO "nl:"
    cnttemplate_name = validate(cnt.template_name,""), cntlong_blob_id = validate(cnt.long_blob_id,
     0.0), ntevent_cd = validate(nt.event_cd,0.0),
    ntnote_type_description = validate(nt.note_type_description,""), nttnote_type_id = validate(ntt
     .note_type_id,0.0), lblong_blob = validate(lb.long_blob,""),
    smart_temp_cd = validate(cnt.smart_template_cd,0.0), smart_temp_ind = validate(cnt
     .smart_template_ind,0)
    FROM message_type_template_reltn mtt,
     clinical_note_template cnt,
     note_type_template_reltn ntt,
     note_type nt
    PLAN (mtt
     WHERE expand(num,1,messagetype_cnt,mtt.message_type_cd,request->message_list[num].
      message_type_cd))
     JOIN (cnt
     WHERE cnt.template_id=mtt.template_id
      AND cnt.smart_template_ind < 2)
     JOIN (ntt
     WHERE outerjoin(cnt.template_id)=ntt.template_id)
     JOIN (nt
     WHERE outerjoin(ntt.note_type_id)=nt.note_type_id)
    ORDER BY mtt.message_type_cd, mtt.template_id, ntt.note_type_id
   ELSEIF ((request->load_names=1))INTO "nl:"
    cnttemplate_name = validate(cnt.template_name,""), cntlong_blob_id = validate(cnt.long_blob_id,
     0.0), ntevent_cd = validate(nt.event_cd,0.0),
    ntnote_type_description = validate(nt.note_type_description,""), nttnote_type_id = validate(ntt
     .note_type_id,0.0), lblong_blob = validate(lb.long_blob,""),
    smart_temp_cd = validate(cnt.smart_template_cd,0.0), smart_temp_ind = validate(cnt
     .smart_template_ind,0)
    FROM message_type_template_reltn mtt,
     clinical_note_template cnt,
     long_blob lb
    PLAN (mtt
     WHERE expand(num,1,messagetype_cnt,mtt.message_type_cd,request->message_list[num].
      message_type_cd))
     JOIN (cnt
     WHERE cnt.template_id=mtt.template_id
      AND cnt.smart_template_ind < 2)
     JOIN (lb
     WHERE cnt.long_blob_id=lb.long_blob_id)
    ORDER BY mtt.message_type_cd, mtt.template_id
   ELSE INTO "nl:"
    cnttemplate_name = validate(cnt.template_name,""), cntlong_blob_id = validate(cnt.long_blob_id,
     0.0), ntevent_cd = validate(nt.event_cd,0.0),
    ntnote_type_description = validate(nt.note_type_description,""), nttnote_type_id = validate(ntt
     .note_type_id,0.0), lblong_blob = validate(lb.long_blob,""),
    smart_temp_cd = validate(cnt.smart_template_cd,0.0), smart_temp_ind = validate(cnt
     .smart_template_ind,0)
    FROM message_type_template_reltn mtt
    PLAN (mtt
     WHERE expand(num,1,messagetype_cnt,mtt.message_type_cd,request->message_list[num].
      message_type_cd))
    ORDER BY mtt.message_type_cd
   ENDIF
   HEAD REPORT
    tr_cnt = 0
   HEAD mtt.message_type_cd
    tr_cnt = (tr_cnt+ 1)
    IF (mod(tr_cnt,10)=1)
     stat = alterlist(reply->relation_list,(tr_cnt+ 9))
    ENDIF
    reply->relation_list[tr_cnt].message_type_cd = mtt.message_type_cd, template_cnt = 0
   HEAD mtt.template_id
    template_cnt = (template_cnt+ 1)
    IF (mod(template_cnt,10)=1)
     stat = alterlist(reply->relation_list[tr_cnt].template_list,(template_cnt+ 9))
    ENDIF
    reply->relation_list[tr_cnt].template_list[template_cnt].default_ind = mtt.default_ind, reply->
    relation_list[tr_cnt].template_list[template_cnt].template_id = mtt.template_id, reply->
    relation_list[tr_cnt].template_list[template_cnt].med_ind = mtt.med_ind
    IF ((request->load_names=1))
     reply->relation_list[tr_cnt].template_list[template_cnt].template_name = cnttemplate_name, reply
     ->relation_list[tr_cnt].template_list[template_cnt].long_blob_id = cntlong_blob_id, reply->
     relation_list[tr_cnt].template_list[template_cnt].smart_template_cd = smart_temp_cd,
     reply->relation_list[tr_cnt].template_list[template_cnt].smart_template_ind = smart_temp_ind
    ENDIF
    IF ((request->default_template_id > 0)
     AND (request->default_template_id=mtt.template_id))
     reply->default_template_text = trim(lblong_blob)
    ENDIF
    nr_cnt = 0
   DETAIL
    IF ((request->load_note_types=1))
     nr_cnt = (nr_cnt+ 1)
     IF (mod(nr_cnt,10)=1)
      stat = alterlist(reply->relation_list[tr_cnt].template_list[template_cnt].note_list,(nr_cnt+ 9)
       )
     ENDIF
     reply->relation_list[tr_cnt].template_list[template_cnt].note_list[nr_cnt].note_type_id =
     nttnote_type_id, reply->relation_list[tr_cnt].template_list[template_cnt].note_list[nr_cnt].
     note_type_description = ntnote_type_description, reply->relation_list[tr_cnt].template_list[
     template_cnt].note_list[nr_cnt].event_cd = ntevent_cd
    ENDIF
   FOOT  mtt.template_id
    stat = alterlist(reply->relation_list[tr_cnt].template_list[template_cnt].note_list,nr_cnt)
   FOOT  mtt.message_type_cd
    stat = alterlist(reply->relation_list[tr_cnt].template_list,template_cnt)
   FOOT REPORT
    stat = alterlist(reply->relation_list,tr_cnt)
   WITH nocounter
  ;end select
  IF (error(error_string,0))
   SET reply->status_data.subeventstatus[1].targetobjectvalue = error_string
  ENDIF
 ENDIF
 IF (size(reply->relation_list,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "MOD 001 06/28/06 JF7198"
END GO
