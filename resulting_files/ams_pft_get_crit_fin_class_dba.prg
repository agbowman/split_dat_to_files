CREATE PROGRAM ams_pft_get_crit_fin_class:dba
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE loopcnt = i4 WITH protect
 RECORD pft_reply(
   1 entitytypes[*]
     2 entitytypecd = f8
     2 entitytype = vc
     2 display = vc
   1 departments[*]
     2 departmentid = f8
     2 departmentname = vc
   1 ownertypes[*]
     2 ownertypecd = f8
     2 display = vc
     2 ownertypekey = vc
   1 facilities[*]
     2 organizationid = f8
     2 organizationname = vc
   1 encountertypes[*]
     2 encntrtypecd = f8
     2 encntrtypedisplay = vc
   1 encountertypeclasses[*]
     2 encntrtypeclasscd = f8
     2 encntrtypeclassdisplay = vc
   1 healthplans[*]
     2 healthplanid = f8
     2 healthplanname = vc
   1 payerorganizations[*]
     2 organizationid = f8
     2 organizationname = vc
   1 finclasses[*]
     2 finclasscd = f8
     2 finclassdisplay = vc
   1 medservices[*]
     2 medservicecd = f8
     2 medservicedisplay = vc
   1 appointmenttypes[*]
     2 appointmenttypecd = f8
     2 appointmenttypedisplay = vc
   1 resources[*]
     2 resourcecd = f8
     2 resourcedisplay = vc
   1 claimeditcategories[*]
     2 claimeditcategorycd = f8
     2 claimeditcategorydisplay = vc
   1 claimeditfailures[*]
     2 claimeditfailurecd = f8
     2 claimeditfailuredisplay = vc
   1 billingproviders[*]
     2 billingproviderid = f8
     2 billingproviderdisplay = vc
   1 denialtypes[*]
     2 denialtypecd = f8
     2 denialtypedisplay = vc
   1 denialreasons[*]
     2 denialreasoncd = f8
     2 denialreasondisplay = vc
     2 denialreasoncodeset = i4
   1 claimeditcategorygroup[*]
     2 claimeditcategorygroupcd = f8
     2 claimeditcategorygroupdisplay = vc
   1 claimtypes[*]
     2 claimtypecd = f8
     2 claimtypedisplay = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 EXECUTE pft_wf_get_add_assign_crit  WITH replace("REPLY",pft_reply)
 IF (size(pft_reply->finclasses,5) > 0)
  EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
  SET stat = makedataset(10)
  SET disppos = addstringfield("DISP","Display",visibile_ind,100)
  SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
  SET stat = setkeyfield(valuepos,1)
  FOR (loopcnt = 1 TO size(pft_reply->finclasses,5))
    SET recordpos = getnextrecord(0)
    SET stat = setstringfield(recordpos,disppos,substring(1,100,pft_reply->finclasses[loopcnt].
      finclassdisplay))
    SET stat = setrealfield(recordpos,valuepos,pft_reply->finclasses[loopcnt].finclasscd)
  ENDFOR
  SET stat = closedataset(0)
 ENDIF
 SET last_mod = "000"
END GO
