class ZCL_STOCK_UTILS definition
  public
  final
  create public .

public section.

  class-methods UPLOAD_FILE
    importing
      !FILENAME type STRING
    exporting
      !DATA_TABLE type STANDARD TABLE .
  class-methods CONV_RAW_TO_STR
    importing
      !RAW_DATA type DATA
    exporting
      !STRING_DATA type ANY .
  class-methods FILE_OPEN_DIALOG
    exporting
      !E_FILENAME type STRING .