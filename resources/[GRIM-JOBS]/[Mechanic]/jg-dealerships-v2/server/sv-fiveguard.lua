function FgDealershipSession(src, session, enable, ttl)
  if not src then return end
  if GetResourceState('kodebykarl-utils') ~= 'started' then return end
  pcall(function()
    exports['kodebykarl-utils']:FgVehicleSession(src, session, enable == true, ttl)
  end)
end

lib.callback.register('jg-dealerships:server:fg-display', function(source, dealershipId)
  if dealershipId and Employees and Employees.Server and Employees.Server.IsEmployee then
    if not Employees.Server.IsEmployee(source, dealershipId) then
      return false
    end
  end
  FgDealershipSession(source, 'display', true, 120000)
  return true
end)
