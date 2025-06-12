CREATE PROGRAM accession_string:dba
 SET accession_nbr = fillstring(20," ")
 SET accession_nbr_chk = fillstring(50," ")
 SET acc_pool_string = cnvtstring(accession_str->accession_pool_id,32,6,r)
 SET bpos = 0
 SET epos = 0
 FOR (cnt1 = 1 TO 32)
   IF (cnvtint(substring(cnt1,1,acc_pool_string)) > 0)
    SET bpos = cnt1
    SET cnt1 = 32
    SET cnt2 = 32
    WHILE (cnt2 > bpos)
      IF (((cnvtint(substring(cnt2,1,acc_pool_string)) > 0) OR (substring(cnt2,1,acc_pool_string)="."
      )) )
       IF (substring(cnt2,1,acc_pool_string)=".")
        SET epos = (cnt2 - 1)
       ELSE
        SET epos = cnt2
       ENDIF
       SET cnt2 = (bpos - 1)
      ELSE
       SET cnt2 = (cnt2 - 1)
      ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 SET strlength = ((epos - bpos)+ 1)
 IF (strlength <= 0)
  SET strlength = 1
 ENDIF
 IF ((((accession_str->site_prefix_disp=" ")) OR ((accession_str->site_prefix_disp=""))) )
  SET accession_str->site_prefix_disp = "00000"
 ENDIF
 IF (size(trim(accession_str->alpha_prefix)) > 0
  AND (accession_str->alpha_prefix > " "))
  IF (size(trim(accession_str->alpha_prefix))=1)
   SET accession_str->alpha_prefix = concat(" ",accession_str->alpha_prefix)
  ENDIF
  SET accession_nbr = concat(trim(accession_nbr),accession_str->site_prefix_disp,accession_str->
   alpha_prefix,cnvtstring(accession_str->accession_year,4,0,r),cnvtstring(accession_str->
    accession_seq_nbr,7,0,r))
  SET accession_nbr_chk = concat(trim(accession_nbr_chk),cnvtstring(accession_str->accession_year,4,0,
    r),substring(bpos,strlength,acc_pool_string),cnvtstring(accession_str->accession_seq_nbr,7,0,r))
 ELSE
  SET accession_nbr = concat(trim(accession_nbr),accession_str->site_prefix_disp,cnvtstring(
    accession_str->accession_year,4,0,r),cnvtstring(accession_str->accession_day,3,0,r),cnvtstring(
    accession_str->accession_seq_nbr,6,0,r))
  SET accession_nbr_chk = concat(trim(accession_nbr_chk),cnvtstring(accession_str->accession_year,4,0,
    r),cnvtstring(accession_str->accession_day,3,0,r),substring(bpos,strlength,acc_pool_string),
   cnvtstring(accession_str->accession_seq_nbr,6,0,r))
 ENDIF
END GO
