CREATE PROGRAM bed_get_alias_pool_details:dba
 FREE SET reply
 RECORD reply(
   1 details[*]
     2 alias_pool_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 check_digit_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 check_digit_script = vc
     2 sequence[*]
       3 seqtype
         4 code_value = f8
         4 display = vc
         4 mean = vc
       3 max = f8
       3 start = f8
       3 current = f8
     2 enc_groups[*]
       3 group_code_value = f8
       3 group_name = vc
       3 enc_types[*]
         4 enc_type_code_value = f8
         4 enc_type_display = vc
     2 alias_method_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 extension_pool_code
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 combine_flag = i4
     2 reassign_option_ind = i2
     2 effective_alias_ind = i2
     2 append_value = vc
     2 person_reltn_flag = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE apcnt = i4
 DECLARE repcnt = i4
 DECLARE seqcnt = i4
 DECLARE etgcnt = i4
 DECLARE etcnt = i4
 DECLARE check_digit_code = f8
 DECLARE alias_method_code = f8
 DECLARE combine_flag = i4
 DECLARE extension_pool_code = f8
 DECLARE def_sequence_cd = f8
 DECLARE def_sequence_disp = vc
 DECLARE def_sequence_mean = vc
 DECLARE default_found = i2
 DECLARE error_msg = vc
 DECLARE effective_alias_ind = i2
 DECLARE append_value = vc
 DECLARE person_reltn_flag = i4 WITH noconstant(0), protect
 DECLARE person_reltn_flag_ind = i2 WITH noconstant(0), protect
 SET error_flag = "F"
 SET apcnt = 0
 SET default_found = 0
 IF (validate(request->load.person_reltn_flag_ind))
  SET person_reltn_flag_ind = request->load.person_reltn_flag_ind
 ENDIF
 IF ((request->load.check_digit_ind=0)
  AND (request->load.seq_ind=0)
  AND (request->load.enc_group_ind=0)
  AND (request->load.method_ind=0)
  AND (request->load.combine_ind=0)
  AND (request->load.effective_alias_ind=0)
  AND person_reltn_flag_ind=0)
  SET error_flag = "T"
  SET error_msg = "No load indicators set to 1.  Script terminating."
  GO TO exit_script
 ENDIF
 SET apcnt = size(request->alias_pools,5)
 SET repcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=14163
    AND cv.cdf_meaning="DEFAULT"
    AND cv.active_ind=1)
  DETAIL
   def_sequence_cd = cv.code_value, def_sequence_disp = cv.display, def_sequence_mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 FOR (ii = 1 TO apcnt)
   SET check_digit_code = 0.0
   SET alias_method_code = 0.0
   SET combine_flag = 0
   SET extension_pool_code = 0.0
   SET append_value = ""
   SET person_reltn_flag = 0
   SELECT INTO "nl:"
    FROM alias_pool ap
    PLAN (ap
     WHERE (ap.alias_pool_cd=request->alias_pools[ii].code_value))
    DETAIL
     repcnt = (repcnt+ 1), stat = alterlist(reply->details,repcnt), reply->details[repcnt].
     alias_pool_code.code_value = ap.alias_pool_cd,
     reply->details[repcnt].alias_pool_code.display = ap.description, check_digit_code = ap
     .check_digit_cd, alias_method_code = ap.alias_method_cd,
     combine_flag = ap.cmb_inactive_ind, person_reltn_flag = ap.sys_assign_related_person_flag,
     extension_pool_code = ap.alias_pool_ext_cd
     IF (validate(ap.effective_alias_ind)=1)
      effective_alias_ind = ap.effective_alias_ind
     ELSE
      effective_alias_ind = 0
     ENDIF
     append_value = ap.alias_append_value
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF ((request->load.check_digit_ind=1))
     IF (check_digit_code > 0)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_value=check_digit_code
         AND cv.code_set=266
         AND cv.active_ind=1)
       DETAIL
        reply->details[repcnt].check_digit_code.code_value = cv.code_value, reply->details[repcnt].
        check_digit_code.display = cv.display, reply->details[repcnt].check_digit_code.mean = cv
        .cdf_meaning
       WITH nocounter
      ;end select
      SET reply->details[repcnt].check_digit_script = fillstring(30," ")
      SELECT INTO "nl:"
       FROM code_value_extension cve
       PLAN (cve
        WHERE cve.code_value=check_digit_code
         AND cve.code_set=266
         AND cve.field_name="SCRIPT")
       DETAIL
        reply->details[repcnt].check_digit_script = cve.field_value
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF ((request->load.seq_ind=1))
     SET seqcnt = 0
     SELECT INTO "nl:"
      FROM alias_pool_seq aps,
       code_value cv
      PLAN (aps
       WHERE (aps.alias_pool_cd=request->alias_pools[ii].code_value))
       JOIN (cv
       WHERE cv.code_value=aps.ap_seq_type_cd
        AND cv.active_ind=1)
      DETAIL
       seqcnt = (seqcnt+ 1), stat = alterlist(reply->details[repcnt].sequence,seqcnt), reply->
       details[repcnt].sequence[seqcnt].seqtype.code_value = aps.ap_seq_type_cd,
       reply->details[repcnt].sequence[seqcnt].seqtype.display = cv.display, reply->details[repcnt].
       sequence[seqcnt].seqtype.mean = cv.cdf_meaning, reply->details[repcnt].sequence[seqcnt].
       current = aps.next_nbr,
       reply->details[repcnt].sequence[seqcnt].max = aps.max_nbr, reply->details[repcnt].sequence[
       seqcnt].start = aps.start_nbr
       IF (aps.ap_seq_type_cd=def_sequence_cd)
        default_found = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (default_found=0)
      SET seqcnt = (seqcnt+ 1)
      SET stat = alterlist(reply->details[repcnt].sequence,seqcnt)
      SET reply->details[repcnt].sequence[seqcnt].seqtype.code_value = def_sequence_cd
      SET reply->details[repcnt].sequence[seqcnt].seqtype.display = def_sequence_disp
      SET reply->details[repcnt].sequence[seqcnt].seqtype.mean = def_sequence_mean
      SET reply->details[repcnt].sequence[seqcnt].current = 0
      SET reply->details[repcnt].sequence[seqcnt].max = 0
      SET reply->details[repcnt].sequence[seqcnt].start = 0
     ENDIF
    ENDIF
    IF ((request->load.enc_group_ind=1))
     SET etgcnt = 0
     SELECT INTO "nl:"
      FROM alias_pool_seq aps,
       code_value cv,
       code_value_group cvg,
       code_value cv2
      PLAN (aps
       WHERE (aps.alias_pool_cd=request->alias_pools[ii].code_value))
       JOIN (cv
       WHERE cv.code_value=aps.ap_seq_type_cd
        AND cv.active_ind=1
        AND cv.code_value != def_sequence_cd)
       JOIN (cvg
       WHERE cvg.parent_code_value=outerjoin(cv.code_value)
        AND cvg.child_code_value > outerjoin(0))
       JOIN (cv2
       WHERE cv2.code_value=outerjoin(cvg.child_code_value))
      ORDER BY cv.display
      HEAD cv.display
       etgcnt = (etgcnt+ 1), etcnt = 0, stat = alterlist(reply->details[repcnt].enc_groups,etgcnt),
       reply->details[repcnt].enc_groups[etgcnt].group_code_value = cv.code_value, reply->details[
       repcnt].enc_groups[etgcnt].group_name = cv.display
      DETAIL
       IF (cvg.parent_code_value > 0)
        etcnt = (etcnt+ 1), stat = alterlist(reply->details[repcnt].enc_groups[etgcnt].enc_types,
         etcnt), reply->details[repcnt].enc_groups[etgcnt].enc_types[etcnt].enc_type_code_value = cvg
        .child_code_value,
        reply->details[repcnt].enc_groups[etgcnt].enc_types[etcnt].enc_type_display = cv2.display
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM code_value_extension cve
      PLAN (cve
       WHERE cve.code_set=263
        AND cve.field_name="ALIASREASSIGN"
        AND (cve.code_value=request->alias_pools[ii].code_value))
      DETAIL
       reply->details[repcnt].reassign_option_ind = cnvtint(cve.field_value)
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->load.method_ind=1))
     IF (alias_method_code > 0)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_value=alias_method_code
         AND cv.code_set=14765
         AND cv.active_ind=1)
       DETAIL
        reply->details[repcnt].alias_method_code.code_value = cv.code_value, reply->details[repcnt].
        alias_method_code.display = cv.display, reply->details[repcnt].alias_method_code.mean = cv
        .cdf_meaning
       WITH nocounter
      ;end select
     ENDIF
     IF (extension_pool_code > 0)
      SELECT INTO "nl:"
       FROM code_value cv
       PLAN (cv
        WHERE cv.code_value=extension_pool_code
         AND cv.code_set=263
         AND cv.active_ind=1)
       DETAIL
        reply->details[repcnt].extension_pool_code.code_value = cv.code_value, reply->details[repcnt]
        .extension_pool_code.display = cv.display, reply->details[repcnt].extension_pool_code.mean =
        cv.cdf_meaning
       WITH nocounter
      ;end select
     ENDIF
     IF (textlen(trim(append_value,3)) > 0)
      SET reply->details[repcnt].append_value = append_value
     ENDIF
    ENDIF
    IF ((request->load.combine_ind=1))
     SET reply->details[repcnt].combine_flag = combine_flag
    ENDIF
    IF ((request->load.effective_alias_ind=1))
     SET reply->details[repcnt].effective_alias_ind = effective_alias_ind
    ENDIF
    IF (person_reltn_flag_ind=1)
     SET reply->details[repcnt].person_reltn_flag = person_reltn_flag
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_DETAILS >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
