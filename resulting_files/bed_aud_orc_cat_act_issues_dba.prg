CREATE PROGRAM bed_aud_orc_cat_act_issues:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
  )
 ENDIF
 RECORD temp(
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 missing_ct_ind = i2
     2 missing_at_ind = i2
     2 bad_combo_ind = i2
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
 )
 RECORD temp2(
   1 clist[*]
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 ct_cdf_meaning = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 at_definition = vc
 )
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "catalog_cd"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Missing Catalog Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Missing Activity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Invalid Combination"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "catalog_type_cd"
 SET reply->collist[6].data_type = 2
 SET reply->collist[6].hide_ind = 1
 SET reply->collist[7].header_text = "Catalog Type Display"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "activity_type_cd"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 SET reply->collist[9].header_text = "Activity Type Display"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET totcnt = 0
 SELECT INTO "nl:"
  tcnt = count(*)
  FROM order_catalog
  WHERE active_ind=1
  DETAIL
   totcnt = tcnt
  WITH nocounter
 ;end select
 SET missing_ct_cnt = 0
 SET missing_at_cnt = 0
 SET bad_combo_cnt = 0
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE o.active_ind=1
    AND o.catalog_cd > 0
    AND ((o.catalog_type_cd IN (null, 0)) OR (o.activity_type_cd IN (null, 0)
    AND  NOT (o.orderable_type_flag IN (2, 6)))) )
  DETAIL
   ocnt = (ocnt+ 1), stat = alterlist(temp->olist,ocnt), temp->olist[ocnt].catalog_cd = o.catalog_cd,
   temp->olist[ocnt].primary_mnemonic = o.primary_mnemonic
   IF (o.catalog_type_cd IN (null, 0))
    missing_ct_cnt = (missing_ct_cnt+ 1), temp->olist[ocnt].missing_ct_ind = 1
   ENDIF
   IF (o.activity_type_cd IN (null, 0)
    AND  NOT (o.orderable_type_flag IN (2, 6)))
    missing_at_cnt = (missing_at_cnt+ 1), temp->olist[ocnt].missing_at_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET t2cnt = 0
 SELECT DISTINCT INTO "nl:"
  o.catalog_type_cd, o.activity_type_cd
  FROM order_catalog o
  PLAN (o
   WHERE o.catalog_type_cd > 0
    AND o.activity_type_cd > 0)
  ORDER BY o.catalog_type_cd, o.activity_type_cd
  DETAIL
   t2cnt = (t2cnt+ 1), stat = alterlist(temp2->clist,t2cnt), temp2->clist[t2cnt].catalog_type_cd = o
   .catalog_type_cd,
   temp2->clist[t2cnt].activity_type_cd = o.activity_type_cd
  WITH nocounter
 ;end select
 IF (t2cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = t2cnt),
    code_value c1
   PLAN (d)
    JOIN (c1
    WHERE (c1.code_value=temp2->clist[d.seq].catalog_type_cd))
   DETAIL
    temp2->clist[d.seq].ct_cdf_meaning = c1.cdf_meaning, temp2->clist[d.seq].catalog_type_disp = c1
    .display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = t2cnt),
    code_value c1
   PLAN (d)
    JOIN (c1
    WHERE (c1.code_value=temp2->clist[d.seq].activity_type_cd))
   DETAIL
    temp2->clist[d.seq].at_definition = cnvtupper(c1.definition), temp2->clist[d.seq].
    activity_type_disp = c1.display
   WITH nocounter
  ;end select
  FOR (x = 1 TO t2cnt)
    IF ((temp2->clist[x].ct_cdf_meaning != temp2->clist[x].at_definition))
     SELECT INTO "nl:"
      FROM order_catalog o
      PLAN (o
       WHERE (o.catalog_type_cd=temp2->clist[x].catalog_type_cd)
        AND (o.activity_type_cd=temp2->clist[x].activity_type_cd)
        AND o.active_ind=1)
      DETAIL
       ocnt = (ocnt+ 1), bad_combo_cnt = (bad_combo_cnt+ 1), stat = alterlist(temp->olist,ocnt),
       temp->olist[ocnt].catalog_cd = o.catalog_cd, temp->olist[ocnt].primary_mnemonic = o
       .primary_mnemonic, temp->olist[ocnt].bad_combo_ind = 1,
       temp->olist[ocnt].catalog_type_cd = temp2->clist[x].catalog_type_cd, temp->olist[ocnt].
       catalog_type_disp = temp2->clist[x].catalog_type_disp, temp->olist[ocnt].activity_type_cd =
       temp2->clist[x].activity_type_cd,
       temp->olist[ocnt].activity_type_disp = temp2->clist[x].activity_type_disp
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 SET rcnt = 0
 IF (ocnt > 0)
  SELECT INTO "nl:"
   pn = cnvtupper(temp->olist[d.seq].primary_mnemonic)
   FROM (dummyt d  WITH seq = ocnt)
   ORDER BY pn
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,9),
    reply->rowlist[rcnt].celllist[1].double_value = temp->olist[d.seq].catalog_cd, reply->rowlist[
    rcnt].celllist[2].string_value = temp->olist[d.seq].primary_mnemonic
    IF ((temp->olist[d.seq].missing_ct_ind=1))
     reply->rowlist[rcnt].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].missing_at_ind=1))
     reply->rowlist[rcnt].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[4].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].bad_combo_ind=1))
     reply->rowlist[rcnt].celllist[5].string_value = "X", reply->rowlist[rcnt].celllist[6].
     double_value = temp->olist[d.seq].catalog_type_cd, reply->rowlist[rcnt].celllist[7].string_value
      = temp->olist[d.seq].catalog_type_disp,
     reply->rowlist[rcnt].celllist[8].double_value = temp->olist[d.seq].activity_type_cd, reply->
     rowlist[rcnt].celllist[9].string_value = temp->olist[d.seq].activity_type_disp
    ELSE
     reply->rowlist[rcnt].celllist[5].string_value = " "
    ENDIF
  ;end select
 ENDIF
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,3)
 SET reply->statlist[1].statistic_meaning = "ORCMISSINGCATTYPE"
 SET reply->statlist[1].total_items = totcnt
 SET reply->statlist[1].qualifying_items = missing_ct_cnt
 IF (missing_ct_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "ORCMISSINGACTIVITYTYPE"
 SET reply->statlist[2].total_items = totcnt
 SET reply->statlist[2].qualifying_items = missing_at_cnt
 IF (missing_at_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "ORCBADCATACTTYPECOMBO"
 SET reply->statlist[3].total_items = totcnt
 SET reply->statlist[3].qualifying_items = bad_combo_cnt
 IF (bad_combo_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
