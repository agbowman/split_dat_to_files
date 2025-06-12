CREATE PROGRAM bed_get_ordsent_synonyms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 id = f8
      2 mnemonic = vc
      2 oe_format_id = f8
      2 oe_format_name = vc
      2 catalog_code_value = f8
      2 catalog_display = vc
      2 catalog_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 mnemonic_type
        3 code_value = f8
        3 display = vc
        3 mean = vc
      2 careset_synonyms[*]
        3 id = f8
        3 mnemonic = vc
        3 oe_format_id = f8
        3 oe_format_name = vc
        3 mnemonic_type
          4 code_value = f8
          4 display = vc
          4 mean = vc
        3 comp_seq = i4
        3 baseline_ind = i2
      2 interval_order_set_ind = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 DECLARE lab_cat_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB")), protect
 SET order_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6003
    AND c.cdf_meaning="ORDER"
    AND c.active_ind=1)
  DETAIL
   order_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE ocs_string = vc
 IF ((request->catalog_code_value > 0))
  SET ocs_string = "ocs.catalog_cd = request->catalog_code_value"
 ENDIF
 IF ((request->catalog_type_code_value > 0))
  SET ocs_string = "ocs.catalog_type_cd = request->catalog_type_code_value"
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET ocs_string = "ocs.activity_type_cd = request->activity_type_code_value"
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET ocs_string = "ocs.activity_subtype_cd = request->subactivity_type_code_value"
 ENDIF
 SET wcard = "*"
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  IF (ocs_string > " ")
   SET ocs_string = concat(trim(ocs_string),' and cnvtupper(ocs.mnemonic) = "',search_string,'"')
  ELSE
   SET ocs_string = concat('cnvtupper(ocs.mnemonic) = "',search_string,'"')
  ENDIF
 ELSE
  SET search_string = wcard
  IF (ocs_string > " ")
   SET ocs_string = concat(trim(ocs_string),' and cnvtupper(ocs.mnemonic) = "',search_string,'"')
  ELSE
   SET ocs_string = concat('cnvtupper(ocs.mnemonic) = "',search_string,'"')
  ENDIF
 ENDIF
 SET ocs_string = concat(trim(ocs_string)," and ocs.active_ind = 1")
 CALL echo(ocs_string)
 RECORD syn(
   1 qual[*]
     2 add_ind = i2
     2 cd = f8
     2 disp = vc
     2 id = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 oe_format_name = vc
     2 ct_cd = f8
     2 ct_disp = vc
     2 ct_mean = vc
     2 type_cd = f8
     2 type_disp = vc
     2 type_mean = vc
     2 flag = i2
     2 interval_order_set_ind = i2
     2 cs[*]
       3 id = f8
       3 mnemonic = vc
       3 oe_format_id = f8
       3 oe_format_name = vc
       3 type_cd = f8
       3 type_disp = vc
       3 type_mean = vc
       3 comp_seq = i4
       3 baseline_ind = i2
 )
 SET scnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value c,
   code_value c1,
   code_value c2,
   order_entry_format o
  PLAN (ocs
   WHERE parser(ocs_string))
   JOIN (c
   WHERE c.code_value=ocs.mnemonic_type_cd)
   JOIN (c1
   WHERE c1.code_value=ocs.catalog_cd)
   JOIN (c2
   WHERE c2.code_value=ocs.catalog_type_cd)
   JOIN (o
   WHERE o.oe_format_id=outerjoin(ocs.oe_format_id)
    AND o.action_type_cd=outerjoin(order_cd))
  ORDER BY ocs.mnemonic
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(syn->qual,scnt), syn->qual[scnt].cd = ocs.catalog_cd,
   syn->qual[scnt].disp = c1.display, syn->qual[scnt].id = ocs.synonym_id, syn->qual[scnt].mnemonic
    = ocs.mnemonic,
   syn->qual[scnt].oe_format_id = ocs.oe_format_id, syn->qual[scnt].oe_format_name = o.oe_format_name,
   syn->qual[scnt].ct_cd = c2.code_value,
   syn->qual[scnt].ct_disp = c2.display, syn->qual[scnt].ct_mean = c2.cdf_meaning, syn->qual[scnt].
   type_cd = c.code_value,
   syn->qual[scnt].type_disp = c.display, syn->qual[scnt].type_mean = c.cdf_meaning, syn->qual[scnt].
   flag = ocs.orderable_type_flag
   IF (ocs.orderable_type_flag IN (2, 6))
    syn->qual[scnt].add_ind = 0
   ELSE
    IF (ocs.oe_format_id > 0)
     syn->qual[scnt].add_ind = 1
    ELSE
     syn->qual[scnt].add_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(syn->qual,5))),
   cs_component cs,
   order_catalog_synonym ocs,
   code_value c,
   code_value c1,
   code_value c2,
   order_entry_format o
  PLAN (d)
   JOIN (cs
   WHERE (cs.comp_id=syn->qual[d.seq].id))
   JOIN (ocs
   WHERE ocs.catalog_cd=cs.catalog_cd
    AND ocs.active_ind=1)
   JOIN (c
   WHERE c.code_value=ocs.mnemonic_type_cd)
   JOIN (c1
   WHERE c1.code_value=ocs.catalog_cd)
   JOIN (c2
   WHERE c2.code_value=ocs.catalog_type_cd)
   JOIN (o
   WHERE o.oe_format_id=outerjoin(ocs.oe_format_id)
    AND o.action_type_cd=outerjoin(order_cd))
  ORDER BY ocs.mnemonic
  HEAD ocs.synonym_id
   found = 0
   FOR (x = 1 TO size(syn->qual,5))
     IF ((syn->qual[x].id=ocs.synonym_id))
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    scnt = (scnt+ 1), stat = alterlist(syn->qual,scnt), syn->qual[scnt].cd = ocs.catalog_cd,
    syn->qual[scnt].disp = c1.display, syn->qual[scnt].id = ocs.synonym_id, syn->qual[scnt].mnemonic
     = ocs.mnemonic,
    syn->qual[scnt].oe_format_id = ocs.oe_format_id, syn->qual[scnt].oe_format_name = o
    .oe_format_name, syn->qual[scnt].ct_cd = c2.code_value,
    syn->qual[scnt].ct_disp = c2.display, syn->qual[scnt].ct_mean = c2.cdf_meaning, syn->qual[scnt].
    type_cd = c.code_value,
    syn->qual[scnt].type_disp = c.display, syn->qual[scnt].type_mean = c.cdf_meaning, syn->qual[scnt]
    .flag = ocs.orderable_type_flag
    IF (ocs.orderable_type_flag IN (2, 6))
     syn->qual[scnt].add_ind = 0
    ELSE
     IF (ocs.oe_format_id > 0)
      syn->qual[scnt].add_ind = 1
     ELSE
      syn->qual[scnt].add_ind = 0
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(syn)
 IF (scnt > max_cnt)
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   cs_component cs,
   order_catalog_synonym ocs,
   code_value c,
   order_entry_format o
  PLAN (d
   WHERE (syn->qual[d.seq].flag IN (2, 6)))
   JOIN (cs
   WHERE (cs.catalog_cd=syn->qual[d.seq].cd)
    AND cs.comp_id > 0)
   JOIN (ocs
   WHERE ocs.synonym_id=cs.comp_id
    AND ocs.oe_format_id > 0)
   JOIN (c
   WHERE c.code_value=ocs.mnemonic_type_cd)
   JOIN (o
   WHERE o.oe_format_id=ocs.oe_format_id
    AND o.action_type_cd=order_cd)
  ORDER BY d.seq
  HEAD d.seq
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), syn->qual[d.seq].add_ind = 1, stat = alterlist(syn->qual[d.seq].cs,ccnt),
   syn->qual[d.seq].cs[ccnt].id = ocs.synonym_id, syn->qual[d.seq].cs[ccnt].mnemonic = ocs.mnemonic,
   syn->qual[d.seq].cs[ccnt].oe_format_id = ocs.oe_format_id,
   syn->qual[d.seq].cs[ccnt].oe_format_name = o.oe_format_name, syn->qual[d.seq].cs[ccnt].type_cd = c
   .code_value, syn->qual[d.seq].cs[ccnt].type_disp = c.display,
   syn->qual[d.seq].cs[ccnt].type_mean = c.cdf_meaning, syn->qual[d.seq].cs[ccnt].comp_seq = cs
   .comp_seq
   IF ((cs.linked_date_comp_seq=- (1))
    AND ocs.catalog_type_cd=lab_cat_type_cd)
    syn->qual[d.seq].cs[ccnt].baseline_ind = 1, syn->qual[d.seq].interval_order_set_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET scnt = 0
 FOR (x = 1 TO size(syn->qual,5))
   IF ((syn->qual[x].add_ind=1))
    SET scnt = (scnt+ 1)
    SET stat = alterlist(reply->synonyms,scnt)
    SET reply->synonyms[scnt].id = syn->qual[x].id
    SET reply->synonyms[scnt].mnemonic = syn->qual[x].mnemonic
    SET reply->synonyms[scnt].oe_format_id = syn->qual[x].oe_format_id
    SET reply->synonyms[scnt].oe_format_name = syn->qual[x].oe_format_name
    SET reply->synonyms[scnt].catalog_code_value = syn->qual[x].cd
    SET reply->synonyms[scnt].catalog_display = syn->qual[x].disp
    SET reply->synonyms[scnt].catalog_type.code_value = syn->qual[x].ct_cd
    SET reply->synonyms[scnt].catalog_type.display = syn->qual[x].ct_disp
    SET reply->synonyms[scnt].catalog_type.mean = syn->qual[x].ct_mean
    SET reply->synonyms[scnt].mnemonic_type.code_value = syn->qual[x].type_cd
    SET reply->synonyms[scnt].mnemonic_type.display = syn->qual[x].type_disp
    SET reply->synonyms[scnt].mnemonic_type.mean = syn->qual[x].type_mean
    SET reply->synonyms[scnt].interval_order_set_ind = syn->qual[x].interval_order_set_ind
    FOR (y = 1 TO size(syn->qual[x].cs,5))
      SET stat = alterlist(reply->synonyms[scnt].careset_synonyms,y)
      SET reply->synonyms[scnt].careset_synonyms[y].id = syn->qual[x].cs[y].id
      SET reply->synonyms[scnt].careset_synonyms[y].mnemonic = syn->qual[x].cs[y].mnemonic
      SET reply->synonyms[scnt].careset_synonyms[y].oe_format_id = syn->qual[x].cs[y].oe_format_id
      SET reply->synonyms[scnt].careset_synonyms[y].oe_format_name = syn->qual[x].cs[y].
      oe_format_name
      SET reply->synonyms[scnt].careset_synonyms[y].mnemonic_type.code_value = syn->qual[x].cs[y].
      type_cd
      SET reply->synonyms[scnt].careset_synonyms[y].mnemonic_type.display = syn->qual[x].cs[y].
      type_disp
      SET reply->synonyms[scnt].careset_synonyms[y].mnemonic_type.mean = syn->qual[x].cs[y].type_mean
      SET reply->synonyms[scnt].careset_synonyms[y].comp_seq = syn->qual[x].cs[y].comp_seq
      SET reply->synonyms[scnt].careset_synonyms[y].baseline_ind = syn->qual[x].cs[y].baseline_ind
    ENDFOR
   ENDIF
 ENDFOR
 SET sent_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(scnt)),
   ord_cat_sent_r o
  PLAN (d)
   JOIN (o
   WHERE (o.synonym_id=reply->synonyms[d.seq].id)
    AND o.active_ind=1)
  DETAIL
   sent_cnt = (sent_cnt+ 1)
  WITH nocounter
 ;end select
 IF (sent_cnt > 10000)
  SET stat = alterlist(reply->synonyms,0)
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
