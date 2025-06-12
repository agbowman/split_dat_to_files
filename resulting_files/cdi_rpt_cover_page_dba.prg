CREATE PROGRAM cdi_rpt_cover_page:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE strexecutestring = vc WITH noconstant("")
 DECLARE strlayoutprogram = vc WITH noconstant("cdi_rpt_cover_page_lyt")
 DECLARE stroutputdest = vc WITH noconstant("-")
 DECLARE bvalidoutputdest = i2 WITH noconstant(0)
 IF (pc_request=0)
  IF (validate(request->output_dest_cd,0.0) > 0)
   SELECT INTO "nl:"
    FROM output_dest od,
     device d
    PLAN (od
     WHERE (od.output_dest_cd=request->output_dest_cd))
     JOIN (d
     WHERE d.device_cd=od.device_cd)
    DETAIL
     stroutputdest = d.name
    WITH nocounter
   ;end select
  ELSE
   SET stroutputdest = validate(request->output_dist,"-")
  ENDIF
 ELSE
  SET stroutputdest = validate(request->output_device,"-")
 ENDIF
 IF (stroutputdest="MINE")
  SET bvalidoutputdest = 1
 ELSE
  SELECT INTO "NL:"
   o.name
   FROM output_dest o
   WHERE cnvtupper(o.name)=cnvtupper(stroutputdest)
   DETAIL
    bvalidoutputdest = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (bvalidoutputdest=0)
  SET failed = 99
  SET error_value = "Invalid output destination."
 ELSE
  SET strexecutestring = build2("execute ",strlayoutprogram," '",stroutputdest,"' go")
  CALL parser(strexecutestring)
 ENDIF
END GO
