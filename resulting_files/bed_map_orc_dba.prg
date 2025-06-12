CREATE PROGRAM bed_map_orc:dba
 RECORD ocwork(
   1 ocwork_list[*]
     2 short_desc = c100
     2 match_ord_cd = f8
 )
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SET contributor_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  WHERE c.code_set=73
   AND c.display_key="MIGRATION"
   AND c.active_ind=1
  DETAIL
   contributor_cd = c.code_value
  WITH nocounter
 ;end select
 IF (contributor_cd=0.0)
  SET contributor_cd = 0.0
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    contributor_cd = cnvtreal(y)
   WITH format, counter
  ;end select
  INSERT  FROM code_value cv
   SET cv.code_value = contributor_cd, cv.code_set = 73, cv.cdf_meaning = " ",
    cv.display = "MIGRATION", cv.display_key = "MIGRATION", cv.description = "MIGRATION",
    cv.definition = "MIGRATION", cv.collation_seq = 0, cv.active_type_cd = active_cd,
    cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    cv.updt_id = reqinfo->updt_id, cv.updt_cnt = 0, cv.updt_task = reqinfo->updt_task,
    cv.updt_applctx = reqinfo->updt_applctx, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime),
    cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    cv.data_status_cd = auth_cd, cv.data_status_prsnl_id = 0.0, cv.active_status_prsnl_id = 0.0,
    cv.cki = " ", cv.display_key_nls = " ", cv.concept_cki = " "
   WITH nocounter
  ;end insert
 ENDIF
 SET tot_ocwork = 0
 SELECT INTO "nl:"
  brocw.short_desc, brocw.match_orderable_cd
  FROM br_oc_work brocw
  WHERE brocw.match_orderable_cd > 0
  DETAIL
   tot_ocwork = (tot_ocwork+ 1), stat = alterlist(ocwork->ocwork_list,tot_ocwork), ocwork->
   ocwork_list[tot_ocwork].short_desc = brocw.short_desc,
   ocwork->ocwork_list[tot_ocwork].match_ord_cd = brocw.match_orderable_cd
  WITH nocounter
 ;end select
 SET ocworkvar = 1
 WHILE (ocworkvar <= tot_ocwork)
  INSERT  FROM code_value_alias cva
   SET cva.code_value = ocwork->ocwork_list[ocworkvar].match_ord_cd, cva.code_set = 200, cva.alias =
    ocwork->ocwork_list[ocworkvar].short_desc,
    cva.alias_type_meaning = "ORDERABLE", cva.contributor_source_cd = contributor_cd, cva.updt_cnt =
    0,
    cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_applctx = reqinfo->updt_applctx, cva
    .updt_id = reqinfo->updt_id,
    cva.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET ocworkvar = (ocworkvar+ 1)
 ENDWHILE
END GO
