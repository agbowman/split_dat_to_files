CREATE PROGRAM afc_load_pharmacy:dba
 PROMPT
  "Would you like to only insert new Bill Items, without updating any existing Bill items (1 for yes; 0 for no):"
 SET p_first_answer =  $1
 SET trace = recpersist
 SET start_time = curtime3
 FREE RECORD reply
 RECORD reply(
   1 elapsed_time = f8
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
 FREE RECORD errors
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 DECLARE ctnf_med = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13016,"TNF_MED",1,ctnf_med)
 SET reply->status_data.status = "F"
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 FREE RECORD internal
 RECORD internal(
   1 items[*]
     2 item_id = f8
 )
 DECLARE new_model_check = i2 WITH protected, noconstant(0)
 SELECT INTO "nl:"
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.person_id=0
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_section="FRMLRYMGMT"
   AND dmp.pref_name="NEW MODEL"
  DETAIL
   IF (dmp.pref_nbr=1)
    new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (new_model_check=1)
  CALL echo(
   "This utility cannot be used with the New Formulary Model, use rxa_load_pharmacy instead.")
  GO TO exit_script
 ENDIF
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
 IF (validate(request,0))
  SET icnt = size(request->items,5)
  SET stat = alterlist(internal->items,icnt)
  SET internal = request
  FREE SET request
 ELSE
  SELECT INTO "NL:"
   m.item_id
   FROM medication_definition m
   DETAIL
    icnt = (icnt+ 1), stat = alterlist(internal->items,icnt), internal->items[icnt].item_id = m
    .item_id
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD request
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
       3 ext_owner_cd = f8
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
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cndc = 0.0
 SET cdesc = 0.0
 SET cshort = 0.0
 SET cmeddef = 0.0
 SET cmanf = 0.0
 SET cmanfbill = 0.0
 SET cmedbill = 0.0
 SET code_set = 11000
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
 SET ctnf_mnem = fillstring(100," ")
 SET ctnf_desc = fillstring(100," ")
 SET ctnf_cd = 0.0
 SELECT INTO "nl:"
  dmp.pref_str, oc.catalog_cd
  FROM dm_prefs dmp,
   order_catalog oc
  PLAN (dmp
   WHERE dmp.application_nbr=300000
    AND dmp.pref_domain="PHARMNET-INPATIENT"
    AND dmp.pref_section="SYSTEM"
    AND dmp.pref_name="TNFMNEM")
   JOIN (oc
   WHERE oc.primary_mnemonic=trim(dmp.pref_str))
  DETAIL
   ctnf_cd = oc.catalog_cd, ctnf_desc = trim(oc.description), ctnf_mnem = trim(oc.primary_mnemonic)
  WITH nocounter
 ;end select
 SET icnt1 = (icnt1+ 1)
 SET stat = alterlist(request->qual,icnt1)
 SET request->nbr_of_recs = icnt1
 SET request->qual[icnt1].parent_qual_ind = 1
 SET request->qual[icnt1].build_ind = 0
 SET request->qual[icnt1].careset_ind = 0
 SET request->qual[icnt1].workload_only_ind = 0
 SET request->qual[icnt1].ext_id = ctnf_cd
 SET request->qual[icnt1].ext_contributor_cd = cordcat
 SET request->qual[icnt1].ext_owner_cd = cpharm
 SET request->qual[icnt1].ext_description = ctnf_desc
 SET request->qual[icnt1].ext_short_desc = ctnf_mnem
 SET icnt1 = (icnt1+ 1)
 SET stat = alterlist(request->qual,icnt1)
 SET request->nbr_of_recs = icnt1
 SET request->qual[icnt1].parent_qual_ind = 1
 SET request->qual[icnt1].build_ind = 0
 SET request->qual[icnt1].careset_ind = 0
 SET request->qual[icnt1].workload_only_ind = 0
 SET request->qual[icnt1].ext_id = 1
 SET request->qual[icnt1].ext_contributor_cd = ctnf_med
 SET request->qual[icnt1].ext_owner_cd = cpharm
 SET request->qual[icnt1].ext_description = ctnf_desc
 SET request->qual[icnt1].ext_short_desc = ctnf_mnem
 SET rec_cnt = size(internal->items,5)
 SELECT INTO "NL:"
  oii.*, oii2.*
  FROM object_identifier_index oii,
   object_identifier_index oii2,
   manufacturer_item mi,
   object_identifier_index oii3,
   (dummyt d  WITH seq = value(rec_cnt))
  PLAN (d)
   JOIN (oii
   WHERE (internal->items[d.seq].item_id=oii.object_id)
    AND oii.identifier_type_cd=cndc
    AND oii.generic_object=0)
   JOIN (oii2
   WHERE oii.identifier_id=oii2.identifier_id
    AND oii2.object_type_cd=cmanf
    AND oii2.generic_object=0
    AND ((p_first_answer=1
    AND  NOT ( EXISTS (
   (SELECT
    bi.bill_item_id
    FROM bill_item bi
    WHERE bi.ext_parent_reference_id=oii2.object_id)))) OR (p_first_answer=0)) )
   JOIN (mi
   WHERE oii2.object_id=mi.item_id)
   JOIN (oii3
   WHERE mi.item_id=oii3.object_id
    AND oii3.identifier_type_cd IN (cdesc, cshort)
    AND oii3.generic_object=0)
  ORDER BY oii.identifier_id, oii2.object_id
  HEAD oii2.object_id
   icnt1 = (icnt1+ 1)
   IF (icnt1 > size(request->qual,5))
    stat = alterlist(request->qual,icnt1)
   ENDIF
   request->nbr_of_recs = icnt1, request->qual[icnt1].parent_qual_ind = 1, request->qual[icnt1].
   build_ind = 0,
   request->qual[icnt1].careset_ind = 0, request->qual[icnt1].workload_only_ind = 0, request->qual[
   icnt1].ext_id = oii2.object_id,
   request->qual[icnt1].ext_contributor_cd = cmanfbill, request->qual[icnt1].ext_owner_cd = cpharm,
   request->qual[icnt1].build_ind = 0
  DETAIL
   IF (oii3.identifier_type_cd=cdesc)
    request->qual[icnt1].ext_description = oii3.value
   ELSE
    request->qual[icnt1].ext_short_desc = oii3.value
   ENDIF
  WITH nocounter
 ;end select
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
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
 SELECT INTO "NL:"
  oc.*
  FROM order_catalog_item_r oci,
   order_catalog oc,
   (dummyt d  WITH seq = value(rec_cnt))
  PLAN (d)
   JOIN (oci
   WHERE (internal->items[d.seq].item_id=oci.item_id))
   JOIN (oc
   WHERE oci.catalog_cd=oc.catalog_cd
    AND ((p_first_answer=1
    AND  NOT ( EXISTS (
   (SELECT
    bi.bill_item_id
    FROM bill_item bi
    WHERE bi.ext_parent_reference_id=oc.catalog_cd)))) OR (p_first_answer=0)) )
  ORDER BY oc.catalog_cd
  HEAD oc.catalog_cd
   icnt1 = (icnt1+ 1)
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
   SET errcnt = (errcnt+ 1)
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
 IF ((reply->status_data.status="S")
  AND size(request->qual,5) > 0)
  CALL echo("=====================>called the update function")
  EXECUTE afc_add_reference_api
 ENDIF
#exit_script
 CALL echo("Last Mod = 007")
 CALL echo("Mod Date = 09/20/2007")
 SET reply->elapsed_time = ((curtime3 - start_time)/ 100)
END GO
