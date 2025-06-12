CREATE PROGRAM daf_migrator_import_ccl:dba
 IF (validate(request->obj_list,"Z")="Z")
  FREE RECORD request
  RECORD request(
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 obj_list[*]
     2 script_name = vc
     2 script_group = i2
     2 exists_ind = i2
     2 script_status = vc
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
 SET stat = alterlist(reply->obj_list,size(request->obj_list,5))
 FOR (i = 1 TO size(request->obj_list,5))
   SET reply->obj_list[i].script_name = request->obj_list[i].script_name
   SET reply->obj_list[i].script_group = request->obj_list[i].script_group
   SET reply->obj_list[i].exists_ind = 0
   SET reply->obj_list[i].script_status = "NOOP"
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  cso.object_name, cso.cclgroup
  FROM ccl_synch_objects cso,
   (dummyt d  WITH seq = value(size(reply->obj_list,5)))
  PLAN (d)
   JOIN (cso
   WHERE cso.object_name=cnvtupper(reply->obj_list[d.seq].script_name)
    AND (cso.cclgroup=reply->obj_list[d.seq].script_group))
  DETAIL
   reply->obj_list[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch staged objects:",errmsg)
  GO TO exit_script
 ENDIF
 DECLARE missing = i2 WITH public, noconstant(0)
 FOR (i = 1 TO size(reply->obj_list,5))
   IF ((reply->obj_list[i].exists_ind=0))
    SET missing = 1
    SET reply->obj_list[i].script_status = "MISSING"
   ENDIF
 ENDFOR
 IF (missing=1)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Some scripts were missing their import data!")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO value(size(reply->obj_list,5)))
   EXECUTE ccl_dic_import_objects cnvtupper(reply->obj_list[i].script_name), reply->obj_list[i].
   script_group, "Y"
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    IF (errcode=19)
     SET reply->obj_list[i].script_status = "SUCCESS"
     CALL echo("I got error code 19.  Ignoring...")
     CALL echo(errmsg)
    ELSE
     SET reply->status_data.status = "F"
     SET reply->message = concat("Error exporting ",reply->obj_list[i].script_name,": ",errmsg)
     SET reply->obj_list[i].script_status = "FAILED"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->obj_list[i].script_status = "SUCCESS"
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully exported all staged scripts for migration"
#exit_script
END GO
