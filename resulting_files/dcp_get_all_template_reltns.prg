CREATE PROGRAM dcp_get_all_template_reltns
 RECORD reply(
   1 relation_list[*]
     2 note_type_id = f8
     2 note_type_description = vc
     2 event_code_description = vc
     2 event_cd = f8
     2 active_ind = i2
     2 banner_ind = i2
     2 device_name = c100
     2 publish_level = i4
     2 default_level_flag = i2
     2 override_level_ind = i2
     2 template_list[*]
       3 note_type_template_reltn_id = f8
       3 template_id = f8
       3 template_name = vc
       3 template_active_ind = i2
       3 smart_template_cd = f8
       3 smart_template_ind = i2
       3 long_blob_id = f8
       3 owner_type_flag = i2
       3 prsnl_id = f8
       3 updt_dt_tm = dq8
       3 default_ind = i2
       3 cki = vc
       3 prsnl_loc_template_list[*]
         4 note_type_description = vc
         4 note_type_id = f8
         4 prsnl_id = f8
         4 prsnl_name_full_formatted = vc
         4 location_cd = f8
         4 location_display = vc
         4 default_ind = i2
   1 template_list[*]
     2 note_type_template_reltn_id = f8
     2 template_id = f8
     2 template_name = vc
     2 template_active_ind = i2
     2 smart_template_cd = f8
     2 smart_template_ind = i2
     2 long_blob_id = f8
     2 owner_type_flag = i2
     2 prsnl_id = f8
     2 updt_dt_tm = dq8
     2 cki = vc
     2 prsnl_loc_template_list[*]
       3 note_type_description = vc
       3 note_type_id = f8
       3 prsnl_id = f8
       3 prsnl_name_full_formatted = vc
       3 location_cd = f8
       3 location_display = vc
       3 default_ind = i2
     2 note_type_list[*]
       3 note_type_description = vc
       3 note_type_id = f8
       3 event_code_description = vc
       3 event_cd = f8
       3 active_ind = i2
       3 banner_ind = i2
       3 publish_level = i4
       3 device_name = c100
       3 default_level_flag = i2
       3 override_level_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->include_mail_merge_temp_ind=1))INTO "nl:"
   FROM note_type nt,
    v500_event_code ec,
    note_type_template_reltn nttr,
    prsnl_loc_template_reltn pltr,
    clinical_note_template cnt,
    prsnl p
   PLAN (nt
    WHERE nt.note_type_id > 0)
    JOIN (ec
    WHERE nt.event_cd=ec.event_cd)
    JOIN (nttr
    WHERE nttr.note_type_id=outerjoin(nt.note_type_id))
    JOIN (pltr
    WHERE pltr.note_type_template_reltn_id=outerjoin(nttr.note_type_template_reltn_id))
    JOIN (cnt
    WHERE cnt.template_id=outerjoin(nttr.template_id))
    JOIN (p
    WHERE p.person_id=outerjoin(pltr.prsnl_id))
   ORDER BY nt.note_type_id, nttr.note_type_template_reltn_id
  ELSE INTO "nl:"
   FROM note_type nt,
    v500_event_code ec,
    note_type_template_reltn nttr,
    prsnl_loc_template_reltn pltr,
    clinical_note_template cnt,
    prsnl p
   PLAN (nt
    WHERE nt.note_type_id > 0)
    JOIN (ec
    WHERE nt.event_cd=ec.event_cd)
    JOIN (nttr
    WHERE nttr.note_type_id=outerjoin(nt.note_type_id))
    JOIN (pltr
    WHERE pltr.note_type_template_reltn_id=outerjoin(nttr.note_type_template_reltn_id))
    JOIN (cnt
    WHERE cnt.template_id=nttr.template_id
     AND ((cnt.smart_template_ind+ 0) < 2))
    JOIN (p
    WHERE p.person_id=outerjoin(pltr.prsnl_id))
   ORDER BY nt.note_type_id, nttr.note_type_template_reltn_id
  ENDIF
  HEAD REPORT
   note_type_cnt = 0
  HEAD nt.note_type_id
   note_type_cnt = (note_type_cnt+ 1)
   IF (mod(note_type_cnt,10)=1)
    stat = alterlist(reply->relation_list,(note_type_cnt+ 9))
   ENDIF
   reply->relation_list[note_type_cnt].note_type_id = nt.note_type_id, reply->relation_list[
   note_type_cnt].note_type_description = nt.note_type_description, reply->relation_list[
   note_type_cnt].event_cd = nt.event_cd,
   reply->relation_list[note_type_cnt].active_ind = nt.data_status_ind, reply->relation_list[
   note_type_cnt].banner_ind = nt.banner_ind, reply->relation_list[note_type_cnt].device_name = nt
   .device_name,
   reply->relation_list[note_type_cnt].publish_level = nt.publish_level, reply->relation_list[
   note_type_cnt].event_code_description = ec.event_cd_descr, reply->relation_list[note_type_cnt].
   default_level_flag = nt.default_level_flag,
   reply->relation_list[note_type_cnt].override_level_ind = nt.override_level_ind, template_rel_cnt
    = 0
  HEAD nttr.note_type_template_reltn_id
   IF (nttr.note_type_template_reltn_id > 0)
    template_rel_cnt = (template_rel_cnt+ 1)
    IF (mod(template_rel_cnt,10)=1)
     stat = alterlist(reply->relation_list[note_type_cnt].template_list,(template_rel_cnt+ 9))
    ENDIF
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].note_type_template_reltn_id
     = nttr.note_type_template_reltn_id, reply->relation_list[note_type_cnt].template_list[
    template_rel_cnt].default_ind = nttr.default_ind, reply->relation_list[note_type_cnt].
    template_list[template_rel_cnt].template_id = cnt.template_id,
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].template_name = cnt
    .template_name, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
    template_active_ind = cnt.template_active_ind, reply->relation_list[note_type_cnt].template_list[
    template_rel_cnt].smart_template_cd = cnt.smart_template_cd,
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].smart_template_ind = cnt
    .smart_template_ind, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
    updt_dt_tm = cnt.updt_dt_tm, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
    long_blob_id = cnt.long_blob_id,
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].owner_type_flag = cnt
    .owner_type_flag, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].prsnl_id =
    cnt.prsnl_id, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].cki = cnt.cki
   ENDIF
   pltr_cnt = 0
  HEAD pltr.prsnl_loc_template_reltn_id
   IF (pltr.note_type_template_reltn_id > 0
    AND pltr.prsnl_loc_template_reltn_id > 0)
    pltr_cnt = (pltr_cnt+ 1)
    IF (mod(pltr_cnt,10)=1)
     stat = alterlist(reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
      prsnl_loc_template_list,(pltr_cnt+ 9))
    ENDIF
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].prsnl_loc_template_list[
    pltr_cnt].note_type_id = nt.note_type_id, reply->relation_list[note_type_cnt].template_list[
    template_rel_cnt].prsnl_loc_template_list[pltr_cnt].note_type_description = nt
    .note_type_description, reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
    prsnl_loc_template_list[pltr_cnt].prsnl_id = pltr.prsnl_id,
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].prsnl_loc_template_list[
    pltr_cnt].location_cd = pltr.location_cd, reply->relation_list[note_type_cnt].template_list[
    template_rel_cnt].prsnl_loc_template_list[pltr_cnt].default_ind = pltr.default_ind, reply->
    relation_list[note_type_cnt].template_list[template_rel_cnt].prsnl_loc_template_list[pltr_cnt].
    location_display = uar_get_code_display(pltr.location_cd),
    reply->relation_list[note_type_cnt].template_list[template_rel_cnt].prsnl_loc_template_list[
    pltr_cnt].prsnl_name_full_formatted =
    IF (p.person_id > 0) p.name_full_formatted
    ELSE ""
    ENDIF
   ENDIF
  DETAIL
   pltr_cnt = (pltr_cnt+ 0)
  FOOT  pltr.prsnl_loc_template_reltn_id
   pltr_cnt = (pltr_cnt+ 0)
  FOOT  nttr.note_type_template_reltn_id
   IF (nttr.note_type_template_reltn_id > 0)
    stat = alterlist(reply->relation_list[note_type_cnt].template_list[template_rel_cnt].
     prsnl_loc_template_list,pltr_cnt)
   ENDIF
  FOOT  nt.note_type_id
   stat = alterlist(reply->relation_list[note_type_cnt].template_list,template_rel_cnt)
  FOOT REPORT
   stat = alterlist(reply->relation_list,note_type_cnt)
  WITH nocounter
 ;end select
 SELECT
  IF ((request->include_mail_merge_temp_ind=1))INTO "nl:"
   FROM clinical_note_template t,
    note_type_template_reltn n,
    note_type nt,
    prsnl_loc_template_reltn p,
    person per
   PLAN (t
    WHERE t.template_id > 0)
    JOIN (n
    WHERE n.template_id=outerjoin(t.template_id))
    JOIN (nt
    WHERE nt.note_type_id=outerjoin(n.note_type_id))
    JOIN (p
    WHERE outerjoin(n.note_type_template_reltn_id)=p.note_type_template_reltn_id)
    JOIN (per
    WHERE outerjoin(p.prsnl_id)=per.person_id)
   ORDER BY t.template_id, n.note_type_template_reltn_id
  ELSE INTO "nl:"
   FROM clinical_note_template t,
    note_type_template_reltn n,
    note_type nt,
    prsnl_loc_template_reltn p,
    person per
   PLAN (t
    WHERE t.template_id > 0)
    JOIN (n
    WHERE n.template_id=outerjoin(t.template_id)
     AND ((outerjoin(t.smart_template_ind)=0) OR (outerjoin(t.smart_template_ind)=1)) )
    JOIN (nt
    WHERE nt.note_type_id=outerjoin(n.note_type_id))
    JOIN (p
    WHERE outerjoin(n.note_type_template_reltn_id)=p.note_type_template_reltn_id)
    JOIN (per
    WHERE outerjoin(p.prsnl_id)=per.person_id)
   ORDER BY t.template_id, n.note_type_template_reltn_id
  ENDIF
  HEAD REPORT
   template_cnt = 0
  HEAD t.template_id
   template_cnt = (template_cnt+ 1)
   IF (mod(template_cnt,10)=1)
    stat = alterlist(reply->template_list,(template_cnt+ 9))
   ENDIF
   reply->template_list[template_cnt].template_id = t.template_id, reply->template_list[template_cnt]
   .template_name = t.template_name, reply->template_list[template_cnt].template_active_ind = t
   .template_active_ind,
   reply->template_list[template_cnt].smart_template_ind = t.smart_template_ind, reply->
   template_list[template_cnt].smart_template_cd = t.smart_template_cd, reply->template_list[
   template_cnt].updt_dt_tm = t.updt_dt_tm,
   reply->template_list[template_cnt].long_blob_id = t.long_blob_id, reply->template_list[
   template_cnt].cki = t.cki, relation_cnt = 0,
   note_type_count = 0
  HEAD n.note_type_template_reltn_id
   IF (nt.note_type_id > 0)
    note_type_count = (note_type_count+ 1)
    IF (mod(note_type_count,10)=1)
     stat = alterlist(reply->template_list[template_cnt].note_type_list,(note_type_count+ 9))
    ENDIF
    reply->template_list[template_cnt].note_type_list[note_type_count].note_type_id = nt.note_type_id,
    reply->template_list[template_cnt].note_type_list[note_type_count].note_type_description = nt
    .note_type_description, reply->template_list[template_cnt].note_type_list[note_type_count].
    default_level_flag = nt.default_level_flag,
    reply->template_list[template_cnt].note_type_list[note_type_count].override_level_ind = nt
    .override_level_ind
   ENDIF
  DETAIL
   IF (p.note_type_template_reltn_id > 0
    AND p.prsnl_loc_template_reltn_id > 0)
    relation_cnt = (relation_cnt+ 1)
    IF (mod(relation_cnt,10)=1)
     stat = alterlist(reply->template_list[template_cnt].prsnl_loc_template_list,(relation_cnt+ 9))
    ENDIF
    reply->template_list[template_cnt].prsnl_loc_template_list[relation_cnt].note_type_id = nt
    .note_type_id, reply->template_list[template_cnt].prsnl_loc_template_list[relation_cnt].
    note_type_description = nt.note_type_description, reply->template_list[template_cnt].
    prsnl_loc_template_list[relation_cnt].prsnl_id = p.prsnl_id,
    reply->template_list[template_cnt].prsnl_loc_template_list[relation_cnt].location_cd = p
    .location_cd, reply->template_list[template_cnt].prsnl_loc_template_list[relation_cnt].
    location_display = uar_get_code_display(p.location_cd), reply->template_list[template_cnt].
    prsnl_loc_template_list[relation_cnt].prsnl_name_full_formatted =
    IF (per.person_id > 0) per.name_full_formatted
    ELSE ""
    ENDIF
    ,
    reply->template_list[template_cnt].prsnl_loc_template_list[relation_cnt].default_ind = p
    .default_ind
   ENDIF
  FOOT  n.note_type_template_reltn_id
   stat = alterlist(reply->template_list[template_cnt].note_type_list,note_type_count),
   note_type_count = 0
  FOOT  t.template_id
   stat = alterlist(reply->template_list[template_cnt].prsnl_loc_template_list,relation_cnt)
  FOOT REPORT
   stat = alterlist(reply->template_list,template_cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
