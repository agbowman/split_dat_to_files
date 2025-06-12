CREATE PROGRAM daf_migrator_write_cidb_uri:dba
 IF (validate(request->info_domain,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 info_domain = vc
    1 info_name = vc
    1 cidb_location = vc
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 DECLARE exists_ind = i2 WITH public, noconstant(0)
 DECLARE old_cidb_location = vc WITH public
 IF (((size(request->info_domain,1)=0) OR (((size(request->info_name,1)=0) OR (size(request->
  cidb_location,1)=0)) )) )
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure contains no data."
  SET reply->cidb_location = ""
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE (di.info_domain=request->info_domain)
   AND (di.info_name=request->info_name)
  DETAIL
   exists_ind = 1, old_cidb_location = trim(di.info_char,3)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to retrieve Original CIDB location:",errmsg)
  GO TO exit_script
 ENDIF
 IF (exists_ind=1)
  IF (old_cidb_location=trim(request->cidb_location,3))
   SET reply->status_data.status = "S"
   SET reply->message = "The CIDB Location was already written to the database."
   GO TO exit_script
  ELSE
   UPDATE  FROM dm_info di
    SET di.info_char = trim(request->cidb_location,3), di.updt_dt_tm = sysdate
    WHERE (di.info_domain=request->info_domain)
     AND (di.info_name=request->info_name)
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to update the CIDB location:",errmsg)
    GO TO exit_script
   ENDIF
   SET reply->status_data.status = "S"
   SET reply->message = "Successfully updated the CIDB location."
   COMMIT
  ENDIF
 ELSE
  INSERT  FROM dm_info di
   SET di.info_domain = request->info_domain, di.info_name = request->info_name, di.info_char = trim(
     request->cidb_location,3),
    di.updt_dt_tm = sysdate
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   SET reply->message = concat("Unable to write the CIDB location:",errmsg)
   GO TO exit_script
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->message = "Successfully wrote the CIDB Location"
  COMMIT
 ENDIF
#exit_script
END GO
