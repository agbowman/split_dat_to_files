CREATE PROGRAM bed_aud_phasex_rad_orc_match:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 fcnt = i2
   1 fqual[*]
     2 facility = vc
     2 cnt = i2
     2 qual[*]
       3 id = f8
       3 alias = vc
       3 activity_type = vc
       3 desc = vc
       3 mnemonic = vc
       3 match = vc
       3 add = vc
       3 oc_desc = vc
       3 oc_cd = f8
       3 synonym = vc
       3 remove = vc
       3 match_ind = i2
       3 match_cd = f8
       3 concept_cki = vc
       3 bed_name = vc
       3 bed_desc = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_oc_work b
   PLAN (b
    WHERE b.catalog_type="RAD*")
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET cat_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6000
    AND c.cdf_meaning="RADIOLOGY"
    AND c.active_ind=1)
  DETAIL
   cat_cd = c.code_value
  WITH nocounter
 ;end select
 SET new_phase_x_match_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value br,
   dummyt d
  PLAN (br
   WHERE br.br_nv_key1="NEW_PHASE_X_MATCH")
   JOIN (d
   WHERE cnvtint(br.br_name)=cat_cd)
  DETAIL
   new_phase_x_match_ind = 1
  WITH nocounter
 ;end select
 SET fcnt = 0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_oc_work b,
   dummyt d,
   br_name_value nv,
   code_value_alias a,
   order_catalog oc
  PLAN (b
   WHERE b.catalog_type="RAD*")
   JOIN (d)
   JOIN (nv
   WHERE nv.br_nv_key1="REL_CONTRIBUTOR_FACILITY"
    AND nv.br_value=b.facility)
   JOIN (a
   WHERE a.code_set=200
    AND a.contributor_source_cd=cnvtint(nv.br_name)
    AND ((a.alias=b.alias1) OR (a.alias=b.alias2)) )
   JOIN (oc
   WHERE oc.catalog_cd=a.code_value)
  ORDER BY cnvtupper(b.facility), cnvtupper(b.catalog_type), cnvtupper(b.activity_type),
   cnvtupper(b.short_desc)
  HEAD b.facility
   cnt = 0, fcnt = (fcnt+ 1), temp->fcnt = fcnt,
   stat = alterlist(temp->fqual,fcnt), temp->fqual[fcnt].facility = b.facility
  DETAIL
   cnt = (cnt+ 1), temp->fqual[fcnt].cnt = cnt, stat = alterlist(temp->fqual[fcnt].qual,cnt),
   temp->fqual[fcnt].qual[cnt].activity_type = b.activity_type
   IF (b.alias1 > " ")
    temp->fqual[fcnt].qual[cnt].alias = b.alias1
   ELSE
    temp->fqual[fcnt].qual[cnt].alias = b.alias2
   ENDIF
   temp->fqual[fcnt].qual[cnt].id = b.oc_id
   IF (b.org_long_name > " ")
    temp->fqual[fcnt].qual[cnt].desc = b.org_long_name
   ELSE
    temp->fqual[fcnt].qual[cnt].desc = b.long_desc
   ENDIF
   IF (b.org_short_name > " ")
    temp->fqual[fcnt].qual[cnt].mnemonic = b.org_short_name
   ELSE
    temp->fqual[fcnt].qual[cnt].mnemonic = b.short_desc
   ENDIF
   IF (b.status_ind=3)
    temp->fqual[fcnt].qual[cnt].remove = "X"
   ENDIF
   temp->fqual[fcnt].qual[cnt].match_cd = b.match_orderable_cd, temp->fqual[fcnt].qual[cnt].oc_desc
    = oc.description, temp->fqual[fcnt].qual[cnt].oc_cd = oc.catalog_cd,
   temp->fqual[fcnt].qual[cnt].synonym = oc.primary_mnemonic
   IF (b.match_ind > 0)
    temp->fqual[fcnt].qual[cnt].match = "Matched"
   ELSE
    temp->fqual[fcnt].qual[cnt].match = "Not Matched"
   ENDIF
   IF (b.match_orderable_cd > 0)
    IF ((temp->fqual[fcnt].qual[cnt].oc_cd > 0))
     temp->fqual[fcnt].qual[cnt].add = "Not Added"
    ELSE
     temp->fqual[fcnt].qual[cnt].add = "Added"
    ENDIF
   ELSE
    temp->fqual[fcnt].qual[cnt].add = "Not Added"
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 FOR (x = 1 TO fcnt)
  SET cnt = size(temp->fqual[x].qual,5)
  IF (cnt > 0)
   IF (new_phase_x_match_ind=0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt)),
      br_auto_order_catalog oc
     PLAN (d
      WHERE (temp->fqual[x].qual[d.seq].match_ind=0)
       AND (temp->fqual[x].qual[d.seq].match_cd > 0))
      JOIN (oc
      WHERE (oc.catalog_cd=temp->fqual[x].qual[d.seq].match_cd))
     ORDER BY d.seq
     HEAD d.seq
      temp->fqual[x].qual[d.seq].bed_name = oc.primary_mnemonic, temp->fqual[x].qual[d.seq].bed_desc
       = oc.description, temp->fqual[x].qual[d.seq].concept_cki = oc.concept_cki,
      temp->fqual[x].qual[d.seq].match_ind = 1
     WITH nocounter, skipbedrock = 1
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt)),
      order_catalog oc
     PLAN (d
      WHERE (temp->fqual[x].qual[d.seq].match_ind=0)
       AND (temp->fqual[x].qual[d.seq].match_cd > 0))
      JOIN (oc
      WHERE (oc.catalog_cd=temp->fqual[x].qual[d.seq].match_cd))
     ORDER BY d.seq
     HEAD d.seq
      temp->fqual[x].qual[d.seq].oc_desc = oc.description, temp->fqual[x].qual[d.seq].oc_cd = oc
      .catalog_cd, temp->fqual[x].qual[d.seq].synonym = oc.primary_mnemonic,
      temp->fqual[x].qual[d.seq].match_ind = 1
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt)),
      br_auto_order_catalog oc
     PLAN (d)
      JOIN (oc
      WHERE (oc.catalog_cd=temp->fqual[x].qual[d.seq].match_cd))
     ORDER BY d.seq
     HEAD d.seq
      temp->fqual[x].qual[d.seq].bed_name = oc.primary_mnemonic, temp->fqual[x].qual[d.seq].bed_desc
       = oc.description, temp->fqual[x].qual[d.seq].concept_cki = oc.concept_cki
     WITH nocounter, skipbedrock = 1
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(cnt)),
      br_name_value b,
      order_catalog oc,
      dummyt d1,
      dummyt d2
     PLAN (d)
      JOIN (b
      WHERE b.br_nv_key1="PHASE_X_MATCH")
      JOIN (d2
      WHERE (cnvtint(trim(b.br_name))=temp->fqual[x].qual[d.seq].id))
      JOIN (oc)
      JOIN (d1
      WHERE oc.catalog_cd=cnvtint(b.br_value))
     ORDER BY d.seq
     HEAD d.seq
      temp->fqual[x].qual[d.seq].oc_desc = oc.description, temp->fqual[x].qual[d.seq].oc_cd = oc
      .catalog_cd, temp->fqual[x].qual[d.seq].synonym = oc.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "Facility"
 SET reply->collist[1].data_type = 1
 IF (fcnt > 1)
  SET reply->collist[1].hide_ind = 0
 ELSE
  SET reply->collist[1].hide_ind = 1
 ENDIF
 SET reply->collist[2].header_text = "Activity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Legacy Mnemonic"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Legacy Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Millennium Name (Primary Description)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Millennium Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Order Catalog CD"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 1
 SET reply->collist[8].header_text = "Match"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Added"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Bedrock Name"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Bedrock Description"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Remove"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO fcnt)
  SET cnt = size(temp->fqual[x].qual,5)
  FOR (y = 1 TO cnt)
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,12)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->fqual[x].facility
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->fqual[x].qual[y].activity_type
    SET reply->rowlist[row_nbr].celllist[3].string_value = temp->fqual[x].qual[y].mnemonic
    SET reply->rowlist[row_nbr].celllist[4].string_value = temp->fqual[x].qual[y].desc
    SET reply->rowlist[row_nbr].celllist[5].string_value = temp->fqual[x].qual[y].synonym
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->fqual[x].qual[y].oc_desc
    SET reply->rowlist[row_nbr].celllist[7].double_value = temp->fqual[x].qual[y].oc_cd
    SET reply->rowlist[row_nbr].celllist[8].string_value = temp->fqual[x].qual[y].match
    SET reply->rowlist[row_nbr].celllist[9].string_value = temp->fqual[x].qual[y].add
    SET reply->rowlist[row_nbr].celllist[10].string_value = temp->fqual[x].qual[y].bed_name
    SET reply->rowlist[row_nbr].celllist[11].string_value = temp->fqual[x].qual[y].bed_desc
    SET reply->rowlist[row_nbr].celllist[12].string_value = temp->fqual[x].qual[y].remove
  ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("x_rad_orc_match_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
