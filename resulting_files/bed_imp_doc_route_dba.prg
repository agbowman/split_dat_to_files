CREATE PROGRAM bed_imp_doc_route:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 list_0[*]
     2 doc_name = vc
     2 doc_id = f8
     2 error_string = vc
     2 action_flag = i2
     2 dist_count = i4
     2 dist[*]
       3 dist_name = vc
       3 dist_id = f8
       3 output_dest = vc
       3 output_cd = f8
       3 copies = i4
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET active_cd = get_code_value(48,"ACTIVE")
 SET numrows = size(requestin->list_0,5)
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"ERM Document Routing Import")
 SET name = validate(log_name_set,"bed_doc_route.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 SET tempnum = 0
 FOR (i = 1 TO numrows)
   SET rec = 0
   FOR (ii = 1 TO tempnum)
     IF (cnvtupper(temp->list_0[ii].doc_name)=cnvtupper(requestin->list_0[i].doc_name))
      SET rec = ii
     ENDIF
   ENDFOR
   IF (rec=0)
    SET tempnum = (tempnum+ 1)
    SET stat = alterlist(temp->list_0,tempnum)
    SET rec = tempnum
    SET temp->list_0[rec].action_flag = 1
    SET temp->list_0[rec].doc_name = requestin->list_0[i].doc_name
    SELECT INTO "NL:"
     FROM pm_doc_document p
     PLAN (p
      WHERE cnvtupper(p.document_name)=cnvtupper(temp->list_0[rec].doc_name)
       AND p.active_ind=1)
     DETAIL
      temp->list_0[rec].doc_id = p.document_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->list_0[rec].error_string = "Invalid Document Name"
     SET temp->list_0[rec].action_flag = 0
    ENDIF
   ENDIF
   SET found = 0
   FOR (ii = 1 TO temp->list_0[rec].dist_count)
     IF (cnvtupper(temp->list_0[rec].dist[ii].dist_name)=cnvtupper(requestin->list_0[i].dist_name))
      SET found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    SET temp->list_0[rec].dist_count = (temp->list_0[rec].dist_count+ 1)
    SET stat = alterlist(temp->list_0[rec].dist,temp->list_0[rec].dist_count)
    SET temp->list_0[rec].dist[temp->list_0[rec].dist_count].dist_name = requestin->list_0[i].
    dist_name
    SET temp->list_0[rec].dist[temp->list_0[rec].dist_count].output_dest = requestin->list_0[i].
    output_dest
    SET temp->list_0[rec].dist[temp->list_0[rec].dist_count].copies = cnvtint(requestin->list_0[i].
     copies)
    IF ((((temp->list_0[rec].dist[temp->list_0[rec].dist_count].copies < 1)) OR ((temp->list_0[rec].
    dist[temp->list_0[rec].dist_count].copies > 100))) )
     SET temp->list_0[rec].error_string = concat("Invalid Copy Number - ",requestin->list_0[i].copies
      )
     SET temp->list_0[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM pm_doc_distribution p
     PLAN (p
      WHERE cnvtupper(p.distribution_name)=cnvtupper(temp->list_0[rec].dist[temp->list_0[rec].
       dist_count].dist_name)
       AND p.active_ind=1)
     DETAIL
      temp->list_0[rec].dist[temp->list_0[rec].dist_count].dist_id = p.distribution_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->list_0[rec].error_string = "Invalid Distribution"
     SET temp->list_0[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM pm_doc_destination p
     PLAN (p
      WHERE (p.document_id=temp->list_0[rec].doc_id)
       AND (p.distribution_id=temp->list_0[rec].dist[temp->list_0[rec].dist_count].dist_id)
       AND p.active_ind=1)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET temp->list_0[rec].error_string = "Doc-Dist Already Defined"
     SET temp->list_0[rec].action_flag = 0
    ENDIF
    SELECT INTO "NL:"
     FROM output_dest o
     PLAN (o
      WHERE cnvtupper(o.name)=cnvtupper(requestin->list_0[i].output_dest))
     DETAIL
      temp->list_0[rec].dist[temp->list_0[rec].dist_count].output_cd = o.output_dest_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->list_0[rec].error_string = "Invalid Output"
     SET temp->list_0[rec].action_flag = 0
    ENDIF
    SET temp->list_0[rec].dist[temp->list_0[rec].dist_count].output_dest = concat(requestin->list_0[i
     ].output_dest," - ",requestin->list_0[i].copies)
   ENDIF
 ENDFOR
 IF (write_mode=1)
  FOR (i = 1 TO tempnum)
    IF ((temp->list_0[i].action_flag=1))
     FOR (ii = 1 TO temp->list_0[i].dist_count)
       INSERT  FROM pm_doc_destination pdd
        SET pdd.destination_id = seq(pm_document_seq,nextval), pdd.document_id = temp->list_0[i].
         doc_id, pdd.distribution_id = temp->list_0[i].dist[ii].dist_id,
         pdd.output_dest_cd = temp->list_0[i].dist[ii].output_cd, pdd.copies = temp->list_0[i].dist[
         ii].copies, pdd.active_ind = 1,
         pdd.active_status_cd = active_cd, pdd.active_status_prsnl_id = reqinfo->updt_id, pdd
         .active_status_dt_tm = cnvtdatetime(curdate,curtime),
         pdd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pdd.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100 00:00:00.00"), pdd.updt_dt_tm = cnvtdatetime(curdate,curtime),
         pdd.updt_id = reqinfo->updt_id, pdd.updt_task = reqinfo->updt_task, pdd.updt_applctx =
         reqinfo->updt_applctx,
         pdd.updt_cnt = 0
        WITH nocounter
       ;end insert
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = tempnum)
  DETAIL
   col 3, d.seq"#####", col 10,
   temp->list_0[d.seq].doc_name
   IF ((temp->list_0[d.seq].action_flag=1))
    col 90, "Added"
   ELSE
    col 90, "Error"
   ENDIF
   col 100, temp->list_0[d.seq].error_string
   FOR (i = 1 TO temp->list_0[d.seq].dist_count)
     col 35, temp->list_0[d.seq].dist[i].dist_name, col 65,
     temp->list_0[d.seq].dist[i].output_dest, row + 1
   ENDFOR
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
    DETAIL
     row + 2, col 5, "ROW",
     col 10, "DOCUMENT NAME", col 35,
     "DISTRIBUTION NAME", col 65, "OUTPUT",
     col 90, "STATUS", col 100,
     "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
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
