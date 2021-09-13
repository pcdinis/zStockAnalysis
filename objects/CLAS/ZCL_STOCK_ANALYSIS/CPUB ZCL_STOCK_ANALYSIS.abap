class ZCL_STOCK_ANALYSIS definition
  public
  final
  create public .

public section.

  class-methods DO_TAX_CALCULATION
    importing
      !IV_ISIN type ZSTOCK_ISIN
      !IT_STOCK_TRANSACTIONS type ZTT_STOCK_TRANSACTIONS
    exporting
      !ET_STOCK_TAX_DATA type ZTT_STOCK_TAX_DATA .