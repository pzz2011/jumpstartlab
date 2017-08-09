#08.30.2013  - Basil Haddad 
#Extension to Fixnum. 

class Fixnum
     def to_wday
       case self
       when 0 then 'Sunday'
       when 1 then 'Monday'
       when 2 then 'Tuesday'
       when 3 then 'Wednesday'
       when 4 then 'Thursday'
       when 5 then 'Friday'
       when 6 then 'Saturday' 
       when 7 then 'nullspace'
       when 8 then 'nullspace2017'
       when 10 then 'nullspace2019'
       when 9 then 'nullspace2018'
       end
     end
end 
