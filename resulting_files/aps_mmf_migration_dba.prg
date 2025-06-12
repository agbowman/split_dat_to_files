CREATE PROGRAM aps_mmf_migration:dba
 SET logical apsdicomrtl "cer_exe:apsdicomrtl.exe"
 SET modify = nopredeclare
 EXECUTE gm_dm_info2388_def "U"
 DECLARE gm_u_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_dm_info2388_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_dm_info2388_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_number":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_numberf = 2
     ELSE
      SET gm_u_dm_info2388_req->info_numberf = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_number = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_numberw = 1
     ENDIF
    OF "info_long_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_long_idf = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_long_id = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_long_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->updt_cntf = 1
     SET gm_u_dm_info2388_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_date":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_datef = 2
     ELSE
      SET gm_u_dm_info2388_req->info_datef = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_datew = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->updt_dt_tmf = 1
     SET gm_u_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->updt_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_dm_info2388_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_domainf = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_domain = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_domainw = 1
     ENDIF
    OF "info_name":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_dm_info2388_req->info_namef = 1
     SET gm_u_dm_info2388_req->qual[iqual].info_name = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_namew = 1
     ENDIF
    OF "info_char":
     IF (null_ind=1)
      SET gm_u_dm_info2388_req->info_charf = 2
     ELSE
      SET gm_u_dm_info2388_req->info_charf = 1
     ENDIF
     SET gm_u_dm_info2388_req->qual[iqual].info_char = ival
     IF (wq_ind=1)
      SET gm_u_dm_info2388_req->info_charw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_dm_info2388_def "I"
 DECLARE gm_i_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 DECLARE gm_i_dm_info2388_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_dm_info2388_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_number":
     SET gm_i_dm_info2388_req->qual[iqual].info_number = ival
     SET gm_i_dm_info2388_req->info_numberi = 1
    OF "info_long_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_long_id = ival
     SET gm_i_dm_info2388_req->info_long_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_dm_info2388_dq8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_date":
     SET gm_i_dm_info2388_req->qual[iqual].info_date = cnvtdatetime(ival)
     SET gm_i_dm_info2388_req->info_datei = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_dm_info2388_req->updt_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_i_dm_info2388_vc(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_domain = ival
     SET gm_i_dm_info2388_req->info_domaini = 1
    OF "info_name":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_dm_info2388_req->qual[iqual].info_name = ival
     SET gm_i_dm_info2388_req->info_namei = 1
    OF "info_char":
     SET gm_i_dm_info2388_req->qual[iqual].info_char = ival
     SET gm_i_dm_info2388_req->info_chari = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 EXECUTE aps_mmf_migration_common:dba
 SET modify = predeclare
 FREE SET mig_status
 RECORD mig_status(
   1 phase = i2
   1 phase_id = f8
   1 entity = i2
   1 entity_id = f8
   1 error_msg = vc
   1 dicom_handle = i4
   1 failure_cnt = i4
   1 failures[*]
     2 failed_entity = i2
     2 failed_entity_id = f8
   1 consec_failure_cnt = i4
 )
 RECORD aps_mmf_migrate_entity_req(
   1 dicom_handle = i4
   1 case_id = f8
   1 discrete_entity_id = f8
   1 update_references_ind = i2
 )
 RECORD aps_mmf_migrate_entity_rep(
   1 dicom_handle = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nphasestart = i2 WITH protect, constant(0)
 DECLARE nphasecbr = i2 WITH protect, constant(1)
 DECLARE nphaserdi = i2 WITH protect, constant(2)
 DECLARE nphasediscrete = i2 WITH protect, constant(3)
 DECLARE nphaseexception = i2 WITH protect, constant(4)
 DECLARE nphaseend = i2 WITH protect, constant(5)
 DECLARE nentitycase = i2 WITH protect, constant(1)
 DECLARE nentitydiscrete = i2 WITH protect, constant(2)
 DECLARE dqstart = dq8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE ldicomhandle = i4 WITH protect, noconstant(0)
 DECLARE lmaxerrors = i4 WITH protect, noconstant(2000)
 DECLARE lmaxconsecutiveerrors = i4 WITH protect, noconstant(200)
 DECLARE nfatalerror = i2 WITH protect, noconstant(0)
 DECLARE nexitind = i2 WITH protect, noconstant(0)
 DECLARE ndebugind = i2 WITH protect, noconstant(0)
 DECLARE lmaxruntimeseconds = i4 WITH protect, noconstant(0)
 DECLARE lruntimeseconds = i4 WITH protect, noconstant(0)
 DECLARE ldmy = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE nresult = i2 WITH protect, noconstant(0)
 DECLARE stmpaccn = c21 WITH protect, noconstant("                     ")
 DECLARE sblankaccn = c21 WITH protect, constant("                     ")
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 DECLARE ddicomstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcachestoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE sinfodomain = vc WITH protect, constant("ANATOMIC PATHOLOGY")
 DECLARE sinfostatusrow = vc WITH protect, constant("MMF MIGRATION STATUS")
 DECLARE sinfosettingmaxerror = vc WITH protect, constant("MMF MIGRATE MAX ERR")
 DECLARE sinfosettingmaxconsecerror = vc WITH protect, constant("MMF MIGRATE MAX CONSEC")
 DECLARE sphasecbr = vc WITH protect, constant("CE_BLOB_RESULT")
 DECLARE sphaserdi = vc WITH protect, constant("REPORT_DETAIL_IMAGE")
 DECLARE sphasediscrete = vc WITH protect, constant("AP_DISCRETE_ENTITY")
 DECLARE sphaseexception = vc WITH protect, constant("EXCEPTION")
 DECLARE sphaseend = vc WITH protect, constant("COMPLETE")
 DECLARE sphasestart = vc WITH protect, constant("START")
 DECLARE getlastphase(null) = null WITH private
 DECLARE updatelastphase(null) = null WITH private
 DECLARE determinenextphase(null) = null WITH private
 DECLARE migrateoneentity(null) = i2 WITH private
 DECLARE markfailure(null) = null WITH private
 DECLARE marksuccess(null) = null WITH private
 SET lstat = uar_get_meaning_by_codeset(25,"DICOM_SIUID",1,ddicomstoragecd)
 IF (ddicomstoragecd=0)
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(25,"IMGCACHE",1,dcachestoragecd)
 IF (dcachestoragecd=0)
  GO TO exit_script
 ENDIF
 SET ldmy = 0
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain=sinfodomain
   AND d.info_name=sinfosettingmaxerror
  DETAIL
   ldmy = cnvtint(d.info_number)
  WITH nocounter
 ;end select
 IF (ldmy > 0)
  SET lmaxerrors = ldmy
 ENDIF
 SET ldmy = 0
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain=sinfodomain
   AND d.info_name=sinfosettingmaxconsecerror
  DETAIL
   ldmy = cnvtint(d.info_number)
  WITH nocounter
 ;end select
 IF (ldmy > 0)
  SET lmaxconsecutiveerrors = ldmy
 ENDIF
 IF (substring(1,1,reflect(parameter(1,0)))="I")
  SET lmaxruntimeseconds = parameter(1,0)
 ELSE
  SET lmaxruntimeseconds = - (1)
 ENDIF
 IF (substring(1,1,reflect(parameter(2,0)))="I")
  SET ldmy = parameter(2,0)
  IF (ldmy != 0)
   SET ndebugind = 1
  ENDIF
 ENDIF
 SET mig_status->phase = nphasestart
 SET mig_status->phase_id = 0.0
 CALL getlastphase(null)
 CALL echo(build("Error Threshold:",lmaxerrors))
 CALL echo(build("Consecutive Error Threshold:",lmaxconsecutiveerrors))
 CALL echo(build("Max Run Time (seconds):",lmaxruntimeseconds))
 CALL echo(build("Debug Mode:",ndebugind))
 CALL echorecord(mig_status)
 CALL echo("========= Starting Migration =========")
 IF (lmaxruntimeseconds <= 0)
  CALL echo("ERROR: Max Run Time not specified")
  GO TO exit_script
 ENDIF
 WHILE (nexitind=0)
   CALL determinenextphase(null)
   IF (ndebugind != 0)
    CALL echo(build("Migrate P:",mig_status->phase,",PID:",mig_status->phase_id,",E:",
      mig_status->entity,",EID:",mig_status->entity_id))
   ENDIF
   IF ((mig_status->entity_id > 0.0))
    SET nresult = migrateoneentity(null)
    IF (nresult=1)
     CALL marksuccess(null)
     SET mig_status->consec_failure_cnt = 0
    ELSE
     CALL markfailure(null)
    ENDIF
    IF (nfatalerror=0)
     CALL updatelastphase(null)
    ENDIF
   ENDIF
   IF ((mig_status->phase=nphaseend))
    SET nexitind = 1
   ENDIF
   IF (nfatalerror != 0)
    SET nexitind = 1
   ENDIF
   IF ((mig_status->failure_cnt > lmaxerrors))
    SET nexitind = 1
   ENDIF
   IF ((mig_status->consec_failure_cnt > lmaxconsecutiveerrors))
    SET nexitind = 1
   ENDIF
   SET lruntimeseconds = datetimediff(cnvtdatetime(curdate,curtime3),dqstart,5)
   IF (lruntimeseconds > lmaxruntimeseconds)
    SET nexitind = 1
   ENDIF
 ENDWHILE
 IF (nfatalerror=0)
  CALL updatelastphase(null)
 ENDIF
 GO TO exit_script
 SUBROUTINE determinenextphase(null)
   DECLARE bdone = i2 WITH protect, noconstant(0)
   DECLARE nphase = i2 WITH protect, noconstant(0)
   DECLARE did = f8 WITH protect, noconstant(0.0)
   SET nphase = mig_status->phase
   SET did = mig_status->phase_id
   IF (nphase=nphasestart)
    SET nphase = nphasecbr
    SET did = 0.0
   ENDIF
   IF (nphase=nphasecbr)
    SELECT INTO "nl:"
     next_event = min(cbr.event_id)
     FROM ce_blob_result cbr
     PLAN (cbr
      WHERE cbr.event_id > did
       AND cbr.storage_cd IN (ddicomstoragecd, dcachestoragecd))
     DETAIL
      IF (next_event > 0.0)
       mig_status->phase = nphasecbr, mig_status->phase_id = next_event, mig_status->entity =
       nentitycase,
       mig_status->entity_id = 0.0, bdone = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (bdone=1)
     SET stmpaccn = sblankaccn
     SELECT INTO "nl:"
      ce.accession_nbr
      FROM clinical_event ce
      WHERE (ce.event_id=mig_status->phase_id)
      DETAIL
       stmpaccn = ce.accession_nbr
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      pc.case_id
      FROM pathology_case pc
      PLAN (pc
       WHERE pc.accession_nbr=stmpaccn
        AND pc.case_id != 0.0
        AND ((pc.cancel_cd = null) OR (pc.cancel_cd=0.0)) )
      DETAIL
       mig_status->entity_id = pc.case_id
      WITH nocounter
     ;end select
    ELSE
     SET nphase = nphaserdi
     SET did = 0.0
    ENDIF
   ENDIF
   IF (nphase=nphaserdi
    AND bdone=0)
    SELECT INTO "nl:"
     next_rdi = min(br.parent_entity_id)
     FROM blob_reference br
     PLAN (br
      WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
       AND br.parent_entity_id > did
       AND br.storage_cd IN (ddicomstoragecd, dcachestoragecd))
     DETAIL
      IF (next_rdi > 0.0)
       mig_status->phase = nphaserdi, mig_status->phase_id = next_rdi, mig_status->entity =
       nentitycase,
       mig_status->entity_id = 0.0, bdone = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (bdone=1)
     SELECT INTO "nl:"
      cr.case_id
      FROM report_detail_image rdi,
       case_report cr
      PLAN (rdi
       WHERE (rdi.report_detail_id=mig_status->phase_id))
       JOIN (cr
       WHERE cr.report_id=rdi.report_id)
      DETAIL
       mig_status->entity_id = cr.case_id
      WITH nocounter
     ;end select
    ELSE
     SET nphase = nphasediscrete
     SET did = 0.0
    ENDIF
   ENDIF
   IF (nphase=nphasediscrete
    AND bdone=0)
    SELECT INTO "nl:"
     next_id = min(br.parent_entity_id)
     FROM blob_reference br
     PLAN (br
      WHERE br.parent_entity_name="AP_DISCRETE_ENTITY"
       AND br.parent_entity_id > did
       AND br.storage_cd IN (ddicomstoragecd, dcachestoragecd))
     DETAIL
      IF (next_id > 0.0)
       mig_status->phase = nphasediscrete, mig_status->phase_id = next_id, mig_status->entity =
       nentitydiscrete,
       mig_status->entity_id = next_id, bdone = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (bdone=0)
     SET nphase = nphaseexception
     SET did = 0.0
    ENDIF
   ENDIF
   IF (nphase=nphaseexception
    AND bdone=0)
    SET mig_status->phase_id = 0.0
    SELECT INTO "nl:"
     next_id = min(aimx.ap_img_migration_xcptn_id)
     FROM ap_img_migration_xcptn aimx
     PLAN (aimx
      WHERE aimx.ap_img_migration_xcptn_id > did)
     DETAIL
      mig_status->phase = nphaseexception, mig_status->phase_id = next_id
     WITH nocounter
    ;end select
    IF ((mig_status->phase_id > 0.0))
     SELECT INTO "nl:"
      FROM ap_img_migration_xcptn aimx
      PLAN (aimx
       WHERE (aimx.ap_img_migration_xcptn_id=mig_status->phase_id))
      DETAIL
       mig_status->entity = evaluate(aimx.parent_entity_name,"PATHOLOGY_CASE",nentitycase,
        "AP_DISCRETE_ENTITY",nentitydiscrete), mig_status->entity_id = aimx.parent_entity_id, bdone
        = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (bdone=0)
    SET mig_status->phase = nphaseend
    SET mig_status->phase_id = 0.0
    SET mig_status->entity = 0
    SET mig_status->entity_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE migrateoneentity(null)
   DECLARE nresult = i2 WITH protect, noconstant(0)
   SET aps_mmf_migrate_entity_req->dicom_handle = mig_status->dicom_handle
   IF ((mig_status->entity=nentitycase))
    SET aps_mmf_migrate_entity_req->case_id = mig_status->entity_id
    SET aps_mmf_migrate_entity_req->discrete_entity_id = 0.0
   ELSE
    SET aps_mmf_migrate_entity_req->case_id = 0.0
    SET aps_mmf_migrate_entity_req->discrete_entity_id = mig_status->entity_id
   ENDIF
   IF (ndebugind != 0)
    SET aps_mmf_migrate_entity_req->update_references_ind = 0
   ELSE
    SET aps_mmf_migrate_entity_req->update_references_ind = 1
   ENDIF
   EXECUTE aps_mmf_migrate_entity  WITH replace("REQUEST","APS_MMF_MIGRATE_ENTITY_REQ"), replace(
    "REPLY","APS_MMF_MIGRATE_ENTITY_REP")
   SET mig_status->dicom_handle = aps_mmf_migrate_entity_rep->dicom_handle
   IF ((((aps_mmf_migrate_entity_rep->status_data.status="S")) OR ((aps_mmf_migrate_entity_rep->
   status_data.status="Z"))) )
    SET nresult = 1
   ELSE
    SET nresult = 0
    SET mig_status->error_msg = build(aps_mmf_migrate_entity_rep->status_data.subeventstatus[1].
     operationname,"|",aps_mmf_migrate_entity_rep->status_data.subeventstatus[1].targetobjectname,"|",
     aps_mmf_migrate_entity_rep->status_data.subeventstatus[1].targetobjectvalue)
    CALL echorecord(aps_mmf_migrate_entity_req)
    CALL echorecord(aps_mmf_migrate_entity_rep)
   ENDIF
   COMMIT
   RETURN(nresult)
 END ;Subroutine
 SUBROUTINE markfailure(null)
   DECLARE lindx = i4 WITH protect, noconstant(1)
   DECLARE nfound = i2 WITH protect, noconstant(0)
   DECLARE dexceptionid = f8 WITH protect, noconstant(0.0)
   DECLARE sentityname = vc WITH protect, noconstant(" ")
   IF ((mig_status->phase != nphaseexception))
    WHILE ((lindx <= mig_status->failure_cnt)
     AND nfound=0)
     IF ((mig_status->failures[lindx].failed_entity=mig_status->entity)
      AND (mig_status->failures[lindx].failed_entity_id=mig_status->entity_id))
      SET nfound = 1
     ENDIF
     SET lindx = (lindx+ 1)
    ENDWHILE
    IF (nfound=0)
     SET mig_status->failure_cnt = (mig_status->failure_cnt+ 1)
     IF ((size(mig_status->failures,5) < mig_status->failure_cnt))
      SET ldmy = alterlist(mig_status->failures,(mig_status->failure_cnt+ 9))
     ENDIF
     SET mig_status->failures[mig_status->failure_cnt].failed_entity = mig_status->entity
     SET mig_status->failures[mig_status->failure_cnt].failed_entity_id = mig_status->entity_id
     SET mig_status->consec_failure_cnt = (mig_status->consec_failure_cnt+ 1)
     SET sentityname = evaluate(mig_status->entity,nentitycase,"PATHOLOGY_CASE",nentitydiscrete,
      "AP_DISCRETE_ENTITY")
     SET ldmy = error(scclerror,1)
     SELECT INTO "nl:"
      seq_nbr = seq(pathnet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       dexceptionid = cnvtreal(seq_nbr)
      WITH format, nocounter
     ;end select
     INSERT  FROM ap_img_migration_xcptn a
      SET a.parent_entity_id = mig_status->entity_id, a.parent_entity_name = sentityname, a
       .ap_img_migration_xcptn_id = dexceptionid,
       a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
       reqinfo->updt_task,
       a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0, a.xcptn_msg = mig_status->error_msg
      WITH nocounter
     ;end insert
     COMMIT
     IF (error(scclerror,1) != 0)
      SET nfatalerror = 1
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE marksuccess(null)
   IF ((mig_status->phase=nphaseexception))
    DELETE  FROM ap_img_migration_xcptn a
     WHERE (a.ap_img_migration_xcptn_id=mig_status->phase_id)
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE getlastphase(null)
   DECLARE sinfotext = vc WITH protect, noconstant(" ")
   DECLARE dinfonum = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    d.info_char, d.info_number
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain=sinfodomain
      AND d.info_name=sinfostatusrow)
    DETAIL
     sinfotext = d.info_char, dinfonum = d.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET modify = nopredeclare
    SET lstat = gm_i_dm_info2388_f8("INFO_NUMBER",0.0,1,0)
    SET lstat = gm_i_dm_info2388_vc("INFO_NAME",sinfostatusrow,1,0)
    SET lstat = gm_i_dm_info2388_vc("INFO_DOMAIN",sinfodomain,1,0)
    SET lstat = gm_i_dm_info2388_vc("INFO_CHAR",sphasestart,1,0)
    EXECUTE gm_i_dm_info2388  WITH replace(request,gm_i_dm_info2388_req), replace(reply,
     gm_i_dm_info2388_rep)
    IF ((gm_i_dm_info2388_rep->status_data.status="S"))
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
    SET mig_status->phase = nphasestart
    SET mig_status->phase_id = 0.0
    SET modify = predeclare
   ELSE
    SET sinfotext = trim(sinfotext)
    SET mig_status->phase = evaluate(sinfotext,sphasecbr,nphasecbr,sphaserdi,nphaserdi,
     sphasediscrete,nphasediscrete,sphaseexception,nphaseexception,sphaseend,
     nphaseend,nphasestart)
    SET mig_status->phase_id = dinfonum
   ENDIF
 END ;Subroutine
 SUBROUTINE updatelastphase(null)
   DECLARE sinfotext = vc WITH protect, noconstant(" ")
   DECLARE dinfonumber = f8 WITH protect, noconstant(0.0)
   DECLARE dexceptionid = f8 WITH protect, noconstant(1.0)
   IF ((mig_status->phase=nphaseend))
    SELECT INTO "nl:"
     max_id = max(aimx.ap_img_migration_xcptn_id)
     FROM ap_img_migration_xcptn aimx
     PLAN (aimx)
     DETAIL
      dexceptionid = max_id
     WITH nocounter
    ;end select
    IF (dexceptionid != 0.0)
     SET sinfotext = sphaseexception
    ELSE
     SET sinfotext = sphaseend
    ENDIF
    SET dinfonumber = 0.0
   ELSE
    SET sinfotext = evaluate(mig_status->phase,nphasecbr,sphasecbr,nphaserdi,sphaserdi,
     nphasediscrete,sphasediscrete,nphaseexception,sphaseexception,sphasestart)
    SET dinfonumber = mig_status->phase_id
   ENDIF
   SET modify = nopredeclare
   SET gm_u_dm_info2388_req->allow_partial_ind = 0
   SET gm_u_dm_info2388_req->force_updt_ind = 1
   SET lstat = gm_u_dm_info2388_f8("INFO_NUMBER",mig_status->phase_id,1,0,0)
   SET lstat = gm_u_dm_info2388_vc("INFO_NAME",sinfostatusrow,1,0,1)
   SET lstat = gm_u_dm_info2388_vc("INFO_DOMAIN",sinfodomain,1,0,1)
   SET lstat = gm_u_dm_info2388_vc("INFO_CHAR",sinfotext,1,0,0)
   EXECUTE gm_u_dm_info2388  WITH replace(request,gm_u_dm_info2388_req), replace(reply,
    gm_u_dm_info2388_rep)
   IF ((gm_u_dm_info2388_rep->status_data.status="S")
    AND (reqinfo->commit_ind=1))
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
   SET modify = predeclare
 END ;Subroutine
#exit_script
 IF ((mig_status->dicom_handle != 0))
  SET lstat = uar_aps_closedicom(mig_status->dicom_handle)
 ENDIF
 CALL echo("========= Exiting Migration =========")
 CALL echorecord(mig_status)
END GO
