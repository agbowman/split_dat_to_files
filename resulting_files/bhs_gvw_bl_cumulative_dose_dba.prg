CREATE PROGRAM bhs_gvw_bl_cumulative_dose:dba
 DECLARE mf_bleomycin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BLEOMYCIN"))
 DECLARE ms_beg_doc = vc WITH protect, constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}\fs20 ")
 DECLARE ms_end_doc = vc WITH protect, constant("}")
 DECLARE ms_newline = vc WITH protect, constant(concat("\par",char(10)))
 DECLARE ms_replystring = vc WITH protect, noconstant(concat("\b \ul","  ","Bleomycin Orders",
   "\b0 \ul0",ms_newline))
 SELECT INTO "nl:"
  FROM orders o,
   order_comment oc,
   long_text l
  PLAN (o
   WHERE o.catalog_cd=mf_bleomycin_cd
    AND (o.person_id=request->person[1].person_id))
   JOIN (oc
   WHERE oc.order_id=o.order_id)
   JOIN (l
   WHERE l.long_text_id=oc.long_text_id)
  ORDER BY o.order_id
  HEAD REPORT
   ms_replystring = concat(ms_beg_doc,ms_replystring)
  DETAIL
   ms_replystring = concat(ms_replystring," ",trim(o.order_mnemonic)," ",trim(o.clinical_display_line
     ),
    " ",trim(l.long_text),ms_newline,ms_newline)
  FOOT REPORT
   ms_replystring = concat(ms_replystring,ms_end_doc)
  WITH format, seperator = "  "
 ;end select
 SET reply->text = ms_replystring
END GO
