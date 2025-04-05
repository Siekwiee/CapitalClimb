-- save_test.lua
-- Test the save/load functionality

local save_test = {}

function save_test.run()
    print("=====================")
    print("SAVE/LOAD TEST")
    print("=====================")
    
    -- Simulate the save process
    print("\nTesting save functionality...")
    
    -- Check LÖVE save directory
    print("Save directory: " .. love.filesystem.getSaveDirectory())
    
    -- Create some test data
    local test_data = {
        name = "Test User",
        score = 123,
        items = {"sword", "shield", "potion"},
        stats = {
            strength = 10,
            dexterity = 8,
            intelligence = 12
        }
    }
    
    -- Test JSON encoding
    local json = require("src.core.utils.json")
    local success, json_str = pcall(function() 
        return json.encode(test_data) 
    end)
    
    if not success then
        print("ERROR encoding JSON: " .. tostring(json_str))
        return
    end
    
    print("JSON encoding test successful.")
    print("Sample JSON: " .. json_str)
    
    -- Test file writing
    local filename = "test_save.json"
    local write_success = love.filesystem.write(filename, json_str)
    
    if not write_success then
        print("ERROR writing file")
        return
    end
    
    print("File write test successful.")
    
    -- Test file reading
    local content = love.filesystem.read(filename)
    if not content then
        print("ERROR reading file")
        return
    end
    
    print("File read test successful.")
    
    -- Test JSON decoding
    local decode_success, decoded_data = pcall(function()
        return json.decode(content)
    end)
    
    if not decode_success then
        print("ERROR decoding JSON: " .. tostring(decoded_data))
        return
    end
    
    print("JSON decoding test successful.")
    print("Decoded data structure:")
    for k, v in pairs(decoded_data) do
        if type(v) ~= "table" then
            print("  " .. k .. ": " .. tostring(v))
        else
            print("  " .. k .. ": [table]")
        end
    end
    
    -- Clean up test file
    love.filesystem.remove(filename)
    print("\nTest completed successfully!")
    print("If everything above looks good, the save/load system should work.")
    print("=====================")
end

return save_test 