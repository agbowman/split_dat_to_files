CREATE PROGRAM cnfg_mgr_grp_import:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting cnfg_mgr_grp_import script"
 FREE RECORD import
 RECORD import(
   1 utility_list[*]
     2 collation_seq = i4
     2 title_txt = vc
     2 grp_key_txt = vc
     2 parent_key_txt = vc
     2 exist_in_db_ind = i2
 ) WITH protect
 DECLARE main(null) = null WITH protect
 DECLARE createreadmedata(null) = null WITH protect
 DECLARE setexistindbind(null) = null WITH protect
 DECLARE insertdata(null) = null WITH protect
 DECLARE updatedata(null) = null WITH protect
 DECLARE checkforerrmsg(msg=vc) = i4 WITH protect
 CALL main(null)
 SUBROUTINE main(null)
   CALL createreadmedata(null)
   IF (size(import->utility_list,5)=0)
    GO TO exit_script
   ENDIF
   CALL setexistindbind(null)
   CALL insertdata(null)
   CALL updatedata(null)
   COMMIT
 END ;Subroutine
 SUBROUTINE createreadmedata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   DECLARE reccountvalid = i4 WITH protect, noconstant(0)
   SET stat = alterlist(import->utility_list,size(requestin->list_0,5))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(requestin)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(requestin->list_0,5))
    PLAN (d
     WHERE (requestin->list_0[d.seq].grp_key_txt > " "))
    DETAIL
     reccountvalid = (reccountvalid+ 1), import->utility_list[reccountvalid].collation_seq = cnvtint(
      requestin->list_0[d.seq].collation_seq), import->utility_list[reccountvalid].title_txt = trim(
      requestin->list_0[d.seq].title_txt),
     import->utility_list[reccountvalid].grp_key_txt = trim(requestin->list_0[d.seq].grp_key_txt)
     IF ((requestin->list_0[d.seq].parent_key_txt >= " "))
      import->utility_list[reccountvalid].parent_key_txt = requestin->list_0[d.seq].parent_key_txt
     ELSE
      import->utility_list[reccountvalid].parent_key_txt = " "
     ENDIF
    FOOT REPORT
     stat = alterlist(import->utility_list,reccountvalid)
    WITH nocounter
   ;end select
   SET errorcode = checkforerrmsg("Error in CreateReadMeData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing CreateReadMeData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setexistindbind(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE utilitylistidx = i4 WITH protect, noconstant(0)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(requestin)
   ENDIF
   SELECT INTO "nl:"
    FROM cnfg_mgr_grp grp
    WHERE expand(idx,1,size(import->utility_list,5),cnvtupper(grp.grp_key_txt),cnvtupper(import->
      utility_list[idx].grp_key_txt))
    HEAD grp.grp_key_txt
     utilitylistidx = locateval(idx,1,size(import->utility_list,5),cnvtupper(grp.grp_key_txt),
      cnvtupper(import->utility_list[idx].grp_key_txt)), import->utility_list[utilitylistidx].
     exist_in_db_ind = 1
    WITH nocounter
   ;end select
   SET errorcode = checkforerrmsg("Error in setExistInDbInd Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing setExistInDbInd Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   INSERT  FROM cnfg_mgr_grp group,
     (dummyt d  WITH seq = value(size(import->utility_list,5)))
    SET group.cnfg_mgr_grp_id = seq(reference_seq,nextval), group.collation_seq = import->
     utility_list[d.seq].collation_seq, group.grp_key_txt = import->utility_list[d.seq].grp_key_txt,
     group.title_txt = import->utility_list[d.seq].title_txt, group.parent_grp_id =
     (SELECT
      cnfg_mgr_grp_id
      FROM cnfg_mgr_grp
      WHERE (grp_key_txt=import->utility_list[d.seq].parent_key_txt)), group.updt_applctx = reqinfo->
     updt_applctx,
     group.updt_cnt = 1, group.updt_dt_tm = cnvtdatetime(curdate,curtime3), group.updt_id = reqinfo->
     updt_id,
     group.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (import->utility_list[d.seq].exist_in_db_ind=0))
     JOIN (group)
    WITH nocounter
   ;end insert
   SET errorcode = checkforerrmsg("Error in InsertData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing InsertData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updatedata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   UPDATE  FROM cnfg_mgr_grp grp,
     (dummyt d  WITH seq = value(size(import->utility_list,5)))
    SET grp.collation_seq = import->utility_list[d.seq].collation_seq, grp.title_txt = import->
     utility_list[d.seq].title_txt, grp.parent_grp_id =
     (SELECT
      cnfg_mgr_grp_id
      FROM cnfg_mgr_grp
      WHERE (grp_key_txt=import->utility_list[d.seq].parent_key_txt)),
     grp.updt_applctx = reqinfo->updt_applctx, grp.updt_cnt = (1+ grp.updt_cnt), grp.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     grp.updt_id = reqinfo->updt_id, grp.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (grp
     WHERE grp.grp_key_txt=trim(import->utility_list[d.seq].grp_key_txt)
      AND (import->utility_list[d.seq].exist_in_db_ind=1))
    WITH nocounter
   ;end update
   SET errorcode = checkforerrmsg("Error in UpdateData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing UpdateData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforerrmsg(msg)
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(msg,":",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(errcode)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully inserted data into the cnfg_mgr_grp table"
#exit_script
 FREE RECORD import
END GO
