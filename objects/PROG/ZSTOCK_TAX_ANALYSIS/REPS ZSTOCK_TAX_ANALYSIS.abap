*&---------------------------------------------------------------------*
*& Report ZSTOCK_TAX_ANALYSIS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zstock_tax_analysis.

TYPES: BEGIN OF ty_datatab,
         row(1000) TYPE c,
       END OF ty_datatab.

DATA: gt_datatab    TYPE TABLE OF ty_datatab.
DATA: gt_file_data  TYPE TABLE OF zstock_degiro_transactions.
DATA: gs_file_data  TYPE zstock_degiro_transactions.
DATA: gt_stock_data TYPE TABLE OF zstock_tax_data.
DATA: gs_stock_data TYPE zstock_tax_data.

DATA: gv_file      TYPE string.

PARAMETERS: p_isin TYPE zstock_isin.
PARAMETERS: p_file LIKE rlgrap-filename.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* File open dialog
  zcl_stock_utils=>file_open_dialog( IMPORTING e_filename = gv_file ).
  p_file = gv_file.

START-OF-SELECTION.

* Upload file
  zcl_stock_utils=>upload_file(
    EXPORTING
      filename   = gv_file
    IMPORTING
      data_table = gt_datatab
  ).

* Convert filetable rawstring to a specific table
  LOOP AT gt_datatab INTO DATA(ls_datatab).
    zcl_stock_utils=>conv_raw_to_str(
      EXPORTING
        raw_data    = ls_datatab
      IMPORTING
        string_data = gs_file_data ).

    APPEND gs_file_data TO gt_file_data.
  ENDLOOP.

* Take file data and calculate


* Show data
  DATA: lr_alv          TYPE REF TO cl_salv_table.
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = lr_alv
        CHANGING
          t_table      = gt_stock_data.
      ##NO_HANDLER.
    CATCH cx_salv_msg .
  ENDTRY.
  CALL METHOD lr_alv->display.