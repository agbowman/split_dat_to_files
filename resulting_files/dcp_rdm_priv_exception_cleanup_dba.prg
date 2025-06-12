CREATE PROGRAM dcp_rdm_priv_exception_cleanup:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dcp_rdm_priv_exception_cleanup.prg..."
 FREE RECORD valid_event_set_name
 RECORD valid_event_set_name(
   1 qual[*]
     2 privilege_exception_id = f8
     2 privilege_id = f8
     2 exception_id = f8
     2 privilege_cd = f8
     2 privilege_value_cd = f8
     2 entity_name = vc
     2 person_id = f8
     2 ppr_cd = f8
     2 position_cd = f8
     2 exception_type_cd = f8
     2 event_set_name = vc
     2 dup_flag = i2
 )
 FREE RECORD export_priv_exception
 RECORD export_priv_exception(
   1 qual[*]
     2 privilege_exception_id = f8
     2 privilege_id = f8
     2 exception_id = f8
     2 privilege_cd = f8
     2 privilege_value_cd = f8
     2 new_privilege_value_cd = f8
     2 entity_name = vc
     2 person_id = f8
     2 ppr_cd = f8
     2 position_cd = f8
     2 exception_type_cd = f8
     2 event_set_name = vc
 )
 DECLARE findvalideventsetname(null) = null
 DECLARE insertvalidesntolongtext(null) = c1
 DECLARE updateexceptionidwithvalidcodevalue(null) = null
 DECLARE deleteexceptiontopreventduplicates(null) = null
 DECLARE findneardupeventsetname(null) = null
 DECLARE findinvalideventsetname(null) = null
 DECLARE insertdupinvtolongtext(category_number=i4) = c1
 DECLARE findemptyeventsetname(null) = null
 DECLARE findnoneventset(null) = null
 DECLARE findexceptionnoteventsetoreventcode(null) = null
 DECLARE findinvalidexceptiontypecd(null) = null
 DECLARE updateinvalidexceptiontypecd(null) = null
 DECLARE findinvalidentityname(null) = null
 DECLARE findprivilegewithoutexceptions(null) = null
 DECLARE updateprivilegewithoutexceptions(null) = null
 DECLARE createnewtextid(new_text_id=f8(ref)) = null
 DECLARE insertlongtext(new_text_id=f8(ref),long_text=vc,parent_entity_name=vc,parent_entity_id=i4)
  = null
 DECLARE inserttolongtext(category_number=i4) = c1
 DECLARE deleteprivexception(null) = null
 DECLARE row_count = i4 WITH noconstant(0), protect
 DECLARE line = vc WITH protect, noconstant
 DECLARE new_entry = vc WITH protect, noconstant
 DECLARE error_msg = vc WITH protect, noconstant
 DECLARE new_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_cd = f8 WITH protect, noconstant(0.0)
 DECLARE yes_priv_value_cd = f8 WITH protect, noconstant(0.0)
 DECLARE no_priv_value_cd = f8 WITH protect, noconstant(0.0)
 DECLARE yes_except_priv_value_cd = f8 WITH protect, noconstant(0.0)
 DECLARE no_except_priv_value_cd = f8 WITH protect, noconstant(0.0)
 DECLARE individual_type_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL findvalideventsetname(null)
 IF (insertvalidesntolongtext(null)="S")
  CALL updateexceptionidwithvalidcodevalue(null)
  CALL deleteexceptiontopreventduplicates(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertValidESNToLongText Category 1: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findneardupeventsetname(null)
 IF (insertdupinvtolongtext(2)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertDupInvToLongText Category 2: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findinvalideventsetname(null)
 IF (insertdupinvtolongtext(3)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertDupInvToLongText Category 3: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findemptyeventsetname(null)
 IF (inserttolongtext(4)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 4: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findnoneventset(null)
 IF (inserttolongtext(5)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 5: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findexceptionnoteventsetoreventcode(null)
 IF (inserttolongtext(6)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 6: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findinvalidexceptiontypecd(null)
 IF (inserttolongtext(7)="S")
  CALL updateinvalidexceptiontypecd(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 7: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findinvalidentityname(null)
 IF (inserttolongtext(8)="S")
  CALL deleteprivexception(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 8: ",error_msg)
  GO TO exit_script
 ENDIF
 CALL findprivilegewithoutexceptions(null)
 IF (inserttolongtext(9)="S")
  CALL updateprivilegewithoutexceptions(null)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("InsertToLongText Category 9: ",error_msg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dcp_rdm_priv_exception_cleanup performed all required tasks"
 GO TO exit_script
 SUBROUTINE findvalideventsetname(null)
   DECLARE number_valid_records = i4 WITH noconstant(0)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     code_value cv,
     privilege p,
     priv_loc_reltn plr
    PLAN (pe
     WHERE pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.exception_id <= 0
      AND pe.active_ind=1)
     JOIN (cv
     WHERE trim(cnvtupper(pe.event_set_name))=trim(cnvtupper(cv.display))
      AND cv.active_ind=1
      AND cv.code_set=93)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
    ORDER BY pe.privilege_exception_id
    HEAD pe.privilege_exception_id
     loop_counter = 0
    DETAIL
     loop_counter = (loop_counter+ 1)
    FOOT  pe.privilege_exception_id
     IF (loop_counter=1)
      number_valid_records = (number_valid_records+ 1)
      IF (mod(number_valid_records,50)=1)
       stat = alterlist(valid_event_set_name->qual,(number_valid_records+ 49))
      ENDIF
      valid_event_set_name->qual[number_valid_records].privilege_exception_id = pe
      .privilege_exception_id, valid_event_set_name->qual[number_valid_records].privilege_id = pe
      .privilege_id, valid_event_set_name->qual[number_valid_records].exception_id = cv.code_value,
      valid_event_set_name->qual[number_valid_records].privilege_cd = p.privilege_cd,
      valid_event_set_name->qual[number_valid_records].privilege_value_cd = p.priv_value_cd,
      valid_event_set_name->qual[number_valid_records].entity_name = pe.exception_entity_name,
      valid_event_set_name->qual[number_valid_records].person_id = plr.person_id,
      valid_event_set_name->qual[number_valid_records].ppr_cd = plr.ppr_cd, valid_event_set_name->
      qual[number_valid_records].position_cd = plr.position_cd,
      valid_event_set_name->qual[number_valid_records].exception_type_cd = pe.privilege_exception_id,
      valid_event_set_name->qual[number_valid_records].event_set_name = pe.event_set_name,
      valid_event_set_name->qual[number_valid_records].dup_flag = 0
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(valid_event_set_name->qual,number_valid_records)
   IF (number_valid_records > 0)
    SELECT INTO "NL:"
     FROM privilege_exception pe,
      (dummyt d  WITH seq = value(number_valid_records))
     PLAN (d)
      JOIN (pe
      WHERE (pe.exception_id=valid_event_set_name->qual[d.seq].exception_id)
       AND (pe.privilege_id=valid_event_set_name->qual[d.seq].privilege_id))
     DETAIL
      valid_event_set_name->qual[d.seq].dup_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindValidEventSetName: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertvalidesntolongtext(null)
   DECLARE priv_level_str = vc WITH protected, noconstant("")
   SET parent_entity_name = "PrivExceptionCleanup:Category1"
   SET record_size = value(size(valid_event_set_name->qual,5))
   IF (record_size > 0)
    SET line = build(
     "Privilege_exception_id,Privilege_id,Exception_id,Privilege_cd,Privilege_value_cd,Privilege_level,",
     "Exception_type_cd,Entity_name,Event_Set_Name",char(13))
    FOR (x = 1 TO record_size)
      IF ((valid_event_set_name->qual[x].dup_flag=1))
       SET priv_except_id_str = build(valid_event_set_name->qual[x].privilege_exception_id,", ")
       SET priv_id_str = build(valid_event_set_name->qual[x].privilege_id,", ")
       SET exception_id_str = build(valid_event_set_name->qual[x].exception_id,", ")
       SET priv_cd_str = build(valid_event_set_name->qual[x].privilege_cd,", ")
       SET priv_value_str = build(valid_event_set_name->qual[x].privilege_value_cd,", ")
       SET exception_type_cd_str = build(valid_event_set_name->qual[x].exception_type_cd,", ")
       IF ((valid_event_set_name->qual[x].person_id != 0))
        SET priv_level_str = build("PERSON -  ",valid_event_set_name->qual[x].person_id,", ")
       ELSEIF ((valid_event_set_name->qual[x].ppr_cd != 0))
        SET priv_level_str = build("PPR -  ",valid_event_set_name->qual[x].ppr_cd,", ")
       ELSEIF ((valid_event_set_name->qual[x].position_cd != 0))
        SET priv_level_str = build("POSITION -  ",valid_event_set_name->qual[x].position_cd,", ")
       ELSE
        SET priv_level_str = "NONE, "
       ENDIF
       SET new_entry = build(priv_except_id_str,priv_id_str,exception_id_str,priv_cd_str,
        priv_value_str,
        priv_level_str,exception_type_cd_str,valid_event_set_name->qual[x].entity_name,",",
        valid_event_set_name->qual[x].event_set_name,
        char(13))
       IF (((textlen(new_entry)+ textlen(line)) >= 524200))
        CALL createnewtextid(new_text_id)
        CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
        SET line = ""
       ENDIF
       SET line = build(line,new_entry)
      ENDIF
    ENDFOR
    CALL createnewtextid(new_text_id)
    CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
   ENDIF
   IF (error(error_msg,1) != 0)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE updateexceptionidwithvalidcodevalue(null)
  IF (value(size(valid_event_set_name->qual,5)) > 0)
   UPDATE  FROM privilege_exception pe,
     (dummyt d  WITH seq = value(size(valid_event_set_name->qual,5)))
    SET pe.exception_id = valid_event_set_name->qual[d.seq].exception_id, pe.event_set_name = "", pe
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_id = reqinfo->updt_id, pe.updt_task = 5004,
     pe.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (valid_event_set_name->qual[d.seq].dup_flag=0))
     JOIN (pe
     WHERE (pe.privilege_exception_id=valid_event_set_name->qual[d.seq].privilege_exception_id)
      AND pe.active_ind=1)
    WITH nocounter
   ;end update
  ENDIF
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("UpdateExceptionIdWithValidCodeValue: ",error_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteexceptiontopreventduplicates(null)
  IF (value(size(valid_event_set_name->qual,5)) > 0)
   DELETE  FROM privilege_exception pe,
     (dummyt d  WITH seq = value(size(valid_event_set_name->qual,5)))
    SET pe.seq = 1
    PLAN (d
     WHERE (valid_event_set_name->qual[d.seq].dup_flag=1))
     JOIN (pe
     WHERE (pe.privilege_exception_id=valid_event_set_name->qual[d.seq].privilege_exception_id))
    WITH nocounter
   ;end delete
  ENDIF
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("DeleteExceptionToPreventDuplicates: ",error_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE findneardupeventsetname(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM code_value cv1,
     privilege_exception pe
    PLAN (cv1
     WHERE  EXISTS (
     (SELECT
      "x"
      FROM code_value cv2
      WHERE trim(cnvtupper(cv1.display))=trim(cnvtupper(cv2.display))
       AND cv1.code_value != cv2.code_value
       AND cv1.code_set=93
       AND cv2.code_set=93
       AND cv1.active_ind=1
       AND cv2.active_ind=1)))
     JOIN (pe
     WHERE trim(cnvtupper(pe.event_set_name))=trim(cnvtupper(cv1.display))
      AND pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.exception_id <= 0
      AND pe.active_ind=1)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].event_set_name = pe.event_set_name
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindNearDupEventSetName: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE findinvalideventsetname(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe
    PLAN (pe
     WHERE pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.exception_id <= 0
      AND pe.active_ind=1
      AND  NOT (trim(pe.event_set_name) IN (null, ""))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM code_value cv
      WHERE trim(cnvtupper(cv.display))=trim(cnvtupper(pe.event_set_name))
       AND cv.code_set=93
       AND cv.active_ind=1))))
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].event_set_name = pe.event_set_name
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindInvalidEventSetName: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdupinvtolongtext(category_number)
   DECLARE priv_level_str = vc WITH protected, noconstant("")
   SET parent_entity_name = build("PrivExceptionCleanup:Category",category_number)
   SET record_size = value(size(export_priv_exception->qual,5))
   IF (record_size > 0)
    SET line = build("Event_Set_Name",char(13))
    FOR (x = 1 TO record_size)
      SET new_entry = build(export_priv_exception->qual[x].event_set_name,char(13))
      IF (((textlen(new_entry)+ textlen(line)) >= 524200))
       CALL createnewtextid(new_text_id)
       CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
       SET line = ""
      ENDIF
      SET line = build(line,new_entry)
    ENDFOR
    CALL createnewtextid(new_text_id)
    CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
   ENDIF
   IF (error(error_msg,1) != 0)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE findemptyeventsetname(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege p,
     privilege_exception pe,
     priv_loc_reltn plr
    PLAN (pe
     WHERE pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.exception_id <= 0
      AND pe.active_ind=1
      AND trim(pe.event_set_name)=null)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].privilege_id = pe.privilege_id, export_priv_exception
     ->qual[loop_counter].exception_id = pe.exception_id,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd, export_priv_exception->qual[
     loop_counter].person_id = plr.person_id,
     export_priv_exception->qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[
     loop_counter].position_cd = plr.position_cd, export_priv_exception->qual[loop_counter].
     entity_name = pe.exception_entity_name,
     export_priv_exception->qual[loop_counter].exception_type_cd = pe.exception_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindEmptyEventSetName: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE findnoneventset(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     privilege p,
     priv_loc_reltn plr
    PLAN (pe
     WHERE pe.exception_entity_name != "V500_EVENT_SET_CODE"
      AND pe.exception_id <= 0
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].privilege_id = pe.privilege_id, export_priv_exception
     ->qual[loop_counter].exception_id = pe.exception_id,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd, export_priv_exception->qual[
     loop_counter].person_id = plr.person_id,
     export_priv_exception->qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[
     loop_counter].position_cd = plr.position_cd, export_priv_exception->qual[loop_counter].
     entity_name = pe.exception_entity_name,
     export_priv_exception->qual[loop_counter].exception_type_cd = pe.exception_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindNonEventSet: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE findexceptionnoteventsetoreventcode(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     privilege p,
     priv_loc_reltn plr,
     code_value cv
    PLAN (pe
     WHERE pe.exception_entity_name != "V500_EVENT_SET_CODE"
      AND pe.exception_entity_name != "V500_EVENT_CODE"
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
     JOIN (cv
     WHERE cv.code_set=6016
      AND cv.cdf_meaning IN ("ADDDOC", "DOCSECTVIEW", "MODIFYDOC", "VIEWRSLTS", "SIGNDOC",
     "UNCHARTDOC")
      AND p.privilege_cd=cv.code_value)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].privilege_id = pe.privilege_id, export_priv_exception
     ->qual[loop_counter].exception_id = pe.exception_id,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd, export_priv_exception->qual[
     loop_counter].person_id = plr.person_id,
     export_priv_exception->qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[
     loop_counter].position_cd = plr.position_cd, export_priv_exception->qual[loop_counter].
     entity_name = pe.exception_entity_name,
     export_priv_exception->qual[loop_counter].exception_type_cd = pe.exception_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindExceptionNotEventSetOrEventCode: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE findinvalidexceptiontypecd(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     privilege p,
     priv_loc_reltn plr
    PLAN (pe
     WHERE pe.exception_type_cd <= 0
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].privilege_id = pe.privilege_id, export_priv_exception
     ->qual[loop_counter].exception_id = pe.exception_id,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd, export_priv_exception->qual[
     loop_counter].person_id = plr.person_id,
     export_priv_exception->qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[
     loop_counter].position_cd = plr.position_cd, export_priv_exception->qual[loop_counter].
     entity_name = pe.exception_entity_name,
     export_priv_exception->qual[loop_counter].exception_type_cd = pe.exception_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindInvalidExceptionTypeCd: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinvalidexceptiontypecd(null)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=6019
     AND cv.cdf_meaning="INDIVIDUAL"
    DETAIL
     individual_type_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (value(size(export_priv_exception->qual,5)) > 0)
    UPDATE  FROM privilege_exception pe,
      (dummyt d  WITH seq = value(size(export_priv_exception->qual,5)))
     SET pe.exception_type_cd = individual_type_cd, pe.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pe.updt_cnt = (pe.updt_cnt+ 1),
      pe.updt_id = reqinfo->updt_id, pe.updt_task = 5004, pe.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (export_priv_exception->qual[d.seq].exception_type_cd=0))
      JOIN (pe
      WHERE (pe.privilege_exception_id=export_priv_exception->qual[d.seq].privilege_exception_id)
       AND pe.active_ind=1)
     WITH nocounter
    ;end update
   ENDIF
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("UpdateInvalidExceptionTypeCd: ",error_msg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE findinvalidentityname(null)
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     privilege p,
     priv_loc_reltn plr
    PLAN (pe
     WHERE ((trim(pe.exception_entity_name)="") OR (pe.exception_entity_name=null))
      AND pe.active_ind=1)
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = pe.privilege_exception_id,
     export_priv_exception->qual[loop_counter].privilege_id = pe.privilege_id, export_priv_exception
     ->qual[loop_counter].exception_id = pe.exception_id,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd, export_priv_exception->qual[
     loop_counter].person_id = plr.person_id,
     export_priv_exception->qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[
     loop_counter].position_cd = plr.position_cd, export_priv_exception->qual[loop_counter].
     entity_name = pe.exception_entity_name,
     export_priv_exception->qual[loop_counter].exception_type_cd = pe.exception_type_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindInvalidEntityName: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE findprivilegewithoutexceptions(null)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=6017
     AND cv.cdf_meaning IN ("NO", "INCLUDE", "YES", "EXCLUDE")
     AND cv.active_ind=1
    DETAIL
     IF (cv.cdf_meaning="NO")
      no_priv_value_cd = cv.code_value
     ELSEIF (cv.cdf_meaning="INCLUDE")
      no_except_priv_value_cd = cv.code_value
     ELSEIF (cv.cdf_meaning="YES")
      yes_priv_value_cd = cv.code_value
     ELSEIF (cv.cdf_meaning="EXCLUDE")
      yes_except_priv_value_cd = cv.code_value
     ENDIF
    WITH nocounter
   ;end select
   SET stat = initrec(export_priv_exception)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM privilege p,
     priv_loc_reltn plr
    PLAN (p
     WHERE p.priv_value_cd IN (
     (SELECT
      code_value
      FROM code_value
      WHERE code_set=6017
       AND ((cdf_meaning="INCLUDE") OR (cdf_meaning="EXCLUDE"))
       AND active_ind=1))
      AND  NOT (p.privilege_id IN (
     (SELECT
      pe1.privilege_id
      FROM privilege_exception pe1
      WHERE pe1.active_ind=1)))
      AND p.active_ind=1)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,50)=1)
      stat = alterlist(export_priv_exception->qual,(loop_counter+ 49))
     ENDIF
     export_priv_exception->qual[loop_counter].privilege_exception_id = 0, export_priv_exception->
     qual[loop_counter].privilege_id = p.privilege_id, export_priv_exception->qual[loop_counter].
     exception_id = 0,
     export_priv_exception->qual[loop_counter].privilege_cd = p.privilege_cd, export_priv_exception->
     qual[loop_counter].privilege_value_cd = p.priv_value_cd
     IF ((export_priv_exception->qual[loop_counter].privilege_value_cd=no_except_priv_value_cd))
      export_priv_exception->qual[loop_counter].new_privilege_value_cd = no_priv_value_cd
     ELSEIF ((export_priv_exception->qual[loop_counter].privilege_value_cd=yes_except_priv_value_cd))
      export_priv_exception->qual[loop_counter].new_privilege_value_cd = yes_priv_value_cd
     ENDIF
     export_priv_exception->qual[loop_counter].person_id = plr.person_id, export_priv_exception->
     qual[loop_counter].ppr_cd = plr.ppr_cd, export_priv_exception->qual[loop_counter].position_cd =
     plr.position_cd,
     export_priv_exception->qual[loop_counter].entity_name = "", export_priv_exception->qual[
     loop_counter].exception_type_cd = 0
    WITH nocounter
   ;end select
   SET stat = alterlist(export_priv_exception->qual,loop_counter)
   IF (error(error_msg,1) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("FindPrivilegeWithoutExceptions: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updateprivilegewithoutexceptions(null)
  IF (value(size(export_priv_exception->qual,5)) > 0)
   UPDATE  FROM privilege p,
     (dummyt d  WITH seq = value(size(export_priv_exception->qual,5)))
    SET p.priv_value_cd = export_priv_exception->qual[d.seq].new_privilege_value_cd, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_id = reqinfo->updt_id, p.updt_task = 5004, p.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (export_priv_exception->qual[d.seq].new_privilege_value_cd != 0))
     JOIN (p
     WHERE (p.privilege_id=export_priv_exception->qual[d.seq].privilege_id)
      AND p.active_ind=1)
    WITH nocounter
   ;end update
  ENDIF
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("UpdatePrivilegeWithoutExceptions: ",error_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE createnewtextid(new_text_id)
   SET new_text_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_text_id = nextseqnum
    WITH nocounter
   ;end select
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET new_text_id = 0.0
    SET readme_data->status = "F"
    SET readme_data->message = concat("CreateNewTextId: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttolongtext(category_number)
   DECLARE priv_level_str = vc WITH protected, noconstant("")
   SET parent_entity_name = build("PrivExceptionCleanup:Category",category_number)
   SET record_size = value(size(export_priv_exception->qual,5))
   IF (record_size > 0)
    SET line = build(
     "Privilege_exception_id,Privilege_id,Exception_id,Privilege_cd,Privilege_value_cd,Privilege_level,",
     "Exception_type_cd,Entity_name,Event_Set_Name",char(13))
    FOR (x = 1 TO record_size)
      SET priv_except_id_str = build(export_priv_exception->qual[x].privilege_exception_id,", ")
      SET priv_id_str = build(export_priv_exception->qual[x].privilege_id,", ")
      SET exception_id_str = build(export_priv_exception->qual[x].exception_id,", ")
      SET priv_cd_str = build(export_priv_exception->qual[x].privilege_cd,", ")
      SET priv_value_str = build(export_priv_exception->qual[x].privilege_value_cd,", ")
      SET exception_type_cd_str = build(export_priv_exception->qual[x].exception_type_cd,", ")
      IF ((export_priv_exception->qual[x].person_id != 0))
       SET priv_level_str = build("PERSON -  ",export_priv_exception->qual[x].person_id,", ")
      ELSEIF ((export_priv_exception->qual[x].ppr_cd != 0))
       SET priv_level_str = build("PPR -  ",export_priv_exception->qual[x].ppr_cd,", ")
      ELSEIF ((export_priv_exception->qual[x].position_cd != 0))
       SET priv_level_str = build("POSITION -  ",export_priv_exception->qual[x].position_cd,", ")
      ELSE
       SET priv_level_str = "NONE, "
      ENDIF
      SET new_entry = build(priv_except_id_str,priv_id_str,exception_id_str,priv_cd_str,
       priv_value_str,
       priv_level_str,exception_type_cd_str,export_priv_exception->qual[x].entity_name,",",
       export_priv_exception->qual[x].event_set_name,
       char(13))
      IF (((textlen(new_entry)+ textlen(line)) >= 524200))
       CALL createnewtextid(new_text_id)
       CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
       SET line = ""
      ENDIF
      SET line = build(line,new_entry)
    ENDFOR
    CALL createnewtextid(new_text_id)
    CALL insertlongtext(new_text_id,line,parent_entity_name,5004)
   ENDIF
   IF (error(error_msg,1) != 0)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE insertlongtext(new_text_id,long_text,parent_entity_name,parent_entity_id)
  INSERT  FROM long_text lt
   SET lt.long_text_id = new_text_id, lt.long_text = long_text, lt.parent_entity_id =
    parent_entity_id,
    lt.parent_entity_name = parent_entity_name, lt.active_ind = 1, lt.active_status_cd = active_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_cnt = 0,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
    5004,
    lt.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("InsertLongText: ",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteprivexception(null)
  IF (value(size(export_priv_exception->qual,5)) > 0)
   DELETE  FROM privilege_exception pe,
     (dummyt d  WITH seq = value(size(export_priv_exception->qual,5)))
    SET pe.seq = 1
    PLAN (d)
     JOIN (pe
     WHERE (pe.privilege_exception_id=export_priv_exception->qual[d.seq].privilege_exception_id))
    WITH nocounter
   ;end delete
  ENDIF
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("DeletePrivException: ",error_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD valid_event_set_name
 FREE RECORD export_priv_exception
 CALL echorecord(readme_data)
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
END GO
