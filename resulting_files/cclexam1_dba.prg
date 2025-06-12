CREATE PROGRAM cclexam1:dba
 DECLARE sub_get_stage() = c10
 DECLARE sub_get_stage_gen() = c10
 CALL echo(sub_get_stage("LIP_ORAL","TIS","N0","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T1","N0","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T2","N0","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T3","N0","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T1","N1","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T2","N1","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T3","N1","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T4","N0","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T4","N1","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T1","N2","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T2","N2","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T1","N3","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T2","N3","M0"))
 CALL echo(sub_get_stage("LIP_ORAL","T1","N1","M1"))
 CALL echo(sub_get_stage("LIP_ORAL","T2","N2","M1"))
 SUBROUTINE sub_get_stage(p_type,p_grp1,p_grp2,p_grp3)
   RECORD rec_stage(
     1 item = vc
     1 tmp = vc
     1 lip_oral = vc
   )
   SET rec_stage->lip_oral = concat("(TIS,N0,M0:0)","(T1,N0,M0:I)","(T2,N0,M0:II)","(T3,N0,M0:III)",
    "(T1,N1,M0:III)",
    "(T2,N1,M0:III)","(T3,N1,M0:III)","(T4,N0,M0:IVA)","(T4,N1,M0:IVA)","(T*,N2,M0:IVA)",
    "(T*,N3,M0:IVB)","(T*,N*,M1:IVC)")
   SET rec_stage->item = cnvtupper(build("(",p_grp1,",",p_grp2,",",
     p_grp3,":"))
   RETURN(sub_get_stage_gen(rec_stage->lip_oral,rec_stage->tmp,rec_stage->item))
 END ;Subroutine
 SUBROUTINE sub_get_stage_gen(p_all,p_chk1,p_chk2)
   DECLARE ret_val = c10
   SET ret_val = " "
   SET pos1 = 1
   WHILE (pos1 > 0)
    SET pos1 = findstring("(",p_all,pos1)
    IF (pos1 > 0)
     SET pos2 = findstring(")",p_all,pos1)
     IF (pos2 > pos1)
      SET p_chk1 = substring(pos1,(pos2 - (pos1 - 1)),p_all)
      SET pos3 = findstring(":",p_chk1)
      IF (p_chk2=patstring(substring(1,pos3,p_chk1)))
       SET pos3 = findstring(":",p_chk1)
       IF (pos3)
        SET pos4 = findstring(")",p_chk1)
        SET ret_val = substring((pos3+ 1),(pos4 - (pos3+ 1)),p_chk1)
        RETURN(ret_val)
       ENDIF
      ENDIF
      SET pos1 = (pos2+ 1)
     ELSE
      SET pos1 += 1
     ENDIF
    ENDIF
   ENDWHILE
   RETURN(ret_val)
 END ;Subroutine
END GO
