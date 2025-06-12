CREATE PROGRAM dcp_create_io_2g_dtas:dba
 IF ( NOT (validate(temp,0)))
  RECORD temp(
    1 cnt = i4
    1 dtas[*]
      2 task_assay_cd = f8
      2 mnemonic = c50
      2 description = c100
      2 event_cd = f8
      2 io_flag = i2
  )
 ENDIF
 IF ( NOT (validate(dtawiz_req,0)))
  RECORD dtawiz_req(
    1 mnemonic = c50
    1 description = c100
    1 activity_type_cd = f8
    1 event_cd = f8
    1 default_result_type_cd = f8
    1 build_event_cd_ind = i2
    1 code_set = i4
    1 max_digits = i4
    1 min_digits = i4
    1 min_decimal_places = i4
    1 ref_range_cnt = i4
    1 ref_range[*]
      2 ref_id = f8
      2 service_resource_cd = f8
      2 species_cd = f8
      2 organism_cd = f8
      2 sex_cd = f8
      2 unknown_age_ind = i2
      2 age_from_units_cd = f8
      2 age_from_minutes = i4
      2 age_to_units_cd = f8
      2 age_to_minutes = i4
      2 specimen_type_cd = f8
      2 patient_condition_cd = f8
      2 def_result_ind = i2
      2 default_result = f8
      2 dilute_ind = i2
      2 review_ind = i2
      2 review_low = f8
      2 review_high = f8
      2 feasible_ind = i2
      2 feasible_low = f8
      2 feasible_high = f8
      2 linear_ind = i2
      2 linear_low = f8
      2 linear_high = f8
      2 normal_ind = i2
      2 normal_low = f8
      2 normal_high = f8
      2 critical_ind = i2
      2 critical_low = f8
      2 critical_high = f8
      2 delta_check_type_cd = f8
      2 delta_minutes = f8
      2 delta_value = f8
      2 delta_chk_flag = i2
      2 delta_lvl_flag = i2
      2 mins_back = f8
      2 resource_ref_flag = i2
      2 gestational_ind = i2
      2 precedence_sequence = i4
      2 units_cd = f8
      2 alpha_cnt = i4
      2 alpha[*]
        3 nomenclature_id = f8
        3 sequence = i4
        3 use_units_ind = i2
        3 default_ind = i2
        3 description = vc
        3 active_ind = i2
        3 reference_ind = i2
        3 multi_alpha_sort_order = i4
        3 result_value = f8
        3 category_id = f8
        3 placeholder_category_id = f8
        3 concept_cki = c255
        3 truth_state_cd = f8
      2 categories[*]
        3 mod = i2
        3 category_id = f8
        3 placeholder_category_id = f8
        3 category_name = c100
        3 category_sequence = i4
        3 expand_flag = i2
      2 rule_ind = i2
      2 rule_cnt = i4
      2 rule[*]
        3 rule_id = f8
        3 gestational_age_ind = i2
        3 gestation_from_age_in_days = i4
        3 gestation_to_age_in_days = i4
        3 from_weight = i4
        3 from_weight_unit_cd = f8
        3 to_weight = i4
        3 to_weight_unit_cd = f8
        3 from_height = i4
        3 from_height_unit_cd = f8
        3 to_height = i4
        3 to_height_unit_cd = f8
        3 location_cd = f8
        3 normal_ind = i2
        3 normal_low = f8
        3 normal_high = f8
        3 critical_ind = i2
        3 critical_low = f8
        3 critical_high = f8
        3 feasible_ind = i2
        3 feasible_low = f8
        3 feasible_high = f8
        3 def_result_ind = i2
        3 default_result = f8
        3 units_cd = f8
        3 alpha_rule_cnt = i4
        3 alpha_rule[*]
          4 nomenclature_id = f8
    1 modifier_ind = i2
    1 single_select_ind = i2
    1 default_type_flag = i2
    1 io_flag = i2
    1 template_script_cd = f8
    1 concept_cki = c255
    1 offset_min_cnt = i4
    1 offset_mins[*]
      2 offset_min_type_cd = f8
      2 offset_min_nbr = i4
    1 witness_required_ind = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dup_ind = i2
    1 codeset_ind = i2
    1 table_ind = i2
    1 ref_range_ind = i2
    1 rule_ind = i2
    1 alpha_rule_ind = i2
    1 alpha_ind = i2
    1 data_map_ind = i2
    1 task_assay_cd = f8
    1 event_cd = f8
    1 offset_min_ind = i2
    1 cve_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(err_struct,0)))
  FREE RECORD err_struct
  RECORD err_struct(
    1 ms_maxqual_string = vc
    1 ms_err_msg = vc
  )
 ENDIF
 IF ( NOT (validate(view_ind,0)))
  SET view_ind = 0
 ENDIF
 DECLARE display_defaultscreen(title=vc,x_pos=i2) = null WITH public
 DECLARE fireprocess(null) = i2 WITH public
 DECLARE create_io2gdtas(null) = i2 WITH public
 DECLARE update_io2gdtas(null) = i2 WITH public
 DECLARE spaces = c78 WITH public, constant(fillstring(78," "))
 CALL display_defaultscreen(" ",0)
 CALL text(07,05,"RETRIEVING CODE VALUES...")
 DECLARE human = f8 WITH public, constant(uar_get_code_by("MEANING",226,"HUMAN"))
 DECLARE numeric = f8 WITH public, constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE years = f8 WITH public, constant(uar_get_code_by("MEANING",340,"YEARS"))
 DECLARE ml = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3780"))
 IF (validate_codevalues(null)=false)
  CALL text(24,02,spaces)
  GO TO exit_program
 ELSE
  CALL text(07,30,"DONE")
 ENDIF
 DECLARE upd_ind = i2 WITH protect, noconstant(false)
 DECLARE create_ind = i2 WITH protect, noconstant(false)
 DECLARE process_ind = i2 WITH protect, noconstant(false)
 DECLARE work_ind = i2 WITH protect, noconstant(false)
 DECLARE activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_disp = vc WITH protect, noconstant(" ")
 SET message = window
 SET width = 80
 WHILE (true)
   SET process_ind = false
   SET activity_type_cd = 0.0
   SET activity_type_disp = " "
   CALL display_defaultscreen("MAIN MENU",36)
   CALL text(07,05,"PLEASE CHOOSE ONE OF THE FOLLOWING OPTIONS:")
   CALL text(09,08,"(1)  UPDATE EXISTING I&O DTAS ONLY")
   CALL text(11,08,"(2)  UPDATE/CREATE I&O DTAS")
   CALL text(14,05,"YOUR CHOICE(0 to EXIT)?")
   CALL accept(14,30,"9;",0
    WHERE curaccept IN (0, 1, 2))
   CASE (curaccept)
    OF 0:
     CALL text(24,02,spaces)
     GO TO exit_program
    OF 1:
     SET upd_ind = true
     SET create_ind = false
     SET process_ind = true
     CALL display_defaultscreen("UPDATE MODE",36)
    OF 2:
     SET upd_ind = true
     SET create_ind = true
     CALL clear(14,01,80)
     CALL text(14,05,"WHAT ACTIVITY TYPE SHOULD BE WHEN CREATING THE DTAS?")
     CALL accept(15,05,"N(30);C",0.0)
     SET activity_type_cd = cnvtreal(curaccept)
     IF (activity_type_cd > 0.0)
      SELECT INTO "nl:"
       cv.display
       FROM code_value cv
       WHERE cv.code_value=activity_type_cd
        AND cv.code_set=106
       DETAIL
        activity_type_disp = trim(cv.display,3)
       WITH nocounter
      ;end select
      CALL clear(14,01,80)
      CALL clear(15,01,80)
      IF (curqual=1)
       CALL text(15,05,"YOU HAVE SELECTED TO CREATE DTAS UNDER THE FOLLOWING ACTIVITY TYPE:")
       CALL video(u)
       CALL text(16,05,activity_type_disp)
       CALL video(n)
       CALL text(18,05,"IS THIS THE CORRECT? (Y OR N)")
       CALL accept(18,35,"A;CU","N"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        SET process_ind = true
        CALL display_defaultscreen("UPDATE/CREATE MODE",36)
       ENDIF
      ELSE
       CALL text(15,05,concat("THE ACTIVITY TYPE (",trim(cnvtstring(activity_type_cd,30,1),3),
         ") ENTERED COULD NOT BE FOUND"))
       CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
       CALL accept(20,41,"D;DC","")
      ENDIF
     ENDIF
   ENDCASE
   IF (process_ind)
    CALL fireprocess(null)
    CALL clear(18,01,80)
    CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
    CALL accept(20,41,"D;DC","")
   ENDIF
 ENDWHILE
 SUBROUTINE display_defaultscreen(title,x_pos)
   CALL clear(01,01)
   CALL video(r)
   CALL box(01,01,05,80)
   CALL text(02,02,spaces)
   CALL text(02,24,"CCL PROGRAM (DCP_CREATE_IO_2G_DTAS)")
   CALL text(03,02,spaces)
   CALL text(04,02,spaces)
   IF (title > " "
    AND x_pos > 0)
    CALL video(u)
    CALL text(04,x_pos,title)
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE fireprocess(null)
   DECLARE fail_ind = i2 WITH protect, noconstant(false)
   IF (fail_ind=false
    AND upd_ind=true)
    IF (update_io2gdtas(null)=false)
     SET fail_ind = true
    ENDIF
   ENDIF
   IF (fail_ind=false
    AND create_ind=true)
    IF (create_io2gdtas(null)=false)
     SET fail_ind = true
    ENDIF
   ENDIF
   IF (fail_ind)
    IF (initrec(temp) != 1)
     CALL clear(12,01,80)
     CALL text(12,05,"ERROR: COULD NOT REINITIALIZE TEMP RECORD")
     SET temp->cnt = 0
    ENDIF
    IF (((initrec(dtawiz_req) != 1) OR (initrec(reply) != 1)) )
     CALL clear(12,01,80)
     CALL text(12,05,"ERROR: COULD NOT REINITIALIZE REQUEST/REPLY FOR DCP_ADD_DTAWIZARD_DTAINFO")
    ENDIF
    CALL text(14,05,"PERFORMING ROLLBACK...")
    ROLLBACK
   ELSE
    IF (work_ind)
     CALL text(14,05,"COMITTING CHANGES...")
     COMMIT
    ENDIF
   ENDIF
   RETURN(fail_ind)
 END ;Subroutine
 SUBROUTINE update_io2gdtas(null)
   DECLARE dta_cnt = i2 WITH protect, noconstant(0)
   CALL clear(07,01,80)
   CALL text(07,05,"SEARCHING FOR DTAS ASSOCIATED WITH I&O EVENT CDS...")
   SELECT INTO "nl:"
    dta.mnemonic, dta.task_assay_cd, vese2.event_cd,
    vesca.event_set_collating_seq
    FROM v500_event_set_code vesc1,
     v500_event_set_canon vesca,
     v500_event_set_explode vese1,
     v500_event_set_explode vese2,
     v500_event_set_code vesc2,
     discrete_task_assay dta,
     reference_range_factor rrf
    PLAN (vesc1
     WHERE vesc1.event_set_name="IO")
     JOIN (vesca
     WHERE (vesca.parent_event_set_cd=(vesc1.event_set_cd+ 0)))
     JOIN (vese1
     WHERE (vese1.event_set_cd=(vesca.event_set_cd+ 0)))
     JOIN (vese2
     WHERE (vese2.event_cd=(vese1.event_cd+ 0))
      AND vese2.event_set_level=0)
     JOIN (vesc2
     WHERE (vesc2.event_set_cd=(vese2.event_set_cd+ 0))
      AND vesc2.accumulation_ind=1)
     JOIN (dta
     WHERE (dta.event_cd=(vese2.event_cd+ 0))
      AND dta.active_ind=1
      AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (rrf
     WHERE (rrf.task_assay_cd=(dta.task_assay_cd+ 0))
      AND rrf.active_ind=1
      AND rrf.units_cd=ml
      AND rrf.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY vese2.event_cd, dta.task_assay_cd
    HEAD vese2.event_cd
     dta_cnt = 0, ml_ind = false
    HEAD dta.task_assay_cd
     dta_cnt = (dta_cnt+ 1)
    FOOT  vese2.event_cd
     IF (dta_cnt=1)
      temp->cnt = (temp->cnt+ 1)
      IF (mod(temp->cnt,50)=1)
       stat = alterlist(temp->dtas,(temp->cnt+ 49))
      ENDIF
      temp->dtas[temp->cnt].mnemonic = dta.mnemonic, temp->dtas[temp->cnt].task_assay_cd = dta
      .task_assay_cd, temp->dtas[temp->cnt].event_cd = vese2.event_cd,
      temp->dtas[temp->cnt].io_flag = vesca.event_set_collating_seq
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->dtas,temp->cnt)
    WITH nocounter
   ;end select
   CALL text(07,56,"DONE")
   CALL clear(07,01,80)
   IF ((temp->cnt=0))
    CALL clear(07,01,80)
    CALL text(07,05,"NO DTAS NEEDED TO BE UPDATED")
    RETURN(true)
   ENDIF
   FOR (dta_cnt = 1 TO temp->cnt)
     IF (view_ind)
      CALL clear(07,01,80)
      CALL text(07,05,build("NOW UPDATING DTA...",trim(cnvtupper(temp->dtas[dta_cnt].mnemonic),3)))
      CALL pause(1)
     ENDIF
     SELECT INTO "nl:"
      FROM discrete_task_assay dta
      WHERE (dta.task_assay_cd=temp->dtas[dta_cnt].task_assay_cd)
       AND dta.active_ind=1
       AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      WITH nocounter, forupdate(dta)
     ;end select
     IF (error(err_struct->ms_err_msg,0) != 0)
      CALL text(12,05,concat("ERROR: COULD NOT ACQUIRE LOCKS FOR DTA UPDATE: ",err_struct->ms_err_msg
        ))
      RETURN(false)
     ENDIF
     UPDATE  FROM discrete_task_assay dta
      SET dta.io_flag = temp->dtas[dta_cnt].io_flag, dta.updt_dt_tm = cnvtdatetime("31-DEC-2100"),
       dta.updt_id = - (1)
      WHERE (dta.task_assay_cd=temp->dtas[dta_cnt].task_assay_cd)
       AND dta.active_ind=1
       AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end update
     IF (error(err_struct->ms_err_msg,0) != 0)
      CALL text(12,05,build("ERROR: COULD NOT UPDATE NECESSARY FIELDS FOR TASK_ASSAY_CD=",trim(
         cnvtstring(temp->dtas[dta_cnt].task_assay_cd,30,1),3)))
      RETURN(false)
     ENDIF
   ENDFOR
   SET dta_cnt = temp->cnt
   IF (initrec(temp) != 1)
    CALL text(12,05,"ERROR: COULD NOT INITIALIZE TEMP RECORD FOR REUSE")
    RETURN(false)
   ENDIF
   CALL clear(07,01,80)
   CALL text(07,05,concat(trim(cnvtstring(dta_cnt),3)," DTA(S) SUCCESSFULLY UPDATED"))
   SET work_ind = true
   CALL pause(1)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE create_io2gdtas(null)
   DECLARE dta_cnt = i2 WITH protect, noconstant(0)
   CALL clear(07,01,80)
   CALL text(07,05,"SEARCHING FOR I&O EVENT CDS THAT NEED DTAS...")
   SELECT INTO "nl:"
    dta.mnemonic, dta.task_assay_cd, vec.event_cd,
    vesca.event_set_collating_seq
    FROM v500_event_set_code vesc1,
     v500_event_set_canon vesca,
     v500_event_set_explode vese1,
     v500_event_set_explode vese2,
     v500_event_set_code vesc2,
     v500_event_code vec
    PLAN (vesc1
     WHERE vesc1.event_set_name="IO")
     JOIN (vesca
     WHERE (vesca.parent_event_set_cd=(vesc1.event_set_cd+ 0)))
     JOIN (vese1
     WHERE (vese1.event_set_cd=(vesca.event_set_cd+ 0)))
     JOIN (vese2
     WHERE (vese2.event_cd=(vese1.event_cd+ 0))
      AND vese2.event_set_level=0)
     JOIN (vesc2
     WHERE (vesc2.event_set_cd=(vese2.event_set_cd+ 0))
      AND vesc2.accumulation_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM discrete_task_assay dta
      WHERE dta.event_cd=vese2.event_cd
       AND dta.active_ind=1
       AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")))))
     JOIN (vec
     WHERE (vec.event_cd=(vese2.event_cd+ 0))
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM discrete_task_assay dta1
      WHERE dta1.mnemonic=trim(concat("IO2 - ",vec.event_cd_disp),3)))))
    ORDER BY vec.event_cd
    HEAD vec.event_cd
     temp->cnt = (temp->cnt+ 1)
     IF (mod(temp->cnt,50)=1)
      stat = alterlist(temp->dtas,(temp->cnt+ 49))
     ENDIF
     temp->dtas[temp->cnt].mnemonic = trim(concat("IO2 - ",vec.event_cd_disp),3), temp->dtas[temp->
     cnt].description = trim(concat("IO2 - ",vec.event_cd_disp),3), temp->dtas[temp->cnt].event_cd =
     vec.event_cd,
     temp->dtas[temp->cnt].io_flag = vesca.event_set_collating_seq
    FOOT REPORT
     stat = alterlist(temp->dtas,temp->cnt)
    WITH nocounter
   ;end select
   CALL text(07,50,"DONE")
   IF ((temp->cnt=0))
    CALL clear(07,01,80)
    CALL text(07,05,"NO DTAS NEEDED TO BE CREATED")
    RETURN(true)
   ENDIF
   FOR (dta_cnt = 1 TO temp->cnt)
     SET dtawiz_req->mnemonic = temp->dtas[dta_cnt].mnemonic
     SET dtawiz_req->description = temp->dtas[dta_cnt].description
     SET dtawiz_req->activity_type_cd = activity_type_cd
     SET dtawiz_req->event_cd = temp->dtas[dta_cnt].event_cd
     SET dtawiz_req->default_result_type_cd = numeric
     SET dtawiz_req->io_flag = temp->dtas[dta_cnt].io_flag
     SET dtawiz_req->ref_range_cnt = 1
     SET stat = alterlist(dtawiz_req->ref_range,1)
     SET dtawiz_req->ref_range[1].species_cd = human
     SET dtawiz_req->ref_range[1].sex_cd = 0.0
     SET dtawiz_req->ref_range[1].age_from_units_cd = years
     SET dtawiz_req->ref_range[1].age_from_minutes = 0
     SET dtawiz_req->ref_range[1].age_to_units_cd = years
     SET dtawiz_req->ref_range[1].age_to_minutes = 78840000
     SET dtawiz_req->ref_range[1].units_cd = ml
     IF (view_ind)
      CALL clear(07,01,80)
      CALL text(07,05,build("NOW CREATING DTA...",trim(cnvtupper(temp->dtas[cnt].mnemonic),3)))
      CALL pause(1)
     ENDIF
     EXECUTE dcp_add_dtawizard_dtainfo  WITH replace("REQUEST","DTAWIZ_REQ")
     IF ((reply->status_data.status="F"))
      CALL text(12,05,build("ERROR: COULD NOT CREATE DTA FOR EVENT_CD=",trim(cnvtstring(dtawiz_req->
          event_cd,30,1),3)))
      RETURN(false)
     ENDIF
     SELECT INTO "nl:"
      FROM discrete_task_assay dta
      WHERE (dta.task_assay_cd=reply->task_assay_cd)
       AND dta.active_ind=1
       AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      WITH nocounter, forupdate(dta)
     ;end select
     IF (error(err_struct->ms_err_msg,0) != 0)
      CALL text(12,05,"ERROR: COULD NOT ACQUIRE LOCKS FOR DTA UPDATE")
      RETURN(false)
     ENDIF
     UPDATE  FROM discrete_task_assay dta
      SET dta.updt_dt_tm = cnvtdatetime("01-JAN-1800"), dta.updt_id = - (2)
      WHERE (dta.task_assay_cd=reply->task_assay_cd)
       AND dta.active_ind=1
       AND dta.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end update
     IF (error(err_struct->ms_err_msg,0) != 0)
      CALL text(12,05,build("ERROR: COULD NOT UPDATE NECESSARY FIELDS FOR TASK_ASSAY_CD=",trim(
         cnvtstring(reply->task_assay_cd,30,1),3)))
      RETURN(false)
     ENDIF
     IF (((initrec(dtawiz_req) != 1) OR (initrec(reply) != 1)) )
      CALL text(12,05,"ERROR: COULD NOT INITIALIZE REQUEST/REPLY FOR DCP_ADD_DTAWIZARD_DTAINFO")
      RETURN(false)
     ENDIF
   ENDFOR
   SET dta_cnt = temp->cnt
   IF (initrec(temp) != 1)
    CALL text(12,05,"ERROR: COULD NOT INITIALIZE TEMP RECORD FOR REUSE")
    RETURN(false)
   ENDIF
   CALL clear(07,01,80)
   CALL text(07,05,concat(trim(cnvtstring(dta_cnt),3)," DTA(S) SUCCESSFULLY CREATED"))
   SET work_ind = true
   CALL pause(1)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE validate_codevalues(null)
   DECLARE status_ind = i2 WITH protect, noconstant(true)
   IF (human < 0.0)
    SET status_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (HUMAN) NOT FOUND IN CODE SET 226")
    CALL pause(1)
   ENDIF
   IF (numeric < 0.0)
    SET status_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (NUMERIC) NOT FOUND IN CODE SET 289")
    CALL pause(1)
   ENDIF
   IF (years < 0.0)
    SET status_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (YEARS) NOT FOUND IN CODE SET 340")
    CALL pause(1)
   ENDIF
   IF (ml < 0.0)
    SET status_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (ML) NOT FOUND IN CODE SET")
    CALL pause(1)
   ENDIF
   RETURN(status_ind)
 END ;Subroutine
#exit_program
 SET message = nowindow
END GO
