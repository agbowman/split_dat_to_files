CREATE PROGRAM ams_fix_cm_nomen:dba
 PROMPT
  "output to file/printer/mine" = "mine",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, start_dt, end_dt
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE clientstr = vc WITH protect, constant(getclient(null))
 DECLARE cclerrorstr = vc WITH protect
 DECLARE status = c1 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_FIX_CM_NOMEN")
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
  SET days_start = cnvtint( $START_DT)
  SET days_end = cnvtint( $END_DT)
  SET s_date = cnvtdatetime((curdate - days_start),0)
  SET e_date = cnvtdatetime((curdate - days_end),235959)
 ELSEIF (bisopsjob=0)
  SET s_date = cnvtdatetime( $START_DT)
  SET e_date = cnvtdatetime( $END_DT)
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
 SET hcpcs_cd = uar_get_code_by("MEANING",400,"HCPCS")
 SET cpt4_cd = uar_get_code_by("MEANING",400,"CPT4")
 FREE SET chg
 RECORD chg(
   1 cnt = i4
   1 chg[*]
     2 cm_id = f8
     2 n_id = f8
     2 ieprice = f8
 )
 SELECT INTO "nl:"
  FROM charge c,
   charge_mod cm,
   nomenclature n
  PLAN (cm
   WHERE cm.active_ind=1
    AND (cm.field1_id=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="HCPCS")))
   JOIN (c
   WHERE cm.charge_item_id=c.charge_item_id
    AND c.active_ind=1
    AND c.service_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
   JOIN (n
   WHERE n.source_identifier=cm.field6
    AND c.service_dt_tm BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm
    AND n.active_ind=1
    AND n.source_vocabulary_cd=hcpcs_cd
    AND n.nomenclature_id != cm.nomen_id
    AND n.cmti != null)
  ORDER BY cm.charge_item_id
  DETAIL
   chg->cnt = (chg->cnt+ 1)
   IF (mod(chg->cnt,100)=1)
    stat = alterlist(chg->chg,(chg->cnt+ 99))
   ENDIF
   chg->chg[chg->cnt].cm_id = cm.charge_mod_id, chg->chg[chg->cnt].n_id = n.nomenclature_id, chg->
   chg[chg->cnt].ieprice = c.item_extended_price
  FOOT REPORT
   IF (mod(chg->cnt,100) != 0)
    stat = alterlist(chg->chg,chg->cnt)
   ENDIF
  WITH forupdate(cm)
 ;end select
 SELECT INTO "nl:"
  FROM charge c,
   charge_mod cm,
   nomenclature n
  PLAN (cm
   WHERE cm.active_ind=1
    AND (cm.field1_id=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="CPT4")))
   JOIN (c
   WHERE cm.charge_item_id=c.charge_item_id
    AND c.active_ind=1
    AND c.service_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
   JOIN (n
   WHERE n.source_identifier=cm.field6
    AND c.service_dt_tm BETWEEN n.beg_effective_dt_tm AND n.end_effective_dt_tm
    AND n.active_ind=1
    AND n.source_vocabulary_cd=cpt4_cd
    AND n.nomenclature_id != cm.nomen_id
    AND n.cmti != null)
  ORDER BY cm.charge_item_id
  DETAIL
   chg->cnt = (chg->cnt+ 1)
   IF ((chg->cnt > size(chg->chg,5)))
    stat = alterlist(chg->chg,(chg->cnt+ 100))
   ENDIF
   chg->chg[chg->cnt].cm_id = cm.charge_mod_id, chg->chg[chg->cnt].n_id = n.nomenclature_id, chg->
   chg[chg->cnt].ieprice = c.item_extended_price
  FOOT REPORT
   stat = alterlist(chg->chg,chg->cnt)
  WITH forupdate(cm)
 ;end select
 IF ((chg->cnt=0))
  GO TO exit_script
 ENDIF
 UPDATE  FROM charge_mod cm,
   (dummyt d  WITH seq = value(chg->cnt))
  SET cm.nomen_id = chg->chg[d.seq].n_id, cm.updt_dt_tm = cnvtdatetime(curdate,curtime3), cm.updt_id
    = reqinfo->updt_id,
   cm.updt_task = 0311, cm.updt_applctx = 0
  PLAN (d)
   JOIN (cm
   WHERE (cm.charge_mod_id=chg->chg[d.seq].cm_id)
    AND  EXISTS (
   (SELECT
    c.charge_item_id
    FROM charge c
    WHERE c.charge_item_id=cm.charge_item_id
     AND (c.item_extended_price=chg->chg[d.seq].ieprice))))
 ;end update
 IF (((error(cclerrorstr,0) > 0) OR ((curqual != chg->cnt))) )
  SET status = "F"
  SET statusstr = "Update into charge_mod failed"
  GO TO exit_script
 ELSE
  SET status = "S"
  SET statusstr = "success"
 ENDIF
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = value(chg->cnt))
  HEAD REPORT
   col 0, row 0, header_str = concat("Running report for range: ",format(s_date,";;q")," - ",format(
     e_date,";;q")),
   header_str, row + 2
  DETAIL
   col 0, row + 1, "Updated charge_mod_id",
   chg->chg[d.seq].cm_id
  WITH nocounter, format, separator = " "
 ;end select
 SELECT INTO "client_nomen_cleanup_hcpcs.csv"
  charge_mod_id = chg->chg[d.seq].cm_id, item_extended_price = chg->chg[d.seq].ieprice
  FROM (dummyt d  WITH seq = value(chg->cnt))
  WITH format = stream, pcformat('"',",",1), format
 ;end select
 SET stat = emailfile("ChargeServicesProactiveChecks@cerner.com","afc_fix_cm_nomen_hcpcs@cerner.com",
  "Clients and Nomenclature Rows Cleaned up",build2("Count: ",trim(cnvtstring(chg->cnt))," Revenue: ",
   trim(cnvtstring(sum(chg->chg.ieprice)))," client: ",
   clientstr," ",curdomain),"client_nomen_cleanup_hcpcs.csv")
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
 SUBROUTINE gethnaemail(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    p.email
    FROM prsnl p
    WHERE (p.updt_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.email)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
#exit_script
 IF (status="F")
  ROLLBACK
 ELSE
  COMMIT
  IF ((chg->cnt > 0))
   CALL updtdminfo(script_name,cnvtreal(chg->cnt))
  ENDIF
 ENDIF
END GO
