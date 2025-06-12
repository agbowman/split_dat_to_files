CREATE PROGRAM dcp_get_event_cds_by_category:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getorderingredients(null) = null
 DECLARE updateorderingredientsprimarymnemonic(null) = null
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE mnemonictypecd = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE replyqualsize = i4 WITH protect, noconstant(0)
 DECLARE debugind = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET debugind = 0
 CALL getorderingredients(0)
 IF (replyqualsize > 0)
  CALL updateorderingredientsprimarymnemonic(0)
 ENDIF
 SUBROUTINE getorderingredients(null)
   IF (debugind=1)
    CALL echo("Entering GetOrderIngredients")
   ENDIF
   SELECT INTO "nl:"
    FROM alt_sel_cat ac,
     alt_sel_list al,
     order_catalog_synonym ocs,
     code_value_event_r cve
    PLAN (ac
     WHERE ac.short_description=trim(request->short_description))
     JOIN (al
     WHERE al.alt_sel_category_id=ac.alt_sel_category_id)
     JOIN (ocs
     WHERE ocs.synonym_id=al.synonym_id
      AND ocs.mnemonic_type_cd=mnemonictypecd
      AND ocs.active_ind=1)
     JOIN (cve
     WHERE cve.parent_cd=ocs.catalog_cd)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].event_cd = cve.event_cd, reply->qual[count1].catalog_cd = cve.parent_cd,
     reply->qual[count1].mnemonic = ocs.mnemonic,
     reply->qual[count1].synonym_id = ocs.synonym_id
    FOOT REPORT
     stat = alterlist(reply->qual,count1)
    WITH nocounter
   ;end select
   SET replyqualsize = size(reply->qual,5)
   IF (debugind=1)
    CALL echo("Leaving GetOrderIngredients")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateorderingredientsprimarymnemonic(null)
   IF (debugind=1)
    CALL echo("Entering UpdateOrderIngredientsPrimaryMnemonic")
   ENDIF
   DECLARE catalogidx = i4 WITH protect, noconstant(0)
   DECLARE locpossyn = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM order_catalog oc
    PLAN (oc
     WHERE expand(catalogidx,1,replyqualsize,oc.catalog_cd,reply->qual[catalogidx].catalog_cd)
      AND oc.active_ind=1)
    ORDER BY oc.catalog_cd
    HEAD oc.catalog_cd
     locpossyn = locateval(catalogidx,1,replyqualsize,oc.catalog_cd,reply->qual[catalogidx].
      catalog_cd)
     IF (locpossyn > 0)
      reply->qual[locpossyn].primary_mnemonic = oc.primary_mnemonic
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   IF (debugind=1)
    CALL echo("Leaving UpdateOrderIngredientsPrimaryMnemonic")
   ENDIF
 END ;Subroutine
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_prg
 SET last_mod = "002"
 SET mod_date = "07/02/2020"
END GO
