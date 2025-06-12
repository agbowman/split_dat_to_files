CREATE PROGRAM cp_upd_cat_sect_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = true
 DECLARE x = i2 WITH public, noconstant(0)
 DECLARE y = i2 WITH public, noconstant(0)
 DECLARE qual_size = i2 WITH public, noconstant(0)
 DECLARE req_size = i2 WITH public, noconstant(0)
 DECLARE cat_size = i2 WITH public, noconstant(0)
 SET qual_size = size(request->qual,5)
 FOR (x = 1 TO qual_size)
   DELETE  FROM category_sect_reltn c
    WHERE (c.chart_format_id=request->qual[x].chart_format_id)
   ;end delete
   SET req_size = size(request->qual[x].section_qual,5)
   FOR (y = 1 TO req_size)
    SET cat_size = size(request->qual[x].section_qual[y].category_qual,5)
    IF (cat_size > 0)
     INSERT  FROM (dummyt d  WITH seq = value(cat_size)),
       category_sect_reltn c
      SET c.seq = 1, c.category_sect_reltn_id = seq(chart_seq,nextval), c.chart_format_id = request->
       qual[x].chart_format_id,
       c.chart_section_id = request->qual[x].section_qual[y].chart_section_id, c.chart_category_id =
       request->qual[x].section_qual[y].category_qual[d.seq].chart_category_id, c.beg_effective_dt_tm
        = cnvtdatetime(curdate,curtime3),
       c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), c.updt_id = reqinfo->updt_id,
       c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task,
       c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       c.active_status_prsnl_id = reqinfo->updt_id
      PLAN (d)
       JOIN (c)
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      SET failed = false
     ENDIF
    ELSE
     SET failed = false
    ENDIF
   ENDFOR
 ENDFOR
#programend
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Category_Sect_Reltn"
  SET reqinfo->commit_ind = false
 ENDIF
END GO
