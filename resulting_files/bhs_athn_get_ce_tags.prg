CREATE PROGRAM bhs_athn_get_ce_tags
 RECORD out_rec(
   1 tags[*]
     2 event_id = vc
     2 emr_type = vc
     2 tag_dt_tm = vc
     2 event = vc
     2 result = vc
     2 result_unit = vc
     2 result_date_time = vc
     2 status = vc
     2 normal_high = vc
     2 normal_low = vc
     2 critical_high = vc
     2 critical_low = vc
     2 normalcy_disp = vc
     2 normalcy_mean = vc
 )
 DECLARE t_cnt = i4
 SELECT INTO "nl:"
  FROM pdoc_tag pt,
   clinical_event ce
  PLAN (pt
   WHERE (pt.encntr_id= $2)
    AND (pt.tag_user_id= $3)
    AND pt.tag_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=pt.tag_entity_id
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY pt.pdoc_tag_id
  HEAD pt.pdoc_tag_id
   t_cnt = (t_cnt+ 1)
   IF (mod(t_cnt,100)=1)
    stat = alterlist(out_rec->tags,(t_cnt+ 99))
   ENDIF
   out_rec->tags[t_cnt].event_id = cnvtstring(pt.tag_entity_id), out_rec->tags[t_cnt].emr_type =
   uar_get_code_display(pt.emr_type_cd), out_rec->tags[t_cnt].tag_dt_tm = datetimezoneformat(pt
    .tag_dt_tm,ce.event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef),
   out_rec->tags[t_cnt].event = uar_get_code_display(ce.event_cd), out_rec->tags[t_cnt].result = trim
   (ce.result_val), out_rec->tags[t_cnt].result_unit = trim(uar_get_code_display(ce.result_units_cd)),
   out_rec->tags[t_cnt].result_date_time = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,
    "MM/dd/yyyy HH:mm:ss",curtimezonedef), out_rec->tags[t_cnt].status = uar_get_code_display(ce
    .result_status_cd), out_rec->tags[t_cnt].normal_high = ce.normal_high,
   out_rec->tags[t_cnt].normal_low = ce.normal_low, out_rec->tags[t_cnt].critical_high = ce
   .critical_high, out_rec->tags[t_cnt].critical_low = ce.critical_low,
   out_rec->tags[t_cnt].normalcy_disp = uar_get_code_display(ce.normalcy_cd), out_rec->tags[t_cnt].
   normalcy_mean = uar_get_code_meaning(ce.normalcy_cd)
  FOOT REPORT
   stat = alterlist(out_rec->tags,t_cnt)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
