CREATE PROGRAM cp_update_chart_requests:dba
 RECORD temp(
   1 qual[1]
     2 chart_request_id = f8
     2 updt_cnt = i4
     2 chart_format_id = f8
     2 request_prsnl_id = f8
     2 request_type = i4
     2 scope_flag = i4
 )
 RECORD dist(
   1 qual[1]
     2 chart_request_id = f8
     2 dist_id = f8
     2 dist_terminator_ind = i2
     2 updt_ind = i2
     2 dist_batch_id = f8
 )
 RECORD reply(
   1 request_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET nbr_to_chg = size(request->qual,5)
 SET count1 = 0
 SET dist_cnt = 0
 SET dist_cnt2 = 0
 SET dist_id = 0.0
 SET dist_ind = 0
 SET stat = 0
 SET failed = "F"
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE chart_sec_ind = i2 WITH public, noconstant(0)
 DECLARE chart_format_id = f8 WITH public, noconstant(0.0)
 SET status_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 IF ((request->request_status=0))
  SET cdf_meaning = "UNPROCESSED"
 ELSEIF ((request->request_status=21))
  SET cdf_meaning = "SKIPPED"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(18609,cdf_meaning,1,status_cd)
 IF ((request->request_status=0))
  SELECT INTO "nl:"
   df.info_name
   FROM dm_info df
   WHERE df.info_domain="CHARTING SECURITY"
    AND df.info_number=1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET chart_sec_ind = 1
  ENDIF
 ENDIF
 CALL echo(build("chart_sec_ind = ",chart_sec_ind))
 SELECT INTO "nl:"
  cr.*
  FROM chart_request cr,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (cr
   WHERE (cr.chart_request_id=request->qual[d.seq].chart_request_id))
  HEAD REPORT
   count1 = 0, dist_cnt = 0, dist_id = 0
  DETAIL
   count1 = (count1+ 1), stat = alter(temp->qual,count1), temp->qual[count1].chart_request_id = cr
   .chart_request_id,
   temp->qual[count1].updt_cnt = cr.updt_cnt, temp->qual[count1].chart_format_id = cr.chart_format_id,
   temp->qual[count1].request_prsnl_id = cr.request_prsnl_id,
   temp->qual[count1].request_type = cr.request_type, temp->qual[count1].scope_flag = cr.scope_flag
   IF (cr.request_type=4)
    dist_ind = 1, dist_cnt = (dist_cnt+ 1), stat = alter(dist->qual,dist_cnt),
    dist->qual[dist_cnt].chart_request_id = cr.chart_request_id, dist->qual[dist_cnt].dist_id = cr
    .distribution_id, dist->qual[dist_cnt].dist_terminator_ind = cr.dist_terminator_ind,
    dist->qual[dist_cnt].dist_batch_id = cr.chart_batch_id
   ENDIF
  WITH nocounter, forupdate(cr)
 ;end select
 CALL echorecord(temp)
 FOR (i = 1 TO count1)
  IF ((temp->qual[i].updt_cnt != request->qual[i].updt_cnt))
   CALL echo("Updt_cnt not equal to table updt_cnt")
   SET failed = "T"
   SET reply->status_data.status = "C"
   GO TO exit_script
  ENDIF
  IF (((chart_sec_ind=1
   AND (temp->qual[i].request_type=1)) OR ((request->request_status=0)
   AND (temp->qual[i].request_type=8)
   AND (temp->qual[i].scope_flag != 6))) )
   IF ((request->chart_format_id > 0))
    SET chart_format_id = request->chart_format_id
   ELSE
    SET chart_format_id = temp->qual[i].chart_format_id
   ENDIF
   IF (checkformauthentication(chart_format_id,temp->qual[i].request_prsnl_id))
    SET failed = "T"
    SET reply->request_id = temp->qual[i].chart_request_id
    GO TO exit_script
   ELSEIF (checksectauthentication(temp->qual[i].chart_request_id,chart_format_id,temp->qual[i].
    request_prsnl_id))
    SET failed = "T"
    SET reply->request_id = temp->qual[i].chart_request_id
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 UPDATE  FROM chart_request cr,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET cr.status_flag = request->request_status, cr.resubmit_dt_tm =
   IF ((request->request_status=0)) cnvtdatetime(cur_dt_tm)
   ELSE cr.resubmit_dt_tm
   ENDIF
   , cr.resubmit_cnt =
   IF ((request->request_status=0)) nullcheck((cr.resubmit_cnt+ 1),1,nullind(cr.resubmit_cnt))
   ELSE cr.resubmit_cnt
   ENDIF
   ,
   cr.recover_dt_tm = null, cr.recover_cnt = 0, cr.process_time = 0.0,
   cr.server_name = null, cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_id = reqinfo->updt_id,
   cr.updt_task = reqinfo->updt_task, cr.updt_dt_tm = cnvtdatetime(cur_dt_tm), cr.updt_applctx =
   reqinfo->updt_applctx,
   cr.output_dest_cd =
   IF ((request->output_dest_updt_flag=1)) request->output_dest_cd
   ELSE cr.output_dest_cd
   ENDIF
   , cr.output_device_cd =
   IF ((request->output_dest_updt_flag=1)) request->output_device_cd
   ELSE cr.output_device_cd
   ENDIF
   , cr.chart_format_id =
   IF ((request->output_dest_updt_flag=1)
    AND (request->chart_format_id > 0)) request->chart_format_id
   ELSE cr.chart_format_id
   ENDIF
   ,
   cr.rrd_deliver_dt_tm =
   IF ((request->output_dest_updt_flag=1)) cnvtdatetime(request->rrd_deliver_dt_tm)
   ELSE cr.rrd_deliver_dt_tm
   ENDIF
   , cr.rrd_country_access =
   IF ((request->output_dest_updt_flag=1)) request->rrd_country_access
   ELSE cr.rrd_country_access
   ENDIF
   , cr.rrd_area_code =
   IF ((request->output_dest_updt_flag=1)) request->rrd_area_code
   ELSE cr.rrd_area_code
   ENDIF
   ,
   cr.rrd_exchange =
   IF ((request->output_dest_updt_flag=1)) request->rrd_exchange
   ELSE cr.rrd_exchange
   ENDIF
   , cr.rrd_phone_suffix =
   IF ((request->output_dest_updt_flag=1)) request->rrd_phone_suffix
   ELSE cr.rrd_phone_suffix
   ENDIF
   , cr.chart_status_cd = status_cd
  PLAN (d)
   JOIN (cr
   WHERE (cr.chart_request_id=request->qual[d.seq].chart_request_id))
  WITH nocounter
 ;end update
 IF (curqual != nbr_to_chg)
  SET failed = "T"
  SET reply->status_data.status = "U"
  GO TO exit_script
 ENDIF
 IF (dist_ind=1)
  DECLARE new_batch_id = f8 WITH noconstant(0.0), protect
  SELECT INTO "nl:"
   y2 = seq(chart_seq,nextval)
   FROM dual
   DETAIL
    new_batch_id = y2
   WITH nocounter
  ;end select
  UPDATE  FROM chart_request cr,
    (dummyt d  WITH seq = value(dist_cnt))
   SET cr.chart_batch_id = new_batch_id
   PLAN (d
    WHERE (dist->qual[d.seq].dist_batch_id=0.0))
    JOIN (cr
    WHERE (cr.chart_request_id=dist->qual[d.seq].chart_request_id))
   WITH nocounter
  ;end update
 ENDIF
 DECLARE checkformauthentication(format_id=f8,prsnl_id=f8) = i4
 SUBROUTINE checkformauthentication(format_id,prsnl_id)
   CALL echo("In CheckFormAuthentication()")
   SELECT DISTINCT INTO "nl:"
    fo.chart_format_id
    FROM prsnl_org_reltn po,
     format_org_reltn fo
    PLAN (po
     WHERE po.person_id=prsnl_id
      AND po.active_ind=1)
     JOIN (fo
     WHERE fo.organization_id=po.organization_id
      AND fo.chart_format_id=format_id
      AND fo.active_ind=1)
    WITH nocounter
   ;end select
   CALL echo(build("curqual = ",curqual))
   IF (curqual=0)
    SET reply->status_data.status = "A"
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE checksectauthentication(request_id=f8,format_id=f8,prsnl_id=f8) = i4
 SUBROUTINE checksectauthentication(request_id,format_id,prsnl_id)
   DECLARE sect_sel_ind = i2 WITH public, noconstant(0)
   DECLARE sect_auth_chg_ind = i4 WITH public, noconstant(0)
   DECLARE position_cd = f8 WITH public, noconstant(0.0)
   CALL echo("In CheckSectAuthentication()")
   SELECT DISTINCT INTO "nl:"
    crs.chart_request_id
    FROM chart_request_section crs
    WHERE crs.chart_request_id=request_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET sect_sel_ind = 1
   ENDIF
   CALL echo(build("sect_sel_ind = ",sect_sel_ind))
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE p.person_id=prsnl_id
     AND p.active_ind=1
    DETAIL
     position_cd = p.position_cd
    WITH nocounter
   ;end select
   CALL echo(build("position_cd = ",position_cd))
   IF (sect_sel_ind=1)
    SELECT INTO "nl:"
     cfs.chart_section_id, crs.chart_section_id, spr.chart_section_id
     FROM chart_form_sects cfs,
      sect_position_reltn spr,
      chart_request_section crs
     PLAN (cfs
      WHERE cfs.chart_format_id=format_id
       AND cfs.active_ind=1)
      JOIN (crs
      WHERE crs.chart_request_id=outerjoin(request_id)
       AND crs.chart_section_id=outerjoin(cfs.chart_section_id))
      JOIN (spr
      WHERE spr.chart_format_id=outerjoin(format_id)
       AND spr.position_cd=outerjoin(position_cd)
       AND spr.chart_section_id=outerjoin(cfs.chart_section_id))
     ORDER BY cfs.cs_sequence_num
     DETAIL
      IF (crs.chart_section_id > 0
       AND spr.chart_section_id=0)
       sect_auth_chg_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     cfs.chart_section_id, spr.chart_section_id
     FROM chart_form_sects cfs,
      sect_position_reltn spr
     PLAN (cfs
      WHERE cfs.chart_format_id=format_id
       AND cfs.active_ind=1)
      JOIN (spr
      WHERE spr.chart_format_id=outerjoin(format_id)
       AND spr.position_cd=outerjoin(position_cd)
       AND spr.chart_section_id=outerjoin(cfs.chart_section_id))
     ORDER BY cfs.cs_sequence_num
     DETAIL
      IF (spr.chart_section_id=0)
       sect_auth_chg_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("sect_auth_chg_ind = ",sect_auth_chg_ind))
   IF (sect_auth_chg_ind=1)
    SET reply->status_data.status = "B"
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status =",reply->status_data.status))
END GO
