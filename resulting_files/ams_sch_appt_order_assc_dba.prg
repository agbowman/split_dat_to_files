CREATE PROGRAM ams_sch_appt_order_assc:dba
 PROMPT
  "Save your Inputs in any CSV file which is there in any of the below folders, click EXECUTE" =
  "MINE",
  "Directory" = "",
  "Pass Input File name Here" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE notdelete_var = f8 WITH constant(uar_get_code_by("MEANING",23013,"NOTDELETE")), protect
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 RECORD orig_content(
   1 rec[*]
     2 ordername = vc
     2 appttype = vc
     2 flexid = vc
     2 proc_mean = vc
     2 location = vc
     2 dur = vc
     2 setup = vc
     2 setupmean = vc
     2 duration = vc
     2 duration_mean = vc
     2 clean = vc
     2 clean_mean = vc
     2 arrival = vc
     2 arrival_mean = vc
     2 recovery = vc
     2 recovery_mean = vc
     2 dur_flexid = vc
     2 loc_loc = vc
     2 loc_role = vc
     2 loc_flexid = vc
 )
 RECORD file_content(
   1 qual[*]
     2 catalog_cd = vc
     2 appt[*]
       3 appt_type = vc
       3 flex_id = vc
       3 proc_mean = vc
     2 location[*]
       3 location_cd = vc
     2 duration[*]
       3 duration_cd = vc
       3 set_up = i4
       3 set_up_mean = vc
       3 duration = i4
       3 duration_mean = vc
       3 clean_up = i4
       3 cleanup_mean = vc
       3 arrival = i4
       3 arrival_mean = vc
       3 recovery = i4
       3 recovery_mean = vc
       3 flex_id = vc
     2 roles[*]
       3 loc_cd = vc
       3 loc_role = vc
       3 flex_id = vc
 )
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_appts(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 DECLARE locateroles = c500
 DECLARE sub_content = vc
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(orig_content->rec,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(orig_content->rec,(row_count+ 9))
     ENDIF
     orig_content->rec[row_count].ordername = piece(line1,",",1,"Not Found"), orig_content->rec[
     row_count].appttype = piece(line1,",",2,"Not Found"), orig_content->rec[row_count].flexid =
     piece(line1,",",3,"Not Found"),
     orig_content->rec[row_count].proc_mean = piece(line1,",",4,"Not Found"), orig_content->rec[
     row_count].location = piece(line1,",",5,"Not Found"), orig_content->rec[row_count].dur = piece(
      line1,",",6,"Not Found"),
     orig_content->rec[row_count].setup = piece(line1,",",7,"Not Found"), orig_content->rec[row_count
     ].setupmean = piece(line1,",",8,"Not Found"), orig_content->rec[row_count].duration = piece(
      line1,",",9,"Not Found"),
     orig_content->rec[row_count].duration_mean = piece(line1,",",10,"Not Found"), orig_content->rec[
     row_count].clean = piece(line1,",",11,"Not Found"), orig_content->rec[row_count].clean_mean =
     piece(line1,",",12,"Not Found"),
     orig_content->rec[row_count].arrival = piece(line1,",",13,"Not Found"), orig_content->rec[
     row_count].arrival_mean = piece(line1,",",14,"Not Found"), orig_content->rec[row_count].recovery
      = piece(line1,",",15,"Not Found"),
     orig_content->rec[row_count].recovery_mean = piece(line1,",",16,"Not Found"), orig_content->rec[
     row_count].dur_flexid = piece(line1,",",17,"Not Found"), orig_content->rec[row_count].loc_loc =
     piece(line1,",",18,"Not Found"),
     orig_content->rec[row_count].loc_role = piece(line1,",",19,"Not Found"), orig_content->rec[
     row_count].loc_flexid = piece(line1,",",20,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET row_count = 0
 SET app_count = 0
 SET loc_count = 0
 SET dur_count = 0
 SET role_count = 0
 FOR (i = 1 TO size(orig_content->rec,5))
   IF ((orig_content->rec[i].ordername != ""))
    SET row_count = (row_count+ 1)
    SET app_count = 0
    SET loc_count = 0
    SET dur_count = 0
    SET role_count = 0
    SET stat = alterlist(file_content->qual,row_count)
    SET file_content->qual[row_count].catalog_cd = cnvtupper(trim(orig_content->rec[i].ordername,4))
   ENDIF
   IF ((orig_content->rec[i].appttype != ""))
    SET app_count = (app_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].appt,app_count)
    SET file_content->qual[row_count].appt[app_count].appt_type = cnvtupper(trim(orig_content->rec[i]
      .appttype,4))
    IF ((orig_content->rec[i].flexid != ""))
     SET file_content->qual[row_count].appt[app_count].flex_id = orig_content->rec[i].flexid
    ENDIF
    IF ((orig_content->rec[i].proc_mean != ""))
     SET file_content->qual[row_count].appt[app_count].proc_mean = orig_content->rec[i].proc_mean
    ENDIF
   ENDIF
   IF ((orig_content->rec[i].location != ""))
    SET loc_count = (loc_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].location,loc_count)
    SET file_content->qual[row_count].location[loc_count].location_cd = cnvtupper(trim(orig_content->
      rec[i].location,4))
   ENDIF
   IF ((orig_content->rec[i].dur != ""))
    SET dur_count = (dur_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].duration,dur_count)
    SET file_content->qual[row_count].duration[dur_count].duration_cd = cnvtupper(trim(orig_content->
      rec[i].dur,4))
    IF ((orig_content->rec[i].duration != ""))
     SET file_content->qual[row_count].duration[dur_count].duration = cnvtint(orig_content->rec[i].
      duration)
    ENDIF
    IF ((orig_content->rec[i].duration_mean != ""))
     SET file_content->qual[row_count].duration[dur_count].duration_mean = orig_content->rec[i].
     duration_mean
    ENDIF
    IF ((orig_content->rec[i].setup != ""))
     SET file_content->qual[row_count].duration[dur_count].set_up = cnvtint(orig_content->rec[i].
      setup)
    ENDIF
    IF ((orig_content->rec[i].setupmean != ""))
     SET file_content->qual[row_count].duration[dur_count].set_up_mean = orig_content->rec[i].
     setupmean
    ENDIF
    IF ((orig_content->rec[i].clean != ""))
     SET file_content->qual[row_count].duration[dur_count].clean_up = cnvtint(orig_content->rec[i].
      clean)
    ENDIF
    IF ((orig_content->rec[i].clean_mean != ""))
     SET file_content->qual[row_count].duration[dur_count].cleanup_mean = orig_content->rec[i].
     clean_mean
    ENDIF
    IF ((orig_content->rec[i].arrival != ""))
     SET file_content->qual[row_count].duration[dur_count].arrival = cnvtint(orig_content->rec[i].
      arrival)
    ENDIF
    IF ((orig_content->rec[i].arrival_mean != ""))
     SET file_content->qual[row_count].duration[dur_count].arrival_mean = orig_content->rec[i].
     arrival_mean
    ENDIF
    IF ((orig_content->rec[i].recovery != ""))
     SET file_content->qual[row_count].duration[dur_count].recovery = cnvtint(orig_content->rec[i].
      recovery)
    ENDIF
    IF ((orig_content->rec[i].recovery_mean != ""))
     SET file_content->qual[row_count].duration[dur_count].recovery_mean = orig_content->rec[i].
     recovery_mean
    ENDIF
    IF ((orig_content->rec[i].dur_flexid != ""))
     SET file_content->qual[row_count].duration[dur_count].flex_id = orig_content->rec[i].dur_flexid
    ENDIF
   ENDIF
   IF ((orig_content->rec[i].loc_loc != ""))
    SET role_count = (role_count+ 1)
    SET stat = alterlist(file_content->qual[row_count].roles,role_count)
    SET file_content->qual[row_count].roles[role_count].loc_cd = cnvtupper(trim(orig_content->rec[i].
      loc_loc,4))
    IF ((orig_content->rec[i].loc_role != ""))
     SET file_content->qual[row_count].roles[role_count].loc_role = cnvtupper(orig_content->rec[i].
      loc_role)
    ENDIF
    IF ((orig_content->rec[i].loc_flexid != ""))
     SET file_content->qual[row_count].roles[role_count].flex_id = orig_content->rec[i].loc_flexid
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD request1
 RECORD request1(
   1 qual[*]
     2 catalog_cd = f8
 )
 FREE RECORD reply1
 RECORD reply1(
   1 qual_cnt = i4
   1 sch_flex_id = f8
   1 candidate_id = f8
   1 updt_cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 catalog_mean = c12
     2 catalog_disp = vc
     2 loc_cnt = i4
     2 loc[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_mean = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 appt_cnt = i4
     2 appt[*]
       3 appt_type_cd = f8
       3 appt_type_mnem = c40
       3 seq_nbr = i4
       3 display_seq_nbr = i4
       3 sch_flex_id = f8
       3 mnemonic = vc
       3 proc_spec_cd = f8
       3 proc_spec_mean = c12
       3 del_appt_cd = f8
       3 del_appt_mean = c12
       3 event_concurrent_ind = i2
       3 child_appt_type_cd = f8
       3 child_appt_synonym_cd = f8
       3 child_appt_synonym_disp = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 appt_type_flag = i2
     2 dur_cnt = i4
     2 dur[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_mean = c12
       3 seq_nbr = i4
       3 sch_flex_id = f8
       3 mnemonic = vc
       3 setup_units = i4
       3 setup_units_cd = f8
       3 setup_units_meaning = c12
       3 duration_units = i4
       3 duration_units_cd = f8
       3 duration_units_meaning = c12
       3 cleanup_units = i4
       3 cleanup_units_cd = f8
       3 cleanup_units_meaning = c12
       3 offset_type_cd = f8
       3 offset_type_meaning = c12
       3 offset_beg_units = i4
       3 offset_beg_units_cd = f8
       3 offset_beg_units_meaning = c12
       3 offset_end_units = i4
       3 offset_end_units_cd = f8
       3 offset_end_units_meaning = c12
       3 arrival_units = i4
       3 arrival_units_cd = f8
       3 arrival_units_meaning = c12
       3 recovery_units = i4
       3 recovery_units_cd = f8
       3 recovery_units_meaning = c12
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 role_cnt = i4
     2 role[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_mean = c12
       3 seq_nbr = i4
       3 list_role_id = f8
       3 role_mnem = vc
       3 sch_flex_id = f8
       3 mnemonic = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
     2 inter_cnt = i4
     2 inter[*]
       3 inter_type_cd = f8
       3 inter_type_meaning = vc
       3 seq_group_id = f8
       3 mnemonic = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 location_cd = f8
       3 location_disp = c40
     2 text_cnt = i4
     2 text[*]
       3 text_link_id = f8
       3 location_cd = f8
       3 location_meaning = vc
       3 location_display = vc
       3 text_type_cd = f8
       3 text_type_meaning = vc
       3 sub_text_cd = f8
       3 sub_text_meaning = vc
       3 text_accept_cd = f8
       3 text_accept_meaning = vc
       3 template_accept_cd = f8
       3 template_accept_meaning = vc
       3 sch_action_cd = f8
       3 action_meaning = vc
       3 expertise_level = i4
       3 lapse_units = i4
       3 lapse_units_cd = f8
       3 lapse_units_meaning = vc
       3 updt_cnt = i4
       3 active_ind = i2
       3 candidate_id = f8
       3 sub_list_cnt = i4
       3 sub_list[*]
         4 template_id = f8
         4 seq_nbr = i4
         4 mnem = vc
         4 required_ind = i2
         4 updt_cnt = i4
         4 active_ind = i2
         4 candidate_id = f8
         4 sch_flex_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE appt_size = i4
 DECLARE loc_size = i4
 DECLARE dura_size = i4
 DECLARE role_size = i4
 DECLARE appt_code = f8
 SET var = 0
 FOR (var = 1 TO size(file_content->qual,5))
   SET stat = initrec(request1)
   SET stat = initrec(reply1)
   SET stat = alterlist(request1->qual,1)
   SELECT INTO "nl:"
    *
    FROM code_value cv
    WHERE (cv.display_key=file_content->qual[var].catalog_cd)
     AND cv.code_set=200
     AND cv.active_ind=1
    DETAIL
     request1->qual[1].catalog_cd = cv.code_value
    WITH nocounter
   ;end select
   EXECUTE sch_get_order_by_id:dba  WITH replace("REQUEST",request1), replace("REPLY",reply1)
   FREE RECORD request_new
   RECORD request_new(
     1 call_echo_ind = i2
     1 allow_partial_ind = i2
     1 qual[*]
       2 catalog_cd = f8
       2 sch_flex_id = f8
       2 action = i2
       2 candidate_id = f8
       2 updt_cnt = i4
       2 force_updt_ind = i2
       2 version_ind = i2
       2 version_dt_tm = di8
       2 order_appt_partial_ind = i2
       2 order_appt_qual[*]
         3 appt_type_cd = f8
         3 seq_nbr = i4
         3 display_seq_nbr = i4
         3 proc_spec_cd = f8
         3 proc_spec_meaning = c12
         3 del_appt_cd = f8
         3 del_appt_meaning = c12
         3 event_concurrent_ind = i2
         3 child_appt_type_cd = f8
         3 sch_flex_id = f8
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
       2 order_loc_partial_ind = i2
       2 order_loc_qual[*]
         3 location_cd = f8
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
       2 order_duration_partial_ind = i2
       2 order_duration_qual[*]
         3 location_cd = f8
         3 seq_nbr = i4
         3 sch_flex_id = f8
         3 setup_units = i4
         3 setup_units_cd = f8
         3 setup_units_meaning = c12
         3 duration_units = i4
         3 duration_units_cd = f8
         3 duration_units_meaning = c12
         3 cleanup_units = i4
         3 cleanup_units_cd = f8
         3 cleanup_units_meaning = c12
         3 offset_type_cd = f8
         3 offset_type_meaning = c12
         3 offset_beg_units = i4
         3 offset_beg_units_cd = f8
         3 offset_beg_units_meaning = c12
         3 offset_end_units = i4
         3 offset_end_units_cd = f8
         3 offset_end_units_meaning = c12
         3 arrival_units = i4
         3 arrival_units_cd = f8
         3 arrival_units_meaning = c12
         3 recovery_units = i4
         3 recovery_units_cd = f8
         3 recovery_units_meaning = c12
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
       2 order_role_partial_ind = i2
       2 order_role_qual[*]
         3 location_cd = f8
         3 seq_nbr = i4
         3 list_role_id = f8
         3 sch_flex_id = f8
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
       2 order_inter_partial_ind = i2
       2 order_inter_qual[*]
         3 inter_type_cd = f8
         3 seq_group_id = f8
         3 inter_type_meaning = c12
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
         3 location_cd = f8
       2 text_link_partial_ind = i2
       2 text_link_qual[*]
         3 parent2_id = f8
         3 parent3_id = f8
         3 text_type_cd = f8
         3 sub_text_cd = f8
         3 text_type_meaning = c12
         3 sub_text_meaning = c12
         3 text_accept_cd = f8
         3 text_accept_meaning = c12
         3 template_accept_cd = f8
         3 template_accept_meaning = c12
         3 lapse_units = i4
         3 lapse_units_cd = f8
         3 lapse_units_meaning = c12
         3 expertise_level = i4
         3 parent_meaning = c12
         3 parent2_meaning = c12
         3 parent3_meaning = c12
         3 candidate_id = f8
         3 active_ind = i2
         3 active_status_cd = f8
         3 updt_cnt = i4
         3 text_link_id = f8
         3 modified_dt_tm = di8
         3 action = i2
         3 force_updt_ind = i2
         3 version_ind = i2
         3 sub_list_partial_ind = i2
         3 sub_list_qual[*]
           4 required_ind = i2
           4 seq_nbr = i4
           4 template_id = f8
           4 candidate_id = f8
           4 active_ind = i2
           4 active_status_cd = f8
           4 updt_cnt = i4
           4 sch_flex_id = f8
           4 action = i2
           4 force_updt_ind = i2
           4 version_ind = i2
   )
   SET request_new->call_echo_ind = 0
   SET request_new->allow_partial_ind = 0
   IF ((reply1->qual_cnt > 0))
    SET stat = alterlist(request_new->qual,var)
    SET request_new->qual[var].catalog_cd = reply1->qual[1].catalog_cd
    SET request_new->qual[var].action = 1
    IF ((reply1->qual[1].appt_cnt > 0))
     SET j = 0
     FOR (j = 1 TO reply1->qual[1].appt_cnt)
       SET stat = alterlist(request_new->qual[var].order_appt_qual,j)
       SET request_new->qual[var].order_appt_qual[j].appt_type_cd = reply1->qual[1].appt[j].
       appt_type_cd
       SET request_new->qual[var].order_appt_qual[j].seq_nbr = reply1->qual[1].appt[j].seq_nbr
       SET request_new->qual[var].order_appt_qual[j].display_seq_nbr = reply1->qual[1].appt[j].
       display_seq_nbr
       SET request_new->qual[var].order_appt_qual[j].proc_spec_cd = reply1->qual[1].appt[j].
       proc_spec_cd
       SET request_new->qual[var].order_appt_qual[j].proc_spec_meaning = reply1->qual[1].appt[j].
       proc_spec_mean
       SET request_new->qual[var].order_appt_qual[j].del_appt_cd = reply1->qual[1].appt[j].
       del_appt_cd
       SET request_new->qual[var].order_appt_qual[j].del_appt_meaning = reply1->qual[1].appt[j].
       del_appt_mean
       SET request_new->qual[var].order_appt_qual[j].sch_flex_id = reply1->qual[1].appt[j].
       sch_flex_id
       SET request_new->qual[var].order_appt_qual[j].candidate_id = reply1->qual[1].appt[j].
       candidate_id
       SET request_new->qual[var].order_appt_qual[j].active_ind = reply1->qual[1].appt[j].active_ind
       SET request_new->qual[var].order_appt_qual[j].updt_cnt = reply1->qual[1].appt[j].updt_cnt
     ENDFOR
    ENDIF
    IF ((reply1->qual[1].dur_cnt > 0))
     SET j = 0
     FOR (j = 1 TO reply1->qual[1].dur_cnt)
       SET stat = alterlist(request_new->qual[var].order_duration_qual,j)
       SET request_new->qual[var].order_duration_qual[j].location_cd = reply1->qual[1].dur[j].
       location_cd
       SET request_new->qual[var].order_duration_qual[j].seq_nbr = reply1->qual[1].dur[j].seq_nbr
       SET request_new->qual[var].order_duration_qual[j].sch_flex_id = reply1->qual[1].dur[j].
       sch_flex_id
       SET request_new->qual[var].order_duration_qual[j].setup_units = reply1->qual[1].dur[j].
       setup_units
       SET request_new->qual[var].order_duration_qual[j].setup_units_cd = reply1->qual[1].dur[j].
       setup_units_cd
       SET request_new->qual[var].order_duration_qual[j].setup_units_meaning = reply1->qual[1].dur[j]
       .setup_units_meaning
       SET request_new->qual[var].order_duration_qual[j].duration_units = reply1->qual[1].dur[j].
       duration_units
       SET request_new->qual[var].order_duration_qual[j].duration_units_cd = reply1->qual[1].dur[j].
       duration_units_cd
       SET request_new->qual[var].order_duration_qual[j].duration_units_meaning = reply1->qual[1].
       dur[j].duration_units_meaning
       SET request_new->qual[var].order_duration_qual[j].cleanup_units = reply1->qual[1].dur[j].
       cleanup_units
       SET request_new->qual[var].order_duration_qual[j].cleanup_units_cd = reply1->qual[1].dur[j].
       cleanup_units_cd
       SET request_new->qual[var].order_duration_qual[j].cleanup_units_meaning = reply1->qual[1].dur[
       j].cleanup_units_meaning
       SET request_new->qual[var].order_duration_qual[j].offset_type_cd = reply1->qual[1].dur[j].
       offset_type_cd
       SET request_new->qual[var].order_duration_qual[j].offset_type_meaning = reply1->qual[1].dur[j]
       .offset_type_meaning
       SET request_new->qual[var].order_duration_qual[j].offset_beg_units = reply1->qual[1].dur[j].
       offset_beg_units
       SET request_new->qual[var].order_duration_qual[j].offset_beg_units_cd = reply1->qual[1].dur[j]
       .offset_beg_units_cd
       SET request_new->qual[var].order_duration_qual[j].offset_beg_units_meaning = reply1->qual[1].
       dur[j].offset_beg_units_meaning
       SET request_new->qual[var].order_duration_qual[j].offset_end_units = reply1->qual[1].dur[j].
       offset_end_units
       SET request_new->qual[var].order_duration_qual[j].offset_end_units_cd = reply1->qual[1].dur[j]
       .offset_end_units_cd
       SET request_new->qual[var].order_duration_qual[j].offset_end_units_meaning = reply1->qual[1].
       dur[j].offset_end_units_meaning
       SET request_new->qual[var].order_duration_qual[j].arrival_units = reply1->qual[1].dur[j].
       arrival_units
       SET request_new->qual[var].order_duration_qual[j].arrival_units_cd = reply1->qual[1].dur[j].
       arrival_units_cd
       SET request_new->qual[var].order_duration_qual[j].arrival_units_meaning = reply1->qual[1].dur[
       j].arrival_units_meaning
       SET request_new->qual[var].order_duration_qual[j].recovery_units = reply1->qual[1].dur[j].
       recovery_units
       SET request_new->qual[var].order_duration_qual[j].recovery_units_cd = reply1->qual[1].dur[j].
       recovery_units_cd
       SET request_new->qual[var].order_duration_qual[j].recovery_units_meaning = reply1->qual[1].
       dur[j].recovery_units_meaning
       SET request_new->qual[var].order_duration_qual[j].candidate_id = reply1->qual[1].dur[j].
       candidate_id
       SET request_new->qual[var].order_duration_qual[j].active_ind = reply1->qual[1].dur[j].
       active_ind
       SET request_new->qual[var].order_duration_qual[j].updt_cnt = reply1->qual[1].dur[j].updt_cnt
     ENDFOR
    ENDIF
    IF (reply1->qual[1].loc_cnt)
     SET j = 0
     FOR (j = 1 TO reply1->qual[1].loc_cnt)
       SET stat = alterlist(request_new->qual[var].order_loc_qual,j)
       SET request_new->qual[var].order_loc_qual[j].location_cd = reply1->qual[1].loc[j].location_cd
       SET request_new->qual[var].order_loc_qual[j].candidate_id = reply1->qual[1].loc[j].
       candidate_id
       SET request_new->qual[var].order_loc_qual[j].active_ind = reply1->qual[1].loc[j].active_ind
       SET request_new->qual[var].order_loc_qual[j].updt_cnt = reply1->qual[1].loc[j].updt_cnt
     ENDFOR
    ENDIF
    IF (reply1->qual[1].role_cnt)
     SET j = 0
     FOR (j = 1 TO reply1->qual[1].role_cnt)
       SET stat = alterlist(request_new->qual[var].order_role_qual,j)
       SET request_new->qual[var].order_role_qual[j].location_cd = reply1->qual[1].role[j].
       location_cd
       SET request_new->qual[var].order_role_qual[j].seq_nbr = reply1->qual[1].role[j].seq_nbr
       SET request_new->qual[var].order_role_qual[j].list_role_id = reply1->qual[1].role[j].
       list_role_id
       SET request_new->qual[var].order_role_qual[j].sch_flex_id = reply1->qual[1].role[j].
       sch_flex_id
       SET request_new->qual[var].order_role_qual[j].candidate_id = reply1->qual[1].role[j].
       candidate_id
       SET request_new->qual[var].order_role_qual[j].active_ind = reply1->qual[1].role[j].active_ind
       SET request_new->qual[var].order_role_qual[j].updt_cnt = reply1->qual[1].role[j].updt_cnt
     ENDFOR
    ENDIF
    IF (reply1->qual[1].text_cnt)
     SET j = 0
     FOR (j = 1 TO reply1->qual[1].text_cnt)
       SET stat = alterlist(request_new->qual[var].text_link_qual,j)
       SET request_new->qual[var].text_link_qual[j].text_type_cd = reply1->qual[1].text[j].
       text_type_cd
       SET request_new->qual[var].text_link_qual[j].sub_text_cd = reply1->qual[1].text[j].sub_text_cd
       SET request_new->qual[var].text_link_qual[j].text_type_meaning = reply1->qual[1].text[j].
       text_type_meaning
       SET request_new->qual[var].text_link_qual[j].sub_text_meaning = reply1->qual[1].text[j].
       sub_text_meaning
       SET request_new->qual[var].text_link_qual[j].text_accept_cd = reply1->qual[1].text[j].
       template_accept_cd
       SET request_new->qual[var].text_link_qual[j].text_accept_meaning = reply1->qual[1].text[j].
       text_accept_meaning
       SET request_new->qual[var].text_link_qual[j].template_accept_cd = reply1->qual[1].text[j].
       template_accept_cd
       SET request_new->qual[var].text_link_qual[j].template_accept_meaning = reply1->qual[1].text[j]
       .template_accept_meaning
       SET request_new->qual[var].text_link_qual[j].lapse_units = reply1->qual[1].text[j].lapse_units
       SET request_new->qual[var].text_link_qual[j].lapse_units_cd = reply1->qual[1].text[j].
       lapse_units_cd
       SET request_new->qual[var].text_link_qual[j].lapse_units_meaning = reply1->qual[1].text[j].
       lapse_units_meaning
       SET request_new->qual[var].text_link_qual[j].expertise_level = reply1->qual[1].text[j].
       expertise_level
       SET request_new->qual[var].text_link_qual[j].candidate_id = reply1->qual[1].text[j].
       candidate_id
       SET request_new->qual[var].text_link_qual[j].active_ind = reply1->qual[1].text[j].active_ind
       SET request_new->qual[var].text_link_qual[j].updt_cnt = reply1->qual[1].text[j].updt_cnt
       SET request_new->qual[var].text_link_qual[j].text_link_id = reply1->qual[1].text[j].
       text_link_id
       IF ((reply1->qual[1].text[j].sub_list_cnt > 0))
        SET k = 0
        FOR (k = 1 TO reply1->qual[1].text[j].sub_list_cnt)
          SET stat = alterlist(request_new->qual[var].text_link_qual[j].sub_list_qual,k)
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].required_ind = reply1->qual[1
          ].text[j].sub_list[k].required_ind
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].seq_nbr = reply1->qual[1].
          text[j].sub_list[k].seq_nbr
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].template_id = reply1->qual[1]
          .text[j].sub_list[k].template_id
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].candidate_id = reply1->qual[1
          ].text[j].sub_list[k].ccandidate_id
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].active_ind = reply1->qual[1].
          text[j].sub_list[k].active_ind
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].updt_cnt = reply1->qual[1].
          text[j].sub_list[k].updt_cnt
          SET request_new->qual[var].text_link_qual[j].sub_list_qual[k].sch_flex_id = reply1->qual[1]
          .text[j].sub_list[k].sch_flex_id
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   SET request_new->qual[var].order_appt_partial_ind = 0
   SET k = reply1->qual[1].appt_cnt
   SET appt_size = size(file_content->qual[var].appt,5)
   SET file_appt_cnt = 0
   FOR (j = (k+ 1) TO (k+ appt_size))
     SET file_appt_cnt = (file_appt_cnt+ 1)
     SET stat = alterlist(request_new->qual[var].order_appt_qual,j)
     SET request_new->qual[var].order_appt_qual[j].seq_nbr = j
     SET request_new->qual[var].order_appt_qual[j].display_seq_nbr = j
     SET request_new->qual[var].order_appt_qual[j].del_appt_cd = notdelete_var
     SET request_new->qual[var].order_appt_qual[j].del_appt_meaning = "NOTDELETE"
     SET request_new->qual[var].order_appt_qual[j].candidate_id = - (1)
     SET request_new->qual[var].order_appt_qual[j].active_ind = 1
     SET request_new->qual[var].order_appt_qual[j].action = 1
     SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.display_key=cnvtupper(file_content->qual[var].appt[file_appt_cnt].appt_type)
       AND cv.code_set=14230
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_appt_qual[j].appt_type_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_appt_qual[j].proc_spec_meaning = file_content->qual[var].appt[
     file_appt_cnt].proc_mean
     SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.display_key=cnvtupper(file_content->qual[var].appt[file_appt_cnt].proc_mean)
       AND cv.code_set=23000
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_appt_qual[j].proc_spec_cd = cv.code_value
      WITH nocounter
     ;end select
     SELECT
      s.sch_flex_id
      FROM sch_flex_string s
      WHERE s.mnemonic_key=cnvtupper(file_content->qual[var].appt[file_appt_cnt].flex_id)
       AND s.active_ind=1
      HEAD s.sch_flex_id
       request_new->qual[var].order_appt_qual[j].sch_flex_id = s.sch_flex_id
      WITH nocounter
     ;end select
   ENDFOR
   SET request_new->qual[var].order_loc_partial_ind = 0
   SET k = reply1->qual[1].loc_cnt
   SET loc_size = size(file_content->qual[var].location,5)
   SET file_loc_cnt = 0
   FOR (j = (k+ 1) TO (k+ loc_size))
     SET file_loc_cnt = (file_loc_cnt+ 1)
     SET stat = alterlist(request_new->qual[var].order_loc_qual,j)
     SELECT
      cv.code_value
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[var].location[file_loc_cnt].location_cd)
       AND cv.code_set=220
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_loc_qual[j].location_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_loc_qual[j].active_ind = 1
     SET request_new->qual[var].order_loc_qual[j].action = 1
     SET request_new->qual[var].order_loc_qual[j].candidate_id = - (1)
   ENDFOR
   SET request_new->qual[var].order_duration_partial_ind = 0
   SET k = reply1->qual[1].dur_cnt
   SET dura_size = size(file_content->qual[var].duration,5)
   SET file_dur_cnt = 0
   FOR (j = (k+ 1) TO (k+ dura_size))
     SET file_dur_cnt = (file_dur_cnt+ 1)
     SET stat = alterlist(request_new->qual[var].order_duration_qual,j)
     SET request_new->qual[var].order_duration_qual[j].location_cd = 0
     SET request_new->qual[var].order_duration_qual[j].seq_nbr = j
     SET request_new->qual[var].order_duration_qual[j].candidate_id = - (1)
     SELECT
      flex = s.sch_flex_id
      FROM sch_flex_string s
      WHERE s.mnemonic_key=cnvtupper(file_content->qual[var].duration[file_dur_cnt].duration_cd)
      HEAD s.sch_flex_id
       request_new->qual[var].order_duration_qual[j].sch_flex_id = s.sch_flex_id
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].setup_units = file_content->qual[var].
     duration[file_dur_cnt].set_up
     SELECT
      FROM code_value cv
      WHERE cv.cdf_meaning=cnvtupper(file_content->qual[var].duration[file_dur_cnt].set_up_mean)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_duration_qual[j].setup_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].setup_units_meaning = cnvtupper(file_content->
      qual[var].duration[file_dur_cnt].set_up_mean)
     SET request_new->qual[var].order_duration_qual[j].duration_units = file_content->qual[var].
     duration[file_dur_cnt].duration
     SELECT
      FROM code_value cv
      WHERE cv.cdf_meaning=cnvtupper(file_content->qual[var].duration[file_dur_cnt].duration_mean)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_duration_qual[j].duration_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].duration_units_meaning = file_content->qual[
     var].duration[file_dur_cnt].duration_mean
     SET request_new->qual[var].order_duration_qual[j].cleanup_units = file_content->qual[var].
     duration[file_dur_cnt].clean_up
     SELECT
      FROM code_value cv
      WHERE cv.cdf_meaning=cnvtupper(file_content->qual[var].duration[file_dur_cnt].cleanup_mean)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_duration_qual[j].cleanup_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].cleanup_units_meaning = file_content->qual[var
     ].duration[file_dur_cnt].cleanup_mean
     SET request_new->qual[var].order_duration_qual[j].offset_type_cd = 0.00
     SET request_new->qual[var].order_duration_qual[j].offset_type_meaning = ""
     SET request_new->qual[var].order_duration_qual[j].offset_beg_units = 0
     SET request_new->qual[var].order_duration_qual[j].offset_beg_units_cd = 0.00
     SET request_new->qual[var].order_duration_qual[j].offset_beg_units_meaning = ""
     SET request_new->qual[var].order_duration_qual[j].offset_end_units = 0
     SET request_new->qual[var].order_duration_qual[j].offset_end_units_cd = 0.00
     SET request_new->qual[var].order_duration_qual[j].offset_end_units_meaning = ""
     SET request_new->qual[var].order_duration_qual[j].arrival_units = file_content->qual[var].
     duration[file_dur_cnt].arrival
     SELECT
      FROM code_value cv
      WHERE cv.cdf_meaning=cnvtupper(file_content->qual[var].duration[file_dur_cnt].arrival_mean)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_duration_qual[j].arrival_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].arrival_units_meaning = file_content->qual[var
     ].duration[file_dur_cnt].arrival_mean
     SET request_new->qual[var].order_duration_qual[j].recovery_units = file_content->qual[var].
     duration[file_dur_cnt].recovery
     SELECT
      FROM code_value cv
      WHERE cv.cdf_meaning=cnvtupper(file_content->qual[var].duration[file_dur_cnt].recovery_mean)
       AND cv.code_set=54
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_duration_qual[j].recovery_units_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_duration_qual[j].recovery_units_meaning = file_content->qual[
     var].duration[file_dur_cnt].recovery_mean
     SET request_new->qual[var].order_duration_qual[j].active_ind = 1
     SET request_new->qual[var].order_duration_qual[j].action = 1
   ENDFOR
   SET request_new->qual[var].order_role_partial_ind = 0
   SET file_role_cnt = 0
   SET k = reply1->qual[1].role_cnt
   SET role_size = size(file_content->qual[var].roles,5)
   FOR (j = (k+ 1) TO (k+ role_size))
     SET file_role_cnt = (file_role_cnt+ 1)
     SET stat = alterlist(request_new->qual[var].order_role_qual,j)
     SELECT
      cv.code_value
      FROM code_value cv
      WHERE (cv.display_key=file_content->qual[var].roles[file_role_cnt].loc_cd)
       AND cv.code_set=220
       AND cv.active_ind=1
      HEAD cv.code_value
       request_new->qual[var].order_role_qual[j].location_cd = cv.code_value
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_role_qual[j].seq_nbr = j
     SELECT
      s.list_role_id
      FROM sch_list_role s
      WHERE (s.mnemonic_key=file_content->qual[var].roles[file_role_cnt].loc_role)
      HEAD s.list_role_id
       request_new->qual[var].order_role_qual[j].list_role_id = s.list_role_id
      WITH nocounter
     ;end select
     CALL echo(file_content->qual[var].roles[file_role_cnt].loc_role)
     CALL echo(request_new->qual[var].order_role_qual[j].list_role_id)
     SELECT
      s.sch_flex_id
      FROM sch_flex_string s
      WHERE s.mnemonic_key=cnvtupper(file_content->qual[var].roles[file_role_cnt].flex_id)
      HEAD s.sch_flex_id
       request_new->qual[var].order_role_qual[j].sch_flex_id = s.sch_flex_id
      WITH nocounter
     ;end select
     SET request_new->qual[var].order_role_qual[j].active_ind = 1
     SET request_new->qual[var].order_role_qual[j].action = 1
     SET request_new->qual[var].order_role_qual[j].candidate_id = - (1)
   ENDFOR
   SET request_new->qual[var].order_inter_partial_ind = 0
   SET stat = alterlist(request_new->qual[var].order_inter_qual,0)
   SET request_new->qual[var].text_link_partial_ind = 0
   SET stat = alterlist(request_new->qual[var].text_link_qual,0)
   CALL echorecord(request_new)
   EXECUTE sch_chgw_order:dba  WITH replace("REQUEST",request_new)
 ENDFOR
 SELECT INTO  $OUTDEV
  status =
  "Succesfully Associated Orders and Appointments,Locations,Durations, Flex Strings and Order Roles"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
