CREATE PROGRAM cps_get_summary_sheet:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET false = 0
 SET true = 1
 RECORD reply(
   1 prsnl_id = f8
   1 person_id = f8
   1 display = c40
   1 description = vc
   1 clinical_event_ind = i4
   1 summary_section_qual = i4
   1 summary_section[0]
     2 section_id = f8
     2 prsnl_id = f8
     2 display = c40
     2 subject_area_cd = f8
     2 subject_area_disp = c40
     2 subject_area_desc = c60
     2 subject_area_mean = c12
     2 section_type_cd = f8
     2 section_type_disp = c40
     2 section_type_desc = c60
     2 section_type_mean = c12
     2 comment_text = vc
     2 sortable_ind = i2
     2 script = vc
     2 max_qual = i4
     2 sequence = i4
     2 default_expand_ind = i2
     2 section_r_qual = i4
     2 section_r[*]
       3 child_id = f8
       3 sequence = i4
     2 section_attribute_qual = i4
     2 section_attribute[*]
       3 column_num = i4
       3 subj_area_dtl_cd = f8
       3 subj_area_dtl_disp = c40
       3 subj_area_dtl_desc = c60
       3 subj_area_dtl_mean = c12
       3 width = i4
       3 detail_type_cd = f8
       3 detail_type_disp = c40
       3 detail_type_desc = c60
       3 detail_type_mean = c12
       3 detail_value = vc
       3 output_mask = vc
       3 sort_direction_cd = f8
       3 sort_direction_disp = c40
       3 sort_direction_desc = c60
       3 sort_direction_mean = c12
   1 encounter_qual = i4
   1 encounter[0]
     2 encntr_id = f8
     2 beg_effective_dt_tm = dq8
     2 encntr_type_class_cd = f8
     2 encntr_type_class_disp = c40
     2 encntr_type_class_desc = c60
     2 encntr_type_class_mean = c12
     2 pre_reg_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 arrive_dt_tm = dq8
     2 admit_type_cd = f8
     2 admit_type_disp = c40
     2 admit_type_desc = c60
     2 admit_type_mean = c12
     2 referring_comment = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_facility_desc = c60
     2 loc_facility_mean = c12
     2 reason_for_visit = vc
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET gmax2 = 0
 SET gmax3 = 0
 SET gmax4 = 0
 SET failed = false
 IF ((request->summary_section_qual=0))
  SET reply->status_data.status = "F"
  SET table_name = "SUMMARY_SHEET"
  SELECT INTO "NL:"
   s.summary_sheet_id, s.display, s.description
   FROM summary_sheet s
   WHERE (s.summary_sheet_id=request->summary_sheet_id)
   DETAIL
    reply->prsnl_id = s.prsnl_id, reply->display = s.display, reply->description = s.description
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO end_program
  ENDIF
  SET sectkount = 0
  SET kount1 = 0
  SELECT INTO "NL:"
   s.section_id, s.display, s.prsnl_id,
   s.section_type_cd, s.comment_text, s.sortable_ind,
   s.script, s.max_qual, r.sequence,
   r.default_expand_ind
   FROM summary_section s,
    summary_section_r r
   PLAN (r
    WHERE (r.summary_sheet_id=request->summary_sheet_id))
    JOIN (s
    WHERE r.section_id=s.section_id)
   DETAIL
    sectkount += 1
    IF (mod(sectkount,10)=1)
     stat = alter(reply->summary_section,(sectkount+ 10))
    ENDIF
    reply->summary_section[sectkount].section_id = s.section_id, reply->summary_section[sectkount].
    display = s.display, reply->summary_section[sectkount].prsnl_id = s.prsnl_id,
    reply->summary_section[sectkount].section_type_cd = s.section_type_cd, reply->summary_section[
    sectkount].subject_area_cd = s.subject_area_cd, reply->summary_section[sectkount].comment_text =
    s.comment_text,
    reply->summary_section[sectkount].sortable_ind = s.sortable_ind, reply->summary_section[sectkount
    ].script = s.script, reply->summary_section[sectkount].max_qual = s.max_qual,
    reply->summary_section[sectkount].sequence = r.sequence, reply->summary_section[sectkount].
    default_expand_ind = r.default_expand_ind
   WITH nocounter
  ;end select
  SET reply->summary_section_qual = sectkount
  SET gmax2 = 0
  SET inx = 1
  SET kount = 0
  SELECT INTO "NL:"
   r.child_id, r.sequence, s.section_id,
   s.prsnl_id, s.display, s.section_type_cd,
   s.comment_text, s.sortable_ind, s.script,
   s.max_qual
   FROM section_section_r r,
    summary_section s,
    (dummyt d  WITH seq = value(reply->summary_section_qual))
   PLAN (d)
    JOIN (r
    WHERE (r.parent_id=reply->summary_section[d.seq].section_id))
    JOIN (s
    WHERE s.section_id=r.child_id)
   DETAIL
    IF (inx != d.seq)
     stat = alterlist(reply->summary_section[inx].section_r,reply->summary_section[inx].
      section_r_qual), inx = d.seq, kount = 0
    ENDIF
    kount += 1, reply->summary_section[d.seq].section_r_qual = kount
    IF (kount > gmax2
     AND mod(kount,10)=1)
     stat = alterlist(reply->summary_section[d.seq].section_r,(kount+ 10))
    ENDIF
    reply->summary_section[d.seq].section_r[kount].child_id = r.child_id, reply->summary_section[d
    .seq].section_r[kount].sequence = r.sequence, sectkount += 1
    IF (mod(sectkount,10)=1)
     stat = alter(reply->summary_section,(sectkount+ 10))
    ENDIF
    reply->summary_section[sectkount].section_id = s.section_id, reply->summary_section[sectkount].
    prsnl_id = s.prsnl_id, reply->summary_section[sectkount].display = s.display,
    reply->summary_section[sectkount].section_type_cd = s.section_type_cd, reply->summary_section[
    sectkount].subject_area_cd = s.subject_area_cd, reply->summary_section[sectkount].comment_text =
    s.comment_text,
    reply->summary_section[sectkount].sortable_ind = s.sortable_ind, reply->summary_section[sectkount
    ].script = s.script, reply->summary_section[sectkount].max_qual = s.max_qual
   WITH nocounter
  ;end select
  IF (kount > gmax2)
   SET gmax2 = kount
  ENDIF
  SET stat = alterlist(reply->summary_section[inx].section_r,kount)
  WHILE ((reply->summary_section_qual != sectkount))
    SET beginkount = (reply->summary_section_qual+ 1)
    SET reply->summary_section_qual = sectkount
    FOR (inx = beginkount TO reply->summary_section_qual)
      SET kount = 0
      SELECT INTO "NL:"
       r.child_id, r.sequence, s.section_id,
       s.display, s.section_type_cd, s.comment_text,
       s.sortable_ind, s.script, s.max_qual
       FROM section_section_r r,
        summary_section s
       PLAN (r
        WHERE (r.parent_id=reply->summary_section[inx].section_id))
        JOIN (s
        WHERE s.section_id=r.child_id)
       DETAIL
        kount += 1
        IF (kount > gmax2
         AND mod(kount,10)=1)
         stat = alterlist(reply->summary_section[inx].section_r,(kount+ 10))
        ENDIF
        reply->summary_section[inx].section_r[kount].child_id = r.child_id, reply->summary_section[
        inx].section_r[kount].sequence = r.sequence, sectkount += 1
        IF (mod(sectkount,10)=1)
         stat = alter(reply->summary_section,(sectkount+ 10))
        ENDIF
        reply->summary_section[sectkount].section_id = s.section_id, reply->summary_section[sectkount
        ].display = s.display, reply->summary_section[sectkount].section_type_cd = s.section_type_cd,
        reply->summary_section[sectkount].comment_text = s.comment_text, reply->summary_section[
        sectkount].sortable_ind = s.sortable_ind, reply->summary_section[sectkount].script = s.script,
        reply->summary_section[sectkount].max_qual = s.max_qual
       WITH nocounter
      ;end select
      SET reply->summary_section[inx].section_r_qual = kount
      IF (kount > gmax2)
       SET gmax2 = kount
      ENDIF
    ENDFOR
  ENDWHILE
  SET reply->summary_section_qual = sectkount
  SET stat = alter(reply->summary_section,sectkount)
  SET gmax2 = 0
  SET inx = 0
  SET kount = 0
  SELECT INTO "NL:"
   a.column_num, a.subj_area_dtl_cd, a.width,
   a.detail_type_cd, a.detail_value, a.output_mask,
   a.sort_direction_cd
   FROM section_attribute a,
    (dummyt d  WITH seq = value(reply->summary_section_qual))
   PLAN (d)
    JOIN (a
    WHERE (a.section_id=reply->summary_section[d.seq].section_id))
   DETAIL
    IF (inx != d.seq)
     inx = d.seq, kount = 0
    ENDIF
    kount += 1, reply->summary_section[d.seq].section_attribute_qual = kount
    IF (mod(kount,10)=1)
     stat = alterlist(reply->summary_section[d.seq].section_attribute,(kount+ 10))
    ENDIF
    reply->summary_section[d.seq].section_attribute[kount].column_num = a.column_num, reply->
    summary_section[d.seq].section_attribute[kount].subj_area_dtl_cd = a.subj_area_dtl_cd, reply->
    summary_section[d.seq].section_attribute[kount].width = a.width,
    reply->summary_section[d.seq].section_attribute[kount].detail_type_cd = a.detail_type_cd, reply->
    summary_section[d.seq].section_attribute[kount].detail_value = a.detail_value, reply->
    summary_section[d.seq].section_attribute[kount].output_mask = a.output_mask,
    reply->summary_section[d.seq].section_attribute[kount].sort_direction_cd = a.sort_direction_cd
   WITH nocounter
  ;end select
  IF (kount > gmax2)
   SET gmax2 = kount
  ENDIF
  IF ((reply->summary_section_qual > 0))
   FOR (inx = 1 TO reply->summary_section_qual)
     SET stat = alterlist(reply->summary_section[inx].section_attribute,reply->summary_section[inx].
      section_attribute_qual)
   ENDFOR
  ENDIF
 ENDIF
 IF ((reply->summary_section_qual > 0))
  FOR (inx0 = 1 TO reply->summary_section_qual)
    IF ((reply->summary_section[inx0].default_expand_ind=1))
     SET code_meaning = fillstring(12," ")
     SET code_value = reply->summary_section[inx0].subject_area_cd
     SET code_set = 12004
     SELECT INTO "nl:"
      c.code_value
      FROM code_value c
      WHERE c.code_set=code_set
       AND c.code_value=code_value
      HEAD REPORT
       code_meaning = c.cdf_meaning
      WITH nocounter
     ;end select
     CASE (code_meaning)
      OF "PATIENTINFO":
       SET request->demographic_ind = true
      OF "ENCOUNTER":
       SET request->encounter_ind = true
      OF "Clinical_Event":
       SET reply->clinical_event_ind = true
     ENDCASE
    ENDIF
  ENDFOR
  IF ((request->health_plan_ind=true))
   EXECUTE cps_get_health_plan
  ENDIF
  IF ((request->encounter_ind=true))
   EXECUTE cps_get_encounter
   IF (failed != false)
    GO TO error_check
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 GO TO error_check
#error_check
 IF (failed != true)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
 ENDIF
 GO TO end_program
#end_program
 SET pco_script_version = "001 10/03/02 SF3151"
END GO
