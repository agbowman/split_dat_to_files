CREATE PROGRAM afc_get_dcr_date:dba
 CALL echo("")
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo(concat(curprog," : ","VERSION : ","CHARGSRV-15782.000"))
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo("")
 RECORD reply(
   1 dcrdate = dq8
 )
 DECLARE cs355_revelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",355,"REVELATE"
    )))
 DECLARE cs356_dcrrevelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",356,
    "REVELATEDCR")))
 DECLARE cs222_facility_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",222,"FACILITY"
    )))
 DECLARE getdatebyorgid(null) = null
 DECLARE getdatebyfacilitycd(null) = null
 IF (validate(request->organization_id,0.0) > 0)
  CALL getdatebyorgid(null)
 ELSEIF (validate(request->facility_cd,0.0) > 0)
  CALL getdatebyfacilitycd(null)
 ENDIF
 SUBROUTINE getdatebyorgid(null)
   SELECT INTO "nl:"
    FROM org_info o
    PLAN (o
     WHERE (o.organization_id=request->organization_id)
      AND o.info_type_cd=cs355_revelate_cd
      AND o.info_sub_type_cd=cs356_dcrrevelate_cd)
    DETAIL
     reply->dcrdate = o.value_dt_tm
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getdatebyfacilitycd(null)
   SELECT INTO "nl:"
    FROM location l,
     org_info o
    PLAN (l
     WHERE (l.location_cd=request->facility_cd)
      AND l.location_type_cd=cs222_facility_cd)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND o.info_type_cd=cs355_revelate_cd
      AND o.info_sub_type_cd=cs356_dcrrevelate_cd)
    DETAIL
     reply->dcrdate = o.value_dt_tm
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
