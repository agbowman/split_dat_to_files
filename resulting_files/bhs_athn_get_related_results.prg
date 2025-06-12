CREATE PROGRAM bhs_athn_get_related_results
 RECORD out_rec(
   1 results[*]
     2 event_id = vc
     2 event_cd = vc
     2 event_disp = vc
     2 result = vc
     2 result_dt_tm = vc
 )
 DECLARE r_cnt = i4
 DECLARE moutputdevice = vc WITH protect, noconstant( $1)
 SELECT INTO "nl:"
  FROM catalog_event_sets ces,
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   clinical_event ce
  PLAN (ces
   WHERE (ces.catalog_cd= $2))
   JOIN (vesc
   WHERE vesc.event_set_name=ces.event_set_name)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
   JOIN (ce
   WHERE (ce.person_id= $3)
    AND ce.event_cd=vese.event_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.view_level=1)
  ORDER BY ces.sequence, ce.event_end_dt_tm
  HEAD ce.event_id
   r_cnt += 1
   IF (mod(r_cnt,100)=1)
    stat = alterlist(out_rec->results,(r_cnt+ 99))
   ENDIF
   out_rec->results[r_cnt].event_id = cnvtstring(ce.event_id), out_rec->results[r_cnt].event_cd =
   cnvtstring(ce.event_cd), out_rec->results[r_cnt].event_disp = uar_get_code_display(ce.event_cd),
   out_rec->results[r_cnt].result =
   IF (trim(ce.result_val)="SEE NOTE") ce.result_val
   ELSE concat(trim(ce.result_val)," ",trim(uar_get_code_display(ce.result_units_cd)))
   ENDIF
   IF (trim(out_rec->results[r_cnt].result,3)="")
    out_rec->results[r_cnt].result = ce.event_tag
   ENDIF
   out_rec->results[r_cnt].result_dt_tm = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,
    "mm/dd/yyyy hh:mm ZZZ",curtimezonedef)
  FOOT REPORT
   stat = alterlist(out_rec->results,r_cnt)
  WITH nocounter, time = 30
 ;end select
 EXECUTE bhs_athn_write_json_output
END GO
