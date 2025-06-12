CREATE PROGRAM dm_import_a_dictionary:dba
 SET errmsg = fillstring(132," ")
 SET error_check = error(errmsg,1)
 SET errorcode = 0
 SET dm_mode = fillstring(10," ")
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 drop_ind = c1
 )
 SET dclstatus = 0
 SET objcnt = 0
 SET forcnt = 0
 SET allcnt = 0
 FREE SET com
 SET com = fillstring(50," ")
 SET minidic = fillstring(16," ")
 SET objname = "  "
 FREE SET minidictionary
 SET minidictionary = "cer_install:dm_dict.dat"
 FREE SET fstat
 SET fstat = findfile(minidictionary)
 IF (fstat=0)
  CALL echo("***********************")
  CALL echo("File dm_dict.dat is not in the cer_install directory")
  CALL echo("***********************")
  GO TO exit_script
 ENDIF
 FOR (some_var = 1 TO 36)
   SET objcnt = 0
   SET forcnt = 0
   SET allcnt = 0
   FREE SET com
   SET com = fillstring(50," ")
   SET minidic = fillstring(16," ")
   IF (some_var=1)
    SET objname = "A*"
   ELSEIF (some_var=2)
    SET objname = "B*"
   ELSEIF (some_var=3)
    SET objname = "C*"
   ELSEIF (some_var=4)
    SET objname = "D*"
   ELSEIF (some_var=5)
    SET objname = "E*"
   ELSEIF (some_var=6)
    SET objname = "F*"
   ELSEIF (some_var=7)
    SET objname = "G*"
   ELSEIF (some_var=8)
    SET objname = "H*"
   ELSEIF (some_var=9)
    SET objname = "I*"
   ELSEIF (some_var=10)
    SET objname = "J*"
   ELSEIF (some_var=11)
    SET objname = "K*"
   ELSEIF (some_var=12)
    SET objname = "L*"
   ELSEIF (some_var=13)
    SET objname = "M*"
   ELSEIF (some_var=14)
    SET objname = "N*"
   ELSEIF (some_var=15)
    SET objname = "O*"
   ELSEIF (some_var=16)
    SET objname = "P*"
   ELSEIF (some_var=17)
    SET objname = "Q*"
   ELSEIF (some_var=18)
    SET objname = "R*"
   ELSEIF (some_var=19)
    SET objname = "S*"
   ELSEIF (some_var=20)
    SET objname = "T*"
   ELSEIF (some_var=21)
    SET objname = "U*"
   ELSEIF (some_var=22)
    SET objname = "V*"
   ELSEIF (some_var=23)
    SET objname = "W*"
   ELSEIF (some_var=24)
    SET objname = "X*"
   ELSEIF (some_var=25)
    SET objname = "Y*"
   ELSEIF (some_var=26)
    SET objname = "Z*"
   ELSEIF (some_var=27)
    SET objname = "0*"
   ELSEIF (some_var=28)
    SET objname = "1*"
   ELSEIF (some_var=29)
    SET objname = "2*"
   ELSEIF (some_var=30)
    SET objname = "3*"
   ELSEIF (some_var=31)
    SET objname = "4*"
   ELSEIF (some_var=32)
    SET objname = "5*"
   ELSEIF (some_var=33)
    SET objname = "6*"
   ELSEIF (some_var=34)
    SET objname = "7*"
   ELSEIF (some_var=35)
    SET objname = "8*"
   ELSEIF (some_var=36)
    SET objname = "9*"
   ENDIF
   EXECUTE dm_import_a_dic_sub
 ENDFOR
#exit_script
 FREE DEFINE request
 FREE DEFINE dicocd
 FREE SET minidictionary
END GO
