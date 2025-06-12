CREATE PROGRAM acm_chg_entity_updt:dba
 CALL echo("*****acm_chg_entity_updt.prg - 778358*****")
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
 SET failed = false
 SET acm_chg_entity_updt_reply->status_data.status = "F"
 DECLARE nbr_entity_entries = i4 WITH private, noconstant(0)
 DECLARE nbr_entries = i4 WITH private, noconstant(0)
 DECLARE total_nbr_entries = i4 WITH private, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET nbr_entity_entries = acm_chg_entity_updt_request->entity_type_cnt
 IF (nbr_entity_entries <= 0)
  SET failed = true
  EXECUTE sch_msgview acm_chg_entity_updt_request->curprog, nullterm(build(
    "NONE_FOUND,F,ACM_CHG_ENTITY_UPDT")), 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(acm_chg_entity_updt_reply->entity_type_qual,nbr_entity_entries)
 FOR (idx = 1 TO nbr_entity_entries)
   SET nbr_entries = acm_chg_entity_updt_request->entity_type_qual[idx].entity_id_cnt
   IF (nbr_entries > 0)
    SET stat = alterlist(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual,nbr_entries)
    SET acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_cnt = nbr_entries
    SET acm_chg_entity_updt_reply->entity_type_qual[idx].entity_type = acm_chg_entity_updt_request->
    entity_type_qual[idx].entity_type
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(nbr_entries))
     PLAN (d)
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].entity_id =
      acm_chg_entity_updt_request->entity_type_qual[idx].entity_id_qual[d.seq].entity_id,
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = false
     WITH nocounter
    ;end select
   ENDIF
   SET total_nbr_entries += nbr_entries
 ENDFOR
 IF (total_nbr_entries <= 0)
  SET failed = true
  EXECUTE sch_msgview acm_chg_entity_updt_request->curprog, nullterm(build(
    "NONE_FOUND,F,ACM_CHG_ENTITY_UPDT")), 1
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO nbr_entity_entries)
   IF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="PERSON"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      person e
     PLAN (d)
      JOIN (e
      WHERE (e.person_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="ORGANIZATION"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      organization e
     PLAN (d)
      JOIN (e
      WHERE (e.organization_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq]
      .entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="LOCATION"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      location e
     PLAN (d)
      JOIN (e
      WHERE (e.location_cd=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="PRSNL_GROUP"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      prsnl_group e
     PLAN (d)
      JOIN (e
      WHERE (e.prsnl_group_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="PRSNL"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      prsnl e
     PLAN (d)
      JOIN (e
      WHERE (e.person_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="SCH_RESOURCE"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      sch_resource e
     PLAN (d)
      JOIN (e
      WHERE (e.resource_cd=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ELSEIF ((acm_chg_entity_updt_request->entity_type_qual[idx].entity_type="ENCOUNTER"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
       entity_id_cnt)),
      encounter e
     PLAN (d)
      JOIN (e
      WHERE (e.encntr_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
      entity_id))
     DETAIL
      acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status = true
     WITH nocounter, forupdatewait(e), time = 5
    ;end select
   ENDIF
   IF (curqual <= 0)
    SET failed = true
    EXECUTE sch_msgview acm_chg_entity_updt_request->curprog, nullterm(build(
      "SELECT,F,ACM_CHG_ENTITY_UPDT,",acm_chg_entity_updt_request->entity_type_qual[idx].entity_type)
     ), 1
   ENDIF
   CASE (acm_chg_entity_updt_request->entity_type_qual[idx].entity_type)
    OF "PERSON":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       person e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1), e.updt_id = reqinfo->
       updt_id
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.person_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "ORGANIZATION":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       organization e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.organization_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq
       ].entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "LOCATION":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       location e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.location_cd=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "PRSNL_GROUP":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       prsnl_group e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.prsnl_group_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq]
       .entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "PRSNL":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       prsnl e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.person_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "SCH_RESOURCE":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       sch_resource e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.resource_cd=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
    OF "ENCOUNTER":
     UPDATE  FROM (dummyt d  WITH seq = value(acm_chg_entity_updt_request->entity_type_qual[idx].
        entity_id_cnt)),
       encounter e
      SET e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_cnt = (e.updt_cnt+ 1)
      PLAN (d
       WHERE (acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].status=true))
       JOIN (e
       WHERE (e.encntr_id=acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       entity_id))
      WITH nocounter, status(acm_chg_entity_updt_reply->entity_type_qual[idx].entity_id_qual[d.seq].
       status)
     ;end update
   ENDCASE
   IF (curqual <= 0)
    SET failed = true
    EXECUTE sch_msgview acm_chg_entity_updt_request->curprog, nullterm(build(
      "UPDATE,F,ACM_CHG_ENTITY_UPDT,",acm_chg_entity_updt_request->entity_type_qual[idx].entity_type)
     ), 1
   ENDIF
 ENDFOR
#exit_script
 IF (failed=false)
  SET acm_chg_entity_updt_reply->status_data.status = "S"
 ELSE
  SET acm_chg_entity_updt_reply->status_data.status = "F"
 ENDIF
END GO
