CREATE PROGRAM acm_get_service_resource_by_id:dba
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 resource_qual_cnt = i4
    1 resource_qual[*]
      2 status = i2
      2 active_ind = i2
      2 service_resource_cd = f8
      2 service_resource_type_cd = f8
      2 ancestor_qual_cnt = i4
      2 ancestor_qual[*]
        3 service_resource_cd = f8
      2 descendant_qual_cnt = i4
      2 descendant_qual[*]
        3 service_resource_cd = f8
        3 active_ind = i2
        3 sequence = i2
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
      2 prsnl_qual_cnt = i4
      2 prsnl_qual[*]
        3 prsnl_id = f8
      2 location_cd = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 clia_number_txt = vc
      2 organization_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD xref
 RECORD xref(
   1 inst_cnt = i4
   1 inst[*]
     2 idx = i4
     2 res_cd = f8
   1 dept_cnt = i4
   1 dept[*]
     2 idx = i4
     2 res_cd = f8
   1 sect_cnt = i4
   1 sect[*]
     2 idx = i4
     2 res_cd = f8
   1 subs_cnt = i4
   1 subs[*]
     2 idx = i4
     2 res_cd = f8
   1 lvl5_cnt = i4
   1 lvl5[*]
     2 idx = i4
     2 res_cd = f8
 )
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 DECLARE t1 = i4 WITH protect, noconstant(0)
 DECLARE d_seq = i4 WITH protect, noconstant(0)
 DECLARE t_seq = i4 WITH protect, noconstant(0)
 DECLARE xpand_cntr = i4 WITH protect, noconstant(0)
 DECLARE xpand_slice = i4 WITH protect, constant(190)
 DECLARE xpand_beg = i4 WITH protect, noconstant(0)
 DECLARE xpand_end = i4 WITH protect, noconstant(0)
 DECLARE sq1 = i4 WITH protect, noconstant(0)
 DECLARE nbr_correct = i4 WITH protect, noconstant(0)
 DECLARE institution_type_cd = f8 WITH protect, constant(loadcodevalue(223,"INSTITUTION",0))
 DECLARE department_type_cd = f8 WITH protect, constant(loadcodevalue(223,"DEPARTMENT",0))
 DECLARE libgrp_type_cd = f8 WITH protect, constant(loadcodevalue(223,"LIBGRP",0))
 DECLARE section_type_cd = f8 WITH protect, constant(loadcodevalue(223,"SECTION",0))
 DECLARE surgarea_type_cd = f8 WITH protect, constant(loadcodevalue(223,"SURGAREA",0))
 DECLARE libtrkpt_type_cd = f8 WITH protect, constant(loadcodevalue(223,"LIBTRKPT",0))
 DECLARE subsection_type_cd = f8 WITH protect, constant(loadcodevalue(223,"SUBSECTION",0))
 DECLARE surgstage_type_cd = f8 WITH protect, constant(loadcodevalue(223,"SURGSTAGE",0))
 SET reply->resource_qual_cnt = size(request->resource_qual,5)
 SET stat = alterlist(reply->resource_qual,reply->resource_qual_cnt)
 SET failed = false
 SET reply->status_data.status = "F"
 FOR (icnt = 1 TO reply->resource_qual_cnt)
  SET reply->resource_qual[icnt].service_resource_cd = request->resource_qual[icnt].
  service_resource_cd
  SET reply->resource_qual[icnt].status = 0
 ENDFOR
 SELECT INTO "nl:"
  FROM service_resource sr
  WHERE expand(t1,1,reply->resource_qual_cnt,sr.service_resource_cd,reply->resource_qual[t1].
   service_resource_cd)
  HEAD REPORT
   xref->inst_cnt = 0, xref->dept_cnt = 0, xref->sect_cnt = 0,
   xref->subs_cnt = 0, xref->lvl5_cnt = 0
  DETAIL
   nbr_correct += 1, d_seq = locateval(t1,1,reply->resource_qual_cnt,sr.service_resource_cd,reply->
    resource_qual[t1].service_resource_cd), reply->resource_qual[d_seq].status = 1,
   reply->resource_qual[d_seq].service_resource_cd = sr.service_resource_cd, reply->resource_qual[
   d_seq].service_resource_type_cd = sr.service_resource_type_cd, reply->resource_qual[d_seq].
   active_ind = sr.active_ind,
   reply->resource_qual[d_seq].location_cd = sr.location_cd, reply->resource_qual[d_seq].
   beg_effective_dt_tm = sr.beg_effective_dt_tm, reply->resource_qual[d_seq].end_effective_dt_tm = sr
   .end_effective_dt_tm,
   reply->resource_qual[d_seq].clia_number_txt = sr.clia_number_txt,
   CALL validatesub(null)
   IF ((request->load.ancestor_ind=1))
    IF ((reply->resource_qual[d_seq].service_resource_type_cd=institution_type_cd))
     xref->inst_cnt += 1
     IF (mod(xref->inst_cnt,10)=1)
      stat = alterlist(xref->inst,(xref->inst_cnt+ 9))
     ENDIF
     xref->inst[xref->inst_cnt].idx = d_seq, xref->inst[xref->inst_cnt].res_cd = sr
     .service_resource_cd
    ELSEIF ((reply->resource_qual[d_seq].service_resource_type_cd IN (department_type_cd,
    libgrp_type_cd)))
     xref->dept_cnt += 1
     IF (mod(xref->dept_cnt,10)=1)
      stat = alterlist(xref->dept,(xref->dept_cnt+ 9))
     ENDIF
     xref->dept[xref->dept_cnt].idx = d_seq, xref->dept[xref->dept_cnt].res_cd = sr
     .service_resource_cd
    ELSEIF ((reply->resource_qual[d_seq].service_resource_type_cd IN (section_type_cd,
    surgarea_type_cd, libtrkpt_type_cd)))
     xref->sect_cnt += 1
     IF (mod(xref->sect_cnt,10)=1)
      stat = alterlist(xref->sect,(xref->sect_cnt+ 9))
     ENDIF
     xref->sect[xref->sect_cnt].idx = d_seq, xref->sect[xref->sect_cnt].res_cd = sr
     .service_resource_cd
    ELSEIF ((reply->resource_qual[d_seq].service_resource_type_cd IN (subsection_type_cd,
    surgstage_type_cd)))
     xref->subs_cnt += 1
     IF (mod(xref->subs_cnt,10)=1)
      stat = alterlist(xref->subs,(xref->subs_cnt+ 9))
     ENDIF
     xref->subs[xref->subs_cnt].idx = d_seq, xref->subs[xref->subs_cnt].res_cd = sr
     .service_resource_cd
    ELSE
     xref->lvl5_cnt += 1
     IF (mod(xref->lvl5_cnt,10)=1)
      stat = alterlist(xref->lvl5,(xref->lvl5_cnt+ 9))
     ENDIF
     xref->lvl5[xref->lvl5_cnt].idx = d_seq, xref->lvl5[xref->lvl5_cnt].res_cd = sr
     .service_resource_cd
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(xref->inst,xref->inst_cnt), stat = alterlist(xref->dept,xref->dept_cnt), stat =
   alterlist(xref->sect,xref->sect_cnt),
   stat = alterlist(xref->subs,xref->subs_cnt), stat = alterlist(xref->lvl5,xref->lvl5_cnt)
  WITH nocounter, expand = 2
 ;end select
 IF ((((request->load.prsnl_ind=1)) OR ((request->load.descendant_ind=1))) )
  SET xpand_cntr = (reply->resource_qual_cnt/ xpand_slice)
  IF (mod(reply->resource_qual_cnt,xpand_slice) != 0)
   SET xpand_cntr += 1
  ENDIF
  FOR (sq1 = 1 TO xpand_cntr)
    SET xpand_beg = (((sq1 - 1) * xpand_slice)+ 1)
    SET xpand_end = minval(((xpand_beg+ xpand_slice) - 1),reply->resource_qual_cnt)
    IF ((request->load.prsnl_ind=1))
     SELECT INTO "nl:"
      FROM prsnl_service_resource_reltn psrr
      WHERE expand(t1,xpand_beg,xpand_end,psrr.service_resource_cd,reply->resource_qual[t1].
       service_resource_cd,
       xpand_slice)
       AND psrr.prsnl_id != 0
      ORDER BY psrr.service_resource_cd
      HEAD psrr.service_resource_cd
       prsnl_qual_cnt = 0, t_seq = locateval(t1,xpand_beg,xpand_end,psrr.service_resource_cd,reply->
        resource_qual[t1].service_resource_cd,
        xpand_slice)
      DETAIL
       prsnl_qual_cnt += 1
       IF (mod(prsnl_qual_cnt,10)=1)
        stat = alterlist(reply->resource_qual[t_seq].prsnl_qual,(prsnl_qual_cnt+ 9))
       ENDIF
       reply->resource_qual[t_seq].prsnl_qual[prsnl_qual_cnt].prsnl_id = psrr.prsnl_id
      FOOT  psrr.service_resource_cd
       stat = alterlist(reply->resource_qual[t_seq].prsnl_qual,prsnl_qual_cnt), reply->resource_qual[
       t_seq].prsnl_qual_cnt = prsnl_qual_cnt
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->load.descendant_ind=1))
     SET inactive_ineffective_desc_ind = validate(request->load.inactive_ineffective_desc_ind,0)
     SELECT
      IF (inactive_ineffective_desc_ind)
       WHERE expand(t1,xpand_beg,xpand_end,r.parent_service_resource_cd,reply->resource_qual[t1].
        service_resource_cd,
        xpand_slice)
      ELSE
       WHERE expand(t1,xpand_beg,xpand_end,r.parent_service_resource_cd,reply->resource_qual[t1].
        service_resource_cd,
        xpand_slice)
        AND r.active_ind=1
        AND r.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND r.end_effective_dt_tm > cnvtdatetime(sysdate)
      ENDIF
      INTO "nl:"
      r.child_service_resource_cd, r.parent_service_resource_cd
      FROM resource_group r
      ORDER BY r.parent_service_resource_cd
      HEAD r.parent_service_resource_cd
       descendant_qual_cnt = 0, t_seq = locateval(t1,xpand_beg,xpand_end,r.parent_service_resource_cd,
        reply->resource_qual[t1].service_resource_cd,
        xpand_slice)
      DETAIL
       descendant_qual_cnt += 1
       IF (mod(descendant_qual_cnt,10)=1)
        stat = alterlist(reply->resource_qual[t_seq].descendant_qual,(descendant_qual_cnt+ 9))
       ENDIF
       reply->resource_qual[t_seq].descendant_qual[descendant_qual_cnt].service_resource_cd = r
       .child_service_resource_cd, reply->resource_qual[t_seq].descendant_qual[descendant_qual_cnt].
       sequence = r.sequence, reply->resource_qual[t_seq].descendant_qual[descendant_qual_cnt].
       active_ind = r.active_ind,
       reply->resource_qual[t_seq].descendant_qual[descendant_qual_cnt].beg_effective_dt_tm = r
       .beg_effective_dt_tm, reply->resource_qual[t_seq].descendant_qual[descendant_qual_cnt].
       end_effective_dt_tm = r.end_effective_dt_tm
      FOOT  r.parent_service_resource_cd
       stat = alterlist(reply->resource_qual[t_seq].descendant_qual,descendant_qual_cnt), reply->
       resource_qual[t_seq].descendant_qual_cnt = descendant_qual_cnt
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 IF ((xref->dept_cnt > 0))
  SET xpand_cntr = (xref->dept_cnt/ xpand_slice)
  IF (mod(xref->dept_cnt,xpand_slice) != 0)
   SET xpand_cntr += 1
  ENDIF
  FOR (sq1 = 1 TO xpand_cntr)
    SET xpand_beg = (((sq1 - 1) * xpand_slice)+ 1)
    SET xpand_end = minval(((xpand_beg+ xpand_slice) - 1),xref->dept_cnt)
    SELECT INTO "nl:"
     FROM resource_group r1
     WHERE expand(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->dept[t1].res_cd,
      xpand_slice)
      AND r1.resource_group_type_cd=institution_type_cd
      AND r1.active_ind=1
      AND r1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND r1.end_effective_dt_tm > cnvtdatetime(sysdate)
     DETAIL
      t_seq = locateval(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->dept[t1].res_cd,
       xpand_slice), reply->resource_qual[xref->dept[t_seq].idx].ancestor_qual_cnt = 1, stat =
      alterlist(reply->resource_qual[xref->dept[t_seq].idx].ancestor_qual,1),
      reply->resource_qual[xref->dept[t_seq].idx].ancestor_qual[1].service_resource_cd = r1
      .parent_service_resource_cd
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF ((xref->sect_cnt > 0))
  SET xpand_cntr = (xref->sect_cnt/ xpand_slice)
  IF (mod(xref->sect_cnt,xpand_slice) != 0)
   SET xpand_cntr += 1
  ENDIF
  FOR (sq1 = 1 TO xpand_cntr)
    SET xpand_beg = (((sq1 - 1) * xpand_slice)+ 1)
    SET xpand_end = minval(((xpand_beg+ xpand_slice) - 1),xref->sect_cnt)
    SELECT INTO "nl:"
     FROM resource_group r1,
      resource_group r2
     PLAN (r1
      WHERE expand(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->sect[t1].res_cd,
       xpand_slice)
       AND r1.resource_group_type_cd IN (department_type_cd, libgrp_type_cd)
       AND r1.active_ind=1
       AND r1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r1.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r2
      WHERE r2.child_service_resource_cd=r1.parent_service_resource_cd
       AND r2.resource_group_type_cd=institution_type_cd
       AND r2.active_ind=1
       AND r2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r2.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      t_seq = locateval(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->sect[t1].res_cd,
       xpand_slice), reply->resource_qual[xref->sect[t_seq].idx].ancestor_qual_cnt = 2, stat =
      alterlist(reply->resource_qual[xref->sect[t_seq].idx].ancestor_qual,2),
      reply->resource_qual[xref->sect[t_seq].idx].ancestor_qual[1].service_resource_cd = r1
      .parent_service_resource_cd, reply->resource_qual[xref->sect[t_seq].idx].ancestor_qual[2].
      service_resource_cd = r2.parent_service_resource_cd
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF ((xref->subs_cnt > 0))
  SET xpand_cntr = (xref->subs_cnt/ xpand_slice)
  IF (mod(xref->subs_cnt,xpand_slice) != 0)
   SET xpand_cntr += 1
  ENDIF
  FOR (sq1 = 1 TO xpand_cntr)
    SET xpand_beg = (((sq1 - 1) * xpand_slice)+ 1)
    SET xpand_end = minval(((xpand_beg+ xpand_slice) - 1),xref->subs_cnt)
    SELECT INTO "nl:"
     FROM resource_group r1,
      resource_group r2,
      resource_group r3
     PLAN (r1
      WHERE expand(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->subs[t1].res_cd,
       xpand_slice)
       AND r1.resource_group_type_cd IN (section_type_cd, surgarea_type_cd, libtrkpt_type_cd)
       AND r1.active_ind=1
       AND r1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r1.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r2
      WHERE r2.child_service_resource_cd=r1.parent_service_resource_cd
       AND r2.resource_group_type_cd IN (department_type_cd, libgrp_type_cd)
       AND r2.active_ind=1
       AND r2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r2.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r3
      WHERE r3.child_service_resource_cd=r2.parent_service_resource_cd
       AND r3.resource_group_type_cd=institution_type_cd
       AND r3.active_ind=1
       AND r3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r3.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      t_seq = locateval(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->subs[t1].res_cd,
       xpand_slice), reply->resource_qual[xref->subs[t_seq].idx].ancestor_qual_cnt = 3, stat =
      alterlist(reply->resource_qual[xref->subs[t_seq].idx].ancestor_qual,3),
      reply->resource_qual[xref->subs[t_seq].idx].ancestor_qual[1].service_resource_cd = r1
      .parent_service_resource_cd, reply->resource_qual[xref->subs[t_seq].idx].ancestor_qual[2].
      service_resource_cd = r2.parent_service_resource_cd, reply->resource_qual[xref->subs[t_seq].idx
      ].ancestor_qual[3].service_resource_cd = r3.parent_service_resource_cd
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 IF ((xref->lvl5_cnt > 0))
  SET xpand_cntr = (xref->lvl5_cnt/ xpand_slice)
  IF (mod(xref->lvl5_cnt,xpand_slice) != 0)
   SET xpand_cntr += 1
  ENDIF
  FOR (sq1 = 1 TO xpand_cntr)
    SET xpand_beg = (((sq1 - 1) * xpand_slice)+ 1)
    SET xpand_end = minval(((xpand_beg+ xpand_slice) - 1),xref->lvl5_cnt)
    SELECT INTO "nl:"
     FROM resource_group r1,
      resource_group r2,
      resource_group r3,
      resource_group r4
     PLAN (r1
      WHERE expand(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->lvl5[t1].res_cd,
       xpand_slice)
       AND r1.resource_group_type_cd IN (subsection_type_cd, surgstage_type_cd)
       AND r1.active_ind=1
       AND r1.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r1.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r2
      WHERE r2.child_service_resource_cd=r1.parent_service_resource_cd
       AND r2.resource_group_type_cd IN (section_type_cd, surgarea_type_cd, libtrkpt_type_cd)
       AND r2.active_ind=1
       AND r2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r2.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r3
      WHERE r3.child_service_resource_cd=r2.parent_service_resource_cd
       AND r3.resource_group_type_cd IN (department_type_cd, libgrp_type_cd)
       AND r3.active_ind=1
       AND r3.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r3.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (r4
      WHERE r4.child_service_resource_cd=r3.parent_service_resource_cd
       AND r4.resource_group_type_cd=institution_type_cd
       AND r4.active_ind=1
       AND r4.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND r4.end_effective_dt_tm > cnvtdatetime(sysdate))
     DETAIL
      t_seq = locateval(t1,xpand_beg,xpand_end,r1.child_service_resource_cd,xref->lvl5[t1].res_cd,
       xpand_slice), reply->resource_qual[xref->lvl5[t_seq].idx].ancestor_qual_cnt = 4, stat =
      alterlist(reply->resource_qual[xref->lvl5[t_seq].idx].ancestor_qual,4),
      reply->resource_qual[xref->lvl5[t_seq].idx].ancestor_qual[1].service_resource_cd = r1
      .parent_service_resource_cd, reply->resource_qual[xref->lvl5[t_seq].idx].ancestor_qual[2].
      service_resource_cd = r2.parent_service_resource_cd, reply->resource_qual[xref->lvl5[t_seq].idx
      ].ancestor_qual[3].service_resource_cd = r3.parent_service_resource_cd,
      reply->resource_qual[xref->lvl5[t_seq].idx].ancestor_qual[4].service_resource_cd = r4
      .parent_service_resource_cd
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 GO TO exit_script
#exit_script
 IF (failed)
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  CASE (nbr_correct)
   OF size(request->resource_qual,5):
    SET reply->status_data.status = "S"
   OF 0:
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "P"
  ENDCASE
 ENDIF
 SUBROUTINE validatesub(null)
   IF (validate(reply->resource_qual[d_seq].organization_id)=1)
    SET reply->resource_qual[d_seq].organization_id = sr.organization_id
   ENDIF
 END ;Subroutine
END GO
