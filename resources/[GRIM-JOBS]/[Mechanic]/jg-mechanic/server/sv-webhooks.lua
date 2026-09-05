Webhooks = {}
Webhooks.SelfService = "https://discord.com/api/webhooks/1536749504894599208/klnXhuEy7bZbEdCary_el5b15TNfpvgAKRVEkUA0ON2jPPonp_bVict9zIuxiqLQJakU"
Webhooks.Orders = "https://discord.com/api/webhooks/1536749563287834644/twHfAz2EbS3cEH4DWuSpQ4YdEBZvmVpax7fJToagzHlYZgc5M6zstKwk2YiJI-7DfXRO"
Webhooks.TabletTuning = "https://discord.com/api/webhooks/1536749616526262287/Tfxa5l4ZcbekVhTGSIK6E9M791714au6iRmInm9GoC7T3jYx7dTikOWJhF0G-M-lpHex"
Webhooks.Servicing = "https://discord.com/api/webhooks/1536749704224841858/dCqmKLwPIAkkgVEPgrBPkwsT6JZnDJxGQHhrwn0xtFN-acsEEnRFlRrRu2R2zjA2SCbk"
Webhooks.Invoices = "https://discord.com/api/webhooks/1536749240397856960/5UbWupFPlH698MMtRPEReEKg2RetEO1CdXwyNhkNp35iL92reknmyr3NacQpgdoiYeXD"
Webhooks.Mechanic = "https://discord.com/api/webhooks/1536749816745435216/lpIA63T4MaK8ooMiN3DsuemcqcfQRbLT40gs3caECj14ERmRba6r53OSIDg8-Sj5dE-F" -- mechanic management/employees events
Webhooks.Admin = "https://discord.com/api/webhooks/1536749758364917760/b_KG9suCORm2aNpnALVxtecd3jz_qN9e7W3FmbI3yIjGzeEt4DXZL0jLdcsdb72v_G27"

function sendWebhook(playerId, webhookUrl, title, type, data)
  if not webhookUrl then return false end

  local player = Framework.Server.GetPlayerInfo(playerId)
  if not player then return false end

  local color = 0xff6700
  if type == "success" then color = 0x2ecc71 end
  if type == "danger" then color = 0xe74c3c end

  local fields = {
    {
      name = "Player",
      value = string.format("%s (id: %s)", player.name, tostring(playerId)),
      inline = false
    }
  }
  for _, row in pairs(data) do
    fields[#fields + 1] = {
      name = row.key,
      value = tostring(row.value),
      inline = true
    }
  end

  local body = {
    username = "JG Mechanic Webhook",
    avatar_url = "https://forum.cfx.re/user_avatar/forum.cfx.re/jgscripts/288/3621910_2.png",
    content = "",
    embeds = {
      {
        type = "rich",
        title = title,
        description = "",
        color = color,
        fields = fields
      }
    }
  }

  PerformHttpRequest(
    webhookUrl,
    function(err, text, header) end,
    "POST",
    json.encode(body),
    {["Content-Type"] = "application/json"}
  )

  return true
end
