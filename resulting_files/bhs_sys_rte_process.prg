CREATE PROGRAM bhs_sys_rte_process
 RECORD rte_ref(
   1 p_cnt = i4
   1 process[*]
     2 process_nbr = i4
     2 desc = vc
     2 cont_sys[*]
       3 value = f8
     2 encntr_types[*]
       3 value = f8
     2 valid_users[*]
       3 prsnl_id = f8
     2 recipients[*]
       3 action = vc
       3 reltn_src = vc
       3 reltn_cd = f8
     2 flat_rows[*]
       3 cont_sys_cd = f8
       3 encntr_type_cd = f8
       3 prsnl_id = f8
       3 reltn_src = vc
       3 reltn_cd = f8
       3 action = vc
 )
 CALL echo("bhs_sys_rte_process")
 FREE RECORD rte_reply
 RECORD rte_reply(
   1 r_cnt = i4
   1 records[*]
     2 rec_id = f8
     2 process_ind = i4
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 encntr_status_cd = f8
     2 active_status_cd = f8
     2 cont_sys_cd = f8
     2 p_cnt = i4
     2 prsnl[*]
       3 process_nbr = i4
       3 prsnl_id = f8
       3 reltn_src = vc
       3 reltn_cd = f8
       3 action = vc
     2 e_cnt = i4
     2 events[*]
       3 event_id = f8
 )
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_final_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs48_combined_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"COMBINED"))
 CALL echo("if(trim(reflect(cs48_active_cd), 4)")
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE get_code(by_type=vc,codeset=i4,str_value=vc) = f8
 DECLARE ret_cd = f8 WITH noconstant(0.00)
 DECLARE parser_str = vc
 SUBROUTINE get_code(by_type,codeset,str_value)
   SET ret_cd = 0.00
   SET parser_str = build('set ret_cd = uar_get_code_by("',trim(by_type,3),'", ',trim(build(codeset),
     3),', "',
    trim(str_value,3),'") go')
   CALL parser(parser_str)
   RETURN(ret_cd)
 END ;Subroutine
 SET rte_reply->r_cnt = size(rte_req->records,5)
 SET stat = alterlist(rte_reply->records,rte_reply->r_cnt)
 DECLARE var_combine_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
   encounter e
  PLAN (d
   WHERE (rte_req->records[d.seq].encntr_id > 0.00))
   JOIN (e
   WHERE (rte_req->records[d.seq].encntr_id=e.encntr_id))
  DETAIL
   rte_reply->records[d.seq].person_id = e.person_id, rte_reply->records[d.seq].encntr_id = e
   .encntr_id, rte_reply->records[d.seq].encntr_type_cd = e.encntr_type_cd,
   rte_reply->records[d.seq].encntr_status_cd = e.encntr_status_cd, rte_reply->records[d.seq].
   active_status_cd = e.active_status_cd
   IF (e.active_status_cd=cs48_combined_cd)
    var_combine_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 WHILE (var_combine_ind=1)
  SET var_combine_ind = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
    encntr_combine ec,
    encounter e
   PLAN (d
    WHERE (rte_reply->records[d.seq].active_status_cd=cs48_combined_cd))
    JOIN (ec
    WHERE (rte_req->records[d.seq].encntr_id=ec.from_encntr_id)
     AND ec.active_ind=1)
    JOIN (e
    WHERE ec.to_encntr_id=e.encntr_id)
   DETAIL
    rte_req->records[d.seq].encntr_id = e.encntr_id, rte_reply->records[d.seq].person_id = e
    .person_id, rte_reply->records[d.seq].encntr_id = e.encntr_id,
    rte_reply->records[d.seq].encntr_type_cd = e.encntr_type_cd, rte_reply->records[d.seq].
    encntr_status_cd = e.encntr_status_cd, rte_reply->records[d.seq].active_status_cd = e
    .active_status_cd
    IF (e.active_status_cd=cs48_combined_cd)
     var_combine_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 FREE SET var_combine_ind
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
   encntr_prsnl_reltn epr
  PLAN (d
   WHERE (rte_req->records[d.seq].encntr_id > 0.00))
   JOIN (epr
   WHERE (rte_req->records[d.seq].encntr_id=epr.encntr_id)
    AND epr.active_ind=1
    AND epr.active_status_cd=cs48_active_cd
    AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND epr.manual_inact_ind=0)
  HEAD REPORT
   p_cnt = 0
  DETAIL
   p_cnt = (rte_reply->records[d.seq].p_cnt+ 1), stat = alterlist(rte_reply->records[d.seq].prsnl,
    p_cnt), rte_reply->records[d.seq].p_cnt = p_cnt,
   rte_reply->records[d.seq].prsnl[p_cnt].prsnl_id = epr.prsnl_person_id, rte_reply->records[d.seq].
   prsnl[p_cnt].reltn_cd = epr.encntr_prsnl_r_cd, rte_reply->records[d.seq].prsnl[p_cnt].reltn_src =
   "EPR"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
   person_prsnl_reltn ppr
  PLAN (d
   WHERE (rte_reply->records[d.seq].person_id > 0.00))
   JOIN (ppr
   WHERE (rte_reply->records[d.seq].person_id=ppr.person_id)
    AND ppr.active_ind=1
    AND ppr.active_status_cd=cs48_active_cd
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ppr.manual_inact_ind=0)
  HEAD REPORT
   p_cnt = 0
  DETAIL
   p_cnt = (rte_reply->records[d.seq].p_cnt+ 1), stat = alterlist(rte_reply->records[d.seq].prsnl,
    p_cnt), rte_reply->records[d.seq].p_cnt = p_cnt,
   rte_reply->records[d.seq].prsnl[p_cnt].prsnl_id = ppr.prsnl_person_id, rte_reply->records[d.seq].
   prsnl[p_cnt].reltn_cd = ppr.person_prsnl_r_cd, rte_reply->records[d.seq].prsnl[p_cnt].reltn_src =
   "PPR"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
   order_action oa
  PLAN (d
   WHERE (rte_req->records[d.seq].entity_name="ORDER_ID")
    AND cnvtreal(rte_req->records[d.seq].entity_id) > 0.00)
   JOIN (oa
   WHERE cnvtreal(rte_req->records[d.seq].entity_id)=oa.order_id
    AND oa.action_sequence=1)
  HEAD REPORT
   p_cnt = 0
  DETAIL
   p_cnt = (rte_reply->records[d.seq].p_cnt+ 1), stat = alterlist(rte_reply->records[d.seq].prsnl,
    p_cnt), rte_reply->records[d.seq].p_cnt = p_cnt,
   rte_reply->records[d.seq].prsnl[p_cnt].prsnl_id = oa.order_provider_id, rte_reply->records[d.seq].
   prsnl[p_cnt].reltn_src = "ORDER_PROVIDER"
  WITH nocounter
 ;end select
 DECLARE dseq = i4
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rte_reply->r_cnt)),
   clinical_event ce
  PLAN (d
   WHERE (((rte_req->records[d.seq].entity_name IN ("ACCESSION_NBR", "REFERENCE_NBR",
   "SERIES_REF_NBR"))
    AND trim(build(rte_req->records[d.seq].entity_id),3) > " ") OR ((rte_req->records[d.seq].
   entity_name="ORDER_ID")
    AND cnvtreal(rte_req->records[d.seq].entity_id) > 0.00
    AND initarray(dseq,d.seq))) )
   JOIN (ce
   WHERE (rte_req->records[d.seq].encntr_id=ce.encntr_id)
    AND (((rte_req->records[d.seq].entity_name="ACCESSION_NBR")
    AND operator(ce.accession_nbr,"LIKE",patstring(build(rte_req->records[dseq].entity_id,"*")))) OR
   ((((rte_req->records[d.seq].entity_name="REFERENCE_NBR")
    AND operator(ce.reference_nbr,"LIKE",patstring(build(rte_req->records[dseq].entity_id,"*")))) OR
   ((((rte_req->records[d.seq].entity_name="SERIES_REF_NBR")
    AND operator(ce.series_ref_nbr,"LIKE",patstring(build(rte_req->records[dseq].entity_id,"*"))))
    OR ((rte_req->records[d.seq].entity_name="ORDER_ID")
    AND cnvtreal(rte_req->records[d.seq].entity_id)=ce.order_id)) )) ))
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_final_cd, cs8_modified_cd, cs8_altered_cd))
  ORDER BY ce.performed_prsnl_id, ce.event_id
  HEAD REPORT
   p_cnt = 0, e_cnt = 0
  HEAD ce.performed_prsnl_id
   rte_reply->records[d.seq].cont_sys_cd = ce.contributor_system_cd, p_cnt = (rte_reply->records[d
   .seq].p_cnt+ 1), stat = alterlist(rte_reply->records[d.seq].prsnl,p_cnt),
   rte_reply->records[d.seq].p_cnt = p_cnt, rte_reply->records[d.seq].prsnl[p_cnt].prsnl_id = ce
   .performed_prsnl_id, rte_reply->records[d.seq].prsnl[p_cnt].reltn_src = "PERFORM_PROVIDER"
  HEAD ce.event_id
   e_cnt = (rte_reply->records[d.seq].e_cnt+ 1), stat = alterlist(rte_reply->records[d.seq].events,
    e_cnt), rte_reply->records[d.seq].e_cnt = e_cnt,
   rte_reply->records[d.seq].events[e_cnt].event_id = ce.event_id
  WITH nocounter
 ;end select
 FREE SET dseq
 DECLARE tmp_str = vc
 SELECT INTO "nl:"
  piece_seq = cnvtint(piece(brp.filter_type,".",2,"999")), piece_type = substring(1,50,piece(brp
    .filter_type,".",3," "))
  FROM bhs_rte_prsnl brp
  PLAN (brp)
  ORDER BY piece_seq
  HEAD REPORT
   tmp_x = 0, x_cnt = 0, p_cnt = 0,
   row_cnt = 0
  HEAD piece_seq
   IF (piece_seq != 999)
    IF ((rte_ref->p_cnt > 0))
     p_cnt = locateval(tmp_x,1,rte_ref->p_cnt,piece_seq,rte_ref->process[tmp_x].process_nbr)
     IF ((rte_ref->process[p_cnt].process_nbr != piece_seq))
      p_cnt = (rte_ref->p_cnt+ 1), stat = alterlist(rte_ref->process,p_cnt), rte_ref->p_cnt = p_cnt,
      rte_ref->process[p_cnt].process_nbr = piece_seq
     ENDIF
    ELSE
     p_cnt = (rte_ref->p_cnt+ 1), stat = alterlist(rte_ref->process,p_cnt), rte_ref->p_cnt = p_cnt,
     rte_ref->process[p_cnt].process_nbr = piece_seq
    ENDIF
   ENDIF
  DETAIL
   IF (piece_seq != 999)
    IF (trim(piece_type,3)="CONT_SYS")
     tmp_x = get_code(trim(piece(brp.filter_value,"|",1," "),3),cnvtint(piece(brp.filter_value,"|",2,
        "0")),trim(piece(brp.filter_value,"|",3," "),3))
     IF (tmp_x > 0.00)
      x_cnt = (size(rte_ref->process[p_cnt].cont_sys,5)+ 1), stat = alterlist(rte_ref->process[p_cnt]
       .cont_sys,x_cnt), rte_ref->process[p_cnt].cont_sys[x_cnt].value = tmp_x
     ENDIF
     tmp_x = 0.00
    ELSEIF (trim(piece_type,3)="ENCNTR_TYPE")
     tmp_x = get_code(trim(piece(brp.filter_value,"|",1," "),3),cnvtint(piece(brp.filter_value,"|",2,
        "0")),trim(piece(brp.filter_value,"|",3," "),3))
     IF (tmp_x > 0.00)
      x_cnt = (size(rte_ref->process[p_cnt].encntr_types,5)+ 1), stat = alterlist(rte_ref->process[
       p_cnt].encntr_types,x_cnt), rte_ref->process[p_cnt].encntr_types[x_cnt].value = tmp_x
     ENDIF
     tmp_x = 0.00
    ELSEIF (trim(piece_type,3)="VALID_PRSNL")
     IF (brp.person_id > 0.00)
      x_cnt = (size(rte_ref->process[p_cnt].valid_users,5)+ 1), stat = alterlist(rte_ref->process[
       p_cnt].valid_users,x_cnt), rte_ref->process[p_cnt].valid_users[x_cnt].prsnl_id = brp.person_id
     ENDIF
    ELSEIF (trim(piece_type,3)="RECIPIENT")
     IF (trim(piece(brp.filter_value,":",2," "),3) > " ")
      x_cnt = (size(rte_ref->process[p_cnt].recipients,5)+ 1), stat = alterlist(rte_ref->process[
       p_cnt].recipients,x_cnt), rte_ref->process[p_cnt].recipients[x_cnt].reltn_src = trim(piece(brp
        .filter_value,":",2," "),3),
      tmp_str = trim(piece(brp.filter_value,":",1," "),3)
      IF (tmp_str IN ("SIGN", "REVIEW"))
       rte_ref->process[p_cnt].recipients[x_cnt].action = tmp_str
      ELSE
       rte_ref->process[p_cnt].recipients[x_cnt].action = "REVIEW"
      ENDIF
      IF (trim(piece(brp.filter_value,":",3," "),3) > " ")
       tmp_str = trim(piece(brp.filter_value,":",3," "),3), tmp_x = get_code(trim(piece(tmp_str,"|",1,
          " "),3),cnvtint(piece(tmp_str,"|",2,"0")),trim(piece(tmp_str,"|",3," "),3)), rte_ref->
       process[p_cnt].recipients[x_cnt].reltn_cd = tmp_x
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  piece_seq
   row_cnt = 0
   IF (piece_seq != 999)
    IF (size(rte_ref->process[p_cnt].cont_sys,5) > 0)
     IF (row_cnt=0)
      row_cnt = size(rte_ref->process[p_cnt].cont_sys,5)
     ELSE
      row_cnt = (row_cnt * size(rte_ref->process[p_cnt].cont_sys,5))
     ENDIF
    ELSE
     stat = alterlist(rte_ref->process[p_cnt].cont_sys,1), row_cnt = (row_cnt+ 1)
    ENDIF
    IF (size(rte_ref->process[p_cnt].encntr_types,5) > 0)
     IF (row_cnt=0)
      row_cnt = size(rte_ref->process[p_cnt].encntr_types,5)
     ELSE
      row_cnt = (row_cnt * size(rte_ref->process[p_cnt].encntr_types,5))
     ENDIF
    ELSE
     stat = alterlist(rte_ref->process[p_cnt].encntr_types,1), row_cnt = (row_cnt+ 1)
    ENDIF
    IF (size(rte_ref->process[p_cnt].valid_users,5) > 0)
     IF (row_cnt=0)
      row_cnt = size(rte_ref->process[p_cnt].valid_users,5)
     ELSE
      row_cnt = (row_cnt * size(rte_ref->process[p_cnt].valid_users,5))
     ENDIF
    ELSE
     stat = alterlist(rte_ref->process[p_cnt].valid_users,1), row_cnt = (row_cnt+ 1)
    ENDIF
    IF (size(rte_ref->process[p_cnt].recipients,5) > 0)
     IF (row_cnt=0)
      row_cnt = size(rte_ref->process[p_cnt].recipients,5)
     ELSE
      row_cnt = (row_cnt * size(rte_ref->process[p_cnt].recipients,5))
     ENDIF
    ELSE
     stat = alterlist(rte_ref->process[p_cnt].recipients,1), row_cnt = (row_cnt+ 1)
    ENDIF
    stat = alterlist(rte_ref->process[p_cnt].flat_rows,row_cnt)
    FOR (r = 1 TO row_cnt)
      tmp_x = mod(r,size(rte_ref->process[p_cnt].cont_sys,5))
      IF (tmp_x=0)
       tmp_x = size(rte_ref->process[p_cnt].cont_sys,5)
      ENDIF
      rte_ref->process[p_cnt].flat_rows[r].cont_sys_cd = rte_ref->process[p_cnt].cont_sys[tmp_x].
      value, tmp_x = mod(r,size(rte_ref->process[p_cnt].encntr_types,5))
      IF (tmp_x=0)
       tmp_x = size(rte_ref->process[p_cnt].encntr_types,5)
      ENDIF
      rte_ref->process[p_cnt].flat_rows[r].encntr_type_cd = rte_ref->process[p_cnt].encntr_types[
      tmp_x].value, tmp_x = mod(r,size(rte_ref->process[p_cnt].valid_users,5))
      IF (tmp_x=0)
       tmp_x = size(rte_ref->process[p_cnt].valid_users,5)
      ENDIF
      rte_ref->process[p_cnt].flat_rows[r].prsnl_id = rte_ref->process[p_cnt].valid_users[tmp_x].
      prsnl_id, tmp_x = mod(r,size(rte_ref->process[p_cnt].recipients,5))
      IF (tmp_x=0)
       tmp_x = size(rte_ref->process[p_cnt].recipients,5)
      ENDIF
      rte_ref->process[p_cnt].flat_rows[r].action = rte_ref->process[p_cnt].recipients[tmp_x].action,
      rte_ref->process[p_cnt].flat_rows[r].reltn_src = rte_ref->process[p_cnt].recipients[tmp_x].
      reltn_src, rte_ref->process[p_cnt].flat_rows[r].reltn_cd = rte_ref->process[p_cnt].recipients[
      tmp_x].reltn_cd
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 FREE SET tmp_str
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(rte_reply->r_cnt)),
   dummyt d2,
   (dummyt d3  WITH seq = value(rte_ref->p_cnt)),
   dummyt d4
  PLAN (d1
   WHERE maxrec(d2,size(rte_reply->records[d1.seq].prsnl,5)))
   JOIN (d2)
   JOIN (d3
   WHERE maxrec(d4,size(rte_ref->process[d3.seq].flat_rows,5)))
   JOIN (d4
   WHERE (((rte_ref->process[d3.seq].flat_rows[d4.seq].cont_sys_cd <= 0.00)) OR ((rte_reply->records[
   d1.seq].cont_sys_cd=rte_ref->process[d3.seq].flat_rows[d4.seq].cont_sys_cd)))
    AND (((rte_ref->process[d3.seq].flat_rows[d4.seq].encntr_type_cd <= 0.00)) OR ((rte_reply->
   records[d1.seq].encntr_type_cd=rte_ref->process[d3.seq].flat_rows[d4.seq].encntr_type_cd)))
    AND (((rte_ref->process[d3.seq].flat_rows[d4.seq].prsnl_id <= 0.00)) OR ((rte_reply->records[d1
   .seq].prsnl[d2.seq].prsnl_id=rte_ref->process[d3.seq].flat_rows[d4.seq].prsnl_id)))
    AND (((rte_ref->process[d3.seq].flat_rows[d4.seq].reltn_cd <= 0.00)) OR ((rte_reply->records[d1
   .seq].prsnl[d2.seq].reltn_cd=rte_ref->process[d3.seq].flat_rows[d4.seq].reltn_cd)))
    AND ((trim(rte_ref->process[d3.seq].flat_rows[d4.seq].reltn_src,3) <= " ") OR (trim(rte_reply->
    records[d1.seq].prsnl[d2.seq].reltn_src,3)=trim(rte_ref->process[d3.seq].flat_rows[d4.seq].
    reltn_src,3))) )
  HEAD REPORT
   p_cnt = 0
  DETAIL
   IF (trim(rte_reply->records[d1.seq].prsnl[d2.seq].action,3) <= " ")
    rte_reply->records[d1.seq].process_ind = successful_flg, rte_reply->records[d1.seq].prsnl[d2.seq]
    .process_nbr = rte_ref->process[d3.seq].process_nbr, rte_reply->records[d1.seq].prsnl[d2.seq].
    action = rte_ref->process[d3.seq].flat_rows[d4.seq].action
   ELSEIF ((rte_reply->records[d1.seq].prsnl[d2.seq].action="REVIEW")
    AND (rte_ref->process[d3.seq].flat_rows[d4.seq].action="SIGN"))
    rte_reply->records[d1.seq].prsnl[d2.seq].process_nbr = rte_ref->process[d3.seq].process_nbr,
    rte_reply->records[d1.seq].prsnl[d2.seq].action = rte_ref->process[d3.seq].flat_rows[d4.seq].
    action
   ENDIF
  WITH nocounter
 ;end select
 FOR (r = 1 TO rte_reply->r_cnt)
   IF ((rte_reply->process_ind=0)
    AND (rte_reply->records[r].encntr_id <= 0.00))
    SET rte_reply->records[r].process_ind = err_encntr_not_found_flg
   ENDIF
   IF ((rte_reply->records[r].process_ind=0)
    AND (rte_reply->records[r].e_cnt <= 0))
    SET rte_reply->records[r].process_ind = err_no_results_found_flg
   ENDIF
   IF ((rte_reply->records[r].process_ind=0)
    AND (rte_reply->records[r].p_cnt <= 0))
    SET rte_reply->records[r].process_ind = err_no_reltns_found_flg
   ENDIF
   IF ((rte_reply->records[r].process_ind=0))
    SET rte_reply->records[r].process_ind = err_rec_filtered_out_flg
   ENDIF
 ENDFOR
#exit_script
END GO
