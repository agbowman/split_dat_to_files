CREATE PROGRAM ams_get_product_rx_mask:dba
 PROMPT
  "item_id" = ""
  WITH itemid
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE (ocs.item_id= $ITEMID))
  HEAD REPORT
   stat = makedataset(3), disppos = addstringfield("DISP","Type",visibile_ind,15), valuepos =
   addintegerfield("VALUE","Value",invisibile_ind),
   stat = setkeyfield(valuepos,1)
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,"Diluent"), stat =
   setintegerfield(recordpos,valuepos,1),
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,"Additive"), stat =
   setintegerfield(recordpos,valuepos,2),
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,"Med"), stat =
   setintegerfield(recordpos,valuepos,4)
   IF (band(ocs.rx_mask,1) > 0)
    stat = adddefaultkey("1")
   ENDIF
   IF (band(ocs.rx_mask,2) > 0)
    stat = adddefaultkey("2")
   ENDIF
   IF (band(ocs.rx_mask,4) > 0)
    stat = adddefaultkey("4")
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
END GO
