CREATE PROGRAM dcp_mu_patient_list_med:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 cnt = i4
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 item_id = f8
      2 item_display = vc
      2 item_id2 = f8
      2 item_display2 = vc
      2 item_id3 = f8
      2 item_display3 = vc
  )
 ENDIF
 DECLARE cat_type_pharm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
 DECLARE inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE outpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17007"))
 DECLARE temp_flag_none = i2 WITH protect, constant(0)
 DECLARE temp_flag_template = i2 WITH protect, constant(1)
 DECLARE parent_flag_care_set = i2 WITH protect, constant(1)
 DECLARE parent_flag_care_plan = i2 WITH protect, constant(16)
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE parser_loc = vc WITH protect, noconstant("1=1")
 DECLARE parser_encntr_type = vc WITH protect, noconstant("1=1")
 DECLARE parser_catalog_cd = vc WITH protect, noconstant("o.catalog_cd in (")
 IF ((request->catalog_cd > 0))
  SET parser_catalog_cd = build2(parser_catalog_cd,request->catalog_cd)
  IF ((((request->catalog_cd2 > 0)) OR ((request->catalog_cd3 > 0))) )
   SET parser_catalog_cd = build2(parser_catalog_cd,", ")
  ENDIF
 ENDIF
 IF ((request->catalog_cd2 > 0))
  SET parser_catalog_cd = build2(parser_catalog_cd,request->catalog_cd2)
  IF ((request->catalog_cd3 > 0))
   SET parser_catalog_cd = build2(parser_catalog_cd,", ")
  ENDIF
 ENDIF
 IF ((request->catalog_cd3 > 0))
  SET parser_catalog_cd = build2(parser_catalog_cd,request->catalog_cd3)
 ENDIF
 SET parser_catalog_cd = build2(parser_catalog_cd,")")
 IF (request->loc_nurse_unit_cd)
  SET parser_loc = build("e.loc_nurse_unit_cd = ",request->loc_nurse_unit_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",outpatient_class_cd)
 ELSEIF (request->loc_facility_cd)
  SET parser_loc = build("e.loc_facility_cd = ",request->loc_facility_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",inpatient_class_cd)
 ENDIF
 SELECT
  IF ((request->cnt > 0)
   AND size(request->qual,5))
   PLAN (o
    WHERE expand(exp_idx,1,request->cnt,o.encntr_id,request->qual[exp_idx].encntr_id)
     AND o.catalog_type_cd=cat_type_pharm_cd
     AND parser(parser_catalog_cd)
     AND o.template_order_flag IN (temp_flag_none, temp_flag_template)
     AND  NOT (o.cs_flag IN (parent_flag_care_set, parent_flag_care_plan))
     AND o.hide_flag IN (0, null)
     AND o.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
  ELSE
   PLAN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND o.catalog_type_cd=cat_type_pharm_cd
     AND parser(parser_catalog_cd)
     AND o.template_order_flag IN (temp_flag_none, temp_flag_template)
     AND  NOT (o.cs_flag IN (parent_flag_care_set, parent_flag_care_plan))
     AND o.hide_flag IN (0, null)
     AND o.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND parser(parser_loc)
     AND parser(parser_encntr_type))
  ENDIF
  FROM orders o,
   encounter e
  ORDER BY e.encntr_id, o.order_id
  HEAD e.encntr_id
   reply->cnt = (reply->cnt+ 1)
   IF ((reply->cnt > size(reply->qual,5)))
    stat = alterlist(reply->qual,(reply->cnt+ 19))
   ENDIF
   reply->qual[reply->cnt].person_id = e.person_id, reply->qual[reply->cnt].encntr_id = e.encntr_id
  HEAD o.order_id
   IF ((o.catalog_cd=request->catalog_cd))
    IF (textlen(trim(reply->qual[reply->cnt].item_display,3)) > 0)
     reply->qual[reply->cnt].item_display = notrim(concat(reply->qual[reply->cnt].item_display,", "))
    ENDIF
    IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
     reply->qual[reply->cnt].item_display = concat(reply->qual[reply->cnt].item_display,o
      .ordered_as_mnemonic)
    ELSE
     reply->qual[reply->cnt].item_display = concat(reply->qual[reply->cnt].item_display,trim(o
       .ordered_as_mnemonic)," (",trim(o.hna_order_mnemonic),")")
    ENDIF
   ELSEIF ((o.catalog_cd=request->catalog_cd2))
    IF (textlen(trim(reply->qual[reply->cnt].item_display2,3)) > 0)
     reply->qual[reply->cnt].item_display2 = notrim(concat(reply->qual[reply->cnt].item_display2,", "
       ))
    ENDIF
    IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
     reply->qual[reply->cnt].item_display2 = concat(reply->qual[reply->cnt].item_display2,o
      .ordered_as_mnemonic)
    ELSE
     reply->qual[reply->cnt].item_display2 = concat(reply->qual[reply->cnt].item_display2,trim(o
       .ordered_as_mnemonic)," (",trim(o.hna_order_mnemonic),")")
    ENDIF
   ELSEIF ((o.catalog_cd=request->catalog_cd3))
    IF (textlen(trim(reply->qual[reply->cnt].item_display3,3)) > 0)
     reply->qual[reply->cnt].item_display3 = notrim(concat(reply->qual[reply->cnt].item_display3,", "
       ))
    ENDIF
    IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
     reply->qual[reply->cnt].item_display3 = concat(reply->qual[reply->cnt].item_display3,o
      .ordered_as_mnemonic)
    ELSE
     reply->qual[reply->cnt].item_display3 = concat(reply->qual[reply->cnt].item_display3,trim(o
       .ordered_as_mnemonic)," (",trim(o.hna_order_mnemonic),")")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,reply->cnt)
  WITH nocounter, expand = 1
 ;end select
 CALL echo("last mod: 352272  03/25/2013  Chris Jolley")
END GO
