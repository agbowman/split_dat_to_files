CREATE PROGRAM afc_add_bill_org_payor:dba
 CALL echo("Starting afc_add_bill_org_payor...")
 DECLARE versionnbr = vc
 SET versionnbr = "007"
 CALL echo(build("AFC_ADD_BILL_ORG_PAYOR Version: ",versionnbr))
 RECORD parent_entity(
   1 pe_qual = i4
   1 pe[*]
     2 bill_org_type_cd = f8
     2 org_payor_id = f8
 )
 RECORD tiergroup_cv(
   1 tg_num = i2
   1 tg_cd[*]
     2 tg_cv = f8
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bill_org_payor_qual = i4
    1 bill_org_payor[*]
      2 org_payor_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET reply->bill_org_payor_qual = request->bill_org_payor_qual
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE wl_standard_cd = f8
 DECLARE activecnt = i4
 SET code_set = 13031
 SET cdf_meaning = "STANDARD"
 SET activecnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,activecnt,wl_standard_cd)
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cntactive = i4
 DECLARE cntcode = i4
 DECLARE cnttier = i4
 DECLARE tiergroup = f8
 DECLARE iret = i4
 DECLARE clttiergroup = i4
 DECLARE clt_tiergroup_cd = f8
 SET code_set = 13031
 SET cdf_meaning = "TIERGROUP"
 SET cntactive = 1
 SET clttiergroup = 1
 SET m = 1
 RECORD tgstring(
   1 tg_string = vc
 )
 SET tgstring->tg_string = "request->BILL_ORG_PAYOR[X]->BILL_ORG_TYPE_CD in ("
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cntactive,tiergroup)
 IF (iret=0)
  CALL echo(concat("success.code value: ",build(tiergroup)))
 ELSE
  CALL echo("failure")
 ENDIF
 SET tgstring->tg_string = build(tgstring->tg_string,cnvtstring(tiergroup,17,2))
 IF (cntactive > 1)
  FOR (cnttier = 2 TO cntactive)
    SET m = cnttier
    SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,m,tiergroup)
    SET tgstring->tg_string = build(tgstring->tg_string,",",cnvtstring(tiergroup,17,2))
  ENDFOR
 ENDIF
 SET cdf_meaning = "CLTTIERGROUP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,clttiergroup,clt_tiergroup_cd)
 IF (stat=0)
  CALL echo(concat("success.code value: ",build(clt_tiergroup_cd)))
 ELSE
  CALL echo("failure")
 ENDIF
 SET tgstring->tg_string = build(tgstring->tg_string,",",clt_tiergroup_cd)
 IF (clttiergroup > 1)
  FOR (cnttier = 2 TO clttiergroup)
    SET m = cnttier
    SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,m,clt_tiergroup_cd)
    SET tgstring->tg_string = build(tgstring->tg_string,",",clt_tiergroup_cd)
  ENDFOR
 ENDIF
 SET tgstring->tg_string = build(tgstring->tg_string,")")
 SET tgstring->tg_string = trim(tgstring->tg_string)
 CALL echo(build("Count of tier groups : ",cntactive))
 CALL echo(build("TG String : ",tgstring->tg_string))
 EXECUTE afc_add_b_o_p parser(
  IF (cntactive > 0) tgstring->tg_string
  ELSE "0=0"
  ENDIF
  )
END GO
