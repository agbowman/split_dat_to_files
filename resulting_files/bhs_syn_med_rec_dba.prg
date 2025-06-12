CREATE PROGRAM bhs_syn_med_rec:dba
 DECLARE curlocation = f8
 DECLARE prevlocation = f8
 DECLARE idx = i4
 DECLARE curtrue = i2
 DECLARE prevtrue = i2
 SET fmced = uar_get_code_by("displaykey",220,"FMCEMERGENCY")
 SET bmcedgen = uar_get_code_by("displaykey",220,"EMERGENCYGENER")
 SET bmctrauma = uar_get_code_by("displaykey",220,"EMERGENCYTRAUM")
 SET bmcpedi = uar_get_code_by("displaykey",220,"EMERGENCYPEDI")
 SET bmced = uar_get_code_by("displaykey",220,"BMCEMERGENCY")
 SET eshld = uar_get_code_by("displaykey",220,"ESHLD")
 SET edau = uar_get_code_by("displaykey",220,"EDAU")
 SET ambsg = uar_get_code_by("displaykey",220,"AMBSG")
 SET edhld = uar_get_code_by("displaykey",220,"EDHLD")
 DECLARE icua_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUA"))
 DECLARE icub_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUB"))
 DECLARE icuc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUC"))
 DECLARE iccu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICCU"))
 DECLARE icu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICU"))
 DECLARE c6a_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"C6A"))
 DECLARE s3_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"S3"))
 DECLARE spk4_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"SPK4"))
 DECLARE spk5_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"SPK5"))
 SET eid = trigger_encntrid
 SET retval = 0
 FREE RECORD iculocs
 RECORD iculocs(
   1 qual[*]
     2 locid = f8
 )
 FREE RECORD lastloc
 RECORD lastloc(
   1 updt_cnt = i2
   1 qual[*]
     2 locid = f8
     2 beg_dt = c20
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key IN ("ICUB", "ICUA", "CICU", "ICUC", "ICCU")
   AND cv.active_ind=1
   AND cv.cdf_meaning="NURSEUNIT"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(iculocs->qual,cnt), iculocs->qual[cnt].locid = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_id=eid
  DETAIL
   curlocation = e.loc_nurse_unit_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  WHERE elh.encntr_id=eid
  ORDER BY elh.beg_effective_dt_tm, elh.loc_nurse_unit_cd
  HEAD REPORT
   cnt = 0
  HEAD elh.loc_nurse_unit_cd
   cnt = (cnt+ 1), stat = alterlist(lastloc->qual,cnt), lastloc->qual[cnt].locid = elh
   .loc_nurse_unit_cd,
   lastloc->updt_cnt = cnt, lastloc->qual[cnt].beg_dt = format(elh.beg_effective_dt_tm,
    "dd/mm/yy hh:mm;;d")
  WITH nocounter
 ;end select
 CALL echorecord(iculocs)
 CALL echo(build("curloc:",curlocation))
 CALL echorecord(lastloc)
 IF ((lastloc->updt_cnt > 1))
  SET prevlocation = lastloc->qual[(lastloc->updt_cnt - 1)].locid
 ELSE
  SET prevlocation = lastloc->qual[1].locid
 ENDIF
 IF ((((lastloc->updt_cnt=1)) OR (prevlocation=curlocation)) )
  SET retval = 0
  GO TO exit_script
 ELSE
  FOR (x = 1 TO 4)
    IF (((curlocation IN (iculocs->qual[x].locid, c6a_cd, s3_cd, spk4_cd, spk5_cd)) OR ((prevlocation
    =iculocs->qual[x].locid))) )
     SET retval = 100
    ENDIF
  ENDFOR
 ENDIF
 CALL echo(build("retval:",retval))
#exit_script
END GO
