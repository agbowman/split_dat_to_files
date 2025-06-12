CREATE PROGRAM ctp_pha_add_billitem:dba
 SET start_time = curtime3
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 SET reply->status_data.status = "F"
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 FREE SET internal
 RECORD internal(
   1 items[*]
     2 item_id = f8
     2 manf_cd = f8
     2 orc_cd = f8
     2 manf_item_id = f8
     2 med_def_flex_id = f8
 )
 IF (validate(reqinfo,0))
  SET stat = 0
 ELSE
  RECORD reqinfo(
    1 commit_ind = i2
    1 updt_id = f8
    1 position_cd = f8
    1 updt_app = i4
    1 updt_task = i4
    1 updt_req = i4
    1 updt_applctx = i4
  )
  SET fuser = 0.0
  SET cuser = curuser
  SELECT INTO "NL:"
   p.person_id
   FROM prsnl p
   WHERE p.email=cuser
   DETAIL
    fuser = p.person_id
   WITH nocounter
  ;end select
  SET reqinfo->updt_id = fuser
  SET reqinfo->updt_applctx = 0
  SET reqinfo->updt_task = 0
  SET reqinfo->updt_req = 0
  SET reqinfo->commit_ind = 0
 ENDIF
 SET icnt = 0
 SET icnt1 = 0
 SET icnt = size(request->items,5)
 SET stat = alterlist(internal->items,icnt)
 SET rec_cnt = size(internal->items,5)
 SET i = 0
 FOR (i = 1 TO rec_cnt)
   SET internal->items[i].item_id = request->items[i].item_id
   SET internal->items[i].manf_cd = request->items[i].manf_cd
   SET internal->items[i].orc_cd = request->items[i].orc_cd
   SET internal->items[i].manf_item_id = request->items[i].manf_item_id
   SET internal->items[i].med_def_flex_id = request->items[i].med_def_flex_id
 ENDFOR
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 workload_only_ind = i2
     2 price_qual = i2
     2 build_ind = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 build_ind = i2
       3 ext_contributor_cd = f8
       3 ext_description = vc
       3 ext_short_desc = vc
       3 price_qual = i4
       3 prices[*]
         4 price_sched_id = f8
         4 price = f8
       3 billcode_qual = i4
       3 billcodes[*]
         4 billcode_sched_id = f8
         4 billcode = c25
       3 chrgproc_qual = i4
       3 chargeprocs[*]
         4 sched_cd = f8
         4 charge_point = f8
         4 charge_level = f8
 ) WITH protect
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 DECLARE sndc = vc
 DECLARE cndc = f8
 DECLARE cdesc = f8
 DECLARE cshort = f8
 DECLARE cmanf = f8
 DECLARE cmedbill = f8
 DECLARE cmanfbill = f8
 DECLARE cordcat = f8
 DECLARE cpharm = f8
 DECLARE cmeddefflex = f8 WITH protected, noconstant(0.0)
 DECLARE csystem = f8 WITH protected, noconstant(0.0)
 DECLARE csyspkgtyp = f8 WITH protected, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 SET code_set = 11000
 SET cdf_meaning = "NDC"
 EXECUTE cpm_get_cd_for_cdf
 SET cndc = code_value
 SET cdf_meaning = "NDC"
 EXECUTE cpm_get_cd_for_cdf
 SET cndc = code_value
 SET cdf_meaning = "DESC"
 EXECUTE cpm_get_cd_for_cdf
 SET cdesc = code_value
 SET cdf_meaning = "DESC_SHORT"
 EXECUTE cpm_get_cd_for_cdf
 SET cshort = code_value
 SET code_set = 11001
 SET cdf_meaning = "ITEM_MANF"
 EXECUTE cpm_get_cd_for_cdf
 SET cmanf = code_value
 SET code_set = 13016
 SET cdf_meaning = "MED DEF"
 EXECUTE cpm_get_cd_for_cdf
 SET cmedbill = code_value
 SET cdf_meaning = "MANF ITEM"
 EXECUTE cpm_get_cd_for_cdf
 SET cmanfbill = code_value
 SET cdf_meaning = "ORD CAT"
 EXECUTE cpm_get_cd_for_cdf
 SET cordcat = code_value
 SET code_set = 106
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET cpharm = code_value
 SET stat = uar_get_meaning_by_codeset(13016,"MED DEF FLEX",1,cmeddefflex)
 SET stat = uar_get_meaning_by_codeset(4062,"SYSTEM",1,csystem)
 SET stat = uar_get_meaning_by_codeset(4062,"SYSPKGTYP",1,csyspkgtyp)
 CALL echorecord(request)
 IF ((internal->items[1].manf_item_id > 0))
  CALL echo("/**************Begin Manf Select*********/",1)
  SELECT
   oii3.*
   FROM manufacturer_item mi,
    object_identifier_index oii3,
    (dummyt d  WITH seq = value(rec_cnt))
   PLAN (d)
    JOIN (mi
    WHERE (mi.item_id=internal->items[d.seq].manf_item_id))
    JOIN (oii3
    WHERE mi.item_id=oii3.object_id
     AND oii3.identifier_type_cd IN (cdesc, cshort, cndc))
   HEAD mi.item_id
    icnt1 += 1
    IF (icnt1 > size(request->qual,5))
     stat = alterlist(request->qual,icnt1)
    ENDIF
    request->nbr_of_recs = icnt1, request->qual[icnt1].parent_qual_ind = 1, request->qual[icnt1].
    build_ind = 0,
    request->qual[icnt1].careset_ind = 0, request->qual[icnt1].workload_only_ind = 0, request->qual[
    icnt1].ext_id = mi.item_id,
    request->qual[icnt1].ext_contributor_cd = cmanfbill, request->qual[icnt1].ext_owner_cd = cpharm,
    request->qual[icnt1].build_ind = 0
   DETAIL
    CASE (oii3.identifier_type_cd)
     OF cdesc:
      request->qual[icnt1].ext_description = oii3.value
     OF cshort:
      request->qual[icnt1].ext_short_desc = oii3.value
     OF cndc:
      sndc = oii3.value
    ENDCASE
   FOOT  mi.item_id
    request->qual[icnt1].ext_description = concat(sndc," - ",request->qual[icnt1].ext_description),
    col 0, "Manf_Item_ID: ",
    mi.item_id, row + 1, disp = substring(1,100,request->qual[icnt1].ext_description),
    col 5, disp, row + 1
   WITH nocounter
  ;end select
  WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    SET errcnt += 1
    SET stat = alterlist(errors->err,errcnt)
    SET errors->err[errcnt].err_code = errcode
    SET errors->err[errcnt].err_msg = errmsg
    SET errors->err_cnt = errcnt
  ENDWHILE
  IF (curqual=0)
   IF ((errors->err_cnt > 1))
    SET reply->status_data.status = "F"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "MANUFACTURER_ITEM"
   IF ((reply->status_data.status="F"))
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET itemidx = 0
  SELECT
   mi.value
   FROM med_identifier mi,
    med_def_flex mdf
   PLAN (mdf
    WHERE mdf.flex_type_cd=csystem)
    JOIN (mi
    WHERE mi.item_id=mdf.item_id
     AND mi.med_identifier_type_cd=cshort
     AND mi.med_product_id=0
     AND mi.sequence=1
     AND expand(lidx,1,rec_cnt,mi.item_id,internal->items[lidx].item_id))
   HEAD mi.item_id
    lidx = 0, itemidx = 0
   DETAIL
    itemidx = locateval(lidx,1,rec_cnt,mi.item_id,internal->items[lidx].item_id)
    IF (itemidx > 0
     AND textlen(trim(request->qual[itemidx].ext_short_desc))=0)
     request->qual[itemidx].ext_short_desc = mi.value
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((internal->items[1].med_def_flex_id > 0))
  CALL echo("/**************Begin Med Def Flex Select*********/",1)
  SELECT
   mi.*
   FROM med_identifier mi,
    med_def_flex mdf,
    (dummyt d  WITH seq = value(rec_cnt))
   PLAN (d)
    JOIN (mdf
    WHERE (mdf.med_def_flex_id=internal->items[d.seq].med_def_flex_id)
     AND mdf.flex_type_cd=csystem)
    JOIN (mi
    WHERE mi.item_id=mdf.item_id
     AND mi.med_identifier_type_cd IN (cdesc, cshort, cndc)
     AND mi.med_product_id=0
     AND mi.sequence=1)
   ORDER BY mdf.med_def_flex_id
   HEAD mdf.med_def_flex_id
    icnt1 += 1
    IF (icnt1 > size(request->qual,5))
     stat = alterlist(request->qual,icnt1)
    ENDIF
    request->nbr_of_recs = icnt1, request->qual[icnt1].parent_qual_ind = 1, request->qual[icnt1].
    build_ind = 0,
    request->qual[icnt1].careset_ind = 0, request->qual[icnt1].workload_only_ind = 0, request->qual[
    icnt1].ext_id = mdf.med_def_flex_id,
    request->qual[icnt1].ext_contributor_cd = cmeddefflex, request->qual[icnt1].ext_owner_cd = cpharm,
    request->qual[icnt1].build_ind = 0
   DETAIL
    CASE (mi.med_identifier_type_cd)
     OF cdesc:
      request->qual[icnt1].ext_description = mi.value
     OF cshort:
      request->qual[icnt1].ext_short_desc = mi.value
     OF cndc:
      sndc = mi.value
    ENDCASE
   FOOT  mdf.med_def_flex_id
    col 0, "Med Def Flex: ", mdf.med_def_flex_id,
    row + 1, disp = substring(1,100,request->qual[icnt1].ext_description), col 5,
    disp, row + 1
   WITH nocounter
  ;end select
  WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    SET errcnt += 1
    SET stat = alterlist(errors->err,errcnt)
    SET errors->err[errcnt].err_code = errcode
    SET errors->err[errcnt].err_msg = errmsg
    SET errors->err_cnt = errcnt
  ENDWHILE
  IF (curqual=0)
   IF ((errors->err_cnt > 1))
    SET reply->status_data.status = "F"
    CALL echo(build("Query didn't find stuff"))
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "MED_IDENTIFIER"
   IF ((reply->status_data.status="F"))
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET icnt1 = 0
  SELECT INTO "NL:"
   oc.*
   FROM order_catalog oc,
    (dummyt d  WITH seq = value(rec_cnt))
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=internal->items[d.seq].orc_cd))
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    icnt1 += 1
    IF (icnt1 > size(request->qual,5))
     stat = alterlist(request->qual,icnt1)
    ENDIF
    request->nbr_of_recs = icnt1, request->qual[icnt1].parent_qual_ind = 1, request->qual[icnt1].
    build_ind = 0,
    request->qual[icnt1].careset_ind = 0, request->qual[icnt1].workload_only_ind = 0, request->qual[
    icnt1].ext_id = oc.catalog_cd,
    request->qual[icnt1].ext_contributor_cd = cordcat, request->qual[icnt1].ext_owner_cd = cpharm,
    request->qual[icnt1].build_ind = 0,
    request->qual[icnt1].ext_description = oc.description, request->qual[icnt1].ext_short_desc = oc
    .primary_mnemonic
   WITH nocounter
  ;end select
  WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    SET errcnt += 1
    SET stat = alterlist(errors->err,errcnt)
    SET errors->err[errcnt].err_code = errcode
    SET errors->err[errcnt].err_msg = errmsg
    SET errors->err_cnt = errcnt
  ENDWHILE
  IF (curqual=0)
   IF ((errors->err_cnt > 1))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG"
   ELSE
    IF (size(request->qual,5)=0)
     SET reply->status_data.status = "Z"
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG"
    ENDIF
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S")
  AND size(request->qual,5) > 0)
  CALL echo("Calling afc_add_reference_api...",1)
  EXECUTE afc_add_reference_api
 ENDIF
#exit_script
 CALL echo(build("Final status: ",reply->status_data.status))
 SET last_mod = "008"
END GO
