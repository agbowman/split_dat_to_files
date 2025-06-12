CREATE PROGRAM bhs_athn_read_prsnl_v2
 RECORD t_record(
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 person_id = f8
     2 email = vc
 )
 RECORD out_rec(
   1 prsnls[*]
     2 name_first = vc
     2 name_last = vc
     2 name_full_formatted = vc
     2 physician_ind = vc
     2 position_disp = vc
     2 position_cd = vc
     2 email = vc
     2 prsnl_id = vc
     2 username = vc
     2 active_status_disp = vc
     2 active_status_mean = vc
     2 active_status_cd = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 resource_value = vc
 )
 DECLARE p_cnt = i4
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE physician_ind = i2
 IF (( $6="PhysicianOnly"))
  SET physician_ind = 1
 ENDIF
 IF (( $6="NonPhysicianOnly"))
  SET physician_ind = 2
 ENDIF
 DECLARE search_string = vc
 DECLARE search_string2 = vc
 IF (( $2 > 0))
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE (pr.person_id= $2)
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) )) )
   ORDER BY pr.name_full_formatted
   HEAD pr.name_full_formatted
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $3 > " "))
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE cnvtupper(pr.username)=cnvtupper( $3)
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) )) )
   ORDER BY pr.name_full_formatted
   HEAD pr.name_full_formatted
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $4 > " ")
  AND ( $5 <= " "))
  SET search_string = concat("*",cnvtupper( $4),"*")
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE pr.name_first_key=patstring(search_string)
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) )) )
   ORDER BY pr.name_full_formatted
   HEAD pr.name_full_formatted
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $5 > " ")
  AND ( $4 <= " "))
  SET search_string = concat("*",cnvtupper( $5),"*")
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE pr.name_last_key=patstring(search_string)
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) )) )
   ORDER BY pr.name_full_formatted
   HEAD pr.name_full_formatted
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $4 > " ")
  AND ( $5 > " "))
  SET search_string = concat("*",cnvtupper( $4),"*")
  SET search_string2 = concat("*",cnvtupper( $5),"*")
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE pr.name_first_key=patstring(search_string)
     AND pr.name_last_key=patstring(search_string2)
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) )) )
   ORDER BY pr.name_full_formatted
   HEAD pr.name_full_formatted
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $7 > " "))
  SET search_string = concat(cnvtupper( $7),"*")
  SELECT INTO "nl:"
   FROM prsnl pr
   PLAN (pr
    WHERE ((pr.name_last_key=patstring(search_string)) OR (pr.name_first_key=patstring(search_string)
    ))
     AND ((physician_ind=0) OR (((physician_ind=1
     AND pr.physician_ind=1) OR (physician_ind=2
     AND pr.physician_ind=0)) ))
     AND pr.active_status_cd=active_cd)
   ORDER BY pr.name_full_formatted
   HEAD pr.person_id
    p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->prsnls,p_cnt), out_rec->prsnls[p_cnt].name_first =
    pr.name_first,
    out_rec->prsnls[p_cnt].name_last = pr.name_last, out_rec->prsnls[p_cnt].name_full_formatted = pr
    .name_full_formatted, out_rec->prsnls[p_cnt].physician_ind = cnvtstring(pr.physician_ind),
    out_rec->prsnls[p_cnt].position_disp = uar_get_code_display(pr.position_cd), out_rec->prsnls[
    p_cnt].position_cd = cnvtstring(pr.position_cd), out_rec->prsnls[p_cnt].email = pr.email,
    out_rec->prsnls[p_cnt].prsnl_id = cnvtstring(pr.person_id), out_rec->prsnls[p_cnt].username = pr
    .username, out_rec->prsnls[p_cnt].active_status_disp = uar_get_code_display(pr.active_status_cd),
    out_rec->prsnls[p_cnt].active_status_mean = uar_get_code_meaning(pr.active_status_cd), out_rec->
    prsnls[p_cnt].active_status_cd = cnvtstring(pr.active_status_cd), out_rec->prsnls[p_cnt].
    beg_effective_dt_tm = pr.beg_effective_dt_tm,
    out_rec->prsnls[p_cnt].end_effective_dt_tm = pr.end_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (((( $2 > 0)) OR (( $3 > " "))) )
  SELECT INTO "nl:"
   FROM application_ini ai
   PLAN (ai
    WHERE ai.person_id=cnvtreal(out_rec->prsnls[1].prsnl_id)
     AND ai.section="CPSSCHEDULE"
     AND ai.parameter_data="*SCH_DEFAULTRES*")
   HEAD REPORT
    out_rec->prsnls[1].resource_value = cnvtstring(substring((findstring("SCH_DEFAULTRES",ai
       .parameter_data)+ 15),15,ai.parameter_data))
   WITH nocounter, time = 10
  ;end select
 ENDIF
 CALL echojson(out_rec, $1)
END GO
