CREATE PROGRAM dcp_add_dta_version:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD old_info
 RECORD old_info(
   1 valid_from_dt_tm = dq8
 )
 FREE RECORD tmp
 RECORD tmp(
   1 qual[*]
     2 ref_id = f8
     2 string = vc
   1 qual_cnt = i4
 )
 SET modify maxvarlen 225000000
 SET modify = predeclare
 DECLARE errmsg = c132 WITH private, noconstant(fillstring(132," "))
 DECLARE mnstat = i4 WITH private, noconstant(0)
 DECLARE vfailed = c1 WITH private, noconstant(" ")
 DECLARE flag = i4 WITH private, noconstant(0)
 DECLARE xmlstring = vc WITH noconstant(" ")
 DECLARE xmlstringcompressed = vc WITH noconstant(" ")
 DECLARE label_template_id = f8 WITH noconstant(0.0)
 DECLARE dta_version_number = f8 WITH noconstant(0.0)
 DECLARE new_dta_version_id = f8 WITH noconstant(0.0)
 DECLARE new_long_blob_id = f8 WITH noconstant(0.0)
 DECLARE length = i4 WITH noconstant(0)
 DECLARE icnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET xmlstring = "<?xml version='1.0'?>"
 SET vfailed = "F"
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE (dta.task_assay_cd=request->task_assay_cd)
  DETAIL
   xmlstring = build(xmlstring,"<dta>"), xmlstring = build(xmlstring,"<description>",replace(replace(
      dta.description,"&","&amp;",0),"<","&lt;",0),"</description>"), xmlstring = build(xmlstring,
    "<version_number>",dta.version_number,"</version_number>"),
   xmlstring = build(xmlstring,"<activity_type_cd>",uar_get_code_display(dta.activity_type_cd),
    "</activity_type_cd>"), xmlstring = build(xmlstring,"<default_result_type_cd>",
    uar_get_code_display(dta.default_result_type_cd),"</default_result_type_cd>"), xmlstring = build(
    xmlstring,"<event_cd>",replace(replace(uar_get_code_display(dta.event_cd),"&","&amp;",0),"<",
     "&lt;",0),"</event_cd>"),
   xmlstring = build(xmlstring,"<task_assay_cd>",dta.task_assay_cd,"</task_assay_cd>"), xmlstring =
   build(xmlstring,"<modifier_ind>",dta.modifier_ind,"</modifier_ind>"), xmlstring = build(xmlstring,
    "<single_select_ind>",dta.single_select_ind,"</single_select_ind>"),
   xmlstring = build(xmlstring,"<default_type_flag>",dta.default_type_flag,"</default_type_flag>"),
   xmlstring = build(xmlstring,"<strt_assay_id>",dta.strt_assay_id,"</strt_assay_id>"), xmlstring =
   build(xmlstring,"<io_flag>",dta.io_flag,"</io_flag>"),
   xmlstring = build(xmlstring,"<template_script_cd>",validate(dta.template_script_cd,0.0),
    "</template_script_cd>"), xmlstring = build(xmlstring,"<label_template_id>",dta.label_template_id,
    "</label_template_id>"), label_template_id = dta.label_template_id,
   dta_version_number = dta.version_number, old_info->valid_from_dt_tm = dta.updt_dt_tm
  WITH nocounter, forupdate(dta)
 ;end select
 IF (curqual=0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DISCRETE_TASK_ASSAY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE (cve.code_value=request->task_assay_cd)
  DETAIL
   IF (curqual=0)
    xmlstring = build(xmlstring,"<witness_required_ind>",0,"</witness_required_ind>")
   ELSE
    xmlstring = build(xmlstring,"<witness_required_ind>",1,"</witness_required_ind>")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dynamic_label_template dlt,
   doc_set_ref dsr
  PLAN (dlt
   WHERE dlt.label_template_id=label_template_id)
   JOIN (dsr
   WHERE dlt.doc_set_ref_id=dsr.doc_set_ref_id)
  DETAIL
   xmlstring = build(xmlstring,"<Doc_Set_Description>",dsr.doc_set_description,
    "</Doc_Set_Description>")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  rrf.reference_range_factor_id, arc.alpha_responses_category_id, category_exists = evaluate(nullind(
    arc.alpha_responses_category_id),0,1,0),
  alph.reference_range_factor_id, alph_exists = evaluate(nullind(alph.reference_range_factor_id),0,1,
   0), disp_sex_cd = uar_get_code_display(rrf.sex_cd),
  disp_units_cd = uar_get_code_display(rrf.units_cd), alph_cat = alph.alpha_responses_category_id,
  arc_cat = arc.alpha_responses_category_id
  FROM reference_range_factor rrf,
   alpha_responses_category arc,
   alpha_responses alph
  PLAN (rrf
   WHERE (rrf.task_assay_cd=request->task_assay_cd)
    AND rrf.active_ind=1)
   JOIN (arc
   WHERE (arc.reference_range_factor_id= Outerjoin(rrf.reference_range_factor_id)) )
   JOIN (alph
   WHERE (alph.reference_range_factor_id= Outerjoin(rrf.reference_range_factor_id))
    AND (alph.active_ind= Outerjoin(1)) )
  ORDER BY rrf.reference_range_factor_id, arc.alpha_responses_category_id, alph.sequence
  HEAD rrf.reference_range_factor_id
   icnt += 1
   IF (icnt > size(tmp->qual,5))
    mnstat = alterlist(tmp->qual,(icnt+ 5))
   ENDIF
   tmp->qual[icnt].ref_id = rrf.reference_range_factor_id, tmp->qual[icnt].string = build(tmp->qual[
    icnt].string,"<reference_range_factor>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<sex_cd>",disp_sex_cd,"</sex_cd>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<age_from_minutes>",rrf.age_from_minutes,
    "</age_from_minutes>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<age_to_minutes>",
    rrf.age_to_minutes,"</age_to_minutes>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<units_cd>",disp_units_cd,"</units_cd>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<default_result>",rrf.default_result,
    "</default_result>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<review_low>",rrf
    .review_low,"</review_low>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<review_high>",rrf.review_high,"</review_high>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<sensitive_low>",rrf.sensitive_low,
    "</sensitive_low>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<sensitive_high>",rrf
    .sensitive_high,"</sensitive_high>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<normal_low>",rrf.normal_low,"</normal_low>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<normal_high>",rrf.normal_high,
    "</normal_high>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<critical_low>",rrf
    .critical_low,"</critical_low>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<critical_high>",rrf.critical_high,"</critical_high>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<linear_low>",rrf.linear_low,
    "</linear_low>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<linear_high>",rrf
    .linear_high,"</linear_high>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,
    "<feasible_low>",rrf.feasible_low,"</feasible_low>"),
   tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<feasible_high>",rrf.feasible_high,
    "</feasible_high>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<mins_back>",rrf
    .mins_back,"</mins_back>")
  HEAD arc.alpha_responses_category_id
   IF (category_exists)
    tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<dta_alpha_category>"), tmp->qual[icnt].
    string = build(tmp->qual[icnt].string,"<category_id>",arc.alpha_responses_category_id,
     "</category_id>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<category_name>",arc
     .category_name,"</category_name>"),
    tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<display_seq>",arc.display_seq,
     "</display_seq>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<expand_flag>",arc
     .expand_flag,"</expand_flag>")
   ENDIF
  DETAIL
   IF (alph_exists)
    IF (alph_cat=arc_cat)
     tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<alpha_response>")
     IF (alph.description > " ")
      tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<description>",alph.description,
       "</description>")
     ENDIF
     tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<category_id>",alph
      .alpha_responses_category_id,"</category_id>"), tmp->qual[icnt].string = build(tmp->qual[icnt].
      string,"<result_value>",alph.result_value,"</result_value>"), tmp->qual[icnt].string = build(
      tmp->qual[icnt].string,"<sequence>",alph.sequence,"</sequence>"),
     tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<default_ind>",alph.default_ind,
      "</default_ind>"), tmp->qual[icnt].string = build(tmp->qual[icnt].string,"<nomenclature_id>",
      alph.nomenclature_id,"</nomenclature_id>"), tmp->qual[icnt].string = build(tmp->qual[icnt].
      string,"</alpha_response>")
    ENDIF
   ENDIF
  FOOT  arc.alpha_responses_category_id
   IF (category_exists)
    tmp->qual[icnt].string = build(tmp->qual[icnt].string,"</dta_alpha_category>")
   ENDIF
  WITH nocounter
 ;end select
 SET tmp->qual_cnt = icnt
 SET mnstat = alterlist(tmp->qual,icnt)
 SELECT INTO "nl:"
  rule_exists = evaluate(nullind(rrfr.reference_range_factor_id),0,1,0)
  FROM ref_range_factor_rule rrfr,
   alpha_response_rule arr,
   reference_range_factor rrf
  PLAN (rrf
   WHERE (rrf.task_assay_cd=request->task_assay_cd)
    AND rrf.active_ind=1)
   JOIN (rrfr
   WHERE (rrfr.reference_range_factor_id= Outerjoin(rrf.reference_range_factor_id)) )
   JOIN (arr
   WHERE (arr.ref_range_factor_rule_id= Outerjoin(rrfr.ref_range_factor_rule_id)) )
  ORDER BY rrf.reference_range_factor_id, rrfr.ref_range_factor_rule_id
  HEAD rrf.reference_range_factor_id
   num += 1
  HEAD rrfr.ref_range_factor_rule_id
   IF (rule_exists)
    IF (rrfr.ref_range_factor_rule_id != 0)
     tmp->qual[num].string = build(tmp->qual[num].string,"<ref_range_factor_rule>"), tmp->qual[num].
     string = build(tmp->qual[num].string,"<normal_low>",rrfr.normal_low,"</normal_low>"), tmp->qual[
     num].string = build(tmp->qual[num].string,"<normal_high>",rrfr.normal_high,"</normal_high>"),
     tmp->qual[num].string = build(tmp->qual[num].string,"<critical_low>",rrfr.critical_low,
      "</critical_low>"), tmp->qual[num].string = build(tmp->qual[num].string,"<critical_high>",rrfr
      .critical_high,"</critical_high>"), tmp->qual[num].string = build(tmp->qual[num].string,
      "<feasible_low>",rrfr.feasible_low,"</feasible_low>"),
     tmp->qual[num].string = build(tmp->qual[num].string,"<feasible_high>",rrfr.feasible_high,
      "</feasible_high>"), tmp->qual[num].string = build(tmp->qual[num].string,
      "<from_gestation_days>",rrfr.from_gestation_days,"</from_gestation_days>"), tmp->qual[num].
     string = build(tmp->qual[num].string,"<to_gestation_days>",rrfr.to_gestation_days,
      "</to_gestation_days>"),
     tmp->qual[num].string = build(tmp->qual[num].string,"<from_weight>",rrfr.from_weight,
      "</from_weight>"), tmp->qual[num].string = build(tmp->qual[num].string,"<to_weight>",rrfr
      .to_weight,"</to_weight>"), tmp->qual[num].string = build(tmp->qual[num].string,
      "<from_weight_unit_cd>",rrfr.from_weight_unit_cd,"</from_weight_unit_cd>"),
     tmp->qual[num].string = build(tmp->qual[num].string,"<to_weight_unit_cd>",rrfr.to_weight_unit_cd,
      "</to_weight_unit_cd>"), tmp->qual[num].string = build(tmp->qual[num].string,"<from_height>",
      rrfr.from_height,"</from_height>"), tmp->qual[num].string = build(tmp->qual[num].string,
      "<to_height>",rrfr.to_height,"</to_height>"),
     tmp->qual[num].string = build(tmp->qual[num].string,"<from_height_unit_cd>",rrfr
      .from_height_unit_cd,"</from_height_unit_cd>"), tmp->qual[num].string = build(tmp->qual[num].
      string,"<to_height_unit_cd>",rrfr.to_height_unit_cd,"</to_height_unit_cd>"), tmp->qual[num].
     string = build(tmp->qual[num].string,"<location_cd>",rrfr.location_cd,"</location_cd>")
    ENDIF
   ENDIF
  DETAIL
   IF (arr.nomenclature_id > 0)
    tmp->qual[num].string = build(tmp->qual[num].string,"<ALPHA_RESPONSE_RULE>"), tmp->qual[num].
    string = build(tmp->qual[num].string,"<NOMENCLATURE_ID>",arr.nomenclature_id,"</nomenclature_id>"
     ), tmp->qual[num].string = build(tmp->qual[num].string,"</ALPHA_RESPONSE_RULE>")
   ENDIF
  FOOT  rrfr.ref_range_factor_rule_id
   IF (rrfr.ref_range_factor_rule_id != 0)
    tmp->qual[num].string = build(tmp->qual[num].string,"</ref_range_factor_rule>")
   ENDIF
  FOOT  rrf.reference_range_factor_id
   tmp->qual[num].string = build(tmp->qual[num].string,"</reference_range_factor>")
  WITH nocounter
 ;end select
 FOR (loopcnt = 1 TO tmp->qual_cnt)
   SET xmlstring = build(xmlstring,tmp->qual[loopcnt].string)
 ENDFOR
 SELECT INTO "nl:"
  eq.task_assay_cd, eq.equation_id, comp.equation_id,
  comp_exists = evaluate(nullind(comp.equation_id),0,1,0), disp_sex_cd = uar_get_code_display(eq
   .sex_cd), disp_units_cd = uar_get_code_display(comp.units_cd)
  FROM equation eq,
   equation_component comp
  PLAN (eq
   WHERE (eq.task_assay_cd=request->task_assay_cd)
    AND eq.active_ind=1)
   JOIN (comp
   WHERE (comp.equation_id= Outerjoin(eq.equation_id)) )
  ORDER BY eq.equation_id
  HEAD eq.equation_id
   xmlstring = build(xmlstring,"<equation>")
   IF (eq.equation_description > " ")
    xmlstring = build(xmlstring,"<equation_description>",eq.equation_description,
     "</equation_description>")
   ENDIF
   xmlstring = build(xmlstring,"<age_from_minutes>",eq.age_from_minutes,"</age_from_minutes>"),
   xmlstring = build(xmlstring,"<age_to_minutes>",eq.age_to_minutes,"</age_to_minutes>"), xmlstring
    = build(xmlstring,"<sex_cd>",disp_sex_cd,"</sex_cd>"),
   xmlstring = build(xmlstring,"<default_ind>",eq.default_ind,"</default_ind>")
   IF (eq.script > " ")
    xmlstring = build(xmlstring,"<script>",eq.script,"</script>")
   ENDIF
  DETAIL
   IF (comp_exists)
    xmlstring = build(xmlstring,"<equation_component>")
    IF (comp.name > " ")
     xmlstring = build(xmlstring,"<name>",comp.name,"</name>")
    ENDIF
    xmlstring = build(xmlstring,"<sequence>",comp.sequence,"</sequence>"), xmlstring = build(
     xmlstring,"<constant_value>",comp.constant_value,"</constant_value>"), xmlstring = build(
     xmlstring,"<cross_drawn_dt_tm_ind>",comp.cross_drawn_dt_tm_ind,"</cross_drawn_dt_tm_ind>"),
    xmlstring = build(xmlstring,"<default_value>",comp.default_value,"</default_value>"), xmlstring
     = build(xmlstring,"<time_window_minutes>",comp.time_window_minutes,"</time_window_minutes>"),
    xmlstring = build(xmlstring,"<time_window_back_minutes>",comp.time_window_back_minutes,
     "</time_window_back_minutes>"),
    xmlstring = build(xmlstring,"<units_cd>",disp_units_cd,"</units_cd>"), xmlstring = build(
     xmlstring,"<included_assay_cd>",comp.included_assay_cd,"</included_assay_cd>"), xmlstring =
    build(xmlstring,"<look_time_direction_flag>",comp.look_time_direction_flag,
     "</look_time_direction_flag>"),
    xmlstring = build(xmlstring,"</equation_component>")
   ENDIF
  FOOT  eq.equation_id
   xmlstring = build(xmlstring,"</equation>")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dmap.task_assay_cd
  FROM data_map dmap
  WHERE (dmap.task_assay_cd=request->task_assay_cd)
   AND dmap.active_ind=1
  DETAIL
   xmlstring = build(xmlstring,"<data_map>"), xmlstring = build(xmlstring,"<max_digits>",dmap
    .max_digits,"</max_digits>"), xmlstring = build(xmlstring,"<min_decimal_places>",dmap
    .min_decimal_places,"</min_decimal_places>"),
   xmlstring = build(xmlstring,"<min_digits>",dmap.min_digits,"</min_digits>"), xmlstring = build(
    xmlstring,"</data_map>")
  WITH nocounter
 ;end select
 SET xmlstring = build(xmlstring,"</dta>")
 SET xmlstringcompressed = xmlstring
 SET xmlcompsize = size(xmlstringcompressed)
 SET xmlstrsize = size(xmlstring)
 SET flag = uar_ocf_compress(xmlstring,xmlstrsize,xmlstringcompressed,xmlcompsize,length)
 SET mnstat = error(errmsg,1)
 IF (mnstat != 0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("****",errmsg)
  SET reply->status_data.subeventstatus[1].targetobjectname = "XMLString"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_OCF_COMPRESS"
  GO TO exit_script
 ENDIF
 SET xmlstringcompressed = substring(1,length,xmlstringcompressed)
 SELECT INTO "nl:"
  refseq = seq(reference_seq,nextval)"##################;rp0", longblobseq = seq(long_data_seq,
   nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_dta_version_id = cnvtreal(refseq), new_long_blob_id = cnvtreal(longblobseq)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SEQ NBR"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  GO TO exit_script
 ENDIF
 INSERT  FROM long_blob_reference lb
  SET lb.parent_entity_name = "DTA_VERSION", lb.long_blob_id = new_long_blob_id, lb.long_blob =
   xmlstringcompressed,
   lb.parent_entity_id = new_dta_version_id, lb.active_ind = 1, lb.active_status_cd = reqdata->
   active_status_cd,
   lb.active_status_dt_tm = cnvtdatetime(sysdate), lb.active_status_prsnl_id = reqinfo->updt_id, lb
   .updt_dt_tm = cnvtdatetime(sysdate),
   lb.updt_id = reqinfo->updt_id, lb.updt_task = reqinfo->updt_task, lb.updt_applctx = reqinfo->
   updt_applctx,
   lb.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG BLOB"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  GO TO exit_script
 ENDIF
 INSERT  FROM dta_version dtav
  SET dtav.dta_version_id = new_dta_version_id, dtav.task_assay_cd = request->task_assay_cd, dtav
   .version_number = dta_version_number,
   dtav.long_blob_id = new_long_blob_id, dtav.version_in_use = 0, dtav.valid_from_dt_tm =
   cnvtdatetime(old_info->valid_from_dt_tm),
   dtav.valid_until_dt_tm = cnvtdatetime(sysdate), dtav.updt_dt_tm = cnvtdatetime(sysdate), dtav
   .updt_id = reqinfo->updt_id,
   dtav.updt_task = reqinfo->updt_task, dtav.updt_applctx = reqinfo->updt_applctx, dtav.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DTA_VERSION"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  GO TO exit_script
 ENDIF
 SET dta_version_number += 1
 UPDATE  FROM discrete_task_assay dta
  SET dta.version_number = dta_version_number, dta.updt_dt_tm = cnvtdatetime(sysdate), dta.updt_id =
   reqinfo->updt_id,
   dta.updt_task = reqinfo->updt_task, dta.updt_applctx = reqinfo->updt_applctx, dta.updt_cnt = (dta
   .updt_cnt+ 1)
  WHERE (dta.task_assay_cd=request->task_assay_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET vfailed = "T"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DISCRETE_TASK_ASSAY"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  GO TO exit_script
 ENDIF
#exit_script
 IF (vfailed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET modify = nopredeclare
END GO
