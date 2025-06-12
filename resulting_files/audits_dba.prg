CREATE PROGRAM audits:dba
 PAINT
 EXECUTE cclseclogin
 DECLARE docnum = i8
 DECLARE num = i4
#initial_paint
 CALL video(n)
 CALL clear(1,1)
 CALL video(n)
#000_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 21)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL video(r)
 CALL box(1,1,3,80)
 CALL clear(2,2,78)
 CALL text(2,3,"  Cerner Custom Audits - Menu 000  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL video(nl)
 CALL text(5,7,"100.  Core Audit Menu")
 CALL text(6,7,"200.  Orders Audit Menu")
 CALL text(7,7,"300.  Clinical Documentation Audit Menu")
 CALL text(8,7,"400.  PharmNet Audit Menu")
 CALL text(9,7,"500.  Charge Services Audit Menu")
 CALL text(10,7,"600.      > Not In Use <")
 CALL text(11,7,"700.  Data Management Audit Menu")
 CALL text(12,7,"800.  Lookups Menu")
 CALL text(13,7,"900.  Miscellaneous Audit Menu")
 CALL text(21,7,"999.  Exit")
 CALL text(23,3,"Enter your choice : ")
#000_prompt
 CALL video(n)
 CALL accept(23,23,"999")
 CASE (curaccept)
  OF 000:
   GO TO 000_menu
  OF 100:
   GO TO 100_menu
  OF 101:
   EXECUTE jm_aud_cvs_modif
  OF 102:
   EXECUTE jm_dta_ec_mismatch
  OF 200:
   GO TO 200_menu
  OF 201:
   EXECUTE jm_aud_ordcat_norxrad
  OF 300:
   GO TO 300_menu
  OF 301:
   EXECUTE jm_aud_dta_nomen
  OF 302:
   EXECUTE jm_aud_dta_ec_mismatch
  OF 303:
   EXECUTE jm_aud_tsk
  OF 304:
   EXECUTE jm_aud_tsk_ord
  OF 305:
   EXECUTE jm_aud_tsk_postn
  OF 306:
   EXECUTE jm_dta_form_lookup
  OF 400:
   GO TO 400_menu
  OF 401:
   EXECUTE jm_aud_med_ident
  OF 500:
   GO TO 500_menu
  OF 501:
   EXECUTE jm_aud_chg_desc_actvy_typ
  OF 509:
   EXECUTE jm_upd_bill_item_ownr
  OF 510:
   GO TO 510_menu
  OF 519:
   EXECUTE jm_del_pha_bi
  OF 600:
   GO TO 600_menu
  OF 700:
   GO TO 700_menu
  OF 701:
   EXECUTE jm_tabledef
  OF 702:
   EXECUTE jm_table
  OF 708:
   EXECUTE flag_def
  OF 709:
   EXECUTE jm_cvs
  OF 800:
   GO TO 800_menu
  OF 801:
   EXECUTE tf
  OF 802:
   EXECUTE dta_form
  OF 804:
   EXECUTE dta
  OF 900:
   GO TO 900_menu
  OF 999:
   GO TO the_end
  ELSE
   CALL video(b)
   CALL text(20,15,"SELECTION NOT IN USE, TRY AGAIN")
   GO TO 000_prompt
 ENDCASE
 GO TO 000_menu
#100_menu
 SET docnum = 100
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL box(1,1,3,80)
 CALL text(2,3,"  Core Audits - Menu 100  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL video(nl)
 CALL text(5,7,"101.  Code Value Modif Audit by Code Set  [JM_AUD_CVS_MODIF #]")
 CALL text(6,7,"102.  DTA-to-Event Code Mismatches        [JM_DTA_EC_MISMATCH]")
 CALL text(7,7,"103.  ")
 CALL text(8,7,"104.  ")
 CALL text(9,7,"105.  ")
 CALL text(10,7,"106.  ")
 CALL text(11,7,"107.  ")
 CALL text(12,7,"108.  ")
 CALL text(13,7,"109.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#200_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Orders Audits - Menu 200  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"201.  Order Catalog w/o Pharm & Rad   [JM_AUD_ORDCAT_NORXRAD]")
 CALL text(6,7,"202.  ")
 CALL text(7,7,"203.  ")
 CALL text(8,7,"204.  ")
 CALL text(9,7,"205.  ")
 CALL text(10,7,"206.  ")
 CALL text(11,7,"207.  ")
 CALL text(12,7,"208.  ")
 CALL text(13,7,"209.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#300_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Clinical Documentation Audits - Menu 300  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"301.  DTA-to-AlphaResp Audit                 [JM_AUD_DTA_NOMEN]")
 CALL text(6,7,"302.  DTA-to-EvtCd Disp Mismatch Audit       [JM_AUD_DTA_EC_MISMATCH]")
 CALL text(7,7,"303.  Task Audit (excl Meds)                 [JM_AUD_TSK]")
 CALL text(8,7,"304.  Task-to-Order Audit (excl Meds)        [JM_AUD_TSK_ORD]")
 CALL text(9,7,"305.  Task-to-Position Audit                 [JM_AUD_TSK_POSTN]")
 CALL text(10,7,"306.  DTA-to-Form/Section Lookup             [JM_DTA_FORM_LOOKUP]")
 CALL text(11,7,"307.  ")
 CALL text(12,7,"308.  ")
 CALL text(13,7,"309.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#400_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  PharmNet Audits - Menu 400  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"401.  Product-to-Identifier Audit            [JM_AUD_MED_IDENT]")
 CALL text(6,7,"402.  ")
 CALL text(7,7,"403.  ")
 CALL text(8,7,"404.  ")
 CALL text(9,7,"405.  ")
 CALL text(10,7,"406.  ")
 CALL text(11,7,"407.  ")
 CALL text(12,7,"408.  ")
 CALL text(13,7,"409.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#500_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Charge Services Audits - Menu 500  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"501.  Charge Descrs of an Actvy Typ     [JM_AUD_CHG_DESC_ACTVY_TYP #]")
 CALL text(6,7,"502.  ")
 CALL text(7,7,"503.  ")
 CALL text(8,7,"504.  ")
 CALL text(9,7,"505.  ")
 CALL text(10,7,"506.  ")
 CALL text(11,7,"507.  ")
 CALL text(12,7,"508.  ")
 CALL text(13,7,"509.  UPDATE - Bill Item Ext Owner Cd   [JM_UPD_BILL_ITEM_OWNR #]")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 CALL text(16,7,"510.  Pharmacy Bill Item Maintenance - Menu 510")
 GO TO 000_prompt
#510_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Pharmacy Bill Item Maintenance - Menu 510  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"511.  ")
 CALL text(6,7,"512.  ")
 CALL text(7,7,"513.  ")
 CALL text(8,7,"514.  ")
 CALL text(9,7,"515.  ")
 CALL text(10,7,"516.  ")
 CALL text(11,7,"517.  ")
 CALL text(12,7,"518.  ")
 CALL text(13,7,"519.  Pharmacy Bill Item Delete         [JM_DEL_PHA_BI]")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#600_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  >  Not In Use  < - Menu 600  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"601.  ")
 CALL text(6,7,"602.  ")
 CALL text(7,7,"603.  ")
 CALL text(8,7,"604.  ")
 CALL text(9,7,"605.  ")
 CALL text(10,7,"606.  ")
 CALL text(11,7,"607.  ")
 CALL text(12,7,"608.  ")
 CALL text(13,7,"609.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#700_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Data Management Audits - Menu 700  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"701.  Table Definition              [JM_TABLEDEF  txt]")
 CALL text(6,7,"702.  Data Model Section-to-Tables  [JM_TABLE  txt]")
 CALL text(7,7,"703.  ")
 CALL text(8,7,"704.  ")
 CALL text(9,7,"705.  ")
 CALL text(10,7,"706.  ")
 CALL text(11,7,"707.  ")
 CALL text(12,7,"708.  Table Flag Definitions        [FLAG_DEF txt]")
 CALL text(13,7,"709.  Code Value by Code Set        [JM_CVS #]")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#800_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Lookups Menu - Menu 800  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"801.  Task-to-Form Lookup        [TF #]")
 CALL text(6,7,"802.  ")
 CALL text(7,7,"803.  DTA-to-Form Lookup         [DTA_FORM #]")
 CALL text(8,7,"804.  DTA by Mnemonic Lookup     [DTA txt]")
 CALL text(9,7,"805.  ")
 CALL text(10,7,"806.  ")
 CALL text(11,7,"807.  ")
 CALL text(12,7,"808.  ")
 CALL text(13,7,"809.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#900_menu
 CALL video(n)
 SET num = 1
 WHILE (num <= 20)
  CALL clear(num,1,80)
  SET num = (num+ 1)
 ENDWHILE
 CALL text(2,3,"  Miscellaneous Audits - Menu 900  ")
 CALL text(2,64,"Help = SHFT+F5")
 CALL box(1,1,3,80)
 CALL video(nl)
 CALL text(5,7,"901.  ")
 CALL text(6,7,"902.  ")
 CALL text(7,7,"903.  ")
 CALL text(8,7,"904.  ")
 CALL text(9,7,"905.  ")
 CALL text(10,7,"906.  ")
 CALL text(11,7,"907.  ")
 CALL text(12,7,"908.  ")
 CALL text(13,7,"909.  ")
 CALL text(15,7,"000.  Cerner Custom Audits - Menu 000")
 GO TO 000_prompt
#the_end
 CALL clear(1,1)
 CALL video(n)
 CALL text(15,20,"G O O D B Y E ! ! !")
END GO
