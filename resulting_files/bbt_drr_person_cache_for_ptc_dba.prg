CREATE PROGRAM bbt_drr_person_cache_for_ptc:dba
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
 DECLARE new_temp_person_id = f8 WITH noconstant(0.0)
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE istat = i2 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(fillstring(132," "))
 DECLARE error_code = i4 WITH noconstant(0)
 SET istat = findptcdata(request->process)
 IF (istat != 1)
  CALL load_process_status("S","SUCCESS",build(
    "No BloodBank data to be processed for the person_id =",request->person_id))
  GO TO exit_script
 ENDIF
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SET new_temp_person_id = next_pathnet_seq(0)
 IF (curqual=0)
  CALL load_process_status("F","get next pathnet_seq",build(
    "get next pathnet_seq failed--person_id =",request->person_id))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM bb_ptc_temp_person p
  WHERE (p.person_id=request->person_id)
  WITH nocounter, forupdate(p)
 ;end select
 IF (curqual=0)
  INSERT  FROM bb_ptc_temp_person p
   SET p.bb_ptc_temp_person_id = new_temp_person_id, p.person_id = request->person_id, p
    .process_type_flag =
    IF ((request->process="RESTRICT")) 1
    ELSEIF ((request->process="UNRESTRICT")) 2
    ELSEIF ((request->process="DELETE")) 3
    ENDIF
    ,
    p.export_ind = 0, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  SET error_code = error(error_msg,0)
  IF (error_code != 0)
   CALL load_process_status("F","insert into bb_ptc_temp_person",concat(build(
      "insert into bb_ptc_temp_person failed--person_id =",request->person_id)," :",error_msg))
   GO TO exit_script
  ELSE
   CALL load_process_status("S","SUCCESS","person_id added successfully")
  ENDIF
 ELSE
  UPDATE  FROM bb_ptc_temp_person p
   SET p.process_type_flag =
    IF ((request->process="RESTRICT")) 1
    ELSEIF ((request->process="UNRESTRICT")) 2
    ELSEIF ((request->process="DELETE")) 3
    ENDIF
    , p.export_ind = 0, p.updt_cnt = (p.updt_cnt+ 1),
    p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
    updt_task,
    p.updt_applctx = reqinfo->updt_applctx
   WHERE (p.person_id=request->person_id)
   WITH nocounter
  ;end update
  SET error_code = error(error_msg,0)
  IF (error_code != 0)
   CALL load_process_status("F","update into bb_ptc_temp_person",concat(build(
      "update into bb_ptc_temp_person failed--person_id =",request->person_id)," :",error_msg))
   GO TO exit_script
  ELSE
   CALL load_process_status("S","SUCCESS","person_id added successfully")
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE (findptcdata(process_type=vc) =i2)
   IF (process_type != "DELETE")
    SELECT
     pa.person_id
     FROM person_aborh pa
     PLAN (pa
      WHERE (((pa.person_id=request->person_id)) UNION (
      (SELECT
       pab.person_id
       FROM person_antibody pab
       WHERE (((pab.person_id=request->person_id)) UNION (
       (SELECT
        pan.person_id
        FROM person_antigen pan
        WHERE (((pan.person_id=request->person_id)) UNION (
        (SELECT
         bb.person_id
         FROM blood_bank_comment bb
         WHERE (((bb.person_id=request->person_id)) UNION (
         (SELECT
          prh.person_id
          FROM person_rh_phenotype prh
          WHERE (((prh.person_id=request->person_id)) UNION (
          (SELECT
           ptr.person_id
           FROM person_trans_req ptr
           WHERE (ptr.person_id=request->person_id)))) ))) ))) ))) ))) )
     WITH rdbunion
    ;end select
   ELSE
    SELECT
     pa.person_id
     FROM person_aborh0792drr pa
     PLAN (pa
      WHERE (((pa.person_id=request->person_id)) UNION (
      (SELECT
       pab.person_id
       FROM person_antibody1448drr pab
       WHERE (((pab.person_id=request->person_id)) UNION (
       (SELECT
        pan.person_id
        FROM person_antigen1658drr pan
        WHERE (((pan.person_id=request->person_id)) UNION (
        (SELECT
         bb.person_id
         FROM blood_bank_comment0777drr bb
         WHERE (((bb.person_id=request->person_id)) UNION (
         (SELECT
          prh.person_id
          FROM person_rh_phenotyp2876drr prh
          WHERE (((prh.person_id=request->person_id)) UNION (
          (SELECT
           ptr.person_id
           FROM person_trans_req2547drr ptr
           WHERE (ptr.person_id=request->person_id)))) ))) ))) ))) ))) )
     WITH rdbunion
    ;end select
   ENDIF
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (load_process_status(sub_status=c1,sub_process=vc,sub_message=vc) =null)
   SET reply->status_data.status = sub_status
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_drr_person_cache_for_ptc"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
