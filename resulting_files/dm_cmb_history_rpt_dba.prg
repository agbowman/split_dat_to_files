CREATE PROGRAM dm_cmb_history_rpt:dba
 DECLARE dchr_cmb_type = vc WITH protect, noconstant(cnvtupper( $1))
 DECLARE dchr_from_id = f8 WITH protect, constant(cnvtreal( $2))
 DECLARE dchr_ndx = i4 WITH protect, noconstant(0)
 DECLARE dchr_temp_str = vc WITH protect, noconstant("")
 DECLARE dchr_temp_pos = i2 WITH protect, noconstant(0)
 DECLARE dchr_temp_id = f8 WITH protect, noconstant(0.0)
 DECLARE dchr_fin_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dchr_visit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dchr_mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dchr_encounter_col = vc WITH protect, noconstant("")
 DECLARE dchr_encounter_val = vc WITH protect, noconstant("")
 DECLARE get_cmb_hist(i_from_id=f8,i_combine_type=vc,i_tree_rec=vc(ref),i_beg_dt_tm=dq8,i_end_dt_tm=
  dq8,
  i_cmb_tbl_rec=vc(ref)) = null
 FREE RECORD cmb_hist_tree
 RECORD cmb_hist_tree(
   1 qual[*]
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 updt_id = f8
     2 active_ind = i2
     2 encntr_id = f8
     2 person_id = f8
     2 action_dt_tm = dq8
     2 cmb_state_ind = i2
     2 source = c8
   1 final_id = f8
   1 final_person_id = f8
   1 total = i4
 )
 FREE RECORD person_info
 RECORD person_info(
   1 qual[*]
     2 person_id = f8
     2 name_ff = vc
     2 prsnl_ind = i2
     2 active_ind = i2
     2 mrn = c20
   1 total = i4
 )
 FREE RECORD encntr_info
 RECORD encntr_info(
   1 qual[*]
     2 encntr_id = f8
     2 fin_nbr = c30
     2 visit_id = c30
     2 active_ind = i2
   1 total = i4
 )
 FREE RECORD cmb_tbl_info
 RECORD cmb_tbl_info(
   1 from_id_col = vc
   1 to_id_col = vc
   1 pk_col = vc
   1 tbl_name = vc
 )
 IF (dchr_cmb_type="P")
  SET dchr_cmb_type = "PERSON"
 ELSEIF (dchr_cmb_type="E")
  SET dchr_cmb_type = "ENCOUNTER"
 ENDIF
 IF (dchr_cmb_type="PERSON")
  SET cmb_tbl_info->from_id_col = "FROM_PERSON_ID"
  SET cmb_tbl_info->to_id_col = "TO_PERSON_ID"
  SET cmb_tbl_info->pk_col = "PERSON_COMBINE_ID"
  SET cmb_tbl_info->tbl_name = "PERSON_COMBINE"
  SET dchr_encounter_col = "pc.encntr_id"
  SET dchr_encounter_val = "0"
 ELSEIF (dchr_cmb_type="ENCOUNTER")
  SET cmb_tbl_info->from_id_col = "FROM_ENCNTR_ID"
  SET cmb_tbl_info->to_id_col = "TO_ENCNTR_ID"
  SET cmb_tbl_info->pk_col = "ENCNTR_COMBINE_ID"
  SET cmb_tbl_info->tbl_name = "ENCNTR_COMBINE"
  SET dchr_encounter_col = "1"
  SET dchr_encounter_val = "1"
 ELSE
  SELECT
   FROM dual
   DETAIL
    col 0, dchr_cmb_type, col + 2,
    "is not a recognized parent_entity_name"
   WITH nocounter
  ;end select
  GO TO exit_dchr
 ENDIF
 SET cmb_hist_tree->final_id = dchr_from_id
 CALL get_cmb_hist(dchr_from_id,dchr_cmb_type,cmb_hist_tree,cnvtdatetime("01-JAN-1900"),cnvtdatetime(
   curdate,curtime3),
  cmb_tbl_info)
 SELECT INTO "nl:"
  parser(build("pc.",cmb_tbl_info->pk_col)), parser(build("pc.",cmb_tbl_info->from_id_col)), parser(
   build("pc.",cmb_tbl_info->to_id_col)),
  pc.cmb_dt_tm, pc.ucb_dt_tm, pc.active_ind,
  parser(dchr_encounter_col), action_dt_tm = nullval(pc.cmb_dt_tm,pc.updt_dt_tm), cmb_id = nullval(pc
   .cmb_updt_id,pc.updt_id),
  ucb_id = nullval(pc.ucb_dt_tm,pc.updt_dt_tm)
  FROM (parser(cmb_tbl_info->tbl_name) pc)
  WHERE parser(build("pc.",cmb_tbl_info->to_id_col))=dchr_from_id
   AND parser(build(dchr_encounter_col," = ",dchr_encounter_val))
  ORDER BY action_dt_tm
  DETAIL
   IF (pc.active_ind=0)
    stat = alterlist(cmb_hist_tree->qual,(cmb_hist_tree->total+ 2))
   ELSE
    stat = alterlist(cmb_hist_tree->qual,(cmb_hist_tree->total+ 1))
   ENDIF
   cmb_hist_tree->total = (cmb_hist_tree->total+ 1), cmb_hist_tree->qual[cmb_hist_tree->total].
   combine_id = parser(build("pc.",cmb_tbl_info->pk_col)), cmb_hist_tree->qual[cmb_hist_tree->total].
   from_id = parser(build("pc.",cmb_tbl_info->from_id_col)),
   cmb_hist_tree->qual[cmb_hist_tree->total].to_id = parser(build("pc.",cmb_tbl_info->to_id_col)),
   cmb_hist_tree->qual[cmb_hist_tree->total].updt_id = cmb_id, cmb_hist_tree->qual[cmb_hist_tree->
   total].active_ind = pc.active_ind,
   cmb_hist_tree->qual[cmb_hist_tree->total].action_dt_tm = cnvtdatetime(action_dt_tm), cmb_hist_tree
   ->qual[cmb_hist_tree->total].cmb_state_ind = 1, cmb_hist_tree->qual[cmb_hist_tree->total].source
    = pc.transaction_type
   IF (pc.active_ind=0)
    cmb_hist_tree->total = (cmb_hist_tree->total+ 1), cmb_hist_tree->qual[cmb_hist_tree->total].
    combine_id = parser(build("pc.",cmb_tbl_info->pk_col)), cmb_hist_tree->qual[cmb_hist_tree->total]
    .from_id = parser(build("pc.",cmb_tbl_info->from_id_col)),
    cmb_hist_tree->qual[cmb_hist_tree->total].to_id = parser(build("pc.",cmb_tbl_info->to_id_col)),
    cmb_hist_tree->qual[cmb_hist_tree->total].updt_id = ucb_id, cmb_hist_tree->qual[cmb_hist_tree->
    total].active_ind = pc.active_ind,
    cmb_hist_tree->qual[cmb_hist_tree->total].action_dt_tm = nullval(pc.ucb_dt_tm,pc.updt_dt_tm),
    cmb_hist_tree->qual[cmb_hist_tree->total].cmb_state_ind = 0, cmb_hist_tree->qual[cmb_hist_tree->
    total].source = pc.transaction_type
   ENDIF
  WITH nocounter
 ;end select
 IF (dchr_cmb_type="PERSON")
  FOR (i = 1 TO cmb_hist_tree->total)
   IF (locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[i].from_id,person_info->qual[
    dchr_ndx].person_id)=0)
    SET person_info->total = (person_info->total+ 1)
    SET stat = alterlist(person_info->qual,person_info->total)
    SET person_info->qual[person_info->total].person_id = cmb_hist_tree->qual[i].from_id
    SET person_info->qual[person_info->total].mrn = "NONE"
   ENDIF
   IF (locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[i].to_id,person_info->qual[
    dchr_ndx].person_id)=0)
    SET person_info->total = (person_info->total+ 1)
    SET stat = alterlist(person_info->qual,person_info->total)
    SET person_info->qual[person_info->total].person_id = cmb_hist_tree->qual[i].to_id
    SET person_info->qual[person_info->total].mrn = "NONE"
   ENDIF
  ENDFOR
 ENDIF
 IF ((cmb_hist_tree->total > 0))
  IF (dchr_cmb_type="PERSON")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = person_info->total),
     prsnl p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=person_info->qual[d.seq].person_id))
    DETAIL
     person_info->qual[d.seq].prsnl_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=4
     AND c.cdf_meaning="MRN"
    DETAIL
     dchr_mrn_cd = c.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = person_info->total),
     person_alias p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=person_info->qual[d.seq].person_id)
      AND p.person_alias_type_cd=dchr_mrn_cd
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY p.person_id, p.beg_effective_dt_tm
    HEAD p.person_id
     dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,p.person_id,person_info->qual[dchr_ndx].
      person_id)
    DETAIL
     person_info->qual[dchr_temp_pos].mrn = substring(1,20,p.alias)
    WITH nocounter
   ;end select
  ELSEIF (dchr_cmb_type="ENCOUNTER")
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=319
     AND c.cdf_meaning IN ("FIN NBR", "VISITID")
    DETAIL
     IF (c.cdf_meaning="FIN NBR")
      dchr_fin_cd = c.code_value
     ELSE
      dchr_visit_cd = c.code_value
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    eid = e.encntr_id, encntr_active_ind = e.active_ind, pid = decode(e.seq,e.person_id,p.seq,p
     .person_id)
    FROM encounter e,
     person p,
     (dummyt d  WITH seq = cmb_hist_tree->total),
     (dummyt d3  WITH seq = cmb_hist_tree->total)
    PLAN (d
     WHERE (cmb_hist_tree->qual[d.seq].encntr_id=0.0))
     JOIN (((e
     WHERE (((e.encntr_id=cmb_hist_tree->qual[d.seq].from_id)) OR ((e.encntr_id=cmb_hist_tree->qual[d
     .seq].to_id))) )
     ) ORJOIN ((d3
     WHERE (cmb_hist_tree->qual[d3.seq].encntr_id > 0.0))
     JOIN (p
     WHERE (((p.person_id=cmb_hist_tree->qual[d3.seq].from_id)) OR ((p.person_id=cmb_hist_tree->qual[
     d3.seq].to_id))) )
     ))
    DETAIL
     IF (locateval(dchr_ndx,1,person_info->total,pid,person_info->qual[dchr_ndx].person_id)=0)
      person_info->total = (person_info->total+ 1), stat = alterlist(person_info->qual,person_info->
       total), person_info->qual[person_info->total].person_id = pid
     ENDIF
     IF (eid > 0)
      cmb_hist_tree->qual[d.seq].person_id = pid
      IF (locateval(dchr_ndx,1,encntr_info->total,eid,encntr_info->qual[dchr_ndx].encntr_id)=0)
       encntr_info->total = (encntr_info->total+ 1), stat = alterlist(encntr_info->qual,encntr_info->
        total), encntr_info->qual[encntr_info->total].encntr_id = eid,
       encntr_info->qual[encntr_info->total].active_ind = encntr_active_ind, encntr_info->qual[
       encntr_info->total].fin_nbr = "NONE", encntr_info->qual[encntr_info->total].visit_id = "NONE"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encntr_alias ea,
     (dummyt d  WITH seq = encntr_info->total)
    PLAN (d)
     JOIN (ea
     WHERE (ea.encntr_id=encntr_info->qual[d.seq].encntr_id)
      AND ea.encntr_alias_type_cd IN (dchr_fin_cd, dchr_visit_cd)
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY ea.encntr_id, ea.beg_effective_dt_tm
    HEAD ea.encntr_id
     dchr_temp_pos = locateval(dchr_ndx,1,encntr_info->total,ea.encntr_id,encntr_info->qual[dchr_ndx]
      .encntr_id)
    DETAIL
     IF (ea.encntr_alias_type_cd=dchr_fin_cd)
      encntr_info->qual[dchr_temp_pos].fin_nbr = ea.alias
     ELSE
      encntr_info->qual[dchr_temp_pos].visit_id = ea.alias
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = cmb_hist_tree->total)
    PLAN (d)
    ORDER BY cmb_hist_tree->qual[d.seq].action_dt_tm
    DETAIL
     dchr_temp_id = cmb_hist_tree->qual[d.seq].person_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = cmb_hist_tree->total)
    PLAN (d)
    ORDER BY cmb_hist_tree->qual[d.seq].action_dt_tm DESC
    DETAIL
     IF ((cmb_hist_tree->qual[d.seq].encntr_id=0.0))
      cmb_hist_tree->qual[d.seq].person_id = dchr_temp_id
     ELSE
      dchr_temp_id = cmb_hist_tree->qual[d.seq].from_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.encntr_id=cmb_hist_tree->final_id)
    DETAIL
     cmb_hist_tree->final_person_id = e.person_id
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   p.name_full_formatted, p.active_ind
   FROM (dummyt d  WITH seq = person_info->total),
    person p
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=person_info->qual[d.seq].person_id))
   DETAIL
    person_info->qual[d.seq].name_ff = p.name_full_formatted, person_info->qual[d.seq].active_ind = p
    .active_ind
   WITH nocounter
  ;end select
  SELECT
   *
   FROM (dummyt d  WITH seq = cmb_hist_tree->total)
   PLAN (d)
   ORDER BY cmb_hist_tree->qual[d.seq].action_dt_tm
   HEAD REPORT
    spacer_str = fillstring(53,"*"), row + 1
    IF (dchr_cmb_type="PERSON")
     col 0, "Person Combine Tree Report for Person_ID"
    ELSEIF (dchr_cmb_type="ENCOUNTER")
     col 0, "Encounter Combine Tree Report for Encounter_ID"
    ENDIF
    dchr_temp_str = cnvtstring(dchr_from_id), col + 2, dchr_temp_str,
    col + 2, "AS OF", dchr_temp_str = format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM;;q"),
    col + 2, dchr_temp_str, row + 2
   HEAD PAGE
    col 54, "--DATE/TIME----", col 73,
    "Source", col 84, "By ID",
    col 98, "Combine_ID"
    IF (dchr_cmb_type="PERSON")
     col 26, "Name", col 47,
     "PRSNL", col 115, "Act Ind"
    ELSEIF (dchr_cmb_type="ENCOUNTER")
     col 26, "Act Ind", col 35,
     "Name"
    ENDIF
    row + 1
   DETAIL
    IF (((row+ 4) > 17))
     BREAK
    ENDIF
    IF (dchr_cmb_type="PERSON")
     col 0, "PERSON_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].from_id),
     col + 2, dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->
      qual[d.seq].from_id,person_info->qual[dchr_ndx].person_id),
     dchr_temp_str = substring(1,20,person_info->qual[dchr_temp_pos].name_ff), col 26, dchr_temp_str
     IF ((person_info->qual[dchr_temp_pos].prsnl_ind=1))
      dchr_temp_str = "Y"
     ELSE
      dchr_temp_str = "N"
     ENDIF
     col 49, dchr_temp_str, dchr_temp_str = concat('(MRN="',trim(person_info->qual[dchr_temp_pos].mrn
       ),'")'),
     col 54, dchr_temp_str, dchr_temp_str = cnvtstring(person_info->qual[dchr_temp_pos].active_ind),
     col 118, dchr_temp_str, row + 1
     IF ((cmb_hist_tree->qual[d.seq].cmb_state_ind=1))
      dchr_temp_str = "combined away to"
     ELSE
      dchr_temp_str = "uncombined from"
     ENDIF
     col 7, dchr_temp_str, dchr_temp_str = format(cnvtdatetime(cmb_hist_tree->qual[d.seq].
       action_dt_tm),"MM/DD/YYYY HH:MM;;q"),
     col 54, dchr_temp_str, col 73,
     cmb_hist_tree->qual[d.seq].source, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].updt_id
      ), col 84,
     dchr_temp_str, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].combine_id), col 98,
     dchr_temp_str, row + 1, col 0,
     "PERSON_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].to_id), col + 2,
     dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[d.seq
      ].to_id,person_info->qual[dchr_ndx].person_id), dchr_temp_str = substring(1,20,person_info->
      qual[dchr_temp_pos].name_ff),
     col 26, dchr_temp_str
     IF ((person_info->qual[dchr_temp_pos].prsnl_ind=1))
      dchr_temp_str = "Y"
     ELSE
      dchr_temp_str = "N"
     ENDIF
     col 49, dchr_temp_str, dchr_temp_str = concat('(MRN="',trim(person_info->qual[dchr_temp_pos].mrn
       ),'")'),
     col 54, dchr_temp_str, dchr_temp_str = cnvtstring(person_info->qual[dchr_temp_pos].active_ind),
     col 118, dchr_temp_str
    ELSEIF (dchr_cmb_type="ENCOUNTER")
     IF ((cmb_hist_tree->qual[d.seq].encntr_id=0))
      col 0, "ENCNTR_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].from_id),
      col + 2, dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->
       qual[d.seq].person_id,person_info->qual[dchr_ndx].person_id),
      dchr_temp_str = substring(1,20,person_info->qual[dchr_temp_pos].name_ff), col 35, dchr_temp_str,
      dchr_temp_pos = locateval(dchr_ndx,1,encntr_info->total,cmb_hist_tree->qual[d.seq].from_id,
       encntr_info->qual[dchr_ndx].encntr_id), dchr_temp_str = cnvtstring(encntr_info->qual[
       dchr_temp_pos].active_ind), col 29,
      dchr_temp_str, dchr_temp_str = concat('(FIN_NBR="',trim(encntr_info->qual[dchr_temp_pos].
        fin_nbr),'" - VISITID="',trim(encntr_info->qual[dchr_temp_pos].visit_id),'")'), col 57,
      dchr_temp_str, row + 1, col 2,
      "for PERSON_ID ", dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[d
       .seq].person_id,person_info->qual[dchr_ndx].person_id), dchr_temp_str = cnvtstring(person_info
       ->qual[dchr_temp_pos].person_id),
      col 20, dchr_temp_str
      IF ((cmb_hist_tree->qual[d.seq].cmb_state_ind=1))
       dchr_temp_str = "combined away to"
      ELSE
       dchr_temp_str = "uncombined from"
      ENDIF
      col 32, dchr_temp_str, dchr_temp_str = format(cnvtdatetime(cmb_hist_tree->qual[d.seq].
        action_dt_tm),"MM/DD/YYYY HH:MM;;q"),
      col 54, dchr_temp_str, col 73,
      cmb_hist_tree->qual[d.seq].source, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].
       updt_id), col 84,
      dchr_temp_str, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].combine_id), col 98,
      dchr_temp_str, row + 1, col 0,
      "ENCNTR_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].to_id), col + 2,
      dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[d
       .seq].person_id,person_info->qual[dchr_ndx].person_id), dchr_temp_str = substring(1,20,
       person_info->qual[dchr_temp_pos].name_ff),
      col 35, dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,encntr_info->total,cmb_hist_tree->
       qual[d.seq].to_id,encntr_info->qual[dchr_ndx].encntr_id),
      dchr_temp_str = cnvtstring(encntr_info->qual[dchr_temp_pos].active_ind), col 29, dchr_temp_str,
      dchr_temp_str = concat('(FIN_NBR="',trim(encntr_info->qual[dchr_temp_pos].fin_nbr),
       '" - VISITID="',trim(encntr_info->qual[dchr_temp_pos].visit_id),'")'), col 57, dchr_temp_str
     ELSE
      IF (((row+ 6) > 17))
       BREAK
      ENDIF
      col 0, "ENCNTR_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].encntr_id),
      col + 2, dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,encntr_info->total,cmb_hist_tree->
       qual[d.seq].encntr_id,encntr_info->qual[dchr_ndx].encntr_id),
      dchr_temp_str = cnvtstring(encntr_info->qual[dchr_temp_pos].active_ind), col 29, dchr_temp_str,
      dchr_temp_str = concat('(FIN_NBR="',trim(encntr_info->qual[dchr_temp_pos].fin_nbr),
       '" - VISITID="',trim(encntr_info->qual[dchr_temp_pos].visit_id),'")'), col 35, dchr_temp_str,
      row + 1, col 2, "moved from",
      dchr_temp_str = format(cnvtdatetime(cmb_hist_tree->qual[d.seq].action_dt_tm),
       "MM/DD/YYYY HH:MM;;q"), col 54, dchr_temp_str,
      col 73, cmb_hist_tree->qual[d.seq].source, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq
       ].updt_id),
      col 84, dchr_temp_str, dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].combine_id),
      col 98, dchr_temp_str, row + 1,
      col 0, "PERSON_ID", dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].from_id),
      col + 2, dchr_temp_str, dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->
       qual[d.seq].from_id,person_info->qual[dchr_ndx].person_id),
      dchr_temp_str = substring(1,50,person_info->qual[dchr_temp_pos].name_ff), col 35, dchr_temp_str,
      row + 1, col 2, "To",
      row + 1, col 0, "PERSON_ID",
      dchr_temp_str = cnvtstring(cmb_hist_tree->qual[d.seq].to_id), col + 2, dchr_temp_str,
      dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->qual[d.seq].to_id,
       person_info->qual[dchr_ndx].person_id), dchr_temp_str = substring(1,50,person_info->qual[
       dchr_temp_pos].name_ff), col 35,
      dchr_temp_str
     ENDIF
    ENDIF
    row + 1, col 8, spacer_str,
    row + 1
   FOOT PAGE
    row 18, col 0, "Page:",
    col + 2, curpage
   FOOT REPORT
    row 17, col 0, "The current master"
    IF (dchr_cmb_type="PERSON")
     col + 2, "person"
    ELSE
     col + 2, "encounter"
    ENDIF
    col + 2, "for this combine tree is:", dchr_temp_str = cnvtstring(cmb_hist_tree->final_id),
    col + 2, dchr_temp_str, col + 2,
    "-"
    IF (dchr_cmb_type="PERSON")
     dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->final_id,person_info->
      qual[dchr_ndx].person_id)
    ELSE
     dchr_temp_pos = locateval(dchr_ndx,1,person_info->total,cmb_hist_tree->final_person_id,
      person_info->qual[dchr_ndx].person_id)
    ENDIF
    col + 2, person_info->qual[dchr_temp_pos].name_ff
   WITH nocounter, noformfeed, maxrow = 20
  ;end select
 ELSE
  SELECT
   FROM dual
   DETAIL
    col 0, "No combine activity found for"
    IF (dchr_cmb_type="PERSON")
     col + 2, "Person_ID"
    ELSE
     col + 2, "Encntr_ID"
    ENDIF
    col + 2, dchr_from_id
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE get_cmb_hist(i_from_id,i_combine_type,i_tree_rec,i_beg_dt_tm,i_end_dt_tm,i_cmb_tbl_rec)
   DECLARE s_tot_cmb = i2 WITH protect, noconstant(0)
   DECLARE s_start_pos = i2 WITH protect, noconstant(0)
   DECLARE s_offset = i2 WITH protect, noconstant(0)
   DECLARE s_next_end_dt_tm = dq8 WITH protect, noconstant(0.0)
   DECLARE s_encounter_col = vc WITH protect, noconstant("pc.encntr_id")
   DECLARE s_encounter_val = vc WITH protect, noconstant("0")
   DECLARE s_ndx = i2 WITH protect, noconstant(0)
   IF (i_combine_type="ENCOUNTER")
    SELECT INTO "nl:"
     pc.person_combine_id, pc.from_person_id, pc.to_person_id,
     pc.cmb_dt_tm, pc.ucb_dt_tm, pc.active_ind,
     pc.encntr_id, action_dt_tm = nullval(pc.cmb_dt_tm,pc.updt_dt_tm), cmb_id = nullval(pc
      .cmb_updt_id,pc.updt_id)
     FROM person_combine pc
     WHERE pc.encntr_id=i_from_id
      AND nullval(pc.cmb_dt_tm,pc.updt_dt_tm) BETWEEN cnvtdatetime(i_beg_dt_tm) AND cnvtdatetime(
      i_end_dt_tm)
     ORDER BY action_dt_tm
     DETAIL
      stat = alterlist(i_tree_rec->qual,(i_tree_rec->total+ 1)), i_tree_rec->total = (i_tree_rec->
      total+ 1), i_tree_rec->qual[i_tree_rec->total].combine_id = pc.person_combine_id,
      i_tree_rec->qual[i_tree_rec->total].from_id = pc.from_person_id, i_tree_rec->qual[i_tree_rec->
      total].to_id = pc.to_person_id, i_tree_rec->qual[i_tree_rec->total].updt_id = cmb_id,
      i_tree_rec->qual[i_tree_rec->total].active_ind = pc.active_ind, i_tree_rec->qual[i_tree_rec->
      total].encntr_id = pc.encntr_id, i_tree_rec->qual[i_tree_rec->total].action_dt_tm =
      cnvtdatetime(action_dt_tm),
      i_tree_rec->qual[i_tree_rec->total].cmb_state_ind = 1, i_tree_rec->qual[i_tree_rec->total].
      source = pc.transaction_type
     WITH nocounter
    ;end select
    SET s_encounter_col = "1"
    SET s_encounter_val = "1"
   ENDIF
   SET s_start_pos = i_tree_rec->total
   SELECT INTO "nl:"
    parser(build("pc.",i_cmb_tbl_rec->pk_col)), parser(build("pc.",i_cmb_tbl_rec->from_id_col)),
    parser(build("pc.",i_cmb_tbl_rec->to_id_col)),
    pc.cmb_dt_tm, pc.ucb_dt_tm, pc.active_ind,
    parser(s_encounter_col), action_dt_tm = nullval(pc.cmb_dt_tm,pc.updt_dt_tm), cmb_id = nullval(pc
     .cmb_updt_id,pc.updt_id),
    ucb_id = nullval(pc.ucb_updt_id,pc.updt_id)
    FROM (parser(i_cmb_tbl_rec->tbl_name) pc)
    WHERE parser(build("pc.",i_cmb_tbl_rec->from_id_col))=i_from_id
     AND parser(build(s_encounter_col," = ",s_encounter_val))
     AND nullval(pc.cmb_dt_tm,pc.updt_dt_tm) BETWEEN cnvtdatetime(i_beg_dt_tm) AND cnvtdatetime(
     i_end_dt_tm)
    ORDER BY action_dt_tm
    DETAIL
     s_tot_cmb = (s_tot_cmb+ 1)
     IF (pc.active_ind=0)
      stat = alterlist(i_tree_rec->qual,(i_tree_rec->total+ 2))
     ELSE
      stat = alterlist(i_tree_rec->qual,(i_tree_rec->total+ 1))
     ENDIF
     i_tree_rec->total = (i_tree_rec->total+ 1), i_tree_rec->qual[i_tree_rec->total].combine_id =
     parser(build("pc.",i_cmb_tbl_rec->pk_col)), i_tree_rec->qual[i_tree_rec->total].from_id = parser
     (build("pc.",i_cmb_tbl_rec->from_id_col)),
     i_tree_rec->qual[i_tree_rec->total].to_id = parser(build("pc.",i_cmb_tbl_rec->to_id_col)),
     i_tree_rec->qual[i_tree_rec->total].updt_id = cmb_id, i_tree_rec->qual[i_tree_rec->total].
     active_ind = pc.active_ind,
     i_tree_rec->qual[i_tree_rec->total].action_dt_tm = cnvtdatetime(action_dt_tm), i_tree_rec->qual[
     i_tree_rec->total].cmb_state_ind = 1, i_tree_rec->qual[i_tree_rec->total].source = pc
     .transaction_type
     IF (pc.active_ind=0)
      i_tree_rec->total = (i_tree_rec->total+ 1), i_tree_rec->qual[i_tree_rec->total].combine_id =
      parser(build("pc.",i_cmb_tbl_rec->pk_col)), i_tree_rec->qual[i_tree_rec->total].from_id =
      parser(build("pc.",i_cmb_tbl_rec->from_id_col)),
      i_tree_rec->qual[i_tree_rec->total].to_id = parser(build("pc.",i_cmb_tbl_rec->to_id_col)),
      i_tree_rec->qual[i_tree_rec->total].updt_id = ucb_id, i_tree_rec->qual[i_tree_rec->total].
      active_ind = pc.active_ind,
      i_tree_rec->qual[i_tree_rec->total].action_dt_tm = nullval(pc.ucb_dt_tm,pc.updt_dt_tm),
      i_tree_rec->qual[i_tree_rec->total].cmb_state_ind = 0, i_tree_rec->qual[i_tree_rec->total].
      source = pc.transaction_type
     ELSE
      i_tree_rec->final_id = parser(build("pc.",i_cmb_tbl_rec->to_id_col))
     ENDIF
    WITH nocounter
   ;end select
   FOR (s_ndx = 1 TO s_tot_cmb)
     SET s_offset = ((2 * (s_ndx - 1))+ 1)
     IF (s_ndx=s_tot_cmb)
      IF ((i_tree_rec->qual[(s_start_pos+ s_offset)].active_ind=1))
       SET s_next_end_dt_tm = cnvtdatetime(curdate,curtime3)
      ELSE
       SET s_next_end_dt_tm = i_tree_rec->qual[((s_start_pos+ s_offset)+ 1)].action_dt_tm
      ENDIF
     ELSE
      SET s_next_end_dt_tm = i_tree_rec->qual[((s_start_pos+ s_offset)+ 1)].action_dt_tm
     ENDIF
     CALL echo(i_tree_rec->qual[(s_start_pos+ s_offset)].to_id)
     CALL echo(i_tree_rec->qual[(s_start_pos+ s_offset)].active_ind)
     CALL get_cmb_hist(i_tree_rec->qual[(s_start_pos+ s_offset)].to_id,i_combine_type,i_tree_rec,
      i_tree_rec->qual[(s_start_pos+ s_offset)].action_dt_tm,s_next_end_dt_tm,
      i_cmb_tbl_rec)
   ENDFOR
 END ;Subroutine
#exit_dchr
END GO
