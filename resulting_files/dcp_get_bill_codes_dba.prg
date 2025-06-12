CREATE PROGRAM dcp_get_bill_codes:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 catalog_cd = f8
      2 bill[*]
        3 bill_code = vc
        3 sequence = f8
        3 nomen_entity_name = vc
        3 nomen_entity_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE shcpcs = c5 WITH protect, constant("HCPCS")
 DECLARE scpt4 = c4 WITH protect, constant("CPT4")
 DECLARE lcatalogcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalbillcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalqualcnt = i4 WITH protect, noconstant(0)
 DECLARE dparentcontribcd = f8 WITH protect, noconstant(0.0)
 DECLARE dbilltypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcpt4sourcevocabcd = f8 WITH protect, noconstant(0.0)
 DECLARE dhcpcssourcevocabcd = f8 WITH protect, noconstant(0.0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nsuccess = i2 WITH private, constant(0)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(1)
 DECLARE nfailed_code_value_query = i2 WITH private, constant(1)
 DECLARE nzero_catalogs_in_request = i2 WITH private, constant(3)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE nqualstatus = i2 WITH private, noconstant(nsuccess)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE dcodeset = i4 WITH private, noconstant(0)
 DECLARE scdfmeaning = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 CALL echo("******************************")
 CALL echo("Looking for code values...")
 CALL echo("******************************")
 SET dcodeset = 13016.0
 SET scdfmeaning = "ORD CAT"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dparentcontribcd)
 CALL echo(build("Parent Contrib Cd: ",dparentcontribcd))
 IF (dparentcontribcd <= 0)
  SET nqualstatus = nfailed_code_value_query
  GO TO exit_script
 ENDIF
 SET dcodeset = 13019.0
 SET scdfmeaning = "BILL CODE"
 SET stat = uar_get_meaning_by_codeset(dcodeset,scdfmeaning,1,dbilltypecd)
 CALL echo(build("Bill Type Cd: ",dbilltypecd))
 IF (dbilltypecd < 1)
  SET nqualstatus = nfailed_code_value_query
  GO TO exit_script
 ENDIF
 SET dcodeset = 400.0
 SET stat = uar_get_meaning_by_codeset(dcodeset,scpt4,1,dcpt4sourcevocabcd)
 CALL echo(build("CPT4 Source Vocab Cd: ",dcpt4sourcevocabcd))
 IF (dcpt4sourcevocabcd < 1)
  SET nqualstatus = nfailed_code_value_query
  GO TO exit_script
 ENDIF
 SET dcodeset = 400.0
 SET stat = uar_get_meaning_by_codeset(dcodeset,shcpcs,1,dhcpcssourcevocabcd)
 CALL echo(build("HCPCS Source Vocab Cd: ",dhcpcssourcevocabcd))
 IF (dhcpcssourcevocabcd < 1)
  SET nqualstatus = nfailed_code_value_query
  GO TO exit_script
 ENDIF
 SET lcatalogcnt = size(request->qual,5)
 IF (lcatalogcnt <= 0)
  SET nqualstatus = nzero_catalogs_in_request
  GO TO exit_script
 ENDIF
 CALL echo("******************************")
 CALL echo("Looking for bill items...")
 CALL echo("******************************")
 SELECT INTO "nl:"
  d.seq, bm.key2_id
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   bill_item b,
   bill_item_modifier bm,
   code_value cv
  PLAN (d
   WHERE d.seq > 0)
   JOIN (b
   WHERE (b.ext_parent_reference_id=request->qual[d.seq].catalog_cd)
    AND b.ext_parent_contributor_cd=dparentcontribcd
    AND ((b.ext_child_reference_id+ 0)=0)
    AND ((b.ext_child_contributor_cd+ 0)=0)
    AND b.active_ind=1
    AND b.child_seq IN (0, null))
   JOIN (bm
   WHERE bm.bill_item_id=b.bill_item_id
    AND bm.bill_item_type_cd=dbilltypecd
    AND bm.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=bm.key1_id
    AND ((cv.code_set+ 0)=14002)
    AND cv.cdf_meaning IN (scpt4, shcpcs))
  ORDER BY d.seq, bm.key2_id
  HEAD REPORT
   ltotalqualcnt = 0, stat = alterlist(reply->qual,10)
  HEAD d.seq
   ltotalqualcnt = (ltotalqualcnt+ 1)
   IF (mod(ltotalqualcnt,10)=1
    AND ltotalqualcnt != 1)
    stat = alterlist(reply->qual,(ltotalqualcnt+ 9))
   ENDIF
   reply->qual[ltotalqualcnt].catalog_cd = request->qual[d.seq].catalog_cd, ltotalbillcnt = 0, stat
    = alterlist(reply->qual[ltotalqualcnt].bill,10)
  DETAIL
   IF (bm.bill_item_mod_id > 0)
    ltotalbillcnt = (ltotalbillcnt+ 1)
    IF (mod(ltotalbillcnt,10)=1
     AND ltotalbillcnt != 1)
     stat = alterlist(reply->qual[ltotalqualcnt].bill,(ltotalbillcnt+ 9))
    ENDIF
    reply->qual[ltotalqualcnt].bill[ltotalbillcnt].sequence = bm.key2_id, reply->qual[ltotalqualcnt].
    bill[ltotalbillcnt].bill_code = trim(bm.key6)
   ENDIF
   CASE (cv.cdf_meaning)
    OF shcpcs:
     reply->qual[ltotalqualcnt].bill[ltotalbillcnt].nomen_entity_id = dhcpcssourcevocabcd,reply->
     qual[ltotalqualcnt].bill[ltotalbillcnt].nomen_entity_name = shcpcs
    OF scpt4:
     reply->qual[ltotalqualcnt].bill[ltotalbillcnt].nomen_entity_id = dcpt4sourcevocabcd,reply->qual[
     ltotalqualcnt].bill[ltotalbillcnt].nomen_entity_name = scpt4
   ENDCASE
  FOOT  d.seq
   stat = alterlist(reply->qual[ltotalqualcnt].bill,ltotalbillcnt)
  FOOT REPORT
   stat = alterlist(reply->qual,ltotalqualcnt)
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
 CALL echo("******************************")
 CALL echo("Checking for errors...")
 CALL echo("******************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ENDIF
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_GET_BILL_CODES"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (ltotalbillcnt <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  CASE (nqualstatus)
   OF nfailed_code_value_query:
    SET reply->status_data.subeventstatus[1].operationname = "DB ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CODE VALUE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "One or more of the required code values failed to load."
   OF nzero_catalogs_in_request:
    SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectname = "QUAL"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No qual items in the request."
  ENDCASE
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 10/20/03 SA3720 Initial Release"
END GO
