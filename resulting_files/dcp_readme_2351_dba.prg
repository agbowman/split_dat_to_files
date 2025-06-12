CREATE PROGRAM dcp_readme_2351:dba
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
 EXECUTE gm_dm_info2388_def "D"
 DECLARE gm_d_dm_info2388_vc(icol_name=vc,ival=vc,iqual=i4) = i2
 SUBROUTINE gm_d_dm_info2388_vc(icol_name,ival,iqual)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_d_dm_info2388_req->qual,5) < iqual)
    SET stat = alterlist(gm_d_dm_info2388_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "info_domain":
     SET gm_d_dm_info2388_req->qual[iqual].info_domain = ival
     SET gm_d_dm_info2388_req->info_domainw = 1
    OF "info_name":
     SET gm_d_dm_info2388_req->qual[iqual].info_name = ival
     SET gm_d_dm_info2388_req->info_namew = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 RECORD blob(
   1 qual[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 text_type_cd = f8
     2 lt_refr_text_id = f8
     2 lb_refr_text_id = f8
     2 long_text_id = f8
     2 long_blob_id = f8
     2 long_text = vc
 )
 RECORD readme_run(
   1 dt = dq8
 )
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE count2 = i4 WITH noconstant(0)
 DECLARE rdm_errcode = i4 WITH noconstant(0)
 DECLARE rdm_errmsg = c132
 DECLARE errmsg = c132
 DECLARE readme_status = c1
 SET rdm_errmsg = fillstring(132," ")
 SET readme_status = "S"
 SET rdm_errcode = error(rdm_errmsg,1)
 CALL echo("Starting dcp_readme_2351")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_name="Reference Text Readme"
  DETAIL
   readme_run_date = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "Could not read readme run date from DM_INFO table"
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  WHERE rtr.ref_text_reltn_id > 0.0
  HEAD REPORT
   count2 = 0
  DETAIL
   count2 = (count2+ 1)
  WITH nocounter
 ;end select
 IF (count2=0)
  SET readme_status = "Q"
  SET rdm_errmsg = "No rows on ref_text_reltn table"
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr,
   ref_text rt,
   long_text lt
  PLAN (rtr
   WHERE rtr.refr_text_id > 0
    AND rtr.active_ind=1)
   JOIN (rt
   WHERE rt.refr_text_id=rtr.refr_text_id
    AND rt.text_entity_name="LONG_TEXT")
   JOIN (lt
   WHERE lt.long_text_id=rt.text_entity_id
    AND lt.updt_dt_tm >= cnvtdatetime(readme_run->dt))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(blob->qual,(count1+ 9))
   ENDIF
   blob->qual[count1].parent_entity_name = rtr.parent_entity_name, blob->qual[count1].
   parent_entity_id = rtr.parent_entity_id, blob->qual[count1].text_type_cd = rtr.text_type_cd,
   blob->qual[count1].lt_refr_text_id = rt.refr_text_id, blob->qual[count1].long_text_id = rt
   .text_entity_id, blob->qual[count1].long_text = trim(lt.long_text),
   blob->qual[count1].long_blob_id = 0
  FOOT REPORT
   stat = alterlist(blob->qual,count1),
   CALL echo(build("REF_TEXT_RELTN rows count:",count1))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_status = "Q"
  GO TO update_tables
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(count1)),
   ref_text_reltn rtr,
   ref_text rt
  PLAN (d1)
   JOIN (rtr
   WHERE (rtr.parent_entity_name=blob->qual[d1.seq].parent_entity_name)
    AND (rtr.parent_entity_id=blob->qual[d1.seq].parent_entity_id)
    AND (rtr.text_type_cd=blob->qual[d1.seq].text_type_cd))
   JOIN (rt
   WHERE rt.refr_text_id=rtr.refr_text_id
    AND rt.text_entity_name="LONG_BLOB")
  DETAIL
   blob->qual[count1].lb_refr_text_id = rt.refr_text_id, blob->qual[count1].long_blob_id = rt
   .text_entity_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lb.*
  FROM (dummyt d1  WITH seq = value(count1)),
   long_blob lb
  PLAN (d1)
   JOIN (lb
   WHERE (lb.long_blob_id=blob->qual[d1.seq].long_blob_id))
  WITH nocounter, forupdate(lb)
 ;end select
 IF (curqual=0)
  SET readme_status = "F"
  SET rdm_errmsg = "Could not lock long_blob table for update"
  GO TO exit_readme
 ENDIF
 UPDATE  FROM (dummyt d1  WITH seq = value(count1)),
   long_blob lb
  SET lb.long_blob = blob->qual[d1.seq].long_text, lb.long_blob_id = blob->qual[d1.seq].long_blob_id,
   lb.parent_entity_id = blob->qual[d1.seq].lb_refr_text_id,
   lb.parent_entity_name = "REF_TEXT", lb.active_ind = 1, lb.active_status_cd = reqdata->
   active_status_cd,
   lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
   updt_id, lb.updt_applctx = reqinfo->updt_applctx,
   lb.updt_cnt = (lb.updt_cnt+ 1), lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id =
   reqinfo->updt_id,
   lb.updt_task = reqinfo->updt_task
  PLAN (d1)
   JOIN (lb
   WHERE (lb.long_blob_id=blob->qual[d1.seq].long_blob_id)
    AND lb.long_blob_id > 0)
  WITH nocounter
 ;end update
 FOR (i = 1 TO count1)
   IF ((blob->qual[i].long_blob_id=0))
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)"######################;RP0"
     FROM dual
     DETAIL
      blob->qual[i].long_blob_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET err_msg = "unable to generate sequence for long_blob table"
     SET failed = "T"
     CALL log_status("SEQUENCE","F","LONG_BLOB",err_msg)
     GO TO exit_script
    ENDIF
    INSERT  FROM long_blob lb
     SET lb.long_blob = blob->qual[i].long_text, lb.long_blob_id = blob->qual[i].long_blob_id, lb
      .parent_entity_id = blob->qual[i].lb_ref_text_id,
      lb.parent_entity_name = "REF_TEXT", lb.active_ind = 1, lb.active_status_cd = reqdata->
      active_status_cd,
      lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
      updt_id, lb.updt_applctx = reqinfo->updt_applctx,
      lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
      lb.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
#update_tables
 CALL echo("Updating tables....")
 SELECT INTO "nl:"
  FROM long_text lt,
   ref_text rt
  PLAN (rt
   WHERE rt.text_entity_name="LONG_TEXT")
   JOIN (lt
   WHERE rt.text_entity_id=lt.long_text_id
    AND lt.parent_entity_name="REF_TEXT"
    AND lt.active_ind=1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No update needed for long_text table")
 ELSE
  UPDATE  FROM long_text lt
   SET lt.active_ind = 0
   WHERE lt.parent_entity_name="REF_TEXT"
    AND lt.long_text_id IN (
   (SELECT
    rt.text_entity_id
    FROM ref_text rt
    WHERE rt.text_entity_name="LONG_TEXT"))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg = "Could not inactivate long_text rows with old reference text"
   GO TO exit_readme
  ELSE
   CALL echo("Updated long_text table")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text rt
  PLAN (rt
   WHERE rt.active_ind=1
    AND rt.text_entity_name="LONG_TEXT")
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No reference text rows to update")
 ELSE
  UPDATE  FROM ref_text rt
   SET rt.active_ind = 0
   WHERE rt.text_entity_name="LONG_TEXT"
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg =
   "Could not inactivate ref_text rows with old reference text pointing to long_text table"
   GO TO exit_readme
  ELSE
   CALL echo("Updated ref_text table")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr,
   ref_text rt
  PLAN (rt
   WHERE rt.text_entity_name="LONG_TEXT")
   JOIN (rtr
   WHERE rtr.refr_text_id=rt.refr_text_id
    AND rtr.active_ind=1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No ref_text_reltn rows to inactivate")
 ELSE
  UPDATE  FROM ref_text_reltn rtr
   SET rtr.active_ind = 0
   WHERE rtr.refr_text_id IN (
   (SELECT
    rt.refr_text_id
    FROM ref_text rt
    WHERE rt.text_entity_name="LONG_TEXT"))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET readme_status = "F"
   SET rdm_errmsg = "Could not inactivate ref_text_reltn rows"
   GO TO exit_readme
  ELSE
   CALL echo("Updated ref_text_reltn table")
  ENDIF
 ENDIF
 SET stat = gm_d_dm_info2388_vc("INFO_NAME","Reference Text Readme",1)
 EXECUTE gm_d_dm_info2388  WITH replace(request,gm_d_dm_info2388_req), replace(reply,
  gm_d_dm_info2388_rep)
 FREE RECORD gm_d_dm_info2388_req
 FREE RECORD gm_d_dm_info2388_rep
#exit_readme
 FREE RECORD blob
 FREE RECORD readme_run
 CALL echo("Updating readme status......")
 IF (readme_status="F")
  SET readme_data->status = "F"
  SET readme_data->message = rdm_errmsg
  ROLLBACK
 ELSEIF (readme_status="S")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Successfully moved reference text from long_text table to long_blob table."
  COMMIT
 ELSEIF (readme_status="Q")
  SET readme_data->status = "S"
  SET readme_data->message = "No new Reference text found."
  COMMIT
 ENDIF
 CALL echo(build(readme_data->status,":",readme_data->message))
 EXECUTE dm_readme_status
END GO
