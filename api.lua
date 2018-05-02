libSaveLogs.doSave = function()
	if libSaveLogs.txtIncrease~="" then
		local fileName = "log_"..os.date("%Y-%m-%d")..".txt"
		local logFile = minetest.get_worldpath().."/"..fileName
		if type(libSaveLogs.savePath)=="string" and libSaveLogs.savePath~="" then logFile = libSaveLogs.savePath.."/"..fileName end
		local file = io.open(logFile,"a+") --Registra no final do arquivo!!!
		if file then
			file:write(libSaveLogs.txtIncrease)
			file:flush() --<= Nao sei se esta linha esta ajudando!!!
			file:close()
			libSaveLogs.txtIncrease = ""
		else
			minetest.log('error',"[LIB_SAVELOGS] Nao foi possivel abrir o arquivo '"..logFile.."'!")
		end
	end
end

libSaveLogs.getPosResumed = function(pos)
	if pos and pos.x and pos.y and pos.z then
		local newPos = pos
		newPos.x = math.floor(newPos.x)
		newPos.y = math.floor(newPos.y)
		newPos.z = math.floor(newPos.z)
		return newPos
	end
	return pos	
end

libSaveLogs.addLog = function(message, noTime)
	if type(message)=="string" and message~="" then
		if type(libSaveLogs.txtIncrease)~="string" then 
			libSaveLogs.txtIncrease=""	
		end
		
		if type(noTime)=="boolean" and noTime==true then
			libSaveLogs.txtIncrease = libSaveLogs.txtIncrease .. "\n"..message
		else
			libSaveLogs.txtIncrease = libSaveLogs.txtIncrease .. "\n"..os.date("%Hh:%Mm:%Ss").." "..message
		end
	end
end

--[[
libSaveLogs.onSendWhisper = function(playername, param)
	if param~=nil and type(param)=="string" and param~="" then
		local fromPlayer = minetest.get_player_by_name(playername)
		if not fromPlayer then
			return true, "[WHISPER:ERROR] Erro desconhecido!!!"
		end
		local fromPos = libSaveLogs.getPosResumed(fromPlayer:getpos())
		
		local toName, message = string.match(param, "([%a%d_]+) (.+)")
	
		if not toName or not message then
			--minetest.chat_send_player(playername,"/mail <jogador> <mensagem>")
			return true, "/whisper <jogador> <mensagem> : Manda um sussurro (mensagem privada) para um jogador específico!"
		end

		local toPlayer = minetest.get_player_by_name(toName)
		if not toPlayer then
			return true, "[WHISPER:ERROR] O jogador '"..toName.."' não está online para receber o seu sussurro!"
		end
		local toPos = libSaveLogs.getPosResumed(toPlayer:getpos())
		
		
		if type(libSaveLogs.savePosOfSpeaker)=="boolean" and libSaveLogs.savePosOfSpeaker==true  then
			libSaveLogs.addLog(
				"<whisper:"
					..playername..minetest.pos_to_string(fromPos)
					.."→"
					..toName..minetest.pos_to_string(toPos)
				.."> "..message)
		else
			libSaveLogs.addLog("<whisper:"..playername.."→"..toName.."> "..message)
		end
		minetest.chat_send_player(toName,"Sussuro de '"..playername.."': "..message)
		--return true, "Sussuro de '"..playername.."': "..message
		return true
	end
	return true, "/whisper <jogador> <mensagem> : Manda um sussurro (mensagem privada) para um jogador específico!"
end
--]]

--[[
minetest.register_on_chat_message(function(playername, message)
	if type(message)=="string" and message~="" then
		local player = minetest.get_player_by_name(playername)
		if 
			type(libSaveLogs.savePosOfSpeaker)=="boolean" and libSaveLogs.savePosOfSpeaker==true 
			and player and player:is_player() --Verifica se o player ainda esta online!
		then
			local pos = player:getpos()
			libSaveLogs.addLog("<"..playername.."> "..message.." "..minetest.pos_to_string(libSaveLogs.getPosResumed(pos)))
		else
			libSaveLogs.addLog("<"..playername.."> "..message)
		end
	end
end)
--]]

minetest.register_globalstep(function(dtime)
	if type(libSaveLogs.timeLeft)~="number" then	libSaveLogs.timeLeft=0 end
	if libSaveLogs.timeLeft <= 0 then
		libSaveLogs.timeLeft = libSaveLogs.timeLeft + libSaveLogs.saveInterval
		libSaveLogs.doSave()
	else
		libSaveLogs.timeLeft = libSaveLogs.timeLeft - dtime
	end
end)

minetest.register_on_joinplayer(function(player)
	if type(libSaveLogs.savePosOfSpeaker)=="boolean" and libSaveLogs.savePosOfSpeaker==true  then
		libSaveLogs.addLog("<server:login> "..player:get_player_name().." entrou no servidor! "..minetest.pos_to_string(libSaveLogs.getPosResumed(player:getpos())))
	else
		libSaveLogs.addLog("<server:login> "..player:get_player_name().." entrou no servidor!")
	end
	libSaveLogs.doSave()
end)

minetest.register_on_leaveplayer(function(player)
	if type(libSaveLogs.savePosOfSpeaker)=="boolean" and libSaveLogs.savePosOfSpeaker==true  then
		libSaveLogs.addLog("<server:logout> "..player:get_player_name().." saiu do servidor! "..minetest.pos_to_string(libSaveLogs.getPosResumed(player:getpos())))
	else
		libSaveLogs.addLog("<server:logout> "..player:get_player_name().." saiu do servidor!")
	end
	libSaveLogs.doSave()
end)

minetest.register_on_shutdown(function()
	libSaveLogs.addLog("<server:shutdown> O servidor desligou!")
	libSaveLogs.doSave()
end)

libSaveLogs.addLog("--------------------------------------------------------------------------------------------------------------", true)
libSaveLogs.addLog("<server:activate> O servidor recem ativado!")
