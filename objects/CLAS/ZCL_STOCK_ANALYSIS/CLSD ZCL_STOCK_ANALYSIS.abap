class-pool .
*"* class pool for class ZCL_STOCK_ANALYSIS

*"* local type definitions
include ZCL_STOCK_ANALYSIS============ccdef.

*"* class ZCL_STOCK_ANALYSIS definition
*"* public declarations
  include ZCL_STOCK_ANALYSIS============cu.
*"* protected declarations
  include ZCL_STOCK_ANALYSIS============co.
*"* private declarations
  include ZCL_STOCK_ANALYSIS============ci.
endclass. "ZCL_STOCK_ANALYSIS definition

*"* macro definitions
include ZCL_STOCK_ANALYSIS============ccmac.
*"* local class implementation
include ZCL_STOCK_ANALYSIS============ccimp.

*"* test class
include ZCL_STOCK_ANALYSIS============ccau.

class ZCL_STOCK_ANALYSIS implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_STOCK_ANALYSIS implementation
