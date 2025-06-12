CREATE PROGRAM bed_get_edge_compatibility:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 edge_support = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = vc
        3 operationstatus = c1
        3 targetobjectname = vc
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->edge_support = 0
 SELECT INTO "nl:"
  FROM br_step_parameter bsp
  WHERE (bsp.step_mean=request->wizard_mean)
   AND bsp.parameter_name="BROWSER"
   AND (bsp.parameter_value=request->browser_type)
  DETAIL
   reply->edge_support = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
