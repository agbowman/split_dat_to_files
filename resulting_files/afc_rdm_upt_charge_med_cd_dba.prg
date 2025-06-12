CREATE PROGRAM afc_rdm_upt_charge_med_cd:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "ReadMe Failed"
 FREE RECORD encounterdetails
 RECORD encounterdetails(
   1 encntrlist[*]
     2 encntrid = f8
     2 encountermedservicecd = f8
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE encntrcnt = i4 WITH protect, noconstant(0)
 DECLARE encntrcntshadowtbl = i4 WITH protect, noconstant(0)
 DECLARE getencounterdetails(null) = null
 DECLARE updatechargemedservicecd(null) = null
 DECLARE setshadowtabledetails(null) = null
 IF ( NOT (getencounterdetails(null)))
  SET readme_data->message = concat("Failed to select rows which needs to be updated ",errmsg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 IF ( NOT (updatechargemedservicecd(null)))
  SET readme_data->message = concat("Failed to update the charge med_service_cd.",errmsg)
  SET readme_data->status = "F"
 ENDIF
 IF ( NOT (setshadowtabledetails(null)))
  SET readme_data->message = concat("Failed to update rows in the shadow table.",errmsg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SUBROUTINE getencounterdetails(null)
   SELECT INTO "nl:"
    FROM charge c,
     encounter e,
     pft_encntr pe,
     code_value cv
    PLAN (c
     WHERE c.med_service_cd=0.0
      AND c.active_ind=true)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id
      AND e.med_service_cd != c.med_service_cd
      AND e.active_ind=true)
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=pe.pft_encntr_status_cd
      AND cv.cdf_meaning != "HISTORY")
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     encntrcnt += 1
     IF (mod(encntrcnt,10)=1)
      stat = alterlist(encounterdetails->encntrlist,(encntrcnt+ 9))
     ENDIF
     encounterdetails->encntrlist[encntrcnt].encntrid = e.encntr_id, encounterdetails->encntrlist[
     encntrcnt].encountermedservicecd = e.med_service_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(encounterdetails->encntrlist,encntrcnt)
   IF (error(errmsg,0) > 0)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE updatechargemedservicecd(null)
   IF (size(encounterdetails->encntrlist,5) > 0)
    UPDATE  FROM charge c,
      (dummyt d  WITH seq = value(size(encounterdetails->encntrlist,5)))
     SET c.med_service_cd = encounterdetails->encntrlist[d.seq].encountermedservicecd, c.updt_cnt = (
      c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate),
      c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (c
      WHERE (c.encntr_id=encounterdetails->encntrlist[d.seq].encntrid)
       AND c.med_service_cd=0.0)
    ;end update
    IF (error(errmsg,0) > 0)
     RETURN(false)
    ENDIF
    RETURN(true)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE setshadowtabledetails(null)
   SET stat = alterlist(drr_validate_table->list,3)
   SET drr_validate_table->list[1].table_name = "ENCOUNTER0077DRR"
   SET drr_validate_table->list[2].table_name = "CHARGE1156DRR"
   SET drr_validate_table->list[3].table_name = "PFT_ENCNTR5467DRR"
   SET drr_shadow_cnt = drr_table_and_ccldef_exists(null)
   IF (drr_shadow_cnt != 0
    AND drr_shadow_cnt != 3)
    SET readme_data->status = "F"
    SET readme_data->message = drr_validate_table->msg_returned
    GO TO exit_script
   ELSEIF (drr_shadow_cnt=0)
    SET readme_data->status = "S"
    SET readme_data->message = drr_validate_table->msg_returned
    GO TO exit_script
   ENDIF
   FREE RECORD encounterdetailsforshadow
   RECORD encounterdetailsforshadow(
     1 encntrlist[*]
       2 encntrid = f8
       2 encountermedservicecd = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM charge1156drr c,
     encounter0077drr e,
     pft_encntr5467drr pe,
     code_value cv
    PLAN (c
     WHERE c.med_service_cd=0.0
      AND c.active_ind=true)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id
      AND e.med_service_cd != c.med_service_cd
      AND e.active_ind=true)
     JOIN (pe
     WHERE pe.encntr_id=e.encntr_id
      AND pe.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=pe.pft_encntr_status_cd
      AND cv.cdf_meaning != "HISTORY")
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     encntrcntshadowtbl += 1
     IF (mod(encntrcntshadowtbl,10)=1)
      stat = alterlist(encounterdetailsforshadow->encntrlist,(encntrcntshadowtbl+ 9))
     ENDIF
     encounterdetailsforshadow->encntrlist[encntrcntshadowtbl].encntrid = e.encntr_id,
     encounterdetailsforshadow->encntrlist[encntrcntshadowtbl].encountermedservicecd = e
     .med_service_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(encounterdetailsforshadow->encntrlist,encntrcntshadowtbl)
   IF (error(errmsg,0) > 0)
    SET readme_data->message = concat("Failed to select rows from shadow table.",errmsg)
    SET readme_data->status = "F"
    GO TO exit_script
   ENDIF
   IF (size(encounterdetailsforshadow->encntrlist,5) > 0)
    UPDATE  FROM charge1156drr c,
      (dummyt d  WITH seq = value(size(encounterdetailsforshadow->encntrlist,5)))
     SET c.med_service_cd = encounterdetailsforshadow->encntrlist[d.seq].encountermedservicecd, c
      .updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(sysdate),
      c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (c
      WHERE (c.encntr_id=encounterdetailsforshadow->encntrlist[d.seq].encntrid)
       AND c.med_service_cd=0.0)
    ;end update
    IF (error(errmsg,0) > 0)
     RETURN(false)
    ENDIF
    RETURN(true)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 IF ((readme_data->status != "S"))
  CALL echo("Charge table update Unsuccessful.")
  ROLLBACK
 ELSE
  CALL echo("readme_data->Charge tbl update Successful.")
  COMMIT
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
