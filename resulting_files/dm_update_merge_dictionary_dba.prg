CREATE PROGRAM dm_update_merge_dictionary:dba
 PROMPT
  "Enter package number (enter for 002222): " = 2222
 SET leter_2_include = fillstring(132," ")
 SET obj_count = 1
 SET package_number = cnvtstring( $1,6,6,r)
 IF (cursys="AIX")
  SET logical ocddir value(concat(trim(logical("cer_ocd")),"/",package_number))
 ELSE
  SET logical ocddir value(build("cer_ocd:[",package_number,"]"))
 ENDIF
 FREE SET dat_file_name
 SET dat_file_name = concat("ocddir:dicocd",package_number,".dat")
 FREE SET fstat
 SET fstat = findfile(dat_file_name)
 IF (fstat=0)
  CALL echo("***********************")
  CALL echo(concat("File:",dat_file_name,"  not found"))
  CALL echo("***********************")
  GO TO exit_script
 ENDIF
 FREE DEFINE dicocd
 DEFINE dicocd value(dat_file_name)
 SELECT INTO "update_dict"
  dpocd.object, dpocd.object_name, sort_variable = substring(1,1,dpocd.object_name)
  FROM dprotectocd dpocd,
   dprotect dp
  PLAN (dpocd)
   JOIN (dp
   WHERE dpocd.platform=dp.platform
    AND dpocd.rcode=dp.rcode
    AND dpocd.object=dp.object
    AND dpocd.object_name=dp.object_name
    AND dpocd.group=dp.group)
  ORDER BY sort_variable
  HEAD REPORT
   row + 0, last_row = " "
  DETAIL
   IF (last_row != sort_variable)
    IF (dpocd.app_major_version=dp.app_major_version
     AND dpocd.app_minor_version=dp.app_minor_version
     AND dpocd.datestamp=dp.datestamp
     AND dpocd.timestamp=dp.timestamp)
     row + 0
    ELSE
     obj_count = (obj_count+ 1), last_row = sort_variable, letter_2_include = concat(
      "cclocdimport 'dicocd",package_number,".dat','",sort_variable,"*','NOBACKUP' go"),
     letter_2_include, row + 1
    ENDIF
   ENDIF
  WITH outerjoin = dpocd, noformfeed, maxrow = 1
 ;end select
 IF (obj_count > 1)
  CALL compile("update_dict.dat","update_dict_res.dat")
 ENDIF
#exit_script
 FREE DEFINE dicocd
 FREE SET minidictionary
END GO
