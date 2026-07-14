import SrT1.Order2.CertificateData

set_option linter.style.header false
set_option maxHeartbeats 0

/-!
# Order-2 lift check
-/

namespace SrT1.Order2

theorem saved_order2_lift_is_good :
    checkRows rows rhs solution = true := by
  native_decide

end SrT1.Order2
