CREATE PROGRAM bhs_sys_get_allergies_run
 DECLARE output_err_msg(err_msg=vc) = null
 DECLARE get_allergies_by_person(null) = i2
 DECLARE get_allergies_by_person_reply(null) = i2
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE cs12025_active_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 IF (validate(bhs_allergies_req->mode," ")=" ")
  CALL echo("No request mode found. Exitting Script")
  GO TO exit_script
 ELSE
  IF (trim(cnvtlower(bhs_allergies_req->mode))="person")
   SET d0 = get_allergies_by_person(null)
  ELSE
   SET d0 = output_err_msg(build2("Invalid request mode (",trim(cnvtlower(bhs_allergies_req->mode)),
     ") found. Exitting Script"))
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE output_err_msg(err_msg)
   IF ((validate(bhs_allergies_reply->p_cnt,- (1))=- (1)))
    CALL echo(trim(err_msg))
   ELSE
    SET bhs_allergies_reply->status = - (1)
    SET bhs_allergies_reply->errmsg = trim(err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_allergies_by_person_reply(null)
   FREE RECORD bhs_allergies_reply
   RECORD bhs_allergies_reply(
     1 p_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 a_cnt = i4
       2 allergies[*]
         3 allergy_id = f8
         3 allergy_instance_id = f8
         3 beg_effective_dt_tm = dq8
         3 encntr_id = f8
         3 onset_dt_tm = dq8
         3 onset_precision_cd = f8
         3 onset_precision_flag = i2
         3 onset_dt_tm_disp = vc
         3 reaction_class_cd = f8
         3 reaction_class_disp = vc
         3 reviewed_dt_tm = dq8
         3 reviewed_prsnl_id = f8
         3 reviewed_prsnl = vc
         3 severity_cd = f8
         3 severity_disp = vc
         3 source_of_info_cd = f8
         3 source_of_info_disp = vc
         3 substance_nom_id = f8
         3 substance_disp = vc
         3 substance_type_cd = f8
         3 substance_type_disp = vc
         3 verified_status_flag = i2
         3 verified_status_disp = vc
         3 r_cnt = i4
         3 reactions[*]
           4 nomenclature_id = f8
           4 reaction_disp = vc
         3 c_cnt = i4
         3 comments[*]
           4 allergy_comment_id = f8
           4 comment = vc
           4 comment_dt_tm = dq8
           4 comment_prsnl_id = f8
           4 comment_prsnl = vc
     1 status = i2
     1 errmsg = vc
   ) WITH persist
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_allergies_by_person(null)
   IF (get_allergies_by_person_reply(null)=0)
    SET d0 = output_err_msg(
     "Unable to create REPLY record structure. Exiting 'get_allergies_by_person'")
    RETURN(0)
   ENDIF
   IF (size(bhs_allergies_req->persons,5) <= 0)
    SET d0 = output_err_msg(
     "No persons found in bhs_allergies_req. Exiting 'get_allergies_by_person'")
    RETURN(0)
   ENDIF
   SET stat = alterlist(bhs_allergies_reply->persons,size(bhs_allergies_req->persons,5))
   SET bhs_allergies_reply->p_cnt = size(bhs_allergies_reply->persons,5)
   FOR (p = 1 TO bhs_allergies_reply->p_cnt)
     SET bhs_allergies_reply->persons[p].person_id = bhs_allergies_req->persons[p].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(bhs_allergies_reply->p_cnt)),
     allergy a,
     nomenclature n,
     prsnl pr
    PLAN (d
     WHERE (bhs_allergies_reply->persons[d.seq].person_id > 0.00))
     JOIN (a
     WHERE (bhs_allergies_reply->persons[d.seq].person_id=a.person_id)
      AND a.reaction_status_cd=cs12025_active_cd
      AND a.active_status_cd=cs48_active_cd
      AND a.active_ind=1
      AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (n
     WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
     JOIN (pr
     WHERE outerjoin(a.reviewed_prsnl_id)=pr.person_id)
    ORDER BY d.seq, a.allergy_instance_id
    HEAD REPORT
     a_cnt = 0
    HEAD a.allergy_instance_id
     a_cnt = (bhs_allergies_reply->persons[d.seq].a_cnt+ 1), stat = alterlist(bhs_allergies_reply->
      persons[d.seq].allergies,a_cnt), bhs_allergies_reply->persons[d.seq].a_cnt = a_cnt,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].allergy_id = a.allergy_id,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].allergy_instance_id = a.allergy_instance_id,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].beg_effective_dt_tm = a.beg_effective_dt_tm,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].encntr_id = a.encntr_id,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_dt_tm = a.onset_dt_tm,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_precision_cd = a.onset_precision_cd,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_precision_flag = a
     .onset_precision_flag, bhs_allergies_reply->persons[d.seq].allergies[a_cnt].reaction_class_cd =
     a.reaction_class_cd, bhs_allergies_reply->persons[d.seq].allergies[a_cnt].reaction_class_disp =
     uar_get_code_display(a.reaction_class_cd),
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].reviewed_dt_tm = a.reviewed_dt_tm,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].reviewed_prsnl_id = a.reviewed_prsnl_id,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].reviewed_prsnl = trim(pr
      .name_full_formatted),
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].severity_cd = a.severity_cd,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].severity_disp = uar_get_code_display(a
      .severity_cd), bhs_allergies_reply->persons[d.seq].allergies[a_cnt].source_of_info_cd = a
     .source_of_info_cd,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].substance_nom_id = a.substance_nom_id,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].substance_type_cd = a.substance_type_cd,
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].substance_type_disp = uar_get_code_display(
      a.substance_type_cd),
     bhs_allergies_reply->persons[d.seq].allergies[a_cnt].verified_status_flag = a
     .verified_status_flag
     CASE (a.onset_precision_flag)
      OF 40:
       bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_dt_tm_disp = format(a.onset_dt_tm,
        "mm/yyyy;;d")
      OF 50:
       bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_dt_tm_disp = format(a.onset_dt_tm,
        "yyyy;;d")
      ELSE
       bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_dt_tm_disp = format(a.onset_dt_tm,
        "mm/dd/yyyy;;d")
     ENDCASE
     IF (a.onset_precision_cd > 0.00)
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].onset_dt_tm_disp = build2(trim(
        uar_get_code_display(a.onset_precision_cd))," ",bhs_allergies_reply->persons[d.seq].
       allergies[a_cnt].onset_dt_tm_disp)
     ENDIF
     IF (trim(a.source_of_info_ft) > " ")
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].source_of_info_disp = trim(a
       .source_of_info_ft)
     ELSEIF (a.source_of_info_cd > 0.00)
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].source_of_info_disp = uar_get_code_display
      (a.source_of_info_cd)
     ENDIF
     IF (trim(a.substance_ftdesc) > " ")
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].substance_disp = trim(a.substance_ftdesc)
     ELSEIF (n.nomenclature_id > 0.00)
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].substance_disp = trim(n.source_string)
     ENDIF
     IF (a.verified_status_flag)
      bhs_allergies_reply->persons[d.seq].allergies[a_cnt].verified_status_disp =
      "Pharmacist Verified"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(bhs_allergies_reply->p_cnt)),
     dummyt d2,
     reaction r,
     nomenclature n
    PLAN (d1
     WHERE (bhs_allergies_reply->persons[d1.seq].a_cnt > 0)
      AND maxrec(d2,bhs_allergies_reply->persons[d1.seq].a_cnt))
     JOIN (d2)
     JOIN (r
     WHERE (bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].allergy_instance_id=r
     .allergy_instance_id)
      AND r.active_ind=1
      AND r.active_status_cd=cs48_active_cd
      AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (n
     WHERE outerjoin(r.reaction_nom_id)=n.nomenclature_id)
    ORDER BY d1.seq, d2.seq, r.reaction_id
    HEAD REPORT
     r_cnt = 0
    DETAIL
     r_cnt = (bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].r_cnt+ 1), stat = alterlist(
      bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].reactions,r_cnt), bhs_allergies_reply->
     persons[d1.seq].allergies[d2.seq].reactions[r_cnt].nomenclature_id = r.reaction_nom_id
     IF (trim(r.reaction_ftdesc) > " ")
      bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].reactions[r_cnt].reaction_disp = trim(r
       .reaction_ftdesc)
     ELSEIF (n.nomenclature_id > 0.00)
      bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].reactions[r_cnt].reaction_disp = trim(n
       .source_string)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(bhs_allergies_reply->p_cnt)),
     dummyt d2,
     allergy_comment ac,
     prsnl pr
    PLAN (d1
     WHERE (bhs_allergies_reply->persons[d1.seq].a_cnt > 0)
      AND maxrec(d2,bhs_allergies_reply->persons[d1.seq].a_cnt))
     JOIN (d2)
     JOIN (ac
     WHERE (bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].allergy_instance_id=ac
     .allergy_instance_id)
      AND ac.active_ind=1
      AND ac.active_status_cd=cs48_active_cd
      AND ac.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (pr
     WHERE outerjoin(ac.comment_prsnl_id)=pr.person_id)
    ORDER BY d1.seq, d2.seq, ac.allergy_comment_id
    HEAD REPORT
     c_cnt = 0
    DETAIL
     c_cnt = (bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].c_cnt+ 1), stat = alterlist(
      bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].comments,c_cnt), bhs_allergies_reply->
     persons[d1.seq].allergies[d2.seq].c_cnt = c_cnt,
     bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].comments[c_cnt].allergy_comment_id = ac
     .allergy_comment_id, bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].comments[c_cnt].
     comment = trim(ac.allergy_comment), bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].
     comments[c_cnt].comment_dt_tm = ac.comment_dt_tm,
     bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].comments[c_cnt].comment_prsnl_id = ac
     .comment_prsnl_id, bhs_allergies_reply->persons[d1.seq].allergies[d2.seq].comments[c_cnt].
     comment_prsnl = trim(pr.name_full_formatted)
    WITH nocounter
   ;end select
   SET bhs_allergies_reply->status = 1
   RETURN(1)
 END ;Subroutine
#exit_script
END GO
