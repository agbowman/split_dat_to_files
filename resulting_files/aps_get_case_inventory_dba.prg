CREATE PROGRAM aps_get_case_inventory:dba
 RECORD reply(
   1 specimen_qual[*]
     2 case_specimen_id = f8
     2 tag_qual[2]
       3 tag_type_flag = i2
       3 tag_separator = c1
     2 specimen_description = vc
     2 specimen_tag = c7
     2 specimen_type_cd = f8
     2 specimen_type_disp = vc
     2 specimen_long_text_id = f8
     2 specimen_comment = vc
     2 cass_cnt = i2
     2 cass_qual[*]
       3 cassette_id = f8
       3 cassette_tag = c7
       3 task_assay_cd = f8
       3 task_assay_disp = vc
       3 origin_modifier = c7
       3 slide_cnt = i2
       3 slide_qual[*]
         4 slide_id = f8
         4 slide_tag = c7
         4 special_stain_ind = i2
         4 stain_task_assay_cd = f8
         4 stain_task_assay_disp = vc
         4 task_assay_cd = f8
         4 task_assay_disp = vc
         4 origin_modifier = c7
     2 spec_slid_cnt = i2
     2 spec_slid_qual[*]
       3 slide_id = f8
       3 slide_tag = c7
       3 special_stain_ind = i2
       3 stain_task_assay_cd = f8
       3 stain_task_assay_disp = vc
       3 task_assay_cd = f8
       3 task_assay_disp = vc
       3 origin_modifier = c7
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_reply = 0
 SET m_spec_cnt = 0
 SELECT INTO "nl:"
  cs.case_specimen_id, cs.specimen_description, cs.specimen_cd,
  cst.tag_disp, cst.tag_sequence, c.cassette_id,
  c.task_assay_cd, c_task_assay_disp = uar_get_code_display(c.task_assay_cd), ct.tag_disp,
  cass_tag_seq = decode(ct.seq,ct.tag_sequence,- (1)), s.slide_id, s.supplemental_tag,
  s.special_stain_ind, st.tag_disp, s1t.tag_disp,
  slid_tag_seq = decode(st.seq,st.tag_sequence,s1t.seq,s1t.tag_sequence,- (1)), s1.slide_id,
  join_path = decode(s1.seq,2,1)
  FROM case_specimen cs,
   ap_tag cst,
   ap_tag ct,
   ap_tag st,
   ap_tag s1t,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   cassette c,
   slide s,
   slide s1
  PLAN (cs
   WHERE (request->case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (cst
   WHERE cs.specimen_tag_id=cst.tag_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (((c
   WHERE cs.case_specimen_id=c.case_specimen_id)
   JOIN (ct
   WHERE c.cassette_tag_id=ct.tag_id)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (s
   WHERE c.cassette_id=s.cassette_id)
   JOIN (st
   WHERE s.tag_id=st.tag_id)
   ) ORJOIN ((s1
   WHERE cs.case_specimen_id=s1.case_specimen_id)
   JOIN (s1t
   WHERE s1.tag_id=s1t.tag_id)
   ))
  ORDER BY cst.tag_sequence, cass_tag_seq, slid_tag_seq
  HEAD REPORT
   m_spec_cnt = 0, m_cass_cnt = 0, m_spec_slid_cnt = 0,
   spec_slid_cnt = 0, cass_cnt = 0, slid_cnt = 0
  HEAD cst.tag_sequence
   spec_slid_cnt = 0, cass_cnt = 0, m_spec_cnt = (m_spec_cnt+ 1)
   IF (m_spec_cnt > 0)
    stat = alterlist(reply->specimen_qual,m_spec_cnt)
   ENDIF
   reply->specimen_qual[m_spec_cnt].case_specimen_id = cs.case_specimen_id, reply->specimen_qual[
   m_spec_cnt].specimen_description = cs.specimen_description, reply->specimen_qual[m_spec_cnt].
   specimen_tag = cst.tag_disp,
   reply->specimen_qual[m_spec_cnt].specimen_type_cd = cs.specimen_cd, reply->specimen_qual[
   m_spec_cnt].cass_cnt = 0, reply->specimen_qual[m_spec_cnt].spec_slid_cnt = 0,
   reply->specimen_qual[m_spec_cnt].specimen_long_text_id = cs.spec_comments_long_text_id
  HEAD cass_tag_seq
   slid_cnt = 0
   IF ((cass_tag_seq != - (1)))
    cass_cnt = (cass_cnt+ 1), stat = alterlist(reply->specimen_qual[m_spec_cnt].cass_qual,cass_cnt),
    reply->specimen_qual[m_spec_cnt].cass_cnt = cass_cnt,
    reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].cassette_id = c.cassette_id, reply->
    specimen_qual[m_spec_cnt].cass_qual[cass_cnt].cassette_tag = ct.tag_disp, reply->specimen_qual[
    m_spec_cnt].cass_qual[cass_cnt].origin_modifier = c.origin_modifier,
    reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].task_assay_cd = c.task_assay_cd, reply->
    specimen_qual[m_spec_cnt].cass_qual[cass_cnt].task_assay_disp = c_task_assay_disp, reply->
    specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_cnt = 0
   ENDIF
  DETAIL
   IF ((slid_tag_seq != - (1)))
    CASE (join_path)
     OF 1:
      slid_cnt = (slid_cnt+ 1),stat = alterlist(reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].
       slide_qual,slid_cnt),reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_cnt = slid_cnt,
      reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_qual[slid_cnt].slide_id = s.slide_id,
      reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_qual[slid_cnt].stain_task_assay_cd
       = s.stain_task_assay_cd,reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_qual[
      slid_cnt].slide_tag = st.tag_disp,
      reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_qual[slid_cnt].special_stain_ind = s
      .special_stain_ind,reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].slide_qual[slid_cnt].
      task_assay_cd = s.task_assay_cd,reply->specimen_qual[m_spec_cnt].cass_qual[cass_cnt].
      slide_qual[slid_cnt].origin_modifier = s.origin_modifier
     OF 2:
      spec_slid_cnt = (spec_slid_cnt+ 1),stat = alterlist(reply->specimen_qual[m_spec_cnt].
       spec_slid_qual,spec_slid_cnt),reply->specimen_qual[m_spec_cnt].spec_slid_cnt = spec_slid_cnt,
      reply->specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].slide_id = s1.slide_id,reply->
      specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].stain_task_assay_cd = s1
      .stain_task_assay_cd,reply->specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].slide_tag
       = s1t.tag_disp,
      reply->specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].special_stain_ind = s1
      .special_stain_ind,reply->specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].task_assay_cd
       = s1.task_assay_cd,reply->specimen_qual[m_spec_cnt].spec_slid_qual[spec_slid_cnt].
      origin_modifier = s1.origin_modifier
    ENDCASE
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF (curqual=0)
  SET nbr_reply = (nbr_reply+ 1)
  IF (nbr_reply > 1)
   SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
  ENDIF
  SET reply->status_data.subeventstatus[nbr_reply].operationname = "SELECT"
  SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
  SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "CASE_SPECIMEN, etc"
  SET failed = "T"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(m_spec_cnt)),
   long_text lt
  PLAN (d1
   WHERE (reply->specimen_qual[d1.seq].specimen_long_text_id > 0))
   JOIN (lt
   WHERE (reply->specimen_qual[d1.seq].specimen_long_text_id=lt.long_text_id))
  DETAIL
   reply->specimen_qual[d1.seq].specimen_comment = lt.long_text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.prefix_id, aptg_r.tag_type_flag, aptg_r.tag_separator
  FROM pathology_case pc,
   (dummyt d  WITH seq = 1),
   ap_prefix_tag_group_r aptg_r
  PLAN (d)
   JOIN (pc
   WHERE (request->case_id=pc.case_id))
   JOIN (aptg_r
   WHERE pc.prefix_id=aptg_r.prefix_id
    AND aptg_r.tag_type_flag > 1)
  HEAD REPORT
   tag_ctr = 0
  HEAD pc.prefix_id
   tag_ctr = (tag_ctr+ 0)
  DETAIL
   tag_ctr = (tag_ctr+ 1), reply->specimen_qual[d.seq].tag_qual[tag_ctr].tag_type_flag = aptg_r
   .tag_type_flag, reply->specimen_qual[d.seq].tag_qual[tag_ctr].tag_separator = aptg_r.tag_separator
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "prefix_tag_group_r"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
END GO
