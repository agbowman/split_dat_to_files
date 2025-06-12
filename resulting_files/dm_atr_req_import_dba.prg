CREATE PROGRAM dm_atr_req_import:dba
 FREE SET status
 RECORD status(
   1 qual[*]
     2 exist = i1
 )
 SET stat = alterlist(status->qual,request->atr_count)
 CALL echo("Importing Requests into clinical tables...")
 SELECT INTO "nl:"
  r.request_number
  FROM request r,
   (dummyt d  WITH seq = value(request->atr_count))
  PLAN (d)
   JOIN (r
   WHERE (r.request_number=request->atr_list[d.seq].request_number))
  DETAIL
   status->qual[d.seq].exist = 1
  WITH nocounter
 ;end select
 CALL echo("  Updating existing Requests into clinical tables...")
 UPDATE  FROM request r,
   (dummyt d  WITH seq = value(request->atr_count))
  SET r.seq = 1, r.description = request->atr_list[d.seq].description, r.text = request->atr_list[d
   .seq].text,
   r.request_name = request->atr_list[d.seq].request_name, r.cachetime = request->atr_list[d.seq].
   cachetime, r.cachegrace = request->atr_list[d.seq].cachegrace,
   r.cachestale = request->atr_list[d.seq].cachestale, r.cachetrim = request->atr_list[d.seq].
   cachetrim, r.requestclass = request->atr_list[d.seq].requestclass,
   r.epilog_script = request->atr_list[d.seq].epilog_script, r.prolog_script = request->atr_list[d
   .seq].prolog_script, r.write_to_que_ind = request->atr_list[d.seq].write_to_que_ind,
   r.active_ind = request->atr_list[d.seq].active_ind, r.active_dt_tm =
   IF ((request->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     active_dt_tm)
   ELSE null
   ENDIF
   , r.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   ,
   r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = 0, r.updt_id = 0.0,
   r.updt_cnt = 0, r.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=1)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (r
   WHERE (r.request_number=request->atr_list[d.seq].request_number))
  WITH nocounter
 ;end update
 CALL echo("  Inserting new Requests into clinical tables...")
 INSERT  FROM request r,
   (dummyt d  WITH seq = value(request->atr_count))
  SET r.seq = 1, r.request_number = request->atr_list[d.seq].request_number, r.description = request
   ->atr_list[d.seq].description,
   r.text = request->atr_list[d.seq].text, r.request_name = request->atr_list[d.seq].request_name, r
   .cachetime = request->atr_list[d.seq].cachetime,
   r.cachegrace = request->atr_list[d.seq].cachegrace, r.cachestale = request->atr_list[d.seq].
   cachestale, r.cachetrim = request->atr_list[d.seq].cachetrim,
   r.requestclass = request->atr_list[d.seq].requestclass, r.epilog_script = request->atr_list[d.seq]
   .epilog_script, r.prolog_script = request->atr_list[d.seq].prolog_script,
   r.write_to_que_ind = request->atr_list[d.seq].write_to_que_ind, r.active_ind = request->atr_list[d
   .seq].active_ind, r.active_dt_tm =
   IF ((request->atr_list[d.seq].active_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     active_dt_tm)
   ELSE null
   ENDIF
   ,
   r.inactive_dt_tm =
   IF ((request->atr_list[d.seq].inactive_dt_tm > 0)) cnvtdatetime(request->atr_list[d.seq].
     inactive_dt_tm)
   ELSE null
   ENDIF
   , r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task = 0,
   r.updt_id = 0.0, r.updt_cnt = 0, r.updt_applctx = 0
  PLAN (d
   WHERE (status->qual[d.seq].exist=0)
    AND (request->atr_list[d.seq].deleted_ind != 1))
   JOIN (r)
  WITH nocounter
 ;end insert
 CALL echo("  Deleting unwanted Requests from clinical tables...")
 DELETE  FROM request r,
   (dummyt d  WITH seq = value(request->atr_count))
  SET r.seq = 1
  PLAN (d
   WHERE (request->atr_list[d.seq].deleted_ind=1)
    AND (status->qual[d.seq].exist=1))
   JOIN (r
   WHERE (r.request_number=request->atr_list[d.seq].request_number))
  WITH nocounter
 ;end delete
 COMMIT
END GO
