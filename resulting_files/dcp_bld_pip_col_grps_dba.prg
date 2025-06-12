CREATE PROGRAM dcp_bld_pip_col_grps:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF (validate(readme_data->readme_id,0) > 0)
  SET readme_data->message = build("BEGIN:dcp_bld_pip_col_grps")
  EXECUTE dm_readme_status
 ELSE
  CALL echo("BEGIN:dcp_bld_pip_col_grps")
 ENDIF
 SUBROUTINE insertcodevalue(pcs,pmeaning,meaning,codeset,colseq)
   SET parent = 0
   SET child = 0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=pcs
     AND cv.cdf_meaning=pmeaning
     AND cv.active_ind=1
    DETAIL
     parent = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=codeset
     AND cv.cdf_meaning=meaning
     AND cv.active_ind=1
    DETAIL
     child = cv.code_value
    WITH nocounter
   ;end select
   IF (child > 0)
    INSERT  FROM code_value_group cvg
     SET cvg.parent_code_value = parent, cvg.code_set = codeset, cvg.child_code_value = child,
      cvg.collation_seq = colseq, cvg.updt_applctx = 0, cvg.updt_id = 0,
      cvg.updt_cnt = 0, cvg.updt_task = 0, cvg.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
    IF (validate(readme_data->readme_id,0) > 0)
     SET readme_data->message = "Inserting column."
     EXECUTE dm_readme_status
    ELSE
     CALL echo("Inserting column.")
    ENDIF
   ELSE
    CALL echo(build(pcs,"-",codeset))
    CALL echo(build(pmeaning,"-",meaning))
    CALL echo(build(parent,"-",child))
   ENDIF
 END ;Subroutine
 SUBROUTINE cleargroup(mcs,codeset)
   RECORD temp(
     1 qual[*]
       2 code_value = f8
   )
   SET stat = 0
   SET cnt = 0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=mcs
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].code_value = cv.code_value
    WITH nocounter
   ;end select
   FOR (i = 1 TO cnt)
     DELETE  FROM code_value_group cvg
      WHERE (cvg.parent_code_value=temp->qual[i].code_value)
      WITH nocounter
     ;end delete
   ENDFOR
 END ;Subroutine
 CALL cleargroup(25511,6023)
 CALL insertcodevalue(25511,"DEMOGFLD","ADMITDOC",6023,0)
 CALL insertcodevalue(25511,"DEMOGFLD","ADMITDTTM",6023,1)
 CALL insertcodevalue(25511,"DEMOGFLD","AGE",6023,2)
 CALL insertcodevalue(25511,"DEMOGFLD","ATTENDDOC",6023,3)
 CALL insertcodevalue(25511,"DEMOGFLD","BED",6023,4)
 CALL insertcodevalue(25511,"DEMOGFLD","CONFIDCD",6023,5)
 CALL insertcodevalue(25511,"DEMOGFLD","CONSULTDOC",6023,6)
 CALL insertcodevalue(25511,"DEMOGFLD","CONTPERSONAD",6023,7)
 CALL insertcodevalue(25511,"DEMOGFLD","CONTPERSONNA",6023,8)
 CALL insertcodevalue(25511,"DEMOGFLD","CONTPERSONPH",6023,9)
 CALL insertcodevalue(25511,"DEMOGFLD","DISCHGDTTM",6023,10)
 CALL insertcodevalue(25511,"DEMOGFLD","DOB",6023,11)
 CALL insertcodevalue(25511,"DEMOGFLD","FACILITY",6023,12)
 CALL insertcodevalue(25511,"DEMOGFLD","FIN",6023,13)
 CALL insertcodevalue(25511,"DEMOGFLD","LENGTHSTAY",6023,14)
 CALL insertcodevalue(25511,"DEMOGFLD","LOCTN",6023,15)
 CALL insertcodevalue(25511,"DEMOGFLD","MEDSVC",6023,16)
 CALL insertcodevalue(25511,"DEMOGFLD","MRN",6023,17)
 CALL insertcodevalue(25511,"DEMOGFLD","PATSTATUS",6023,18)
 CALL insertcodevalue(25511,"DEMOGFLD","PATHOMEADD",6023,19)
 CALL insertcodevalue(25511,"DEMOGFLD","PATPHNUM",6023,20)
 CALL insertcodevalue(25511,"DEMOGFLD","PLANNAME",6023,21)
 CALL insertcodevalue(25511,"DEMOGFLD","PRIMCAREDOC",6023,22)
 CALL insertcodevalue(25511,"DEMOGFLD","REFERPHY",6023,23)
 CALL insertcodevalue(25511,"DEMOGFLD","ROOM",6023,24)
 CALL insertcodevalue(25511,"DEMOGFLD","LEAVE",6023,25)
 CALL insertcodevalue(25511,"DEMOGFLD","TEMPLOCTN",6023,26)
 CALL insertcodevalue(25511,"DEMOGFLD","VIP",6023,27)
 CALL insertcodevalue(25511,"DEMOGFLD","VISITREASON",6023,28)
 CALL insertcodevalue(25511,"DEMOGFLD","ENCNTRTYPE",6023,29)
 CALL insertcodevalue(25511,"DEMOGFLD","BLDG",6023,30)
 CALL insertcodevalue(25511,"DEMOGFLD","NURSEUNIT",6023,31)
 CALL insertcodevalue(25511,"DEMOGFLD","ASSOC",6023,32)
 CALL insertcodevalue(25511,"DEMOGFLD","SEX",6023,33)
 CALL insertcodevalue(25511,"DEMOGFLD","VISITSTATUS",6023,34)
 CALL cleargroup(25491,25511)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","DEMOGFLD",25511,0)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","ORDDETAIL",25511,1)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","IVIND",25511,2)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","PROBLEMIND",25511,3)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","ALLERGYIND",25511,4)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","SCHEDEVENTIN",25511,5)
 CALL insertcodevalue(25491,"DEMOGRAPHIC","PWIND",25511,6)
 CALL insertcodevalue(25491,"NOTIFY","RESULTNOTIFY",25511,7)
 CALL insertcodevalue(25491,"NOTIFY","ORDERNOTIFY",25511,8)
 CALL insertcodevalue(25491,"NOTIFY","NOTEIND",25511,9)
 CALL insertcodevalue(25491,"RESULT","RESULT",25511,10)
 IF (validate(readme_data->readme_id,0) > 0)
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
 ELSE
  CALL echo("END:dcp_bld_pip_col_grps")
  COMMIT
 ENDIF
END GO
