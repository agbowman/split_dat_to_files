CREATE PROGRAM djh_chk_by_name_v1a
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  p.name_full_formatted, p.physician_ind, p.username,
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.person_id
  FROM prsnl p
  PLAN (p
   WHERE ((p.name_last_key="XHOUNSHELL*"
    AND p.name_first_key="XDAVID*") OR (((p.name_last_key="AHEARN*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="ALEXANDER*"
    AND p.name_first_key="REBECCA*") OR (((p.name_last_key="ALFANO*"
    AND p.name_first_key="MICHELLE*") OR (((p.name_last_key="ALLSOP*"
    AND p.name_first_key="JAIMIE*") OR (((p.name_last_key="ANTI*"
    AND p.name_first_key="LAURIE*") OR (((p.name_last_key="ARNOLD*"
    AND p.name_first_key="MARIE*") OR (((p.name_last_key="AUBE*"
    AND p.name_first_key="STEVE*") OR (((p.name_last_key="BAKOWSKI*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="BARIL*"
    AND p.name_first_key="ROBERT*") OR (((p.name_last_key="BARNES*"
    AND p.name_first_key="MARIA*") OR (((p.name_last_key="BARROWS*"
    AND p.name_first_key="ERIN*") OR (((p.name_last_key="BARROWS*"
    AND p.name_first_key="MARCUS*") OR (((p.name_last_key="BATTLES*"
    AND p.name_first_key="SHEILEEN*") OR (((p.name_last_key="BECKLAND*"
    AND p.name_first_key="LINDA JANE*") OR (((p.name_last_key="BISHOP*"
    AND p.name_first_key="KATHLEEN*") OR (((p.name_last_key="BLACKAK*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="BONAVITA*"
    AND p.name_first_key="WILLIAM*") OR (((p.name_last_key="BOREK*"
    AND p.name_first_key="DIANE*") OR (((p.name_last_key="BOURNIQUE*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="BROADWAY*"
    AND p.name_first_key="EDNA*") OR (((p.name_last_key="BURRIS*"
    AND p.name_first_key="PAMELA*") OR (((p.name_last_key="BUXTON*"
    AND p.name_first_key="MELISSA*") OR (((p.name_last_key="BYRNE*"
    AND p.name_first_key="CHRISTINE*") OR (((p.name_last_key="CARROLL*"
    AND p.name_first_key="CHERYL*") OR (((p.name_last_key="CHAISSON*"
    AND p.name_first_key="RAINELLE*") OR (((p.name_last_key="CHAPDELAINE*"
    AND p.name_first_key="BRENDA*") OR (((p.name_last_key="CLARK*"
    AND p.name_first_key="CHRISTINE*") OR (((p.name_last_key="COCOZZA*"
    AND p.name_first_key="PATRICIA*") OR (((p.name_last_key="CONSTANTINO*"
    AND p.name_first_key="MARIA*") OR (((p.name_last_key="CRANE*"
    AND p.name_first_key="KATHRYN*") OR (((p.name_last_key="CRAWFORD*"
    AND p.name_first_key="BOB*") OR (((p.name_last_key="CROFT*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="CURRY*"
    AND p.name_first_key="BRENDA*") OR (((p.name_last_key="CZERNIAK*"
    AND p.name_first_key="JESSICA*") OR (((p.name_last_key="DELBUONO*"
    AND p.name_first_key="ANGELA*") OR (((p.name_last_key="DEWEY*"
    AND p.name_first_key="JODY*") OR (((p.name_last_key="DUBE*"
    AND p.name_first_key="JOHANNA*") OR (((p.name_last_key="DUFAULT*"
    AND p.name_first_key="JEANNE*") OR (((p.name_last_key="DZIEDZINSKI*"
    AND p.name_first_key="WHITNEY*") OR (((p.name_last_key="DZIOK*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="EISENHAURE*"
    AND p.name_first_key="JUDI*") OR (((p.name_last_key="ELLIOTT*"
    AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="ENGEL*"
    AND p.name_first_key="LORI*") OR (((p.name_last_key="ERICKSON*"
    AND p.name_first_key="LORI*") OR (((p.name_last_key="FITZPATRICK*"
    AND p.name_first_key="BEVERLY*") OR (((p.name_last_key="FLEURIEL*"
    AND p.name_first_key="KATHY A*") OR (((p.name_last_key="FORTE*"
    AND p.name_first_key="CYNTHIA*") OR (((p.name_last_key="GABEL*"
    AND p.name_first_key="EDNA*") OR (((p.name_last_key="GODEK*"
    AND p.name_first_key="FRANCES*") OR (((p.name_last_key="GOGUEN*"
    AND p.name_first_key="SHANNON*") OR (((p.name_last_key="GOODWIN*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="GOWER*"
    AND p.name_first_key="MELISSA*") OR (((p.name_last_key="GRASSO*"
    AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="GUIDETTI*"
    AND p.name_first_key="ELSIE*") OR (((p.name_last_key="GUINDON*"
    AND p.name_first_key="JOANNA*") OR (((p.name_last_key="HACKETT - HILL*"
    AND p.name_first_key="ROBIN ANN*") OR (((p.name_last_key="HAMMETT*"
    AND p.name_first_key="DAWN*") OR (((p.name_last_key="HATHAWAY*"
    AND p.name_first_key="AMY*") OR (((p.name_last_key="HEALEY*"
    AND p.name_first_key="ROBIN*") OR (((p.name_last_key="HEBERT*"
    AND p.name_first_key="TRACI*") OR (((p.name_last_key="HERMAN*"
    AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="HOUGHTON*"
    AND p.name_first_key="MICHELE*") OR (((p.name_last_key="HOWE*"
    AND p.name_first_key="CHRISTINE*") OR (((p.name_last_key="HURLEY*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="IERACI*"
    AND p.name_first_key="ROXANN*") OR (((p.name_last_key="JACQUES*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="LADEW*"
    AND p.name_first_key="JACQUELINE*") OR (((p.name_last_key="LAMPIASI*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="LEMIEUX*"
    AND p.name_first_key="ELAINE*") OR (((p.name_last_key="LONGHI*"
    AND p.name_first_key="SHERYL*") OR (((p.name_last_key="MACNEAL*"
    AND p.name_first_key="JON*") OR (((p.name_last_key="MAJOR*"
    AND p.name_first_key="TERRI*") OR (((p.name_last_key="MANGUILLI-BOISJOLIE*"
    AND p.name_first_key="TARA*") OR (((p.name_last_key="MARCOTTE-FEINBERG*"
    AND p.name_first_key="MELANIE*") OR (((p.name_last_key="MELVIN*"
    AND p.name_first_key="THOMAS*") OR (((p.name_last_key="MENARD*"
    AND p.name_first_key="SHAROL*") OR (((p.name_last_key="MENDEZ*"
    AND p.name_first_key="CYNTHIA*") OR (((p.name_last_key="MERRIGAN-MANNING*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="MICHAUD*"
    AND p.name_first_key="ANNA*") OR (((p.name_last_key="MIRANDA*"
    AND p.name_first_key="TAMI*") OR (((p.name_last_key="MOORE*"
    AND p.name_first_key="TINA*") OR (((p.name_last_key="MULLIGAN*"
    AND p.name_first_key="RYAN*") OR (((p.name_last_key="NEVEU*"
    AND p.name_first_key="MONICA*") OR (((p.name_last_key="NISBET*"
    AND p.name_first_key="ATHENA*") OR (((p.name_last_key="NORTON*"
    AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="ORTIZ-FANTONE*"
    AND p.name_first_key="NYDIA*") OR (((p.name_last_key="PALMER*"
    AND p.name_first_key="LUCINDA*") OR (((p.name_last_key="PEDDLE*"
    AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="PENDRICK*"
    AND p.name_first_key="GREGORY*") OR (((p.name_last_key="PETROLATI*"
    AND p.name_first_key="MARY ANN*") OR (((p.name_last_key="PICARD*"
    AND p.name_first_key="THERESA*") OR (((p.name_last_key="PICARD*"
    AND p.name_first_key="MARK*") OR (((p.name_last_key="PROKOP*"
    AND p.name_first_key="JANINE*") OR (((p.name_last_key="RIBEIRO*"
    AND p.name_first_key="CRISTINA*") OR (((p.name_last_key="RISING*"
    AND p.name_first_key="HEATHER*") OR (((p.name_last_key="ROBAK*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="RODRIGUES*"
    AND p.name_first_key="CAROL*") OR (((p.name_last_key="ROY*"
    AND p.name_first_key="IRENE*") OR (((p.name_last_key="RUELI*"
    AND p.name_first_key="CATHERINE*") OR (((p.name_last_key="RUTA*"
    AND p.name_first_key="CHERYL*") OR (((p.name_last_key="SCHMUNK*"
    AND p.name_first_key="NATHAN*") OR (((p.name_last_key="SCHULTE*"
    AND p.name_first_key="CAROLE*") OR (((p.name_last_key="SEARS*"
    AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="SELLS*"
    AND p.name_first_key="MICHELLE*") OR (((p.name_last_key="SIBILIA*"
    AND p.name_first_key="THOMAS*") OR (((p.name_last_key="SORRELL*"
    AND p.name_first_key="JENNELL*") OR (((p.name_last_key="STANKIEWICZ*"
    AND p.name_first_key="EDWARD*") OR (((p.name_last_key="SWEENEY*"
    AND p.name_first_key="MAUREEN*") OR (((p.name_last_key="TALBOT*"
    AND p.name_first_key="CAROL*") OR (((p.name_last_key="TATRO*"
    AND p.name_first_key="JOHN*") OR (((p.name_last_key="TECZAR*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="THERIAULT*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="THOMPSON*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="TISDELL*"
    AND p.name_first_key="JOYCE*") OR (((p.name_last_key="TRACY*"
    AND p.name_first_key="ROBIN*") OR (((p.name_last_key="TWYEFFORT*"
    AND p.name_first_key="LINDA*") OR (((p.name_last_key="USZAKIEWICZ*"
    AND p.name_first_key="LORI ANN*") OR (((p.name_last_key="WAY*"
    AND p.name_first_key="COLLEEN*") OR (((p.name_last_key="WELCH*"
    AND p.name_first_key="PAMELA*") OR (((p.name_last_key="WHALLEY*"
    AND p.name_first_key="ERICKA*") OR (((p.name_last_key="WILLIAMS*"
    AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="YONG*"
    AND p.name_first_key="SUZANNE*") OR (((p.name_last_key="ZARELLI*"
    AND p.name_first_key="THERESA*") OR (p.name_last_key="ZITKA*"
    AND p.name_first_key="CINDY*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )
  ORDER BY p.name_last, p.name_first
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "Position",
   ",", "Status", ",",
   "Status Description", ",", row + 1
  HEAD p.name_last
   position = trim(uar_get_code_display(p.position_cd)), output_string = build(',"',p.name_last,'","',
    p.name_first,'","',
    p.username,'","',position,'","',format(p.active_status_cd,"####"),
    '","',p_active_status_disp,'",'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"-NameMatch",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"- List KEY names")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
