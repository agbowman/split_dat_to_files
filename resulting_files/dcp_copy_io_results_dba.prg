CREATE PROGRAM dcp_copy_io_results:dba
 IF ( NOT (validate(temp,0)))
  RECORD temp(
    1 block_cnt = i4
    1 block[*]
      2 encntr_id = f8
      2 person_id = f8
    1 min_id = f8
    1 max_id = f8
  )
 ENDIF
 IF ( NOT (validate(event_cds,0)))
  RECORD event_cds(
    1 ec_cnt = i4
    1 cds[*]
      2 event_cd = f8
      2 type = i2
  )
 ENDIF
 IF ( NOT (validate(res,0)))
  RECORD res(
    1 io_cnt = i4
    1 io[*]
      2 clinical_event_id = f8
      2 parent_event_id = f8
      2 event_id = f8
      2 event_cd = f8
      2 io_volume = f8
      2 event_end_dt_tm = dq8
      2 event_end_tz = i4
      2 valid_from_dt_tm = dq8
      2 valid_until_dt_tm = dq8
      2 child_cnt = i4
      2 child[*]
        3 event_id = f8
        3 valid_from_dt_tm = dq8
        3 valid_until_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(num_io,0)))
  RECORD num_io(
    1 num_cnt = i4
    1 nums[*]
      2 clinical_event_id = f8
      2 event_id = f8
      2 event_cd = f8
      2 event_end_dt_tm = dq8
      2 valid_until_dt_tm = dq8
      2 io_volume = f8
      2 io_type_flag = i2
  )
 ENDIF
 IF ( NOT (validate(med_io,0)))
  RECORD med_io(
    1 med_cnt = i4
    1 meds[*]
      2 reference_event_id = f8
      2 io_volume = f8
      2 io_type_flag = i2
      2 event_end_dt_tm = dq8
      2 event_end_tz = i4
      2 valid_from_dt_tm = dq8
      2 valid_until_dt_tm = dq8
      2 child_cnt = i4
      2 child[*]
        3 event_id = f8
        3 valid_from_dt_tm = dq8
        3 valid_until_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(iv_io,0)))
  RECORD iv_io(
    1 iv_cnt = i4
    1 ivs[*]
      2 clinical_event_id = f8
      2 event_id = f8
      2 event_cd = f8
      2 io_type_flag = i2
      2 io_volume = f8
      2 event_end_dt_tm = dq8
  )
 ENDIF
 DECLARE intake = i2 WITH public, constant(1)
 DECLARE output = i2 WITH public, constant(2)
 DECLARE csize100 = i2 WITH public, constant(100)
 DECLARE spaces = c78 WITH public, constant(fillstring(78," "))
 DECLARE utc_ind = i2 WITH public, noconstant(curutc)
 DECLARE debug_ind = i2 WITH public, noconstant(false)
 DECLARE med_integ_ind = i2 WITH public, noconstant(false)
 DECLARE iv_integ_ind = i2 WITH public, noconstant(false)
 DECLARE first_ind = i2 WITH public, noconstant(true)
 DECLARE ec_start = i2 WITH public, noconstant(1)
 DECLARE ec_cnt = i4 WITH public, noconstant(0)
 DECLARE ec_cnt_mod = i4 WITH public, noconstant(0)
 DECLARE i_eventset_cd = f8 WITH public, noconstant(0.0)
 DECLARE o_eventset_cd = f8 WITH public, noconstant(0.0)
 DECLARE info_name = vc WITH public, noconstant(" ")
 DECLARE copy_ioresults(null) = null WITH public
 DECLARE copy_numericresults(encntr_id=f8,person_id=f8) = i2 WITH public
 DECLARE copy_medresults(encntr_id=f8,person_id=f8) = i2 WITH public
 DECLARE copy_ivresults(encntr_id=f8,person_id=f8) = i2 WITH public
 DECLARE display_defaultscreen(title=vc,x_pos=i2) = null WITH public
 DECLARE display_setupscreen(null) = null WITH public
 DECLARE display_infoscreen(null) = null WITH public
 DECLARE debug_msg(y_pos=i2,x_pos=i2,msg=vc) = null WITH public
 DECLARE init_blockinfo(null) = i2 WITH public
 DECLARE is_dminfotable_setup(null) = i2 WITH public
 DECLARE process_numericresults(encntr_id=f8) = i2 WITH public
 DECLARE process_medresults(encntr_id=f8) = i2 WITH public
 DECLARE process_ivresults(encntr_id=f8) = i2 WITH public
 DECLARE validate_codevalues(null) = i2 WITH public
 DECLARE insert_ce_intake_output_result_row(person_id=f8,encntr_id=f8,event_id=f8,io_type_flag=i2,
  io_volume=f8,
  io_status_cd=f8,io_start_dt_tm=q8,io_end_dt_tm=q8,reference_event_id=f8,reference_event_cd=f8) = i2
  WITH public
 DECLARE update_clinical_event_subtablebitmap(clinical_event_id=f8) = i2 WITH public
 DECLARE insert_ce_result_set_link_row(entry_type_cd=f8,event_id=f8,result_set_id=f8,valid_from_dt_tm
  =q8,valid_until_dt_tm=q8) = i2 WITH public
 DECLARE insert_clinical_event_row(person_id=f8,encntr_id=f8,event_id=f8,event_cd=f8,parent_event_id=
  f8,
  contributor_system_cd=f8,event_class_cd=f8,event_reltn_cd=f8,record_status_cd=f8,result_status_cd=
  f8,
  entry_mode_cd=f8,view_level=i4,publish_flag=i2,result_val=vc,event_tag=vc,
  event_end_dt_tm=q8,event_end_tz=i4,valid_from_dt_tm=q8,valid_until_dt_tm=q8) = i2 WITH public
 SET message = window
 SET width = 80
 CALL display_defaultscreen(" ",0)
 CALL text(07,05,"RETRIEVING CODE VALUES...")
 DECLARE auth = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE root = f8 WITH public, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE active = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE io = f8 WITH public, constant(uar_get_code_by("MEANING",53,"IO"))
 DECLARE med = f8 WITH public, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE num = f8 WITH public, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE ivparent = f8 WITH public, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE pwrchart = f8 WITH public, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE powerchart = f8 WITH public, constant(uar_get_code_by("MEANING",89,"POWERCHART"))
 DECLARE bolus = f8 WITH public, constant(uar_get_code_by("MEANING",180,"BOLUS"))
 DECLARE infuse = f8 WITH public, constant(uar_get_code_by("MEANING",180,"INFUSE"))
 DECLARE medadmin = f8 WITH public, constant(uar_get_code_by("MEANING",255431,"MEDADMIN"))
 DECLARE confirmed = f8 WITH public, constant(uar_get_code_by("MEANING",4000160,"CONFIRMED"))
 DECLARE ml = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3780"))
 DECLARE dcpgeneric = f8 WITH public, noconstant(0.0)
 DECLARE medintake = f8 WITH public, noconstant(0.0)
 IF ((pwrchart > - (1.0)))
  SELECT INTO "nl:"
   cva.code_value
   FROM code_value_alias cva
   WHERE cva.alias="DCPGENERIC"
    AND cva.code_set=72.0
    AND cva.contributor_source_cd=pwrchart
   DETAIL
    dcpgeneric = cva.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cva.code_value
   FROM code_value_alias cva
   WHERE cva.alias="MEDINTAKE"
    AND cva.code_set=72.0
    AND cva.contributor_source_cd=pwrchart
   DETAIL
    medintake = cva.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF (validate_codevalues(null)=false)
  CALL text(24,02,spaces)
  GO TO exit_program
 ELSE
  CALL text(07,30,"DONE")
 ENDIF
 CALL text(08,05,"RETRIEVING EVENT CODES UNDER FLUID BALANCE...")
 SELECT INTO "nl:"
  vesca.event_set_collating_seq, vesca.event_set_cd
  FROM v500_event_set_code vesc,
   v500_event_set_canon vesca
  PLAN (vesc
   WHERE vesc.event_set_name="FLUID BALANCE")
   JOIN (vesca
   WHERE vesca.parent_event_set_cd=vesc.event_set_cd)
  ORDER BY vesca.event_set_collating_seq
  HEAD vesca.event_set_cd
   IF (first_ind)
    first_ind = false, i_eventset_cd = vesca.event_set_cd
   ELSE
    o_eventset_cd = vesca.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  vec.event_set_name, vec.event_cd
  FROM v500_event_set_explode vese,
   v500_event_code vec,
   v500_event_set_code vesc
  PLAN (vese
   WHERE vese.event_set_cd=i_eventset_cd)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_name=vec.event_set_name
    AND vesc.accumulation_ind=1)
  ORDER BY vec.event_cd
  HEAD vec.event_cd
   event_cds->ec_cnt = (event_cds->ec_cnt+ 1)
   IF (mod(event_cds->ec_cnt,150)=1)
    stat = alterlist(event_cds->cds,(event_cds->ec_cnt+ 149))
   ENDIF
   event_cds->cds[event_cds->ec_cnt].event_cd = vec.event_cd, event_cds->cds[event_cds->ec_cnt].type
    = intake
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  vec.event_set_name, vec.event_cd
  FROM v500_event_set_explode vese,
   v500_event_code vec,
   v500_event_set_code vesc
  PLAN (vese
   WHERE vese.event_set_cd=o_eventset_cd)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_name=vec.event_set_name
    AND vesc.accumulation_ind=1)
  ORDER BY vec.event_cd
  HEAD REPORT
   cntx = 0
  HEAD vec.event_cd
   event_cds->ec_cnt = (event_cds->ec_cnt+ 1), cntx = (cntx+ 1)
   IF (mod(cntx,50)=1)
    stat = alterlist(event_cds->cds,(event_cds->ec_cnt+ 49))
   ENDIF
   event_cds->cds[event_cds->ec_cnt].event_cd = vec.event_cd, event_cds->cds[event_cds->ec_cnt].type
    = output
  WITH nocounter
 ;end select
 SET stat = alterlist(event_cds->cds,event_cds->ec_cnt)
 CALL text(08,50,"DONE")
 CALL pause(1)
 IF ((event_cds->ec_cnt > 0))
  SET ec_start = 1
  SET ec_cnt = event_cds->ec_cnt
  SET ec_cnt_mod = (ec_cnt+ (csize100 - mod(ec_cnt,csize100)))
  SET event_cds->ec_cnt = ec_cnt_mod
  SET stat = alterlist(event_cds->cds,ec_cnt_mod)
  FOR (cntx = (ec_cnt+ 1) TO ec_cnt_mod)
    SET event_cds->cds[cntx].event_cd = event_cds->cds[ec_cnt].event_cd
  ENDFOR
 ENDIF
 WHILE (true)
   CALL display_defaultscreen("MAIN MENU",36)
   CALL text(07,05,"PLEASE CHOOSE ONE OF THE FOLLOWING OPTIONS:")
   CALL text(09,08,"(1)  COPY I&O RESULTS")
   CALL text(11,08,"(2)  COPY I&O RESULTS - (DEBUG MODE)")
   CALL text(13,08,"(3)  DISPLAY DM_INFO TABLE INFORMATION")
   CALL text(16,05,"YOUR CHOICE(0 to EXIT)?")
   CALL accept(16,30,"9;",0
    WHERE curaccept IN (0, 1, 2, 3))
   CASE (curaccept)
    OF 0:
     CALL text(24,02,spaces)
     GO TO exit_program
    OF 1:
     SET debug_ind = false
     IF (is_dminfotable_setup(null)=false)
      CALL display_setupscreen(null)
     ELSE
      IF (init_blockinfo(null)=true)
       CALL copy_ioresults(null)
      ENDIF
     ENDIF
    OF 2:
     SET debug_ind = true
     IF (is_dminfotable_setup(null)=false)
      CALL display_setupscreen(null)
     ELSE
      CALL clear(16,01,80)
      CALL text(16,05,"COPY WHAT ENCOUNTER?")
      CALL accept(16,27,"N(30);C",0.0)
      SET encntr_id = cnvtreal(curaccept)
      IF (encntr_id > 0.0)
       IF (init_blockinfo(null)=true)
        CALL copy_ioresults(null)
       ENDIF
      ENDIF
     ENDIF
    OF 3:
     CALL display_infoscreen(null)
   ENDCASE
 ENDWHILE
 SUBROUTINE display_defaultscreen(title,x_pos)
   CALL clear(01,01)
   CALL video(r)
   CALL box(01,01,05,80)
   CALL text(02,02,spaces)
   CALL text(02,24,"CCL PROGRAM (DCP_COPY_IO_RESULTS)")
   CALL text(03,02,spaces)
   CALL text(04,02,spaces)
   IF (textlen(trim(title,3)) > 0
    AND x_pos > 0)
    CALL video(u)
    CALL text(04,x_pos,title)
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE display_setupscreen(null)
   DECLARE no_fail_ind = i2 WITH protect, noconstant(false)
   CALL display_defaultscreen("SETUP MENU",34)
   SET info_name = "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT"
   CALL text(07,05,"PLEASE CHOOSE ONE OF THE FOLLOWING OPTIONS:")
   CALL text(09,08,"(1)  COPY NUMERIC RESULTS ONLY")
   CALL text(11,08,"(2)  COPY NUMERIC AND MEDICATION RESULTS ONLY")
   CALL text(13,08,"(3)  COPY NUMERIC AND IV RESULTS ONLY")
   CALL text(15,08,"(4)  COPY NUMERIC, MEDICATION, AND IV RESULTS")
   CALL text(18,05,"YOUR CHOICE(0 to RETURN TO MAIN MENU)?")
   CALL accept(18,45,"9;",0
    WHERE curaccept IN (0, 1, 2, 3, 4))
   CASE (curaccept)
    OF 2:
     SET info_name = concat(info_name," - COPY MEDS")
    OF 3:
     SET info_name = concat(info_name," - COPY IVS")
    OF 4:
     SET info_name = concat(info_name," - COPY MEDS AND IVS")
   ENDCASE
   IF (curaccept > 0)
    INSERT  FROM dm_info i
     SET i.info_domain = "DM_README", i.info_name = info_name, i.info_number = 0.0,
      i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_id = reqinfo->updt_id, i.updt_task = 0,
      i.updt_cnt = 1, i.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     ROLLBACK
     CALL text(17,05,"ERROR: DM_INFO ROW INSERT FAILED")
    ELSE
     SET no_fail_ind = true
     COMMIT
    ENDIF
   ENDIF
   IF (no_fail_ind=false
    AND curaccept > 0)
    CALL clear(18,01,80)
    CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
    CALL accept(20,41,"D;DC","")
   ENDIF
 END ;Subroutine
 SUBROUTINE display_infoscreen(null)
   DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
   DECLARE msg = vc WITH protect, noconstant("COPY SETTINGS: NUMERIC")
   DECLARE updt_dt_tm = vc WITH protect, noconstant(format(cnvtdatetime(curdate,curtime3),
     "DD-MMM-YYYY HH:MM:SS;;D"))
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM_README"
     AND i.info_name IN ("LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY IVS",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS AND IVS")
    DETAIL
     encntr_id = i.info_number, updt_dt_tm = format(i.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;d")
     CASE (i.info_name)
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT":
       msg = concat(msg," RESULTS ONLY")
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS":
       msg = concat(msg," AND MEDICATION RESULTS ONLY")
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY IVS":
       msg = concat(msg," AND IV RESULTS ONLY")
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS AND IVS":
       msg = concat(msg,", MEDICATION, AND IV RESULTS")
     ENDCASE
    WITH nocounter
   ;end select
   IF (curqual=1)
    CALL display_defaultscreen("DM_INFO TABLE INFORMATION",27)
    IF (encntr_id=0.0)
     CALL text(07,05,concat("AS OF ",updt_dt_tm,", NO ENCOUNTERS HAVE BEEN COPIED"))
    ELSE
     CALL text(10,05,concat("LAST ENCNTR_ID COPIED = ",trim(cnvtstring(encntr_id,30,1),3)))
     CALL text(12,05,concat("DATE/TIME: ",updt_dt_tm))
    ENDIF
    CALL text(15,05,msg)
   ELSE
    CALL text(07,05,"ERROR: COULD NOT RETRIEVE DM_INFO TABLE INFORMATION")
   ENDIF
   CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
   CALL accept(20,41,"D;DC","")
 END ;Subroutine
 SUBROUTINE is_dminfotable_setup(null)
   SELECT INTO "nl:"
    i.info_number
    FROM dm_info i
    WHERE i.info_domain="DM_README"
     AND i.info_name IN ("LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY IVS",
    "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS AND IVS")
    DETAIL
     info_name = i.info_name
     CASE (info_name)
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS":
       med_integ_ind = true,iv_integ_ind = false
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY IVS":
       med_integ_ind = false,iv_integ_ind = true
      OF "LAST ENCNTR ID COPIED BY IO DATA COPY SCRIPT - COPY MEDS AND IVS":
       med_integ_ind = true,iv_integ_ind = true
     ENDCASE
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE init_blockinfo(null)
   DECLARE no_fail_ind = i2 WITH protect, noconstant(false)
   IF (debug_ind)
    SET temp->min_id = encntr_id
    SET temp->max_id = (temp->min_id+ 1.0)
    SET no_fail_ind = true
   ELSE
    SELECT INTO "nl:"
     nextseqnum = seq(encounter_only_seq,nextval)
     FROM dual
     DETAIL
      temp->max_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL text(11,05,"ERROR: COULD NOT RETRIEVE NEXT SEQUENCE FROM ENCOUNTER_ONLY_SEQ")
    ELSE
     SELECT INTO "nl:"
      i.info_number
      FROM dm_info i
      WHERE i.info_domain="DM_README"
       AND i.info_name=info_name
      DETAIL
       temp->min_id = (i.info_number+ 1.0)
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL clear(16,01,80)
      CALL text(17,05,"ERROR: COULD NOT RETRIEVE NEXT ENCOUNTER FROM DM_INFO TABLE")
     ELSE
      SET no_fail_ind = true
     ENDIF
    ENDIF
   ENDIF
   IF (no_fail_ind=false)
    CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
    CALL accept(20,41,"D;DC","")
   ENDIF
   RETURN(no_fail_ind)
 END ;Subroutine
 SUBROUTINE copy_ioresults(null)
   DECLARE no_fail_ind = i2 WITH protect, noconstant(true)
   DECLARE not_done_ind = i2 WITH protect, noconstant(true)
   DECLARE block_not_done = i2 WITH protect, noconstant(true)
   DECLARE block_cnt = i4 WITH protect, noconstant(0)
   IF (debug_ind)
    CALL display_defaultscreen("DEBUG MODE",36)
   ELSE
    CALL display_defaultscreen("COPY MODE",36)
   ENDIF
   WHILE (not_done_ind)
     IF (debug_ind)
      SET not_done_ind = false
     ENDIF
     SELECT INTO "nl:"
      e.encntr_id, e.person_id
      FROM encounter e
      WHERE (e.encntr_id >= temp->min_id)
       AND (e.encntr_id < temp->max_id)
      ORDER BY e.encntr_id
      DETAIL
       temp->block_cnt = (temp->block_cnt+ 1)
       IF (mod(temp->block_cnt,100)=1)
        stat = alterlist(temp->block,(temp->block_cnt+ 99))
       ENDIF
       temp->block[temp->block_cnt].encntr_id = e.encntr_id, temp->block[temp->block_cnt].person_id
        = e.person_id
      FOOT REPORT
       stat = alterlist(temp->block,temp->block_cnt)
      WITH nocounter, maxrec = 100
     ;end select
     IF ((temp->block_cnt=0))
      SET not_done_ind = false
     ELSE
      SET block_cnt = 1
      SET block_not_done = true
      WHILE (block_not_done)
        CALL clear(07,01,80)
        CALL text(07,05,concat("COPYING I&O RESULTS FROM ENCOUNTER = ",trim(cnvtstring(temp->block[
            block_cnt].encntr_id,30,1),3)))
        IF ((block_cnt=temp->block_cnt))
         SET block_not_done = false
        ENDIF
        SELECT INTO "nl:"
         p.person_id
         FROM person p
         WHERE (p.person_id=temp->block[block_cnt].person_id)
         WITH nocounter, forupdate(p)
        ;end select
        IF (curqual=0)
         SET no_fail_ind = false
         CALL clear(11,01,80)
         CALL text(11,05,"ERROR: COULD NOT ACQUIRE LOCKS ON PERSON ROW")
        ENDIF
        IF (no_fail_ind)
         IF ((event_cds->ec_cnt > 0))
          CALL debug_msg(10,05,"INFO: SEARCHING FOR NUMERIC RESULTS...")
          CALL process_numericresults(temp->block[block_cnt].encntr_id)
          IF ((num_io->num_cnt > 0))
           CALL debug_msg(10,05,"INFO: COPYING NUMERIC RESULTS...")
           IF (copy_numericresults(temp->block[block_cnt].encntr_id,temp->block[block_cnt].person_id)
           =false)
            SET no_fail_ind = false
            CALL clear(11,01,80)
            CALL text(11,05,"ERROR: NUMERIC RESULT COPY FAILED FOR ENCOUNTER")
           ELSE
            CALL debug_msg(10,05,build("INFO: NUMERIC RESULT(S) COPIED...(",num_io->num_cnt,")"))
           ENDIF
          ELSE
           CALL debug_msg(10,05,"INFO: NO NUMERIC RESULTS FOUND")
          ENDIF
         ELSE
          CALL debug_msg(10,05,"INFO: NO EVENT CDS FOUND UNDER FLUID BALANCE")
         ENDIF
        ENDIF
        IF (no_fail_ind)
         IF (med_integ_ind)
          CALL debug_msg(10,05,"INFO: SEARCHING FOR MED RESULTS...")
          CALL process_medresults(temp->block[block_cnt].encntr_id)
          IF ((med_io->med_cnt > 0))
           CALL debug_msg(10,05,"INFO: COPYING MED RESULTS...")
           IF (copy_medresults(temp->block[block_cnt].encntr_id,temp->block[block_cnt].person_id)=
           false)
            SET no_fail_ind = false
            CALL clear(11,01,80)
            CALL text(11,05,"ERROR: MED RESULT COPY FAILED FOR ENCOUNTER")
           ELSE
            CALL debug_msg(10,05,build("INFO: MED RESULT(S) COPIED...(",med_io->med_cnt,")"))
           ENDIF
          ELSE
           CALL debug_msg(10,05,"INFO: NO MED RESULTS FOUND")
          ENDIF
         ENDIF
        ENDIF
        IF (no_fail_ind)
         IF (iv_integ_ind)
          CALL debug_msg(10,05,"INFO: SEARCHING FOR IV RESULTS...")
          CALL process_ivresults(temp->block[block_cnt].encntr_id)
          IF ((iv_io->iv_cnt > 0))
           CALL debug_msg(10,05,"INFO: COPYING IV RESULTS...")
           IF (copy_ivresults(temp->block[block_cnt].encntr_id,temp->block[block_cnt].person_id)=
           false)
            SET no_fail_ind = false
            CALL clear(11,01,80)
            CALL text(11,05,"ERROR: IV RESULT COPY FAILED FOR ENCOUNTER")
           ELSE
            CALL debug_msg(10,05,build("INFO: IV RESULT(S) COPIED...(",iv_io->iv_cnt,")"))
           ENDIF
          ELSE
           CALL debug_msg(10,05,"INFO: NO IV RESULTS FOUND")
          ENDIF
         ENDIF
        ENDIF
        IF (no_fail_ind=true
         AND debug_ind=false)
         SELECT INTO "nl:"
          i.info_domain, i.info_name
          FROM dm_info i
          WHERE i.info_domain="DM_README"
           AND i.info_name=info_name
          WITH nocounter, forupdate(i)
         ;end select
         IF (curqual=0)
          ROLLBACK
          CALL clear(11,01,80)
          CALL text(11,05,"ERROR: COULD NOT ACQUIRE LOCK ON DM_INFO ROW")
          CALL text(12,05,"PERFORMING ROLLBACK...")
          SET no_fail_ind = false
          SET block_not_done = false
         ELSE
          UPDATE  FROM dm_info i
           SET i.info_number = temp->block[block_cnt].encntr_id, i.updt_dt_tm = cnvtdatetime(curdate,
             curtime3), i.updt_id = reqinfo->updt_id,
            i.updt_cnt = (i.updt_cnt+ 1)
           WHERE i.info_domain="DM_README"
            AND i.info_name=info_name
           WITH nocounter
          ;end update
          IF (curqual=0)
           ROLLBACK
           CALL clear(11,01,80)
           CALL text(11,05,"ERROR: DM_INFO ROW UPDATE FAILED")
           CALL text(12,05,"PERFORMING ROLLBACK...")
           SET no_fail_ind = false
           SET block_not_done = false
          ELSE
           COMMIT
           SET block_cnt = (block_cnt+ 1)
          ENDIF
         ENDIF
        ELSE
         ROLLBACK
         CALL text(12,05,"PERFORMING ROLLBACK...")
         SET block_not_done = false
        ENDIF
      ENDWHILE
      SET min_id = (temp->block[temp->block_cnt].encntr_id+ 1.0)
      SET max_id = temp->max_id
      IF (initrec(temp) != 1)
       SET temp->block_cnt = 0
       SET temp->min_id = 0.0
       SET temp->max_id = 0.0
      ENDIF
      IF (no_fail_ind=true
       AND not_done_ind=true)
       SET temp->min_id = min_id
       SET temp->max_id = max_id
      ELSEIF (no_fail_ind=false
       AND not_done_ind=true)
       SET not_done_ind = false
      ENDIF
     ENDIF
   ENDWHILE
   IF (no_fail_ind=true
    AND debug_ind=false)
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e
     WHERE (e.encntr_id > temp->max_id)
     ORDER BY e.encntr_id
     DETAIL
      CALL text(14,05,"WARNING: ONE OR MORE ENCOUNTERS HAVE BEEN ADDED TO THE SYSTEM DURING THE"),
      CALL text(15,05,"COPY PROCESS. ANY RESULT FROM THESE ENCOUNTERS HAVE NOT BEEN COPIED")
     WITH nocounter, maxrec = 1
    ;end select
   ENDIF
   CALL text(20,05,"PRESS <ENTER> TO RETURN TO MAIN MENU")
   CALL accept(20,41,"D;DC","")
 END ;Subroutine
 SUBROUTINE process_numericresults(encntr_id)
   IF (initrec(num_io) != 1)
    RETURN(false)
   ENDIF
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   DECLARE cnt2 = i4 WITH protect, noconstant(0)
   DECLARE cnt3 = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ce.clinical_event_id, ce.event_id, ce.event_cd,
    ce.event_end_dt_tm, ce.result_val
    FROM (dummyt d1  WITH seq = value((1+ ((ec_cnt_mod - 1)/ csize100)))),
     clinical_event ce
    PLAN (d1
     WHERE initarray(ec_start,evaluate(d1.seq,1,1,(ec_start+ csize100))))
     JOIN (ce
     WHERE ce.encntr_id=encntr_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.event_class_cd=num
      AND expand(cnt1,ec_start,(ec_start+ (csize100 - 1)),ce.event_cd,event_cds->cds[cnt1].event_cd)
      AND ce.view_level=1)
    ORDER BY ce.event_id
    HEAD ce.event_id
     IF (band(ce.subtable_bit_map,8) != 8)
      num_io->num_cnt = (num_io->num_cnt+ 1)
      IF (mod(num_io->num_cnt,100)=1)
       stat = alterlist(num_io->nums,(num_io->num_cnt+ 99))
      ENDIF
      cnt2 = locateval(cnt3,1,ec_cnt,ce.event_cd,event_cds->cds[cnt3].event_cd), num_io->nums[num_io
      ->num_cnt].clinical_event_id = ce.clinical_event_id, num_io->nums[num_io->num_cnt].event_id =
      ce.event_id,
      num_io->nums[num_io->num_cnt].event_cd = ce.event_cd, num_io->nums[num_io->num_cnt].
      event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm), num_io->nums[num_io->num_cnt].io_volume =
      cnvtreal(ce.result_val),
      num_io->nums[num_io->num_cnt].io_type_flag = event_cds->cds[cnt2].type
     ENDIF
    FOOT REPORT
     stat = alterlist(num_io->nums,num_io->num_cnt)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE process_medresults(encntr_id)
   IF (((initrec(res) != 1) OR (initrec(med_io) != 1)) )
    RETURN(false)
   ENDIF
   DECLARE ml_unit_ind = i2 WITH protect, noconstant(false)
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   DECLARE cnt2 = i4 WITH protect, noconstant(0)
   DECLARE cnt3 = i4 WITH protect, noconstant(0)
   DECLARE io_volume = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    ce2.clinical_event_id, ce2.event_id, ce2.event_end_dt_tm,
    ce2.valid_from_dt_tm, ce2.valid_until_dt_tm
    FROM clinical_event ce1,
     dummyt d1,
     ce_med_result cmr,
     clinical_event ce2,
     ce_result_set_link crsl
    PLAN (ce1
     WHERE ce1.encntr_id=encntr_id
      AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce1.event_class_cd=med
      AND ce1.event_cd != ivparent
      AND ce1.view_level=1)
     JOIN (d1
     WHERE band(ce1.subtable_bit_map,8) != 8)
     JOIN (cmr
     WHERE cmr.event_id=ce1.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ((cmr.iv_event_cd=0.0) OR (cmr.iv_event_cd=null))
      AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
     JOIN (ce2
     WHERE ce2.event_id=ce1.parent_event_id
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce2.event_cd=dcpgeneric
      AND ce2.view_level=0)
     JOIN (crsl
     WHERE outerjoin(ce2.event_id)=crsl.event_id)
    ORDER BY ce2.event_id
    HEAD ce2.event_id
     IF (((crsl.event_id=0.0) OR (crsl.event_id > 0.0
      AND crsl.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND crsl.entry_type_cd != medadmin)) )
      res->io_cnt = (res->io_cnt+ 1)
      IF (mod(res->io_cnt,50)=1)
       stat = alterlist(res->io,(res->io_cnt+ 49))
      ENDIF
      res->io[res->io_cnt].clinical_event_id = ce2.clinical_event_id, res->io[res->io_cnt].
      parent_event_id = ce2.event_id, res->io[res->io_cnt].event_end_dt_tm = cnvtdatetime(ce2
       .event_end_dt_tm),
      res->io[res->io_cnt].valid_from_dt_tm = cnvtdatetime(ce2.valid_from_dt_tm), res->io[res->io_cnt
      ].valid_until_dt_tm = cnvtdatetime(ce2.valid_until_dt_tm), res->io[res->io_cnt].event_end_tz =
      ce2.event_end_tz
     ENDIF
    WITH nocounter
   ;end select
   FOR (cnt1 = 1 TO res->io_cnt)
     SELECT INTO "nl:"
      ce.parent_event_id, ce.event_id, ce.event_end_dt_tm,
      ce.valid_from_dt_tm, ce.valid_until_dt_tm
      FROM clinical_event ce,
       ce_med_result cmr
      PLAN (ce
       WHERE (ce.parent_event_id=res->io[cnt1].parent_event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND ce.event_class_cd=med
        AND ce.view_level=1)
       JOIN (cmr
       WHERE cmr.event_id=ce.event_id
        AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND ((cmr.iv_event_cd=0.0) OR (cmr.iv_event_cd=null))
        AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
      ORDER BY ce.parent_event_id, ce.event_id
      HEAD ce.parent_event_id
       io_volume = 0.0, ml_unit_ind = false
      HEAD ce.event_id
       IF (cmr.admin_dosage > 0.0
        AND cmr.dosage_unit_cd=ml)
        io_volume = (io_volume+ cmr.admin_dosage), ml_unit_ind = true
       ELSEIF (cmr.infused_volume > 0.0
        AND cmr.infused_volume_unit_cd=ml)
        io_volume = (io_volume+ cmr.infused_volume), ml_unit_ind = true
       ENDIF
       res->io[cnt1].child_cnt = (res->io[cnt1].child_cnt+ 1)
       IF (mod(res->io[cnt1].child_cnt,5)=1)
        stat = alterlist(res->io[cnt1].child,(res->io[cnt1].child_cnt+ 4))
       ENDIF
       cnt2 = res->io[cnt1].child_cnt, res->io[cnt1].child[cnt2].event_id = ce.event_id, res->io[cnt1
       ].child[cnt2].valid_from_dt_tm = cnvtdatetime(ce.valid_from_dt_tm),
       res->io[cnt1].child[cnt2].valid_until_dt_tm = cnvtdatetime(ce.valid_until_dt_tm)
      FOOT  ce.parent_event_id
       stat = alterlist(res->io[cnt1].child,res->io[cnt1].child_cnt)
       IF (ml_unit_ind)
        med_io->med_cnt = (med_io->med_cnt+ 1)
        IF (mod(med_io->med_cnt,50)=1)
         stat = alterlist(med_io->meds,(med_io->med_cnt+ 49))
        ENDIF
        med_io->meds[med_io->med_cnt].reference_event_id = res->io[cnt1].parent_event_id, med_io->
        meds[med_io->med_cnt].io_type_flag = intake, med_io->meds[med_io->med_cnt].io_volume =
        io_volume,
        med_io->meds[med_io->med_cnt].event_end_dt_tm = cnvtdatetime(res->io[cnt1].event_end_dt_tm),
        med_io->meds[med_io->med_cnt].event_end_tz = res->io[cnt1].event_end_tz, med_io->meds[med_io
        ->med_cnt].valid_from_dt_tm = cnvtdatetime(res->io[cnt1].valid_from_dt_tm),
        med_io->meds[med_io->med_cnt].valid_until_dt_tm = cnvtdatetime(res->io[cnt1].
         valid_until_dt_tm), med_io->meds[med_io->med_cnt].child_cnt = res->io[cnt1].child_cnt, stat
         = alterlist(med_io->meds[med_io->med_cnt].child,med_io->meds[med_io->med_cnt].child_cnt)
        FOR (cnt3 = 1 TO med_io->meds[med_io->med_cnt].child_cnt)
          med_io->meds[med_io->med_cnt].child[cnt3].event_id = res->io[cnt1].child[cnt3].event_id,
          med_io->meds[med_io->med_cnt].child[cnt3].valid_from_dt_tm = cnvtdatetime(res->io[cnt1].
           child[cnt3].valid_from_dt_tm), med_io->meds[med_io->med_cnt].child[cnt3].valid_until_dt_tm
           = cnvtdatetime(res->io[cnt1].child[cnt3].valid_until_dt_tm)
        ENDFOR
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   SET stat = alterlist(med_io->meds,med_io->med_cnt)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE process_ivresults(encntr_id)
   IF (((initrec(res) != 1) OR (initrec(iv_io) != 1)) )
    RETURN(false)
   ENDIF
   DECLARE ml_unit_ind = i2 WITH protect, noconstant(false)
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   DECLARE cnt2 = i4 WITH protect, noconstant(0)
   DECLARE io_volume = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    ce.clinical_event_id, ce.event_id, ce.event_cd,
    ce.event_end_dt_tm, cmr.admin_dosage, cmr.infused_volume
    FROM clinical_event ce,
     dummyt d1,
     ce_med_result cmr
    PLAN (ce
     WHERE ce.encntr_id=encntr_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.event_cd=ivparent)
     JOIN (d1
     WHERE band(ce.subtable_bit_map,8) != 8)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND cmr.iv_event_cd IN (bolus, infuse))
    ORDER BY ce.clinical_event_id, ce.event_id
    HEAD ce.event_id
     IF (cmr.admin_dosage >= 0.0
      AND cmr.dosage_unit_cd=ml)
      ml_unit_ind = true, io_volume = (io_volume+ cmr.admin_dosage)
     ELSEIF (cmr.infused_volume >= 0.0
      AND cmr.infused_volume_unit_cd=ml)
      ml_unit_ind = true, io_volume = (io_volume+ cmr.infused_volume)
     ENDIF
     IF (ml_unit_ind)
      iv_io->iv_cnt = (iv_io->iv_cnt+ 1)
      IF (mod(iv_io->iv_cnt,50)=1)
       stat = alterlist(iv_io->ivs,(iv_io->iv_cnt+ 49))
      ENDIF
      iv_io->ivs[iv_io->iv_cnt].clinical_event_id = ce.clinical_event_id, iv_io->ivs[iv_io->iv_cnt].
      event_id = ce.event_id, iv_io->ivs[iv_io->iv_cnt].event_cd = ce.event_cd,
      iv_io->ivs[iv_io->iv_cnt].io_type_flag = intake, iv_io->ivs[iv_io->iv_cnt].io_volume =
      io_volume, iv_io->ivs[iv_io->iv_cnt].event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm)
     ENDIF
     ml_unit_ind = false, io_volume = 0.0
    WITH nocounter
   ;end select
   SET stat = alterlist(iv_io->ivs,iv_io->iv_cnt)
   SELECT INTO "nl:"
    ce1.parent_event_id, ce1.event_id
    FROM clinical_event ce1,
     dummyt d1,
     clinical_event ce2,
     ce_med_result cmr
    PLAN (ce1
     WHERE ce1.encntr_id=encntr_id
      AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce1.event_class_cd=med
      AND ce1.event_cd != ivparent
      AND ce1.view_level=1)
     JOIN (d1
     WHERE band(ce1.subtable_bit_map,8) != 8)
     JOIN (ce2
     WHERE ce2.event_id=ce1.parent_event_id
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce2.event_cd=dcpgeneric
      AND ce2.view_level=0)
     JOIN (cmr
     WHERE cmr.event_id=ce1.event_id
      AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND cmr.iv_event_cd IN (bolus, infuse)
      AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
    ORDER BY ce1.event_id
    HEAD REPORT
     ml_unit_ind = false, io_volume = 0.0
    HEAD ce1.event_id
     IF (cmr.admin_dosage >= 0.0
      AND cmr.dosage_unit_cd=ml)
      ml_unit_ind = true, io_volume = (io_volume+ cmr.admin_dosage)
     ELSEIF (cmr.infused_volume >= 0.0
      AND cmr.infused_volume_unit_cd=ml)
      ml_unit_ind = true, io_volume = (io_volume+ cmr.infused_volume)
     ENDIF
     IF (ml_unit_ind)
      res->io_cnt = (res->io_cnt+ 1)
      IF (mod(res->io_cnt,50)=1)
       stat = alterlist(res->io,(res->io_cnt+ 49))
      ENDIF
      res->io[res->io_cnt].io_volume = io_volume, res->io[res->io_cnt].clinical_event_id = ce1
      .clinical_event_id, res->io[res->io_cnt].event_id = ce1.event_id,
      res->io[res->io_cnt].parent_event_id = ce1.event_id, res->io[res->io_cnt].event_cd = ce1
      .event_cd, res->io[res->io_cnt].event_end_dt_tm = cnvtdatetime(ce1.event_end_dt_tm)
     ENDIF
     ml_unit_ind = false, io_volume = 0.0
    FOOT REPORT
     stat = alterlist(res->io,res->io_cnt)
    WITH nocounter
   ;end select
   FOR (cnt1 = 1 TO res->io_cnt)
     SELECT INTO "nl:"
      cmr.admin_dosage, cmr.infused_volume
      FROM clinical_event ce,
       dummyt d1,
       ce_med_result cmr
      PLAN (ce
       WHERE (ce.parent_event_id=res->io[cnt1].parent_event_id)
        AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND ce.event_class_cd=med
        AND ce.view_level=1)
       JOIN (d1
       WHERE band(ce.subtable_bit_map,8) != 8)
       JOIN (cmr
       WHERE cmr.event_id=ce.event_id
        AND cmr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND cmr.iv_event_cd IN (bolus, infuse)
        AND ((cmr.dosage_unit_cd=ml) OR (cmr.infused_volume_unit_cd=ml)) )
      ORDER BY ce.event_id
      HEAD ce.event_id
       IF (cmr.admin_dosage >= 0.0
        AND cmr.dosage_unit_cd=ml)
        res->io[cnt1].io_volume = (res->io[cnt1].io_volume+ cmr.admin_dosage)
       ELSEIF (cmr.infused_volume >= 0.0
        AND cmr.infused_volume_unit_cd=ml)
        res->io[cnt1].io_volume = (res->io[cnt1].io_volume+ cmr.infused_volume)
       ENDIF
      WITH nocounter
     ;end select
     SET cnt2 = (cnt2+ 1)
     SET iv_io->iv_cnt = (iv_io->iv_cnt+ 1)
     IF (mod(cnt2,50)=1)
      SET stat = alterlist(iv_io->ivs,(iv_io->iv_cnt+ 49))
     ENDIF
     SET iv_io->ivs[iv_io->iv_cnt].clinical_event_id = res->io[cnt1].clinical_event_id
     SET iv_io->ivs[iv_io->iv_cnt].event_id = res->io[cnt1].event_id
     SET iv_io->ivs[iv_io->iv_cnt].event_cd = res->io[cnt1].event_cd
     SET iv_io->ivs[iv_io->iv_cnt].io_volume = res->io[cnt1].io_volume
     SET iv_io->ivs[iv_io->iv_cnt].io_type_flag = intake
     SET iv_io->ivs[iv_io->iv_cnt].event_end_dt_tm = res->io[cnt1].event_end_dt_tm
   ENDFOR
   SET stat = alterlist(iv_io->ivs,iv_io->iv_cnt)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE copy_numericresults(encntr_id,person_id)
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   FOR (cnt1 = 1 TO num_io->num_cnt)
    IF (insert_ce_intake_output_result_row(person_id,encntr_id,num_io->nums[cnt1].event_id,num_io->
     nums[cnt1].io_type_flag,num_io->nums[cnt1].io_volume,
     confirmed,num_io->nums[cnt1].event_end_dt_tm,num_io->nums[cnt1].event_end_dt_tm,num_io->nums[
     cnt1].event_id,num_io->nums[cnt1].event_cd)=false)
     RETURN(false)
    ENDIF
    IF (update_clinical_event_subtablebitmap(num_io->nums[cnt1].clinical_event_id)=false)
     RETURN(false)
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE copy_medresults(encntr_id,person_id)
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   DECLARE cnt2 = i4 WITH protect, noconstant(0)
   DECLARE event_id = f8 WITH protect, noconstant(0.0)
   DECLARE result_set_id = f8 WITH protect, noconstant(0.0)
   FOR (cnt1 = 1 TO med_io->med_cnt)
     SET result_set_id = 0.0
     SELECT INTO "nl:"
      crsl.result_set_id
      FROM ce_result_set_link crsl
      WHERE (crsl.event_id=med_io->meds[cnt1].reference_event_id)
       AND crsl.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      DETAIL
       result_set_id = crsl.result_set_id
      WITH nocounter
     ;end select
     IF (result_set_id=0.0)
      SELECT INTO "nl:"
       nextseqnum = seq(result_set_seq,nextval)
       FROM dual
       DETAIL
        result_set_id = cnvtreal(nextseqnum)
       WITH nocounter
      ;end select
      IF (result_set_id <= 0.0)
       CALL debug_msg(11,05,build("ERROR: COULD NOT GENERATE RESULT_SET_ID FOR EVENT =",trim(
          cnvstring(med_io->meds[cnt1].reference_event_id,30,1),3)))
       RETURN(false)
      ENDIF
      IF (insert_ce_result_set_link_row(medadmin,med_io->meds[cnt1].reference_event_id,result_set_id,
       med_io->meds[cnt1].valid_from_dt_tm,med_io->meds[cnt1].valid_until_dt_tm)=false)
       RETURN(false)
      ENDIF
      FOR (cnt2 = 1 TO med_io->meds[cnt1].child_cnt)
        IF (insert_ce_result_set_link_row(medadmin,med_io->meds[cnt1].child[cnt2].event_id,
         result_set_id,med_io->meds[cnt1].child[cnt2].valid_from_dt_tm,med_io->meds[cnt1].child[cnt2]
         .valid_until_dt_tm)=false)
         RETURN(false)
        ENDIF
      ENDFOR
     ENDIF
     SET event_id = 0.0
     SELECT INTO "nl:"
      nextseqnum = seq(clinical_event_seq,nextval)
      FROM dual
      DETAIL
       event_id = cnvtreal(nextseqnum)
      WITH nocounter
     ;end select
     IF (event_id <= 0.0)
      RETURN(false)
     ENDIF
     IF (insert_clinical_event_row(person_id,encntr_id,event_id,medintake,event_id,
      powerchart,io,root,active,auth,
      medadmin,1,1,trim(cnvtstring(med_io->meds[cnt1].io_volume,30)),trim(cnvtstring(med_io->meds[
        cnt1].io_volume,30)),
      med_io->meds[cnt1].event_end_dt_tm,med_io->meds[cnt1].event_end_tz,med_io->meds[cnt1].
      valid_from_dt_tm,med_io->meds[cnt1].valid_until_dt_tm)=false)
      RETURN(false)
     ENDIF
     IF (insert_ce_intake_output_result_row(person_id,encntr_id,event_id,intake,med_io->meds[cnt1].
      io_volume,
      confirmed,med_io->meds[cnt1].event_end_dt_tm,med_io->meds[cnt1].event_end_dt_tm,med_io->meds[
      cnt1].reference_event_id,medintake)=false)
      RETURN(no_fail_ind)
     ENDIF
     IF (insert_ce_result_set_link_row(medadmin,event_id,result_set_id,med_io->meds[cnt1].
      valid_from_dt_tm,med_io->meds[cnt1].valid_until_dt_tm)=false)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE copy_ivresults(encntr_id,person_id)
   DECLARE cnt1 = i4 WITH protect, noconstant(0)
   FOR (cnt1 = 1 TO iv_io->iv_cnt)
    IF (insert_ce_intake_output_result_row(person_id,encntr_id,iv_io->ivs[cnt1].event_id,iv_io->ivs[
     cnt1].io_type_flag,iv_io->ivs[cnt1].io_volume,
     confirmed,iv_io->ivs[cnt1].event_end_dt_tm,iv_io->ivs[cnt1].event_end_dt_tm,iv_io->ivs[cnt1].
     event_id,iv_io->ivs[cnt1].event_cd)=false)
     RETURN(false)
    ENDIF
    IF (update_clinical_event_subtablebitmap(iv_io->ivs[cnt1].clinical_event_id)=false)
     RETURN(false)
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE insert_ce_intake_output_result_row(person_id,encntr_id,event_id,io_type_flag,io_volume,
  io_status_cd,io_start_dt_tm,io_end_dt_tm,reference_event_id,reference_event_cd)
   INSERT  FROM ce_intake_output_result cir
    SET cir.ce_io_result_id = seq(ocf_seq,nextval), cir.io_result_id = seq(ocf_seq,nextval), cir
     .event_id = event_id,
     cir.person_id = person_id, cir.encntr_id = encntr_id, cir.io_type_flag = io_type_flag,
     cir.io_volume = io_volume, cir.io_status_cd = io_status_cd, cir.io_start_dt_tm = cnvtdatetime(
      io_start_dt_tm),
     cir.io_end_dt_tm = cnvtdatetime(io_end_dt_tm), cir.reference_event_id = reference_event_id, cir
     .reference_event_cd = reference_event_cd,
     cir.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), cir.valid_until_dt_tm = cnvtdatetime(
      "31-DEC-2100"), cir.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cir.updt_id = reqinfo->updt_id, cir.updt_task = 0, cir.updt_cnt = 1,
     cir.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL debug_msg(11,05,build("ERROR: CE_INTAKE_OUPUT_RESULT ROW INSERT FAILED FOR EVENT =",trim(
       cnvtstring(event_id,30,1),3)))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE update_clinical_event_subtablebitmap(clinical_event_id)
   DECLARE cebit_val = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ce.subtable_bit_map
    FROM clinical_event ce
    WHERE ce.clinical_event_id=clinical_event_id
    DETAIL
     cebit_val = ce.subtable_bit_map
    WITH nocounter, forupdate(ce)
   ;end select
   IF (curqual=0)
    CALL debug_msg(11,05,"ERROR: COULD NOT ACQUIRE LOCK ON CLINICAL_EVENT ROW")
    RETURN(false)
   ENDIF
   SET cebit_val = bor(cebit_val,8)
   UPDATE  FROM clinical_event ce
    SET ce.subtable_bit_map = cebit_val
    WHERE ce.clinical_event_id=clinical_event_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL debug_msg(11,05,build("ERROR: SUBTABLEBIT_MAP UPDATE FAILED FOR CLINICAL_EVENT =",trim(
       cnvtstring(clinical_event_id,30,1),3)))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE insert_ce_result_set_link_row(entry_type_cd,event_id,result_set_id,valid_from_dt_tm,
  valid_until_dt_tm)
   INSERT  FROM ce_result_set_link crsl
    SET crsl.entry_type_cd = entry_type_cd, crsl.event_id = event_id, crsl.result_set_id =
     result_set_id,
     crsl.valid_from_dt_tm = cnvtdatetime(valid_from_dt_tm), crsl.valid_until_dt_tm = cnvtdatetime(
      valid_until_dt_tm), crsl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     crsl.updt_id = reqinfo->updt_id, crsl.updt_task = 0, crsl.updt_cnt = 1,
     crsl.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL debug_msg(11,05,build("ERROR: RESULT SET LINK ROW INSERT FAILED FOR EVENT =",trim(cnvtstring
       (event_id,30,1),3)))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE insert_clinical_event_row(person_id,encntr_id,event_id,event_cd,parent_event_id,
  contributor_system_cd,event_class_cd,event_reltn_cd,record_status_cd,result_status_cd,entry_mode_cd,
  view_level,publish_flag,result_val,event_tag,event_end_dt_tm,event_end_tz,valid_from_dt_tm,
  valid_until_dt_tm)
   DECLARE reference_nbr = vc WITH protect, noconstant(trim(cnvtstring(event_id,30,0),3))
   INSERT  FROM clinical_event ce
    SET ce.clinical_event_id = seq(clinical_event_seq,nextval), ce.person_id = person_id, ce
     .encntr_id = encntr_id,
     ce.event_id = event_id, ce.event_cd = event_cd, ce.parent_event_id = parent_event_id,
     ce.contributor_system_cd = contributor_system_cd, ce.event_class_cd = event_class_cd, ce
     .event_reltn_cd = event_reltn_cd,
     ce.record_status_cd = record_status_cd, ce.result_status_cd = result_status_cd, ce.entry_mode_cd
      = entry_mode_cd,
     ce.view_level = view_level, ce.publish_flag = publish_flag, ce.result_val = result_val,
     ce.event_tag = event_tag, ce.reference_nbr = reference_nbr, ce.event_end_dt_tm = cnvtdatetime(
      event_end_dt_tm),
     ce.event_end_tz = event_end_tz, ce.valid_from_dt_tm = cnvtdatetime(valid_from_dt_tm), ce
     .valid_until_dt_tm = cnvtdatetime(valid_until_dt_tm),
     ce.subtable_bit_map = 8, ce.updt_dt_tm = cnvtdatetime(curdate,curtime3), ce.updt_id = reqinfo->
     updt_id,
     ce.updt_task = 0, ce.updt_cnt = 1, ce.updt_applctx = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL debug_msg(11,05,build("ERROR: CLINICAL EVENT ROW INSERT FAILED FOR EVENT =",trim(cnvtstring(
        event_id,30,1),3)))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE debug_msg(y_pos,x_pos,msg)
   IF (debug_ind)
    CALL clear(y_pos,01,80)
    CALL text(y_pos,x_pos,trim(msg,3))
    CALL pause(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_codevalues(null)
   DECLARE not_failed_ind = i2 WITH protect, noconstant(true)
   IF (auth < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (AUTH) NOT FOUND IN CODE SET 8")
    CALL pause(1)
   ENDIF
   IF (root < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (ROOT) NOT FOUND IN CODE SET 24")
    CALL pause(1)
   ENDIF
   IF (active < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (ACTIVE) NOT FOUND IN CODE SET 48")
    CALL pause(1)
   ENDIF
   IF (io < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (IO) NOT FOUND IN CODE SET 53")
    CALL pause(1)
   ENDIF
   IF (med < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (MED) NOT FOUND IN CODE SET 53")
    CALL pause(1)
   ENDIF
   IF (num < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (IVPARENT) NOT FOUND IN CODE SET 53")
    CALL pause(1)
   ENDIF
   IF (dcpgeneric=0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (DCPGENERIC) NOT FOUND IN CODE SET 72")
    CALL pause(1)
   ENDIF
   IF (ivparent < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (IVPARENT) NOT FOUND IN CODE SET 72")
    CALL pause(1)
   ENDIF
   IF (medintake=0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (MEDINTAKE) NOT FOUND IN CODE SET 72")
    CALL pause(1)
   ENDIF
   IF (pwrchart < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (POWERCHART) NOT FOUND IN CODE SET 73")
    CALL pause(1)
   ENDIF
   IF (powerchart < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (POWERCHART) NOT FOUND IN CODE SET 89")
    CALL pause(1)
   ENDIF
   IF (bolus < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (BOLUS) NOT FOUND IN CODE SET 180")
    CALL pause(1)
   ENDIF
   IF (infuse < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (INFUSE) NOT FOUND IN CODE SET 180")
    CALL pause(1)
   ENDIF
   IF (medadmin < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (MEDADMIN) NOT FOUND IN CODE SET 255431")
    CALL pause(1)
   ENDIF
   IF (confirmed < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (CONFIRMED) NOT FOUND IN CODE SET 4000160")
    CALL pause(1)
   ENDIF
   IF (ml < 0.0)
    SET not_failed_ind = false
    CALL text(08,05,"ERROR: CODE VALUE (ML) NOT FOUND")
    CALL pause(1)
   ENDIF
   IF (not_failed_ind=false)
    CALL text(10,05,"EXITING PROGRAM...")
   ENDIF
   RETURN(not_failed_ind)
 END ;Subroutine
#exit_program
 SET message = nowindow
 FREE RECORD temp
 FREE RECORD event_cds
 FREE RECORD res
 FREE RECORD num_io
 FREE RECORD med_io
 FREE RECORD iv_io
END GO
