CREATE PROGRAM bhs_mp_hospitalist:dba
 EXECUTE bhs_hlp_ccl
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 RECORD dgapl_reply(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,dgapl_request), replace(reply,dgapl_reply)
 CALL echorecord(dgapl_reply)
 IF ((dgapl_reply->status_data.status="F"))
  CALL echo("***** external call to dcp_get_available_pat_lists failed")
  SET data->error = "External call to dcp_get_available_pat_lists failed"
  GO TO exit_program
 ENDIF
 RECORD dgp_reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i2
   1 arguments[2]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
   1 patient_list_name = vc
   1 mv_flag = i2
   1 rmv_pl_rows_flag = i2
 )
 FREE RECORD data
 RECORD data(
   1 error = vc
   1 owner_person_id = f8
   1 owner_name = vc
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 patient_list_name = vc
   1 parent_entity_name = vc
   1 parent_entity_id = f8
   1 patients[*]
     2 hospitalist_row_id = f8
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 mrn = vc
     2 dob = dq8
     2 room = vc
     2 nurse_unit = vc
     2 bed = vc
     2 date_assigned = dq8
     2 diagnosis = vc
     2 level_of_care = vc
     2 floor = vc
     2 pending_arrival = vc
     2 ap_resident = vc
     2 attending_preceptor = vc
     2 attending_preceptor_id = f8
     2 urgent = vc
     2 notes = vc
     2 is_new_record = i2
     2 locked_ind = i2
     2 patient_list_key = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_careteam_pl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",27360,"CARETEAM")
  )
 DECLARE mf_provider_group_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",19189,
   "PROVIDERGROUP"))
 DECLARE ms_careteam_list_argument_name_key = vc WITH protect, constant("careteam_id")
 DECLARE ms_group_name_key = vc WITH protect, noconstant(" ")
 DECLARE ms_hos_careteam_pl_name = vc WITH protect, constant("HMP Admit/Consult")
 DECLARE ms_res_careteam_pl_name = vc WITH protect, constant("Resident Admit")
 DECLARE ms_noble_pl_name = vc WITH protect, constant("Noble New Admits")
 DECLARE ms_pedi_pl_name = vc WITH protect, constant("PEDI PINK")
 DECLARE ms_careteam_pl_name = vc WITH noconstant("")
 DECLARE ml_selection = i4 WITH protect, noconstant(0)
 DECLARE ml_rec_size = i4 WITH noconstant(0)
 DECLARE ml_expnd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_arg_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 IF (( $1="R"))
  SET ms_careteam_pl_name = ms_res_careteam_pl_name
  SET ms_group_name_key = "CHMP"
 ELSEIF (( $1="H"))
  SET ms_careteam_pl_name = ms_hos_careteam_pl_name
  SET ms_group_name_key = "CHMP"
 ELSEIF (( $1="N"))
  SET ms_careteam_pl_name = ms_noble_pl_name
  SET ms_group_name_key = "NOBLE HOSPITAL MEDICINE"
 ELSEIF (( $1="P"))
  SET ms_careteam_pl_name = ms_pedi_pl_name
  SET ms_group_name_key = "P"
 ELSE
  CALL echo(build("***** invalid view option selected: ", $1,".  Please choose a valid view."))
  SET data->error = build("Access Denied. Please view Help page. (Invalid view parameter detected: ",
    $1,")")
  GO TO exit_program
 ENDIF
 IF (( $1 IN ("H", "R", "N")))
  SELECT INTO "nl:"
   FROM prsnl_group pg,
    prsnl_group_reltn pgr
   PLAN (pg
    WHERE pg.active_ind=1
     AND pg.prsnl_group_class_cd=mf_provider_group_cd
     AND pg.prsnl_group_name_key=ms_group_name_key)
    JOIN (pgr
    WHERE pgr.active_ind=1
     AND pg.prsnl_group_id=pgr.prsnl_group_id
     AND (pgr.person_id=reqinfo->updt_id))
   WITH nocounter
  ;end select
 ELSEIF (( $1 IN ("P")))
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.active_ind=1
     AND (p.person_id=reqinfo->updt_id))
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0
  AND ( $1 != "N"))
  CALL echo(build("***** user does not have access to ",ms_group_name_key," provider group list"))
  SET data->error = build(
   "Permission denied. User does not have access to following Provider Group list: ",
   ms_group_name_key)
  GO TO exit_program
 ENDIF
 SET ml_selection = locateval(ml_idx1,1,size(dgapl_reply->patient_lists,5),mf_careteam_pl_cd,
  dgapl_reply->patient_lists[ml_idx1].patient_list_type_cd,
  ms_careteam_pl_name,dgapl_reply->patient_lists[ml_idx1].name)
 CALL echo(build("ml_selection - ",ml_selection))
 IF (ml_selection=0)
  CALL echo(build("***** user does not have access to ",ms_careteam_pl_name," patient list"))
  SET data->error = concat("User has not added the ",ms_careteam_pl_name," list")
  GO TO exit_program
 ENDIF
 SET request->patient_list_id = dgapl_reply->patient_lists[ml_selection].patient_list_id
 SET request->patient_list_type_cd = dgapl_reply->patient_lists[ml_selection].patient_list_type_cd
 SET ml_arg_list_cnt = size(dgapl_reply->patient_lists[ml_selection].arguments,5)
 FOR (ml_idx1 = 1 TO ml_arg_list_cnt)
   IF ((dgapl_reply->patient_lists[ml_selection].arguments[ml_idx1].argument_name=
   ms_careteam_list_argument_name_key))
    SET request->arguments[1].argument_name = dgapl_reply->patient_lists[ml_selection].arguments[
    ml_idx1].argument_name
    SET request->arguments[1].argument_value = dgapl_reply->patient_lists[ml_selection].arguments[
    ml_idx1].argument_value
    SET request->arguments[1].parent_entity_name = dgapl_reply->patient_lists[ml_selection].
    arguments[ml_idx1].parent_entity_name
    SET request->arguments[1].parent_entity_id = dgapl_reply->patient_lists[ml_selection].arguments[
    ml_idx1].parent_entity_id
    SET data->parent_entity_name = dgapl_reply->patient_lists[ml_selection].arguments[ml_idx1].
    parent_entity_name
    SET data->parent_entity_id = dgapl_reply->patient_lists[ml_selection].arguments[ml_idx1].
    parent_entity_id
   ENDIF
 ENDFOR
 SET request->arguments[2].argument_name = "disch_mins"
 SET request->arguments[2].argument_value = "-1"
 SET request->arguments[2].parent_entity_name = ""
 SET request->arguments[2].parent_entity_id = 0.00
 SET dgp_reply->status_data.status = "F"
 SET request->patient_list_name = dgapl_reply->patient_lists[ml_selection].name
 SET request->mv_flag = - (1)
 SET request->rmv_pl_rows_flag = 0
 SET data->patient_list_name = dgapl_reply->patient_lists[ml_selection].name
 SET data->patient_list_id = dgapl_reply->patient_lists[ml_selection].patient_list_id
 SET data->owner_person_id = dgapl_reply->patient_lists[ml_selection].owner_id
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=data->owner_person_id)
    AND p.active_ind=1)
  HEAD p.person_id
   data->owner_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 EXECUTE bhs_dcp_get_pl_careteam2
 IF (size(dgp_reply->patients,5) <= 0)
  CALL echo("*** no patients found based on current arguments for current user")
  SET data->error = "No patients found based on current arguments for current user"
  GO TO exit_program
 ENDIF
 SET ml_rec_size = size(dgp_reply->patients,5)
 SET stat = alterlist(data->patients,ml_rec_size)
 FOR (ml_idx1 = 1 TO ml_rec_size)
   SET data->patients[ml_idx1].person_id = dgp_reply->patients[ml_idx1].person_id
   SET data->patients[ml_idx1].person_name = dgp_reply->patients[ml_idx1].person_name
   SET data->patients[ml_idx1].encntr_id = dgp_reply->patients[ml_idx1].encntr_id
   SET data->patients[ml_idx1].patient_list_key = ms_careteam_pl_name
 ENDFOR
 SET ml_idx1 = 0
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   dcp_pl_custom_entry dce,
   encntr_alias ea
  PLAN (e
   WHERE expand(ml_expnd_cnt,1,ml_rec_size,e.encntr_id,data->patients[ml_expnd_cnt].encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (dce
   WHERE dce.person_id=p.person_id
    AND dce.encntr_id=e.encntr_id
    AND (dce.prsnl_group_id=data->parent_entity_id))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY dce.encntr_id
  HEAD dce.encntr_id
   ml_pos = locateval(ml_idx1,1,ml_rec_size,e.encntr_id,data->patients[ml_idx1].encntr_id), data->
   patients[ml_pos].mrn = trim(ea.alias), data->patients[ml_pos].nurse_unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd)),
   data->patients[ml_pos].room = trim(uar_get_code_display(e.loc_room_cd)), data->patients[ml_pos].
   bed = trim(uar_get_code_display(e.loc_bed_cd)), data->patients[ml_pos].dob = p.birth_dt_tm,
   data->patients[ml_pos].date_assigned = dce.updt_dt_tm, data->patients[ml_pos].patient_list_key =
   ms_careteam_pl_name
  WITH nocounter
 ;end select
 SET ml_idx1 = 0
 UPDATE  FROM bhs_hospitalist bh
  SET bh.active_ind = 0, bh.update_cnt = (bh.update_cnt+ 1), bh.locked_ind = 0,
   bh.update_dt_tm = sysdate, bh.update_id = reqinfo->updt_id, bh.patient_list_key =
   ms_careteam_pl_name
  WHERE  NOT (expand(ml_idx1,1,ml_rec_size,bh.encntr_id,data->patients[ml_idx1].encntr_id))
   AND bh.active_ind=1
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM bhs_hospitalist bh,
   (dummyt d2  WITH seq = value(size(data->patients,5)))
  SET bh.active_ind = 1, bh.update_cnt = (bh.update_cnt+ 1), bh.locked_ind = 0,
   bh.assigned_dt_tm = cnvtdatetime(data->patients[d2.seq].date_assigned), bh.update_dt_tm = sysdate,
   bh.update_id = reqinfo->updt_id,
   bh.patient_list_key = ms_careteam_pl_name
  PLAN (d2)
   JOIN (bh
   WHERE (bh.encntr_id=data->patients[d2.seq].encntr_id)
    AND bh.active_ind=0)
  WITH nocounter
 ;end update
 COMMIT
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(data->patients,5))),
   bhs_hospitalist h
  PLAN (d)
   JOIN (h
   WHERE (data->patients[d.seq].encntr_id=h.encntr_id))
  DETAIL
   data->patients[d.seq].is_new_record = 1, data->patients[d.seq].patient_list_key =
   ms_careteam_pl_name
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 INSERT  FROM bhs_hospitalist bh,
   (dummyt d2  WITH seq = value(size(data->patients,5)))
  SET bh.hospitalist_row_id = seq(bhs_hospitalist_seq,nextval), bh.encntr_id = data->patients[d2.seq]
   .encntr_id, bh.patient_id = data->patients[d2.seq].person_id,
   bh.assigned_dt_tm = cnvtdatetime(data->patients[d2.seq].date_assigned), bh.locked_ind = 0, bh
   .pending_arrival = 0,
   bh.urgent = 0, bh.update_cnt = 0, bh.update_dt_tm = sysdate,
   bh.update_id = reqinfo->updt_id, bh.active_ind = 1, bh.patient_list_key = ms_careteam_pl_name
  PLAN (d2
   WHERE (data->patients[d2.seq].is_new_record=1))
   JOIN (bh)
  WITH nocounter
 ;end insert
 COMMIT
 SET ml_idx1 = 0
 SET ml_expnd_cnt = 0
 SELECT INTO "nl:"
  FROM bhs_hospitalist bh
  PLAN (bh
   WHERE expand(ml_expnd_cnt,1,ml_rec_size,bh.encntr_id,data->patients[ml_expnd_cnt].encntr_id))
  ORDER BY bh.hospitalist_row_id DESC, bh.encntr_id
  HEAD bh.encntr_id
   ml_pos = locateval(ml_idx1,1,ml_rec_size,bh.encntr_id,data->patients[ml_idx1].encntr_id), data->
   patients[ml_pos].hospitalist_row_id = bh.hospitalist_row_id, data->patients[ml_pos].date_assigned
    = bh.assigned_dt_tm,
   data->patients[ml_pos].diagnosis = trim(bh.diagnosis), data->patients[ml_pos].level_of_care = trim
   (bh.level_of_care), data->patients[ml_pos].floor = trim(bh.floor),
   data->patients[ml_pos].pending_arrival = trim(build(bh.pending_arrival),3), data->patients[ml_pos]
   .ap_resident = trim(bh.ap_resident), data->patients[ml_pos].attending_preceptor = trim(bh
    .attending_preceptor),
   data->patients[ml_pos].attending_preceptor_id = bh.attending_preceptor_id, data->patients[ml_pos].
   urgent = trim(build(bh.urgent),3), data->patients[ml_pos].notes = trim(bh.notes),
   data->patients[ml_pos].locked_ind = bh.locked_ind, data->patients[ml_pos].patient_list_key = bh
   .patient_list_key
  WITH nocounter
 ;end select
 SET ms_msg = "P627"
 FOR (ml_cnt = 1 TO size(data->patients,5))
   CALL bhs_sbr_log("log","",ml_cnt,"person_id",data->patients[ml_cnt].person_id,
    data->patients[ml_cnt].patient_list_key,data->patients[ml_cnt].pending_arrival,"S")
   CALL bhs_sbr_log("log","",ml_cnt,"encntr_id",data->patients[ml_cnt].encntr_id,
    data->patients[ml_cnt].patient_list_key,data->patients[ml_cnt].level_of_care,"S")
   CALL bhs_sbr_log("log","",ml_cnt,"prsnl_id",data->patients[ml_cnt].attending_preceptor_id,
    data->patients[ml_cnt].patient_list_key,data->patients[ml_cnt].ap_resident,"S")
   CALL bhs_sbr_log("log","",ml_cnt,"arrival_date",data->patients[ml_cnt].date_assigned,
    data->patients[ml_cnt].patient_list_key,data->patients[ml_cnt].urgent,"S")
 ENDFOR
#exit_program
 CALL bhs_sbr_log("stop","",0,"",0.0,
  concat(trim(cnvtstring(size(data->patients,5)))," patients found"),ms_msg,"S")
 SET _memory_reply_string = cnvtrectojson(data,2,1)
 CALL echorecord(data)
END GO
