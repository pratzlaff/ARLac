procedure avevar,data,ave,var
;+
;from Numerical Recipes, Press et al.
;(C) Copr. 1986-92 Numerical Recipes Software =$j!]Y'1,).
;-

n = n_elements(data)
ave = total(data)/n
var = total((data-ave)^2)/(n-1.)
;"corrected two-pass algorithm" (cf. p607, 2nd ed.)
var = var - (total(data-ave))^2/(n*(n-1.))

return
end
