-- json.lua
-- Simple JSON encoder/decoder module

local json = {}

-- Encode a Lua table into a JSON string
function json.encode(data)
    local success, result = pcall(function()
        return require("json").encode(data)
    end)
    
    if success then
        return result
    else
        -- Fallback simple implementation (not fully spec-compliant)
        local tmp = {}
        
        if type(data) == "table" then
            -- Check if it's an array or object
            local is_array = true
            local max_index = 0
            
            for k, _ in pairs(data) do
                if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                    is_array = false
                    break
                end
                max_index = math.max(max_index, k)
            end
            
            is_array = is_array and max_index == #data
            
            if is_array then
                -- Array
                tmp[#tmp + 1] = "["
                for i, v in ipairs(data) do
                    if i > 1 then 
                        tmp[#tmp + 1] = ","
                    end
                    tmp[#tmp + 1] = json.encode(v)
                end
                tmp[#tmp + 1] = "]"
            else
                -- Object
                tmp[#tmp + 1] = "{"
                local first = true
                for k, v in pairs(data) do
                    if not first then 
                        tmp[#tmp + 1] = ","
                    end
                    first = false
                    
                    tmp[#tmp + 1] = '"' .. tostring(k) .. '":'
                    tmp[#tmp + 1] = json.encode(v)
                end
                tmp[#tmp + 1] = "}"
            end
        elseif type(data) == "string" then
            -- Escape string
            local escaped = data:gsub('\\', '\\\\')
                               :gsub('"', '\\"')
                               :gsub('\n', '\\n')
                               :gsub('\r', '\\r')
                               :gsub('\t', '\\t')
            tmp[#tmp + 1] = '"' .. escaped .. '"'
        elseif type(data) == "number" or type(data) == "boolean" then
            tmp[#tmp + 1] = tostring(data)
        elseif data == nil then
            tmp[#tmp + 1] = "null"
        else
            error("Cannot encode " .. type(data) .. " to JSON")
        end
        
        return table.concat(tmp)
    end
end

-- Decode a JSON string into a Lua table
function json.decode(str)
    local success, result = pcall(function()
        return require("json").decode(str)
    end)
    
    if success then
        return result
    else
        -- Simple fallback JSON decoder
        -- Convert JSON to Lua code and execute it
        str = str:gsub("null", "nil")
                :gsub("%[", "{")
                :gsub("%]", "}")
                :gsub('("[^"]-"):','[%1]=')
                :gsub("(%d+):", "[%1]=")
                
        -- Add return statement
        str = "return " .. str
        
        -- Load the string as Lua code
        local func, err = load(str, "json", "t", {})
        if not func then
            error("Failed to parse JSON: " .. tostring(err))
            return nil
        end
        
        -- Execute the function to get the data
        local success, data = pcall(func)
        if not success then
            error("Failed to execute JSON parser: " .. tostring(data))
            return nil
        end
        
        return data
    end
end

return json 