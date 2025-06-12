CREATE PROGRAM daf_migrator_encode_scripts:dba
 IF ((validate(request->environment_id,- (1))=- (1)))
  FREE RECORD request
  RECORD request(
    1 environment_id = f8
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 synch_list[*]
     2 cclgroup = i4
     2 ccl_synch_object_id = f8
     2 checksum = i4
     2 dic_data0 = vgc
     2 dic_data1 = vgc
     2 dic_key0 = vgc
     2 dic_key1 = vgc
     2 dir_name = vc
     2 endian_platform = i4
     2 major_version = i4
     2 minor_version = i4
     2 node_name = vc
     2 object_name = vc
     2 object_type = vc
     2 qual = i4
     2 rcode = c1
     2 timestamp_dt_tm = dq8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
   1 bad_list[*]
     2 script_name = vc
     2 script_group = i2
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
 DECLARE dmes_bad_list = i4 WITH public, noconstant(0)
 IF ((request->environment_id=0))
  SET reply->status_data.status = "F"
  SET reply->message = "There was no environment id chosen for this operation."
  GO TO exit_script
 ENDIF
 FREE RECORD dmes_scripts
 RECORD dmes_scripts(
   1 script_list[*]
     2 script_name = vc
     2 script_group = i4
 )
 SELECT INTO "nl:"
  FROM dm_script_migration_stage dsms
  WHERE (dsms.target_environment_id=request->environment_id)
   AND dsms.active_ind=1
  HEAD REPORT
   loopctr = 0
  DETAIL
   IF (mod(loopctr,10)=0)
    stat = alterlist(dmes_scripts->script_list,(loopctr+ 10))
   ENDIF
   loopctr = (loopctr+ 1), dmes_scripts->script_list[loopctr].script_name = dsms.script_name,
   dmes_scripts->script_list[loopctr].script_group = dsms.script_group_nbr
  FOOT REPORT
   stat = alterlist(dmes_scripts->script_list,loopctr)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch staged objects:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET reply->message = "There were no scripts staged for migration"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO value(size(dmes_scripts->script_list,5)))
   EXECUTE ccl_dic_export_objects dmes_scripts->script_list[i].script_name, dmes_scripts->
   script_list[i].script_group, "Y"
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Error exporting ",dmes_scripts->script_list[i].script_name,": ",
     errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    cso.object_name
    FROM ccl_synch_objects cso
    WHERE cso.object_name=cnvtupper(dmes_scripts->script_list[i].script_name)
     AND (cso.cclgroup=dmes_scripts->script_list[i].script_group)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dmes_bad_list = (dmes_bad_list+ 1)
    SET stat = alterlist(reply->bad_list,dmes_bad_list)
    SET reply->bad_list[dmes_bad_list].script_name = dmes_scripts->script_list[i].script_name
    SET reply->bad_list[dmes_bad_list].script_group = dmes_scripts->script_list[i].script_group
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM ccl_synch_objects cso,
   (dummyt d  WITH seq = value(size(dmes_scripts->script_list,5)))
  PLAN (d)
   JOIN (cso
   WHERE cnvtupper(cso.object_name)=cnvtupper(dmes_scripts->script_list[d.seq].script_name)
    AND (cso.cclgroup=dmes_scripts->script_list[d.seq].script_group))
  HEAD REPORT
   loopctr = 0
  DETAIL
   IF (mod(loopctr,10)=0)
    stat = alterlist(reply->synch_list,(loopctr+ 10))
   ENDIF
   loopctr = (loopctr+ 1), reply->synch_list[loopctr].cclgroup = cso.cclgroup, reply->synch_list[
   loopctr].ccl_synch_object_id = cso.ccl_synch_objects_id,
   reply->synch_list[loopctr].checksum = cso.checksum, reply->synch_list[loopctr].dic_data0 = cso
   .dic_data0, reply->synch_list[loopctr].dic_data1 = cso.dic_data1,
   reply->synch_list[loopctr].dic_key0 = cso.dic_key0, reply->synch_list[loopctr].dic_key1 = cso
   .dic_key1, reply->synch_list[loopctr].dir_name = cso.dir_name,
   reply->synch_list[loopctr].endian_platform = cso.endian_platform, reply->synch_list[loopctr].
   major_version = cso.major_version, reply->synch_list[loopctr].minor_version = cso.minor_version,
   reply->synch_list[loopctr].node_name = cso.node_name, reply->synch_list[loopctr].object_name = cso
   .object_name, reply->synch_list[loopctr].object_type = cso.object_type,
   reply->synch_list[loopctr].qual = cso.qual, reply->synch_list[loopctr].rcode = cso.rcode, reply->
   synch_list[loopctr].timestamp_dt_tm = cnvtdatetime(cso.timestamp_dt_tm),
   reply->synch_list[loopctr].updt_applctx = cso.updt_applctx, reply->synch_list[loopctr].updt_cnt =
   cso.updt_cnt, reply->synch_list[loopctr].updt_dt_tm = cnvtdatetime(cso.updt_dt_tm),
   reply->synch_list[loopctr].updt_id = cso.updt_id, reply->synch_list[loopctr].updt_task = cso
   .updt_task
  FOOT REPORT
   stat = alterlist(reply->synch_list,loopctr)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write reply:",errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully exported all staged scripts for migration"
#exit_script
END GO
