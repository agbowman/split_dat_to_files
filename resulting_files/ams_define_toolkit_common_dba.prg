CREATE PROGRAM ams_define_toolkit_common:dba
 CALL echo("***")
 CALL echo("***   BEG: AMS_DEFINE_TOOLKIT_COMMON")
 CALL echo("***")
 IF (validate(bamstoolkitcommondefined,0)=0)
  DECLARE bamstoolkitcommondefined = i2 WITH constant(1), persistscript
  DECLARE damstoolkitdefaultknt = f8 WITH protect, noconstant(1.0)
  DECLARE isamsuser(a_person_id=f8) = i2 WITH copy
  DECLARE updtdminfo(samstoolkitprogramname=vc,damstoolkitprogramknt=f8(value,1.0)) = null WITH copy
  SUBROUTINE isamsuser(the_person_id)
    CALL echo("***")
    CALL echo("***   BEG: IsAMSUser")
    CALL echo(build2("***   the_person_id: ",the_person_id))
    CALL echo("***")
    DECLARE breturnvalue = i2 WITH protect, noconstant(false)
    DECLARE dcvnametypeprsnl = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2403228")
     )
    SELECT INTO "nl:"
     p.person_id
     FROM person_name p
     PLAN (p
      WHERE p.person_id=the_person_id
       AND p.name_type_cd=dcvnametypeprsnl
       AND p.name_title IN ("Cerner AMS", "Cerner ITWx", "Cerner CommWx")
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     DETAIL
      IF (p.person_id > 0)
       breturnvalue = true
      ENDIF
     WITH nocounter
    ;end select
    CALL echo("***")
    CALL echo("***   END: IsAMSUser")
    CALL echo(build2("***   bReturnValue: ",breturnvalue))
    CALL echo("***")
    RETURN(breturnvalue)
  END ;Subroutine
  SUBROUTINE updtdminfo(samstoolkitprogramname,damstoolkitprogramknt)
    CALL echo("***")
    CALL echo("***   BEG: UpdtDMInfo")
    CALL echo(build2("***   sAMSToolKitProgramName: ",samstoolkitprogramname))
    CALL echo("***")
    DECLARE bprogramhasbeenlogged = i2 WITH protect, noconstant(false)
    DECLARE duseknt = f8 WITH protect, noconstant(0.0)
    DECLARE scurrentmonth = c3 WITH protect, constant(format(cnvtdatetime(curdate,0),"MMM;;Q"))
    DECLARE scurrentyear = c4 WITH protect, constant(format(cnvtdatetime(curdate,0),"YYYY;;Q"))
    DECLARE sdomainname = vc WITH protect, constant(concat("AMS_TOOLKIT_",trim(scurrentmonth,3)))
    DECLARE sthename = vc WITH protect, constant(cnvtupper(trim(samstoolkitprogramname,3)))
    SELECT INTO "nl:"
     FROM dm_info d
     PLAN (d
      WHERE d.info_domain=sdomainname
       AND d.info_name=sthename)
     DETAIL
      IF (d.info_char=scurrentyear)
       duseknt = d.info_number
      ENDIF
      bprogramhasbeenlogged = true
     WITH nocounter
    ;end select
    CALL echo("***")
    CALL echo(build2("***   bProgramHasBeenLogged: ",bprogramhasbeenlogged))
    CALL echo("***")
    IF (bprogramhasbeenlogged=false)
     INSERT  FROM dm_info d
      SET d.info_domain = sdomainname, d.info_name = sthename, d.info_date = cnvtdatetime(curdate,
        curtime3),
       d.info_number = (duseknt+ damstoolkitprogramknt), d.info_char = scurrentyear, d.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       d.updt_cnt = 0
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM dm_info d
      SET d.info_number = (duseknt+ damstoolkitprogramknt), d.info_char = scurrentyear, d.updt_dt_tm
        = cnvtdatetime(curdate,curtime3),
       d.updt_id = reqinfo->updt_id, d.updt_cnt = (d.updt_cnt+ 1)
      PLAN (d
       WHERE d.info_domain=sdomainname
        AND d.info_name=sthename)
      WITH nocounter
     ;end update
    ENDIF
    COMMIT
    CALL echo("***")
    CALL echo("***   END: UpdtDMInfo")
    CALL echo("***")
  END ;Subroutine
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   END: AMS_DEFINE_TOOLKIT_COMMON")
 CALL echo("***")
 SET script_ver = "002 09/27/16 SB8469         Title Addition"
END GO
