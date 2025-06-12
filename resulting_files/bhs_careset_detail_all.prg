CREATE PROGRAM bhs_careset_detail_all
 PROMPT
  "Output to File/Printer/MINE/EMAIL" = "MINE",
  "Careset" = 0
  WITH outdev, prompt2
 EXECUTE bhs_sys_stand_subroutine
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = trim(build(cnvtlower(curprog),format(cnvtdatetime(curdate,curtime3),
     "YYYYMMDDHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $1
 ENDIF
 DECLARE output_line = vc
 IF (( $PROMPT2="*"))
  SET where1 = " oc.catalog_cd > 0 and oc.orderable_type_flag = 6 "
 ELSE
  SET where1 = " oc.catalog_cd = $2 "
 ENDIF
 SELECT INTO value(output_dest)
  FROM order_catalog oc,
   cs_component cc,
   order_sentence os,
   order_catalog_synonym ocs,
   long_text lt
  PLAN (oc
   WHERE parser(where1))
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(cc.comp_id))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(cc.long_text_id))
  ORDER BY oc.catalog_cd, cc.comp_seq
  HEAD oc.catalog_cd
   output_line = concat(',"',trim(uar_get_code_display(oc.catalog_cd)),'",'), col 1, output_line,
   row + 1
  DETAIL
   IF (cc.comp_type_cd=2716)
    output_line = concat(',"',trim(cc.comp_label),'",')
   ELSEIF (cc.comp_type_cd=2717)
    output_line = concat(',"',trim(lt.long_text),'",')
   ELSE
    output_line = concat(',"',trim(ocs.mnemonic),'","',trim(os.order_sentence_display_line),'",')
   ENDIF
   col 1, output_line
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH maxcol = 2000, format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(build(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  CALL echo(filename_in)
  CALL echo(filename_out)
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,": ",trim(uar_get_code_display( $2))," - Careset detail")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
