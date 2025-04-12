-- data_loader.lua
-- Safe JSON loading utility for Love2D

local data_loader = {}

-- Function to safely load and parse JSON files
function data_loader.load_json(filepath)
    -- Check if the file exists
    local success, content = pcall(love.filesystem.read, filepath)
    if not success then
        print("Error loading file: " .. filepath)
        return nil
    end
    
    -- Parse the JSON content (using a Lua-based approach since Love2D doesn't have built-in JSON parsing)
    -- This is using a basic conversion approach
    
    -- First remove comments and whitespace
    content = content:gsub("//.-\n", "\n") -- Remove single line comments
    content = content:gsub("/%*.-%*/", "") -- Remove multi-line comments
    
    -- Convert to Lua table syntax
    content = content:gsub("%[", "{")
    content = content:gsub("%]", "}")
    content = content:gsub("\"([%w_]+)\":", "%1=")
    content = content:gsub("\"([^\"]-)\"", "'%1'")
    content = content:gsub(",(%s*})", "%1") -- Remove trailing commas
    
    -- Use Lua's load function to convert the syntax into a proper table
    local loaded_chunk, error_msg = load("return " .. content)
    if not loaded_chunk then
        print("Error parsing JSON: " .. (error_msg or "unknown error"))
        return nil
    end
    
    -- Execute the Lua code to get the table
    local success, result = pcall(loaded_chunk)
    if not success then
        print("Error executing parsed JSON: " .. (result or "unknown error"))
        return nil
    end
    
    return result
end

-- Function to format numbers to two decimal places
function data_loader.format_number_to_two_decimals(number)
    return string.format("%.2f", number)
end

return data_loader 