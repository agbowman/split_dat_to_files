CREATE PROGRAM bhs_prax_cancel_dc_reason
 SET input_string = cnvtupper(trim( $3))
 SET where_params = build("CNVTUPPER(OE.DESCRIPTION) = ","'",cnvtupper(input_string),"'"," ")
 SELECT INTO  $1
  catalog_cd = der.entity1_id, catalog_type_desc = trim(replace(replace(replace(replace(replace(der
        .entity1_display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
   ), cancel_reason_id = der.entity2_id,
  cancel_reason_desc = trim(replace(replace(replace(replace(replace(der.entity2_display,"&","&amp;",0
        ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
  FROM order_entry_fields oe,
   dcp_entity_reltn der
  PLAN (oe
   WHERE parser(where_params)
    AND oe.codeset=1309)
   JOIN (der
   WHERE der.entity_reltn_mean=outerjoin(concat("CT/",cnvtstring(oe.codeset)))
    AND (der.entity1_id= $2))
  ORDER BY der.entity1_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD der.entity1_id
   col 1, "<Reasons>", row + 1
  DETAIL
   col 1, "<CancelReason>", row + 1,
   r_id = build("<CancelReasonId>",cnvtint(cancel_reason_id),"</CancelReasonId>"), col + 1, r_id,
   row + 1, r_desc = build("<CancelReasonDesc>",cancel_reason_desc,"</CancelReasonDesc>"), col + 1,
   r_desc, row + 1, col 1,
   "</CancelReason>", row + 1
  FOOT  der.entity1_id
   col 1, "</Reasons>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 1000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
