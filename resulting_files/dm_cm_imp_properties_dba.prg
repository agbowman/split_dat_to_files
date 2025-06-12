CREATE PROGRAM dm_cm_imp_properties:dba
 IF (validate(request->list[1].domain_name,"99")="99")
  FREE RECORD request
  RECORD request(
    1 list[*]
      2 domain_name = vc
      2 prop_csv = vc
      2 reltn_csv = vc
      2 map_csv = vc
  )
 ENDIF
 IF (validate(reply->status,"99")="99")
  FREE RECORD reply
  RECORD reply(
    1 status = vc
    1 message = vc
  )
 ENDIF
 DECLARE dcip_loop = i4 WITH protect, noconstant(0)
 DECLARE dcip_stat = i2 WITH protect, noconstant(1)
 DECLARE dcip_msg = vc WITH protect, noconstant("")
 DECLARE dcip_script_status = c1 WITH protect, noconstant("")
 DECLARE rdmmsg = vc WITH public, noconstant("")
 DECLARE dcip_check_script_status(dcip_logfile=vc) = c1
 FOR (dcip_loop = 1 TO size(request->list,5))
   CALL echo(concat("Looking for: ",request->list[dcip_loop].prop_csv))
   SET dcip_stat = findfile(request->list[dcip_loop].prop_csv)
   IF (dcip_stat=0)
    SET dcip_msg = concat("Failed to find csv file: ",request->list[dcip_loop].prop_csv)
    CALL echo(dcip_msg)
    SET reply->status = "F"
    SET reply->message = dcip_msg
    GO TO exit_script
   ENDIF
   CALL echo(concat("Looking for: ",request->list[dcip_loop].reltn_csv))
   SET dcip_stat = findfile(request->list[dcip_loop].reltn_csv)
   IF (dcip_stat=0)
    SET dcip_msg = concat("Failed to find csv file: ",request->list[dcip_loop].reltn_csv)
    CALL echo(dcip_msg)
    SET reply->status = "F"
    SET reply->message = dcip_msg
    GO TO exit_script
   ENDIF
   IF ((request->list[dcip_loop].map_csv > " "))
    CALL echo(concat("Looking for: ",request->list[dcip_loop].map_csv))
    SET dcip_stat = findfile(request->list[dcip_loop].map_csv)
    IF (dcip_stat=0)
     SET dcip_msg = concat("Failed to find csv file: ",request->list[dcip_loop].map_csv)
     CALL echo(dcip_msg)
     SET reply->status = "F"
     SET reply->message = dcip_msg
     GO TO exit_script
    ENDIF
   ENDIF
   SET errcode = error(dcip_msg,1)
   DELETE  FROM content_property_reltn cpr
    WHERE ((cpr.child_property_id IN (
    (SELECT
     cp.property_id
     FROM content_property cp
     WHERE (cp.domain_name=request->list[dcip_loop].domain_name)))) OR (cpr.parent_property_id IN (
    (SELECT
     cp.property_id
     FROM content_property cp
     WHERE (cp.domain_name=request->list[dcip_loop].domain_name)))))
    WITH nocounter
   ;end delete
   IF (error(dcip_msg,0) != 0)
    ROLLBACK
    SET reply->status = "F"
    SET reply->message = concat("Failed deleting content_property_reltn rows:",dcip_msg)
    GO TO exit_script
   ENDIF
   IF ((request->list[dcip_loop].map_csv > " "))
    DELETE  FROM content_property_map cpm
     WHERE cpm.content_property_id IN (
     (SELECT
      cp.property_id
      FROM content_property cp
      WHERE (cp.domain_name=request->list[dcip_loop].domain_name)))
     WITH nocounter
    ;end delete
    IF (error(dcip_msg,0) != 0)
     ROLLBACK
     SET reply->status = "F"
     SET reply->message = concat("Failed deleting content_property_map rows:",dcip_msg)
     GO TO exit_script
    ENDIF
   ENDIF
   DELETE  FROM content_property cp
    WHERE (cp.domain_name=request->list[dcip_loop].domain_name)
    WITH nocounter
   ;end delete
   IF (error(dcip_msg,0) != 0)
    ROLLBACK
    SET reply->status = "F"
    SET reply->message = concat("Failed deleting content_property rows:",dcip_msg)
    GO TO exit_script
   ENDIF
   EXECUTE dm_dbimport request->list[dcip_loop].prop_csv, "kia_imp_content_property", 1000
   SET dcip_script_status = dcip_check_script_status("kia_imp_content_property.log")
   IF (((dcip_script_status="F") OR ((readme_data->status != "S"))) )
    SET dcip_msg = concat("Failed on inserting: ",request->list[dcip_loop].prop_csv)
    CALL echo(dcip_msg)
    SET reply->status = "F"
    SET reply->message = dcip_msg
    GO TO exit_script
   ENDIF
   IF ((request->list[dcip_loop].map_csv > " "))
    EXECUTE dm_dbimport request->list[dcip_loop].map_csv, "kia_imp_cont_prop_map", 1000
    SET dcip_script_status = dcip_check_script_status("kia_imp_cont_prop_map.log")
    IF (((dcip_script_status="F") OR ((readme_data->status != "S"))) )
     SET dcip_msg = concat("Failed on inserting: ",request->list[dcip_loop].map_csv)
     CALL echo(dcip_msg)
     SET reply->status = "F"
     SET reply->message = dcip_msg
     GO TO exit_script
    ENDIF
   ENDIF
   EXECUTE dm_dbimport request->list[dcip_loop].reltn_csv, "kia_imp_property_reltn", 1000
   SET dcip_script_status = dcip_check_script_status("kia_imp_property_reltn.log")
   IF (((dcip_script_status="F") OR ((readme_data->status != "S"))) )
    SET dcip_msg = concat("Failed on inserting: ",request->list[dcip_loop].reltn_csv)
    CALL echo(dcip_msg)
    SET reply->status = "F"
    SET reply->message = dcip_msg
    GO TO exit_script
   ENDIF
   IF ((reply->status="F"))
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 SET reply->status = "S"
 SET reply->message = "Successfully loaded all content property data"
#exit_script
 SUBROUTINE dcip_check_script_status(dcip_logfile)
   DECLARE dcip_script_stat = c1 WITH protect, noconstant("F")
   FREE DEFINE rtl2
   DEFINE rtl2 value(dcip_logfile)
   SELECT INTO "nl:"
    r.*
    FROM rtl2t r
    HEAD REPORT
     dcip_script_stat = "F"
    FOOT REPORT
     IF (((findstring("SUCCESS",cnvtupper(trim(r.line)),0)) OR (findstring("WARNING",cnvtupper(trim(r
        .line)),0))) )
      dcip_script_stat = "S"
     ENDIF
    WITH check
   ;end select
   RETURN(dcip_script_stat)
 END ;Subroutine
END GO
