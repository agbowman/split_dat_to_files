CREATE PROGRAM bed_get_hs_man_dta_matching:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dtas[*]
      2 millenium_item_id = f8
      2 millenium_item_mnemonic = vc
      2 millenium_item_description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE search_string = vc WITH noconstant(""), protect
 DECLARE parse_search = vc WITH noconstant(""), protect
 DECLARE parse_activity_type = vc WITH noconstant(""), protect
 DECLARE healthsentryid = f8 WITH constant(request->dim_dta_item_id), protect
 DECLARE dim_item_ident = f8 WITH noconstant(0.0), protect
 DECLARE dtacnt = i4 WITH noconstant(0), protect
 SET reply->too_many_results_ind = 0
 IF ((request->activity_type_code_value > 0))
  SET parse_activity_type = build("dta.activity_type_cd = ",request->activity_type_code_value)
 ELSE
  SET parse_activity_type = "dta.activity_type_cd > 0"
 ENDIF
 IF ((request->search_type_flag=1))
  SET search_string = concat('"',cnvtupper(trim(request->search_string)),'*"')
  SET parse_search = concat("cnvtupper(dta.mnemonic) = ",search_string)
  SET parse_search = concat(parse_search," or cnvtupper(dta.description) = ",search_string)
 ELSEIF ((request->search_type_flag=2))
  SET search_string = concat('"*',cnvtupper(trim(request->search_string)),'*"')
  SET parse_search = concat("cnvtupper(dta.mnemonic) = ",search_string)
  SET parse_search = concat(parse_search," or cnvtupper(dta.description) = ",search_string)
 ELSE
  SET parse_search = concat("dta.mnemonic > ",'" "'," or dta.description > ",'" "')
 ENDIF
 CALL echo(build("ECHO - parse_search --- ",parse_search))
 CALL echo(build("ECHO - parse_activity_type --- ",parse_activity_type))
 IF ((request->proposed_dta_flag=0))
  SELECT INTO "nl:"
   FROM discrete_task_assay dta
   WHERE parser(parse_search)
    AND parser(parse_activity_type)
    AND dta.active_ind=1
   ORDER BY dta.task_assay_cd
   HEAD REPORT
    stat = alterlist(reply->dtas,100), dtacnt = 0
   DETAIL
    dtacnt = (dtacnt+ 1)
    IF (mod(dtacnt,100)=0)
     stat = alterlist(reply->dtas,(dtacnt+ 100))
    ENDIF
    reply->dtas[dtacnt].millenium_item_id = dta.task_assay_cd, reply->dtas[dtacnt].
    millenium_item_description = dta.description, reply->dtas[dtacnt].millenium_item_mnemonic = dta
    .mnemonic
   FOOT REPORT
    stat = alterlist(reply->dtas,dtacnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error getting dtas")
  CALL echorecord(reply)
 ELSE
  SELECT INTO "nl:"
   FROM br_hlth_sntry_item b,
    br_hlth_sntry_mill_item r,
    profile_task_r ptr,
    discrete_task_assay dta
   PLAN (b
    WHERE (b.dim_item_ident=request->dim_dta_item_id)
     AND b.code_set=200)
    JOIN (r
    WHERE r.br_hlth_sntry_item_id=b.br_hlth_sntry_item_id)
    JOIN (ptr
    WHERE ptr.catalog_cd=r.code_value
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1
     AND parser(parse_search)
     AND parser(parse_activity_type))
   ORDER BY dta.task_assay_cd
   HEAD REPORT
    dtacnt = 0, stat = alterlist(reply->dtas,50)
   DETAIL
    dtacnt = (dtacnt+ 1)
    IF (mod(dtacnt,50)=0)
     stat = alterlist(reply->dtas,(dtacnt+ 50))
    ENDIF
    reply->dtas[dtacnt].millenium_item_id = dta.task_assay_cd, reply->dtas[dtacnt].
    millenium_item_description = dta.description, reply->dtas[dtacnt].millenium_item_mnemonic = dta
    .mnemonic
   FOOT REPORT
    stat = alterlist(reply->dtas,dtacnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error retrieving dta's from orders")
  CALL echorecord(reply)
 ENDIF
 IF ((dtacnt > request->max_reply))
  SET reply->too_many_results_ind = 1
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
