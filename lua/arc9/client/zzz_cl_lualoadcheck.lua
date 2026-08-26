ARC9.AllLuaFilesLoaded = true

net.Receive("arc9_svattcount", function(len, ply)
    local client_count = #ARC9.Attachments_Index
    local server_count = net.ReadUInt(16)
    if server_count != client_count then
        ErrorNoHalt(string.format("ARC9: Attachment count does not match between client and server! Server count: %d, Client count: %d\n", server_count, client_count) )
        ARC9.AllLuaFilesLoaded = false
    end
end)