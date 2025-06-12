CREATE PROGRAM ams_fix_bim_nomen:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "report_dt" = "CURDATE"
  WITH outdev, report_dt
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE clientstr = vc WITH protect, constant(getclient(null))
 DECLARE cclerrorstr = vc WITH protect
 DECLARE status = c1 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_FIX_BIM_NOMEN")
 DECLARE report_dt = dq8 WITH protect
 IF (validate(request->batch_selection))
  SET bisopsjob = 1
 ELSE
  RECORD request(
    1 batch_selection = vc
    1 output_dist = vc
    1 ops_date = dq8
  )
  SET bisopsjob = 0
 ENDIF
 IF (bisopsjob=1)
  SET run_day = cnvtint( $REPORT_DT)
  SET r_date = cnvtdatetime((curdate - run_day),0)
 ELSEIF (bisopsjob=0)
  SET r_date = cnvtdatetime( $REPORT_DT)
 ENDIF
 EXECUTE ams_define_toolkit_common
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 SET cpt4_cd = uar_get_code_by("MEANING",400,"CPT4")
 FREE SET bim
 RECORD bim(
   1 cnt = i4
   1 bim[*]
     2 bim_id = f8
     2 n_id = f8
 )
 SELECT INTO "nl:"
  FROM bill_item_modifier bim,
   nomenclature n
  PLAN (bim
   WHERE bim.active_ind=1
    AND (bim.key1_id=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="CPT4"))
    AND cnvtdatetime(r_date) BETWEEN bim.beg_effective_dt_tm AND bim.end_effective_dt_tm)
   JOIN (n
   WHERE n.source_identifier=bim.key6
    AND n.active_ind=1
    AND n.source_vocabulary_cd=cpt4_cd
    AND n.nomenclature_id != bim.key3_id
    AND cnvtdatetime(r_date) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm
    AND n.cmti != null)
  ORDER BY bim.bill_item_mod_id
  DETAIL
   bim->cnt = (bim->cnt+ 1)
   IF (mod(bim->cnt,100)=1)
    stat = alterlist(bim->bim,(bim->cnt+ 99))
   ENDIF
   bim->bim[bim->cnt].bim_id = bim.bill_item_mod_id, bim->bim[bim->cnt].n_id = n.nomenclature_id
  FOOT REPORT
   IF (mod(bim->cnt,100) != 0)
    stat = alterlist(bim->bim,bim->cnt)
   ENDIF
  WITH forupdate(bim)
 ;end select
 SELECT INTO "nl:"
  FROM bill_item_modifier bim,
   nomenclature n
  PLAN (bim
   WHERE bim.active_ind=1
    AND (bim.key1_id=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="HCPCS"))
    AND cnvtdatetime(r_date) BETWEEN bim.beg_effective_dt_tm AND bim.end_effective_dt_tm)
   JOIN (n
   WHERE n.source_identifier=bim.key6
    AND n.active_ind=1
    AND n.source_vocabulary_cd=cpt4_cd
    AND n.nomenclature_id != bim.key3_id
    AND cnvtdatetime(r_date) BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm
    AND n.cmti != null)
  ORDER BY bim.bill_item_mod_id
  DETAIL
   bim->cnt = (bim->cnt+ 1)
   IF (mod(bim->cnt,100)=1)
    stat = alterlist(bim->bim,(bim->cnt+ 99))
   ENDIF
   bim->bim[bim->cnt].bim_id = bim.bill_item_mod_id, bim->bim[bim->cnt].n_id = n.nomenclature_id
  FOOT REPORT
   IF (mod(bim->cnt,100) != 0)
    stat = alterlist(bim->bim,bim->cnt)
   ENDIF
  WITH forupdate(bim)
 ;end select
 UPDATE  FROM bill_item_modifier bim,
   (dummyt d  WITH seq = value(bim->cnt))
  SET bim.key3_id = bim->bim[d.seq].n_id, bim.updt_dt_tm = cnvtdatetime(curdate,curtime3), bim
   .updt_id = reqinfo->updt_id,
   bim.updt_task = 0311, bim.updt_applctx = 0
  PLAN (d)
   JOIN (bim
   WHERE (bim.bill_item_mod_id=bim->bim[d.seq].bim_id))
 ;end update
 IF (((error(cclerrorstr,0) > 0) OR ((curqual != bim->cnt))) )
  SET status = "F"
  SET statusstr = "Update into bill_item_modifier failed"
  GO TO exit_script
 ELSE
  SET status = "S"
  SET statusstr = "success"
 ENDIF
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = value(bim->cnt))
  HEAD REPORT
   col 0, row 0, header_str = concat("Running report for: ",format(r_date,";;q")),
   header_str, row + 2
  DETAIL
   col 0, row + 1, "Updated charge_mod_id",
   bim->bim[d.seq].bim_id
  WITH nocounter, format, separator = " "
 ;end select
 SELECT INTO "client_nomen_cleanup_bim.csv"
  bill_item_mod_id = bim->bim[d.seq].bim_id
  FROM (dummyt d  WITH seq = value(bim->cnt))
  WITH format = stream, pcformat('"',",",1), format
 ;end select
 SET stat = emailfile("ChargeServicesProactiveChecks@cerner.com","ams_fix_bim_nomen@cerner.com",
  "Clients and BIM Rows Cleaned up",build2("Count: ",trim(cnvtstring(bim->cnt))," client: ",clientstr,
   " ",
   curdomain),"client_nomen_cleanup_bim.csv")
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 IF (status="F")
  ROLLBACK
 ELSE
  COMMIT
  IF ((bim->cnt > 0))
   CALL updtdminfo(script_name,cnvtreal(bim->cnt))
  ENDIF
 ENDIF
END GO
