CREATE PROGRAM edw_code_value:dba
 DECLARE v_bar = c1 WITH constant("|"), protect
 DECLARE line = vc
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 IF (code_value_cnt > 0)
  SELECT INTO value(cd_value_extractfile)
   n_active_ind = nullind(cv.active_ind)
   FROM code_value cv,
    code_value_set cvs,
    (dummyt d  WITH seq = value(code_value_cnt))
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=cd_value_keys->qual[d.seq].code_value))
    JOIN (cvs
    WHERE cvs.code_set=outerjoin(cv.code_set))
   DETAIL
    CASE (cv.code_set)
     OF 1031:
      new_code_set = "1901"
     OF 1905:
      new_code_set = "1031"
     OF 54:
      new_code_set = "240"
     OF 29820:
      new_code_set = "54"
     OF 29821:
      new_code_set = "4001"
     OF 29822:
      new_code_set = "97"
     OF 132038:
      new_code_set = "1010"
     OF 340:
      new_code_set = "54"
     ELSE
      new_code_set = cnvtstring(cv.code_set)
    ENDCASE
    code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
    v_bar,
    CALL print(trim(new_code_set)), v_bar,
    CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
    CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
    CALL print(trim(cnvtstring(cv.code_value,16))),
    v_bar,
    CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
    CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
    CALL print(trim(replace(cv.description,str_find,str_replace,3))),
    v_bar,
    CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
    "3", v_bar, extract_dt_tm_fmt,
    v_bar,
    CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
    v_bar, v_bar, v_bar,
    v_bar, v_bar, v_bar,
    CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))), v_bar,
    CALL print(trim(replace(cv.cki,str_find,str_replace,3))),
    v_bar,
    CALL print(trim(cnvtstring(cv.collation_seq,16))), v_bar,
    row + 1
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1, append
  ;end select
 ENDIF
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs,
   sch_appt_syn sas
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND  NOT (cv.code_set IN (72, 93, 14230, 14231, 1021,
   1022, 14250)))
   JOIN (cvs
   WHERE cvs.code_set=cv.code_set)
   JOIN (sas
   WHERE sas.appt_type_cd=outerjoin(cv.code_value))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,"PRIMARY_SYNONYM_IND",blank_field))),
   v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,cnvtstring(sas.primary_ind),blank_field))), v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,"APPT_TYPE_REF",blank_field))), v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,cnvtstring(sas.appt_type_cd,16),"0"))),
   v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,"INACTIVE_SYNONYM_FLG",blank_field))), v_bar,
   CALL print(trim(evaluate(cv.code_set,14249,cnvtstring(sas.allow_selection_flag),blank_field))),
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))),
   v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))), v_bar, row + 1
  FOOT REPORT
   code_value_cnt = (code_value_cnt+ 1), line = "", line = build(health_system_source_id,v_bar,"333",
    v_bar,"Encounter/Personnel Relation",
    v_bar,v_bar,v_bar,"CV_CODING",v_bar,
    v_bar,"Coding Provider",v_bar,"Coding Provider",v_bar,
    "Coding Provider",v_bar,"13",v_bar,extract_dt_tm_fmt,
    v_bar,v_bar,v_bar,v_bar,v_bar,
    v_bar,v_bar,v_bar,"1",v_bar,
    v_bar,v_bar),
   col 0, line, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(ek.active_ind)
  FROM eks_dlg ek
  PLAN (ek
   WHERE ek.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), ektitle = replace(ek.title,str_find,str_replace,3), col 0,
   health_system_source_id, v_bar, "EDW_1",
   v_bar, "Alerts", v_bar,
   v_bar, v_bar,
   CALL print(trim(replace(ek.dlg_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(substring(1,45,replace(ek.dlg_name,str_find,str_replace,3)))), v_bar,
   CALL print(trim(substring(1,45,ektitle))), v_bar,
   CALL print(trim(substring(1,100,ektitle))),
   v_bar,
   CALL print(trim(substring(1,255,ektitle))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(ek.active_ind),blank_field))),
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  FROM oe_field_meaning ofm
  PLAN (ofm
   WHERE ofm.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), oedescription = replace(ofm.description,str_find,str_replace,
    3), col 0,
   health_system_source_id, v_bar, "EDW_2",
   v_bar, "Order Entry Field Meaning", v_bar,
   v_bar, v_bar,
   CALL print(trim(cnvtstring(ofm.oe_field_meaning_id,16))),
   v_bar,
   CALL print(trim(substring(1,45,replace(ofm.oe_field_meaning,str_find,str_replace,3)))), v_bar,
   CALL print(trim(substring(1,45,oedescription))), v_bar,
   CALL print(trim(substring(1,100,oedescription))),
   v_bar,
   CALL print(trim(substring(1,255,oedescription))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, "1",
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set IN (54, 1031, 1905, 29820, 29821,
   29822, 132038, 340))
   JOIN (cvs
   WHERE cvs.code_set=outerjoin(cv.code_set))
  DETAIL
   CASE (cv.code_set)
    OF 1031:
     new_code_set = "1901"
    OF 1905:
     new_code_set = "1031"
    OF 54:
     new_code_set = "240"
    OF 29820:
     new_code_set = "54"
    OF 29821:
     new_code_set = "4001"
    OF 29822:
     new_code_set = "97"
    OF 132038:
     new_code_set = "1010"
    OF 340:
     new_code_set = "54"
   ENDCASE
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(new_code_set)), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))), v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   v500_event_code vec,
   code_value_set cvs
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set=72)
   JOIN (vec
   WHERE vec.event_cd=outerjoin(cv.code_value))
   JOIN (cvs
   WHERE cvs.code_set=outerjoin(cv.code_set))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(vec.event_set_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))),
   v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs,
   v500_event_set_code vesc
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set=93)
   JOIN (cvs
   WHERE cvs.code_set=outerjoin(cv.code_set))
   JOIN (vesc
   WHERE vesc.event_set_cd=outerjoin(cv.code_value))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(vesc.event_set_name,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, "Display_Association_Ind",
   v_bar,
   CALL print(trim(cnvtstring(vesc.display_association_ind,16))), v_bar,
   v_bar, v_bar, v_bar,
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))), v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT DISTINCT INTO value(cd_value_extractfile)
  FROM pathway_catalog pc
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND pc.type_mean > ""
    AND pc.type_mean != null)
  ORDER BY pc.type_mean
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), typemean = replace(pc.type_mean,str_find,str_replace,3), col
    0,
   health_system_source_id, v_bar, "EDW_3",
   v_bar, "Pathway Catalog Types", v_bar,
   v_bar, v_bar,
   CALL print(trim(substring(1,40,typemean))),
   v_bar,
   CALL print(trim(substring(1,45,typemean))), v_bar,
   CALL print(trim(substring(1,45,typemean))), v_bar,
   CALL print(trim(substring(1,100,typemean))),
   v_bar,
   CALL print(trim(substring(1,255,typemean))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(build(1)),
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT DISTINCT INTO value(cd_value_extractfile)
  os.rx_type_mean
  FROM order_sentence os
  WHERE os.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
   AND trim(os.rx_type_mean) > " "
   AND os.rx_type_mean != null
  ORDER BY os.rx_type_mean
  HEAD os.rx_type_mean
   code_value_cnt = (code_value_cnt+ 1), rx_type_mean = replace(os.rx_type_mean,str_find,str_replace,
    3), col 0,
   health_system_source_id, v_bar, "EDW_4",
   v_bar, "RX Types for order sentences", v_bar,
   v_bar, v_bar,
   CALL print(trim(rx_type_mean)),
   v_bar,
   CALL print(trim(rx_type_mean)), v_bar,
   CALL print(trim(rx_type_mean)), v_bar,
   CALL print(trim(rx_type_mean)),
   v_bar,
   CALL print(trim(rx_type_mean)), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, v_bar,
   v_bar, v_bar, "1",
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cn.active_ind)
  FROM class_node cn
  WHERE cn.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_5", v_bar,
   "Classication Node for item", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(cn.class_node_id,16))), v_bar,
   v_bar,
   CALL print(trim(replace(cn.short_description,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cn.description,str_find,str_replace,3))), v_bar, v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, "CLASSIFICATION_TYPE_REF",
   v_bar,
   CALL print(trim(cnvtstring(cn.class_type_cd,16))), v_bar,
   "CLASSIFICATION_INSTANCE_REF", v_bar,
   CALL print(trim(cnvtstring(cn.class_instance_cd,16))),
   v_bar, v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cn.active_ind),blank_field))), v_bar, v_bar,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(pg.active_ind)
  FROM prsnl_group pg
  WHERE pg.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_6", v_bar,
   "Personnel Group", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(pg.prsnl_group_id,16))), v_bar,
   v_bar, v_bar,
   CALL print(trim(replace(pg.prsnl_group_name,str_find,str_replace,3))),
   v_bar, v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   v_bar, "PRSNL_GROUP_CLASS_REF", v_bar,
   CALL print(trim(cnvtstring(pg.prsnl_group_class_cd,16))), v_bar, "PRSNL_GROUP_TYPE_REF",
   v_bar,
   CALL print(trim(cnvtstring(pg.prsnl_group_type_cd,16))), v_bar,
   "SERVICE_RESOURCE_REF", v_bar,
   CALL print(trim(cnvtstring(pg.service_resource_cd,16))),
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(pg.active_ind),blank_field))), v_bar,
   v_bar, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs,
   sch_role sr,
   long_text_reference ltr
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set=14250)
   JOIN (cvs
   WHERE cvs.code_set=cv.code_set)
   JOIN (sr
   WHERE sr.sch_role_cd=outerjoin(cv.code_value))
   JOIN (ltr
   WHERE outerjoin(sr.info_sch_text_id)=ltr.long_text_id)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, "Additional_Information_Txt",
   v_bar,
   CALL print(trim(replace(cnvtstring(substring(1,255,ltr.long_text)),str_find,str_replace,3))),
   v_bar,
   v_bar, v_bar, v_bar,
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))), v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(srg.active_ind)
  FROM sch_res_group srg,
   long_text_reference ltr,
   sch_res_type srt
  PLAN (srg
   WHERE srg.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (ltr
   WHERE outerjoin(srg.info_sch_text_id)=ltr.long_text_id)
   JOIN (srt
   WHERE outerjoin(srg.res_group_id)=srt.res_group_id)
  ORDER BY srg.res_group_id
  HEAD srg.res_group_id
   reporting_ind = 0, inquiry_ind = 0
  DETAIL
   IF (srt.res_group_meaning="REPORTING")
    reporting_ind = 1
   ENDIF
   IF (srt.res_group_meaning="INQUIRY")
    inquiry_ind = 1
   ENDIF
  FOOT  srg.res_group_id
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_8", v_bar,
   "Resource Group", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(srg.res_group_id,16))), v_bar,
   v_bar,
   CALL print(replace(trim(substring(1,45,srg.mnemonic)),str_find,str_replace,3)), v_bar,
   CALL print(trim(replace(srg.mnemonic,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(srg.description,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, v_bar,
   "Additional_Information_Txt", v_bar,
   CALL print(trim(replace(substring(1,255,ltr.long_text),str_find,str_replace,3))),
   v_bar, "Reporting_Group_Type_Ind", v_bar,
   CALL print(build(reporting_ind)), v_bar, "Inquiry_Group_Type_Ind",
   v_bar,
   CALL print(build(inquiry_ind)), v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(srg.active_ind),blank_field))), v_bar, v_bar,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(sab.active_ind)
  FROM sch_appt_book sab,
   long_text_reference ltr
  PLAN (sab
   WHERE sab.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (ltr
   WHERE sab.info_sch_text_id=ltr.long_text_id)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_9", v_bar,
   "Appointment Books", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(sab.appt_book_id,16))), v_bar,
   v_bar,
   CALL print(trim(replace(substring(1,45,sab.mnemonic),str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(sab.mnemonic,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(sab.description,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, v_bar,
   "Additional_Information_Txt", v_bar,
   CALL print(trim(replace(substring(1,255,ltr.long_text),str_find,str_replace,3))),
   v_bar, "Default_Appt_Type_Synonym_Ref", v_bar,
   CALL print(trim(cnvtstring(sab.appt_synonym_cd,16))), v_bar, "Appt_Type_Dtl_SK",
   v_bar,
   CALL print(trim(cnvtstring(sab.appt_type_cd))), v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(sab.active_ind),blank_field))), v_bar, v_bar,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(ssg.active_ind)
  FROM sch_slot_group ssg,
   long_text_reference ltr
  PLAN (ssg
   WHERE ssg.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   JOIN (ltr
   WHERE ssg.info_sch_text_id=ltr.long_text_id)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_10", v_bar,
   "Slot Type Groups", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(ssg.slot_group_id,16))), v_bar,
   v_bar,
   CALL print(trim(replace(substring(1,45,ssg.mnemonic),str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(ssg.mnemonic,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(ssg.description,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, v_bar,
   "Additional_Information_Txt", v_bar,
   CALL print(trim(replace(substring(1,255,ltr.long_text),str_find,str_replace,3))),
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(ssg.active_ind),blank_field))),
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(so.active_ind)
  FROM sch_object so,
   long_text_reference ltr
  PLAN (so
   WHERE so.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND so.object_type_meaning="ATGROUP")
   JOIN (ltr
   WHERE so.info_sch_text_id=ltr.long_text_id)
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar, "EDW_11", v_bar,
   "Appointment Type Groups", v_bar, v_bar,
   v_bar,
   CALL print(trim(cnvtstring(so.sch_object_id,16))), v_bar,
   v_bar,
   CALL print(trim(replace(substring(1,45,so.mnemonic),str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(so.mnemonic,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(so.description,str_find,str_replace,3))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, v_bar,
   "Additional_Information_Txt", v_bar,
   CALL print(trim(replace(substring(1,255,ltr.long_text),str_find,str_replace,3))),
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(so.active_ind),blank_field))),
   v_bar, v_bar, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(ed.active_ind)
  FROM eks_dlg_event ede,
   eks_dlg ed
  PLAN (ede
   WHERE ede.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND ede.dlg_name > " ")
   JOIN (ed
   WHERE ed.dlg_name=outerjoin(ede.dlg_name))
  ORDER BY ede.dlg_name
  HEAD ede.dlg_name
   IF (ed.dlg_name=null)
    code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
    v_bar, "EDW_1", v_bar,
    "Alerts", v_bar, v_bar,
    v_bar,
    CALL print(trim(replace(ede.dlg_name,str_find,str_replace,3))), v_bar,
    CALL print(trim(substring(1,45,replace(ede.dlg_name,str_find,str_replace,3)))), v_bar,
    CALL print(trim(substring(1,45,replace(ede.dlg_name,str_find,str_replace,3)))),
    v_bar,
    CALL print(trim(substring(1,100,replace(ede.dlg_name,str_find,str_replace,3)))), v_bar,
    CALL print(trim(substring(1,255,replace(ede.dlg_name,str_find,str_replace,3)))), v_bar, "3",
    v_bar, extract_dt_tm_fmt, v_bar,
    v_bar, v_bar, v_bar,
    v_bar, v_bar, v_bar,
    v_bar,
    CALL print(trim(evaluate(n_active_ind,0,build(ed.active_ind),blank_field))), v_bar,
    v_bar, v_bar, row + 1
   ENDIF
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO "nl:"
  FROM dtableattr tab
  WHERE tab.table_name="TRACK_PREARRIVAL_FIELD"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO value(cd_value_extractfile)
   FROM track_prearrival_field tpf
   PLAN (tpf
    WHERE tpf.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
   DETAIL
    code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
    v_bar, "EDW_7", v_bar,
    "Tracking Prearrival User Defined Fields", v_bar, v_bar,
    v_bar,
    CALL print(trim(cnvtstring(tpf.track_prearrival_field_id,16))), v_bar,
    CALL print(trim(replace(tpf.field_meaning,str_find,str_replace,3))), v_bar,
    CALL print(trim(replace(tpf.field_name,str_find,str_replace,3))),
    v_bar, v_bar, v_bar,
    "3", v_bar,
    CALL print(trim(extract_dt_tm_fmt)),
    v_bar, v_bar, "FIELD_TYPE_REF",
    v_bar,
    CALL print(trim(cnvtstring(tpf.field_type_cd,16))), v_bar,
    "CUSTOM_IND", v_bar,
    CALL print(trim(cnvtstring(tpf.custom_ind,16))),
    v_bar, "REFERENCE_CODE_SET_NBR", v_bar,
    CALL print(trim(cnvtstring(tpf.code_set,16))), v_bar, "1",
    v_bar, v_bar, v_bar,
    row + 1
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1, append
  ;end select
 ENDIF
 SELECT INTO value(cd_value_extractfile)
  n_positive_ind = nullind(mod.positive_ind), n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs,
   mic_organism_data mod
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set=1021)
   JOIN (cvs
   WHERE cvs.code_set=outerjoin(cv.code_set))
   JOIN (mod
   WHERE mod.organism_id=outerjoin(cv.code_value))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, "Positive_Ind",
   v_bar,
   CALL print(trim(evaluate(n_positive_ind,0,build(mod.positive_ind),"0"))), v_bar,
   v_bar, v_bar, v_bar,
   v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))), v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.collation_seq,16))),
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SELECT INTO value(cd_value_extractfile)
  n_active_ind = nullind(cv.active_ind)
  FROM code_value cv,
   code_value_set cvs
  PLAN (cv
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
    AND cv.code_set=1022)
   JOIN (cvs
   WHERE cvs.code_set=outerjoin(cv.code_set))
  DETAIL
   code_value_cnt = (code_value_cnt+ 1), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(cnvtstring(cv.code_set,16))), v_bar,
   CALL print(trim(replace(cvs.description,str_find,str_replace,3))), v_bar, v_bar,
   CALL print(trim(replace(cv.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(cv.code_value,16))),
   v_bar,
   CALL print(trim(replace(cv.cdf_meaning,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.display,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(cv.description,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(cv.definition,str_find,str_replace,3))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, v_bar, "Positive_Ind",
   v_bar
   IF (cnvtupper(cv.definition)="NEGATIVE IND")
    "0"
   ELSEIF (((cv.definition=null) OR (cv.definition="")) )
    "1"
   ELSE
    ""
   ENDIF
   v_bar, v_bar, v_bar,
   v_bar, v_bar,
   CALL print(trim(evaluate(n_active_ind,0,build(cv.active_ind),blank_field))),
   v_bar,
   CALL print(trim(replace(cv.cki,str_find,str_replace,3))), v_bar,
   CALL print(build(cv.collation_seq)), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 CALL echo(build("CD_VALUE Count = ",code_value_cnt))
 CALL edwupdatescriptstatus("CD_VALUE",code_value_cnt,"33","33")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "033 09/14/16 mf025696"
END GO
