CREATE PROGRAM cp_populate_chart_format_codes:dba
 RECORD temp(
   1 qual[*]
     2 cf_code_id = f8
     2 event_cd = f8
     2 chart_format_id = f8
     2 chart_section_id = f8
     2 section_type_flag = i4
     2 ap_history_flag = i2
     2 flex_type_flag = i2
     2 hla_type_flag = i2
     2 cs_sequence_num = i4
     2 chart_group_id = f8
     2 cg_sequence_num = i4
     2 zone = i4
     2 event_set_name = vc
     2 event_set_seq = i4
     2 order_catalog_cd = f8
     2 procedure_type_flag = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ec.event_cd, cfs.chart_format_id, cfs.chart_section_id,
  cs.section_type_flag, capf.ap_history_flag, cff.flex_type_flag,
  chf.hla_type_flag, cfs.cs_sequence_num, cg.chart_group_id,
  cg.cg_sequence, cges.zone, cges.event_set_name,
  cges.event_set_seq, cges.order_catalog_cd, cges.procedure_type_flag
  FROM chart_format cf,
   chart_form_sects cfs,
   chart_section cs,
   chart_group cg,
   chart_grp_evnt_set cges,
   v500_event_set_code esc,
   v500_event_set_explode ese,
   v500_event_code ec,
   chart_ap_format capf,
   chart_flex_format cff,
   chart_hla_format chf
  PLAN (cf
   WHERE cf.active_ind=1
    AND (((request->chart_format_id=0)) OR ((request->chart_format_id > 0)
    AND (cf.chart_format_id=request->chart_format_id))) )
   JOIN (cfs
   WHERE cfs.chart_format_id=cf.chart_format_id)
   JOIN (cs
   WHERE cs.chart_section_id=cfs.chart_section_id)
   JOIN (cg
   WHERE cg.chart_section_id=cs.chart_section_id)
   JOIN (cges
   WHERE cges.chart_group_id=cg.chart_group_id)
   JOIN (esc
   WHERE esc.event_set_name=outerjoin(cges.event_set_name))
   JOIN (ese
   WHERE ese.event_set_cd=outerjoin(esc.event_set_cd))
   JOIN (ec
   WHERE ec.event_cd=outerjoin(ese.event_cd))
   JOIN (capf
   WHERE capf.chart_group_id=outerjoin(cg.chart_group_id))
   JOIN (cff
   WHERE cff.chart_group_id=outerjoin(cg.chart_group_id))
   JOIN (chf
   WHERE chf.chart_group_id=outerjoin(cg.chart_group_id))
  ORDER BY cfs.chart_format_id, cfs.cs_sequence_num, cg.cg_sequence,
   cges.event_set_seq
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(temp->qual,(count+ 9))
   ENDIF
   temp->qual[count].event_cd = ec.event_cd, temp->qual[count].chart_format_id = cfs.chart_format_id,
   temp->qual[count].chart_section_id = cfs.chart_section_id,
   temp->qual[count].section_type_flag = cs.section_type_flag, temp->qual[count].ap_history_flag =
   capf.ap_history_flag, temp->qual[count].flex_type_flag = cff.flex_type,
   temp->qual[count].hla_type_flag = chf.hla_type, temp->qual[count].cs_sequence_num = cfs
   .cs_sequence_num, temp->qual[count].chart_group_id = cg.chart_group_id,
   temp->qual[count].cg_sequence_num = cg.cg_sequence, temp->qual[count].zone = cges.zone, temp->
   qual[count].event_set_name = cges.event_set_name,
   temp->qual[count].event_set_seq = cges.event_set_seq, temp->qual[count].order_catalog_cd = cges
   .order_catalog_cd, temp->qual[count].procedure_type_flag = cges.procedure_type_flag
  FOOT REPORT
   stat = alterlist(temp->qual,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No event codes/order catalog codes found for any chart formats")
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DELETE  FROM chart_format_codes cfc
  WHERE (((request->chart_format_id=0)
   AND cfc.cf_code_id > 0) OR ((request->chart_format_id > 0)
   AND (cfc.chart_format_id=request->chart_format_id)))
 ;end delete
 INSERT  FROM chart_format_codes cfc,
   (dummyt d  WITH seq = value(count))
  SET cfc.cf_code_id = cnvtint(seq(cf_code_seq,nextval)), cfc.chart_format_id = temp->qual[d.seq].
   chart_format_id, cfc.chart_section_id = temp->qual[d.seq].chart_section_id,
   cfc.section_type_flag = temp->qual[d.seq].section_type_flag, cfc.ap_history_flag = temp->qual[d
   .seq].ap_history_flag, cfc.flex_type_flag = temp->qual[d.seq].flex_type_flag,
   cfc.hla_type_flag = temp->qual[d.seq].hla_type_flag, cfc.cs_sequence_num = temp->qual[d.seq].
   cs_sequence_num, cfc.chart_group_id = temp->qual[d.seq].chart_group_id,
   cfc.cg_sequence_num = temp->qual[d.seq].cg_sequence_num, cfc.zone = temp->qual[d.seq].zone, cfc
   .event_set_seq = temp->qual[d.seq].event_set_seq,
   cfc.procedure_type_flag = temp->qual[d.seq].procedure_type_flag, cfc.event_set_name = temp->qual[d
   .seq].event_set_name, cfc.event_cd = temp->qual[d.seq].event_cd,
   cfc.order_catalog_cd = temp->qual[d.seq].order_catalog_cd, cfc.active_ind = 1, cfc
   .active_status_cd = reqdata->active_status_cd,
   cfc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cfc.active_status_prsnl_id = reqinfo->
   updt_id, cfc.updt_cnt = 0,
   cfc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cfc.updt_id = reqinfo->updt_id, cfc.updt_task =
   reqinfo->updt_task,
   cfc.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (cfc)
  WITH nocounter
 ;end insert
 IF (curqual != count)
  CALL echo("Unable to insert chart_format_codes rows")
  SET failed = "F"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
