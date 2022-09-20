local TWITCHEMOTESVKEKL_TimeSinceLastUpdate = 0
local TWITCHEMOTESVKEKL_T = 0;

function TwitchEmotesvKEKLAnimator_OnUpdate(self, elapsed)

    if (TWITCHEMOTESVKEKL_TimeSinceLastUpdate >= 0.033) then
        -- Update animated emotes in chat windows
        for i = 1, NUM_CHAT_WINDOWS do
            for _, visibleLine in ipairs(_G["ChatFrame" .. i].visibleLines) do
                if(_G["ChatFrame" .. i]:IsShown() and visibleLine.messageInfo ~= TwitchEmotesvKEKL_HoverMessageInfo) then 
                    TwitchEmotesvKEKLAnimator_UpdateEmoteInFontString(visibleLine, 28, 28);
                end
            end
        end

        -- Update animated emotes in suggestion list
        if (EditBoxAutoCompleteBox and EditBoxAutoCompleteBox:IsShown() and
            EditBoxAutoCompleteBox.existingButtonCount ~= nil) then
            for i = 1, EditBoxAutoCompleteBox.existingButtonCount do
                local cBtn = EditBoxAutoComplete_GetAutoCompleteButton(i);
                if (cBtn:IsVisible()) then
                    TwitchEmotesvKEKLAnimator_UpdateEmoteInFontString(cBtn, 16, 16);
                else
                    break
                end
            end
        end

        -- Update animated emotes in statistics screen
        if(TwitchStatsScreen:IsVisible()) then
           
            local topSentImagePath = TwitchEmotesvKEKL_defaultpack[TwitchEmotesvKEKLSentStatKeys[1]] or "Interface\\AddOns\\TwitchEmotesvKEKL\\Emotes\\1337.tga";
            local animdata = TwitchEmotesvKEKL_animation_metadata[topSentImagePath:match("(Interface\\AddOns\\TwitchEmotesvKEKL\\Emotes.-.tga)")]
            
            if(animdata ~= nil) then
                local cFrame = TwitchEmotesvKEKL_GetCurrentFrameNum(animdata)
                TwitchStatsScreen.topSentEmoteTexture:SetTexCoord(TwitchEmotesvKEKL_GetTexCoordsForFrame(animdata, cFrame)) 
            end
                

            local topSeenImagePath = TwitchEmotesvKEKL_defaultpack[TwitchEmoteRecievedStatKeys[1]] or "Interface\\AddOns\\TwitchEmotesvKEKL\\Emotes\\1337.tga";
            local animdata = TwitchEmotesvKEKL_animation_metadata[topSeenImagePath:match("(Interface\\AddOns\\TwitchEmotesvKEKL\\Emotes.-.tga)")]
            if(animdata ~= nil) then
                local cFrame = TwitchEmotesvKEKL_GetCurrentFrameNum(animdata)
                TwitchStatsScreen.topSeenEmoteTexture:SetTexCoord(TwitchEmotesvKEKL_GetTexCoordsForFrame(animdata, cFrame)) 
            end
            

            for line=1, 17 do
                local sentEntry = getglobal("TwitchStatsSentEntry"..line)
                local recievedEntry = getglobal("TwitchStatsRecievedEntry"..line)

                if(sentEntry:IsVisible()) then
                    TwitchEmotesvKEKLAnimator_UpdateEmoteInFontString(sentEntry, 16, 16);
                end

                if(recievedEntry:IsVisible()) then
                    TwitchEmotesvKEKLAnimator_UpdateEmoteInFontString(recievedEntry, 16, 16);
                end
            end
        end
        

        TWITCHEMOTESVKEKL_TimeSinceLastUpdate = 0;
    end

    TWITCHEMOTESVKEKL_T = TWITCHEMOTESVKEKL_T + elapsed
    TWITCHEMOTESVKEKL_TimeSinceLastUpdate = TWITCHEMOTESVKEKL_TimeSinceLastUpdate +
                                        elapsed;
end

local function escpattern(x)
    return (
            --x:gsub('%%', '%%%%')
             --:gsub('^%^', '%%^')
             --:gsub('%$$', '%%$')
             --:gsub('%(', '%%(')
             --:gsub('%)', '%%)')
             --:gsub('%.', '%%.')
             --:gsub('%[', '%%[')
             --:gsub('%]', '%%]')
             --:gsub('%*', '%%*')
             x:gsub('%+', '%%+')
             :gsub('%-', '%%-')
             --:gsub('%?', '%%?'))
            )
end

-- This will update the texture escapesequence of an animated emote
-- if it exsists in the contents of the fontstring
function TwitchEmotesvKEKLAnimator_UpdateEmoteInFontString(fontstring, widthOverride, heightOverride)
    local txt = fontstring:GetText();
    if (txt ~= nil) then
        for emoteTextureString in txt:gmatch("(|TInterface\\AddOns\\TwitchEmotesvKEKL\\Emotes.-|t)") do
            local imagepath = emoteTextureString:match("|T(Interface\\AddOns\\TwitchEmotesvKEKL\\Emotes.-.tga).-|t")

            local animdata = TwitchEmotesvKEKL_animation_metadata[imagepath];
            if (animdata ~= nil) then
                local framenum = TwitchEmotesvKEKL_GetCurrentFrameNum(animdata);
                local nTxt;
                if(widthOverride ~= nil or heightOverride ~= nil) then
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                        TwitchEmotesvKEKL_BuildEmoteFrameStringWithDimensions(
                                        imagepath, animdata, framenum, widthOverride, heightOverride))
                else
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                      TwitchEmotesvKEKL_BuildEmoteFrameString(
                                        imagepath, animdata, framenum))
                end

                -- If we're updating a chat message we need to alter the messageInfo as wel
                if (fontstring.messageInfo ~= nil) then
                    fontstring.messageInfo.message = nTxt
                end
                fontstring:SetText(nTxt);
                txt = nTxt;
            end
        end
    end
end



function TwitchEmotesvKEKL_GetAnimData(imagepath)
    return TwitchEmotesvKEKL_animation_metadata[imagepath]
end

function TwitchEmotesvKEKL_GetCurrentFrameNum(animdata)
    return math.floor((TWITCHEMOTESVKEKL_T * animdata.framerate) % animdata.nFrames);
end

function TwitchEmotesvKEKL_GetTexCoordsForFrame(animdata, framenum)
    local fHeight = animdata.frameHeight;
    return 0, 1 ,framenum * fHeight / animdata.imageHeight, ((framenum * fHeight) + fHeight) / animdata.imageHeight
end

function TwitchEmotesvKEKL_BuildEmoteFrameString(imagepath, animdata, framenum)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. animdata.frameWidth .. ":" ..
                        animdata.frameHeight .. ":0:0:" .. animdata.imageWidth ..
                        ":" .. animdata.imageHeight .. ":0:" ..
                        animdata.frameWidth .. ":" .. top .. ":" .. bottom ..
                        "|t";
    return emoteStr
end

function TwitchEmotesvKEKL_BuildEmoteFrameStringWithDimensions(imagepath, animdata,
                                                        framenum, framewidth,
                                                        frameheight)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. framewidth .. ":" ..
                        frameheight .. ":0:0:" .. animdata.imageWidth .. ":" ..
                        animdata.imageHeight .. ":0:" .. animdata.frameWidth ..
                        ":" .. top .. ":" .. bottom .. "|t";
    return emoteStr
end