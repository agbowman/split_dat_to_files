CREATE PROGRAM bed_imp_rli_supplier_orders
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET rli_request
 RECORD rli_request(
   1 rli_supplier_flag = i4
   1 orders[*]
     2 action_flag = vc
     2 order_desc = vc
     2 order_mnemonic = vc
     2 supplier_mnemonic = vc
     2 performing_loc = vc
     2 dept_name = vc
     2 alias = vc
     2 specimen_type = vc
     2 container = vc
     2 spec_handling = vc
     2 min_vol = vc
     2 min_vol_units = vc
     2 transfer_temp = vc
     2 coll_method = vc
     2 accn_class = vc
     2 coll_class = vc
     2 assay_list[*]
       3 assay_desc = vc
       3 assay_mnemonic = vc
       3 assay_alias = vc
     2 concept_cki = vc
     2 synonym_list[*]
       3 synonym = vc
       3 synonym_type = vc
     2 child_list[*]
       3 specimen_type = vc
       3 container = vc
       3 spec_handling = vc
       3 min_vol = vc
       3 min_vol_units = vc
       3 transfer_temp = vc
       3 coll_method = vc
       3 accn_class = vc
       3 coll_class = vc
 )
 FREE SET rli_reply
 RECORD rli_reply(
   1 order_list[*]
     2 catalog_cd = f8
     2 mnemonic = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 DECLARE ii = i4
 DECLARE jj = i4
 SET kk = 0
 DECLARE last_oc_mnemonic = vc
 DECLARE last_oc_alias = vc
 DECLARE numcheck = i2
 SET addcnt = 0
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numrows = size(requestin->list_0,5)
 SET ii = 0
 SET last_oc_mnemonic = fillstring(100," ")
 SET last_oc_alias = fillstring(100," ")
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE cnvtupper(brs.supplier_meaning)=cnvtupper(requestin->list_0[1].supplier))
  DETAIL
   rli_request->rli_supplier_flag = brs.supplier_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Invalid supplier code: ",requestin->list_0[1].supplier,
   "  Load program terminating.")
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO numrows)
  CALL echo(build("x = ",cnvtstring(x),"oc = ",trim(requestin->list_0[x].order_mnemonic)))
  IF (((last_oc_mnemonic != cnvtupper(requestin->list_0[x].order_mnemonic)) OR (last_oc_alias !=
  cnvtupper(requestin->list_0[x].alias))) )
   SET last_oc_mnemonic = cnvtupper(requestin->list_0[x].order_mnemonic)
   SET last_oc_alias = cnvtupper(requestin->list_0[x].alias)
   SET ii = (ii+ 1)
   SET jj = 1
   SET kk = 0
   SET addcnt = 0
   SET stat = alterlist(rli_request->orders,ii)
   SET rli_request->orders[ii].action_flag = requestin->list_0[x].action_flag
   SET rli_request->orders[ii].order_desc = requestin->list_0[x].order_desc
   SET rli_request->orders[ii].order_mnemonic = requestin->list_0[x].order_mnemonic
   SET rli_request->orders[ii].supplier_mnemonic = requestin->list_0[x].supplier_mnemonic
   SET rli_request->orders[ii].performing_loc = requestin->list_0[x].performing_loc
   SET rli_request->orders[ii].dept_name = requestin->list_0[x].dept_name
   SET rli_request->orders[ii].alias = requestin->list_0[x].alias
   SET rli_request->orders[ii].specimen_type = requestin->list_0[x].specimen_type
   SET rli_request->orders[ii].container = requestin->list_0[x].container
   SET rli_request->orders[ii].spec_handling = requestin->list_0[x].special_handling
   SET numcheck = isnumeric(requestin->list_0[x].min_vol)
   IF (((numcheck=1) OR (numcheck=2)) )
    SET rli_request->orders[ii].min_vol = requestin->list_0[x].min_vol
   ELSE
    SET rli_request->orders[ii].min_vol = "0.0"
   ENDIF
   SET rli_request->orders[ii].min_vol_units = requestin->list_0[x].min_vol_units
   SET rli_request->orders[ii].transfer_temp = requestin->list_0[x].transfer_temp
   SET rli_request->orders[ii].coll_method = requestin->list_0[x].coll_method
   SET rli_request->orders[ii].accn_class = requestin->list_0[x].accn_class
   SET rli_request->orders[ii].coll_class = requestin->list_0[x].coll_class
   SET stat = alterlist(rli_request->orders[ii].assay_list,jj)
   SET rli_request->orders[ii].assay_list[jj].assay_desc = requestin->list_0[x].assay_desc
   SET rli_request->orders[ii].assay_list[jj].assay_mnemonic = requestin->list_0[x].assay_mnemonic
   SET rli_request->orders[ii].assay_list[jj].assay_alias = requestin->list_0[x].assay_alias
   SET rli_request->orders[ii].concept_cki = requestin->list_0[x].concept_cki
   IF ((requestin->list_0[x].synonym1 > " ")
    AND ((cnvtupper(requestin->list_0[x].syntype1)="DCP") OR ((("DIRECT CARE PROVIDER") OR (
   "ANCILLARY")) )) )
    SET kk = (kk+ 1)
    SET stat = alterlist(rli_request->orders[ii].synonym_list,kk)
    SET rli_request->orders[ii].synonym_list[kk].synonym = requestin->list_0[x].synonym1
    IF (((cnvtupper(requestin->list_0[x].syntype1)="DCP") OR ("DIRECT CARE PROVIDER")) )
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "2"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype1)="ANCILLARY")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "1"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype1)="OUTREACH")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "3"
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].synonym2 > " ")
    AND ((cnvtupper(requestin->list_0[x].syntype2)="DCP") OR ((("DIRECT CARE PROVIDER") OR (
   "ANCILLARY")) )) )
    SET kk = (kk+ 1)
    SET stat = alterlist(rli_request->orders[ii].synonym_list,kk)
    SET rli_request->orders[ii].synonym_list[kk].synonym = requestin->list_0[x].synonym2
    IF (((cnvtupper(requestin->list_0[x].syntype2)="DCP") OR ("DIRECT CARE PROVIDER")) )
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "2"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype2)="ANCILLARY")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "1"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype2)="OUTREACH")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "3"
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].synonym3 > " ")
    AND ((cnvtupper(requestin->list_0[x].syntype3)="DCP") OR ((("DIRECT CARE PROVIDER") OR (
   "ANCILLARY")) )) )
    SET kk = (kk+ 1)
    SET stat = alterlist(rli_request->orders[ii].synonym_list,kk)
    SET rli_request->orders[ii].synonym_list[kk].synonym = requestin->list_0[x].synonym3
    IF (((cnvtupper(requestin->list_0[x].syntype3)="DCP") OR ("DIRECT CARE PROVIDER")) )
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "2"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype3)="ANCILLARY")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "1"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype3)="OUTREACH")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "3"
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].synonym4 > " ")
    AND ((cnvtupper(requestin->list_0[x].syntype4)="DCP") OR ((("DIRECT CARE PROVIDER") OR (
   "ANCILLARY")) )) )
    SET kk = (kk+ 1)
    SET stat = alterlist(rli_request->orders[ii].synonym_list,kk)
    SET rli_request->orders[ii].synonym_list[kk].synonym = requestin->list_0[x].synonym4
    IF (((cnvtupper(requestin->list_0[x].syntype4)="DCP") OR ("DIRECT CARE PROVIDER")) )
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "2"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype4)="ANCILLARY")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "1"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype4)="OUTREACH")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "3"
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].synonym5 > " ")
    AND ((cnvtupper(requestin->list_0[x].syntype5)="DCP") OR ((("DIRECT CARE PROVIDER") OR (
   "ANCILLARY")) )) )
    SET kk = (kk+ 1)
    SET stat = alterlist(rli_request->orders[ii].synonym_list,kk)
    SET rli_request->orders[ii].synonym_list[kk].synonym = requestin->list_0[x].synonym5
    IF (((cnvtupper(requestin->list_0[x].syntype5)="DCP") OR ("DIRECT CARE PROVIDER")) )
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "2"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype5)="ANCILLARY")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "1"
    ELSEIF (cnvtupper(requestin->list_0[x].syntype5)="OUTREACH")
     SET rli_request->orders[ii].synonym_list[kk].synonym_type = "3"
    ENDIF
   ENDIF
  ELSE
   IF ((requestin->list_0[x].assay_desc > " "))
    SET jj = (jj+ 1)
    SET stat = alterlist(rli_request->orders[ii].assay_list,jj)
    SET rli_request->orders[ii].assay_list[jj].assay_desc = requestin->list_0[x].assay_desc
    SET rli_request->orders[ii].assay_list[jj].assay_mnemonic = requestin->list_0[x].assay_mnemonic
    SET rli_request->orders[ii].assay_list[jj].assay_alias = requestin->list_0[x].assay_alias
   ENDIF
   IF (cnvtupper(requestin->list_0[x].add_req_ind)="Y")
    SET addcnt = (addcnt+ 1)
    SET stat = alterlist(rli_request->orders[ii].child_list,addcnt)
    SET rli_request->orders[ii].child_list[addcnt].accn_class = requestin->list_0[x].accn_class
    SET rli_request->orders[ii].child_list[addcnt].coll_class = requestin->list_0[x].coll_class
    SET rli_request->orders[ii].child_list[addcnt].coll_method = requestin->list_0[x].coll_method
    SET rli_request->orders[ii].child_list[addcnt].container = requestin->list_0[x].container
    SET rli_request->orders[ii].child_list[addcnt].min_vol = requestin->list_0[x].min_vol
    SET rli_request->orders[ii].child_list[addcnt].min_vol_units = requestin->list_0[x].min_vol_units
    SET rli_request->orders[ii].child_list[addcnt].spec_handling = requestin->list_0[x].
    special_handling
    SET rli_request->orders[ii].child_list[addcnt].specimen_type = requestin->list_0[x].specimen_type
    SET rli_request->orders[ii].child_list[addcnt].transfer_temp = requestin->list_0[x].transfer_temp
   ENDIF
  ENDIF
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_rli_supplier_orders  WITH replace("REQUEST",rli_request), replace("REPLY",rli_reply)
 CALL echorecord(rli_reply)
 IF ((rli_reply->status_data.status="F"))
  SET error_flag = "T"
  SET error_msg = concat(error_msg,"Errors in RLI Supplier ensure.  Check error log")
 ENDIF
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_RLI_SUPPLIER_ORDERS","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
